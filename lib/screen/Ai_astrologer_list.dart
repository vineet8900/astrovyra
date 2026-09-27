import 'package:astrokavach/api/consultation/chat_api/recharge_paynow_api.dart';
import 'package:astrokavach/api/consultation/chat_api/recharge_wallet_api.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/api/payment/payment_verify_api.dart';
import 'package:astrokavach/custom_widgets/app_date_time_picker_theme.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/payment_confirming_overlay.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/AIastrologermodel/aiastrologer.dart';
import 'package:astrokavach/model/aichatmodel/aichatmodel.dart';
import 'package:astrokavach/model/astrologer/chat_model/recharge_wallet_model.dart';
import 'package:astrokavach/model/astrologer/chat_model/rechargepaynow_model.dart'
    hide Theme;
import 'package:astrokavach/model/kundalimodel/locationkundali.dart';
import 'package:astrokavach/model/services/services.dart';
import 'package:astrokavach/screen/AiAstrologer.dart';
import 'package:astrokavach/screen/aichatscreen.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/walletupdate.dart';
import 'package:astrokavach/screen/astrologer/consultation/blinkingscreen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiAstrologerListScreen extends StatefulWidget {
  const AiAstrologerListScreen({Key? key}) : super(key: key);

  @override
  State<AiAstrologerListScreen> createState() => _AiAstrologerListScreenState();
}

class _AiAstrologerListScreenState extends State<AiAstrologerListScreen> {
  // Original Astrologer List
  List<AiAstrologer> mainAiAstrologerList = [];
  // List that will be displayed and filtered
  List<AiAstrologer> filteredAiAstrologerList = [];

  // Service filter state variables
  List<AstrologerService> astrologerServices = [];
  bool areServicesLoading = true;

  // List to hold the 'value' of all selected services (for multi-select)
  List<int> selectedServiceValues = [];

  bool isLoading = true;
  final RechargeWalletApiService rechargeWalletApiService =
      RechargeWalletApiService();
  final RechargePaynowApiService rechargePaynowApiService =
      RechargePaynowApiService();
  final PaymentVerifyApi paymentVerifyApi = PaymentVerifyApi();
  late Razorpay razorpay;

  double _walletBalance = 0.0;
  String? apiToken;
  List<RechargeWalletList> _rechargePlans = [];
  bool _arePlansLoading = true;
  String? callbackurl;
  int? selectedRechargeId;

  // Form related variables (no changes here)
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthTimeController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  LocationData? _selectedLocation;
  List<LocationData> _locationSuggestions = [];
  bool _isLoadingLocations = false;
  bool _showLocationDropdown = false;
  bool _isBottomSheetLoading = false;
  final ReusableFunction reusableFunction = ReusableFunction();
  int _selectedGender = 0;
  String? selectedMaritalStatus;
  String? selectedOccupation;
  final Map<String, String> maritalStatusMap = {
    'Single': 'single',
    'Married': 'married',
    'Divorsed': 'divorsed',
    'Widow': 'widow',
    'Not Specified': ''
  };
  final Map<String, String> occupationMap = {
    'Employed': 'employed',
    'Business Person': 'business_person',
    'Housewife': 'house_wife',
    'Retired': 'retaired',
    'Student': 'student',
    'Not Specified': ''
  };

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _resetServiceFilters() {
    setState(() {
      selectedServiceValues.clear();
      filteredAiAstrologerList = List.from(mainAiAstrologerList);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
    razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    if (!isLoading) setState(() => isLoading = true);
    await _loadApiToken();
    await _fetchRechargePlans();

    final results = await Future.wait([
      AstroApiService.fetchAiAstrologers(),
      AstroApiService.fetchAstrologerServices(),
      reusableFunction.getUserDataFromPrefs(),
    ]);

    if (mounted) {
      setState(() {
        mainAiAstrologerList = results[0] as List<AiAstrologer>? ?? [];
        filteredAiAstrologerList = List.from(mainAiAstrologerList);
        astrologerServices = results[1] as List<AstrologerService>? ?? [];
        areServicesLoading = false;

        var userData = results[2] as Map<String, dynamic>?;
        if (userData != null) {
          _nameController.text = userData['name'] ?? '';
          _mobileController.text = userData['phone'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _selectedGender = userData['gender_id'] ?? 0;
          _walletBalance =
              double.tryParse(userData['wallet']?.toString() ?? '0.0') ?? 0.0;
        }
        isLoading = false;
      });
    }
  }

  Future<void> _loadApiToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => apiToken = prefs.getString('api_token'));
  }

  Future<void> _fetchRechargePlans() async {
    setState(() => _arePlansLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    if (token == null) {
      setState(() => _arePlansLoading = false);
      return;
    }
    try {
      var result =
          await rechargeWalletApiService.fetchrechargeapidata(token.toString());
      if (mounted && result != null && result.data != null) {
        setState(() {
          _rechargePlans = result.data!;
        });
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _arePlansLoading = false);
      }
    }
  }

  void _updateAndApplyFilters(int? serviceValue) {
    if (serviceValue == null) {
      _resetServiceFilters();
      return;
    }

    setState(() {
      if (selectedServiceValues.contains(serviceValue)) {
        selectedServiceValues.remove(serviceValue);
      } else {
        selectedServiceValues.add(serviceValue);
      }

      if (selectedServiceValues.isEmpty) {
        filteredAiAstrologerList = List.from(mainAiAstrologerList);
        return;
      }

      filteredAiAstrologerList = mainAiAstrologerList.where((astrologer) {
        final Set<int> astrologerServiceValues =
            astrologer.services.map((slug) {
          try {
            return astrologerServices
                .firstWhere((s) => s.slug.toLowerCase() == slug.toLowerCase())
                .value;
          } catch (e) {
            return -1;
          }
        }).toSet();
        return selectedServiceValues.every(
            (selectedValue) => astrologerServiceValues.contains(selectedValue));
      }).toList();
    });
  }

  Future<void> _searchLocation(String query, StateSetter setState) async {
    if (query.length < 2) {
      setState(() {
        _locationSuggestions = [];
        _showLocationDropdown = false;
      });
      return;
    }
    setState(() {
      _isLoadingLocations = true;
      _showLocationDropdown = true;
    });
    try {
      final locationResponse = await AstroApiService.searchLocations(query);
      if (locationResponse != null && locationResponse.success) {
        setState(() => _locationSuggestions = locationResponse.data);
      } else {
        setState(() => _locationSuggestions = []);
      }
    } catch (e) {
      setState(() => _locationSuggestions = []);
    }
    setState(() => _isLoadingLocations = false);
  }

  void _showWalletRechargeSuccessOnPage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Wallet recharged successfully.'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final dynamic result = await PaymentConfirmingOverlay.run(context, () async {
      return paymentVerifyApi.fetchpaymentapidata(
          context, token, response, callbackurl.toString());
    });

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      var newWalletAmount = result['wallet']['amount'];

      final currentUserData = await reusableFunction.getUserDataFromPrefs();
      if (currentUserData != null) {
        currentUserData['wallet'] = newWalletAmount;
        await reusableFunction.saveUserDataToPrefs(currentUserData);
        WalletEventBus().updateWallet(currentUserData);
      }

      setState(() {
        _walletBalance =
            double.tryParse(newWalletAmount?.toString() ?? '0.0') ?? 0.0;
      });

      if (mounted) {
        _showWalletRechargeSuccessOnPage();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment verification failed")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Failed: ${response.message}",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  Future<void> _initiateRazorpayPayment(int planId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token == null || token.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please login to continue",
        backgroundColor: Colors.red,
      );
      return;
    }

    Map<String, dynamic>? userData =
        await reusableFunction.getUserDataFromPrefs();
    if (userData == null) {
      Fluttertoast.showToast(msg: "User data not found. Please login again.");
      return;
    }

    RechargePayNowModel? rechargePayNowModel = await rechargePaynowApiService
        .fetchrechargepaynowapidata(token, planId, "");

    if (rechargePayNowModel?.data == null) {
      Fluttertoast.showToast(
        msg: "Payment data could not be fetched",
        backgroundColor: Colors.red,
      );
      return;
    }

    final data = rechargePayNowModel!.data!;
    callbackurl = data.callbackUrl;

    if (data.amount != null && data.amount! > 0) {
      var options = {
        'key': data.key ?? '',
        'amount': data.amount,
        'name': data.name ?? '',
        'order_id': data.orderId ?? '',
        'description': data.description ?? '',
        'prefill': {
          'contact': data.prefill?.contact ?? '',
          'email': data.prefill?.email ?? '',
        },
        'theme': {'color': '#F37254'},
      };

      razorpay.open(options);
    } else {
      if (mounted) {
        _showWalletRechargeSuccessOnPage();
      }
    }
  }

  void _showRechargeBottomSheet(BuildContext context, AiAstrologer astrologer,
      double requiredBalance, int minutes) {
    int? selectedPlanIndex;
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            color: Colors.grey.shade600, size: 22),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7CFC00), Color(0xFF32CD32)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.celebration,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            "Get 100% Cashback on your First recharge",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFD6D6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: Colors.black87,
                              height: 1.3),
                          children: [
                            TextSpan(
                              text: "(₹ ${requiredBalance.toStringAsFixed(0)})",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F)),
                            ),
                            const TextSpan(
                                text: " is required to start chat with "),
                            TextSpan(
                              text: astrologer.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Recharge Now",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 12, color: Colors.orange.shade700),
                        const SizedBox(width: 3),
                        Text(
                          "Tip: 90% users recharge for 10 mins or more.",
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _arePlansLoading
                        ? const CircularProgressIndicator()
                        : _rechargePlans.isEmpty
                            ? const Text("No recharge plans available.")
                            : Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                alignment: WrapAlignment.center,
                                children:
                                    _rechargePlans.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  RechargeWalletList plan = entry.value;
                                  bool isSelected = selectedPlanIndex == index;
                                  bool hasExtra =
                                      plan.extra != null && plan.extra! > 0;

                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        selectedPlanIndex = index;
                                        selectedRechargeId = plan.id;
                                      });
                                    },
                                    child: Container(
                                      width: 70,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? CustomStyles.pinki
                                              : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Stack(
                                        children: [
                                          if (hasExtra)
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              child: ClipPath(
                                                clipper: RibbonClipper(),
                                                child: Container(
                                                  width: 40,
                                                  height: 18,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        CustomStyles.pinki,
                                                        CustomStyles.ctaColor
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 3, top: 2),
                                                    child: Text(
                                                      "${plan.extra}%",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 8,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (hasExtra)
                                                  SizedBox(height: 6),
                                                Text(
                                                  "₹ ${plan.amount}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                    const SizedBox(height: 16),
                    isProcessing
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomStyles.pinki,
                              minimumSize: const Size(double.infinity, 46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: selectedPlanIndex == null
                                ? null
                                : () async {
                                    if (selectedRechargeId == null) {
                                      Fluttertoast.showToast(
                                        msg: "Please select a recharge plan",
                                        backgroundColor: Colors.red,
                                      );
                                      return;
                                    }

                                    setModalState(() => isProcessing = true);

                                    try {
                                      await _initiateRazorpayPayment(
                                          selectedRechargeId!);
                                      Navigator.pop(context);
                                    } catch (e) {
                                      Fluttertoast.showToast(
                                        msg: "Payment initiation failed",
                                        backgroundColor: Colors.red,
                                      );
                                    } finally {
                                      if (mounted) {
                                        setModalState(
                                            () => isProcessing = false);
                                      }
                                    }
                                  },
                            child: const Text(
                              "Proceed to Pay",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAiConsultationForm(BuildContext context, AiAstrologer astrologer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final bool isTablet = MediaQuery.of(context).size.width > 600;

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              builder: (_, scrollController) => Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: isTablet ? 40 : 20,
                  right: isTablet ? 40 : 20,
                  top: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Start AI Consultation',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: 30),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: isTablet
                                  ? MediaQuery.of(context).size.width * 0.4
                                  : double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600])),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration:
                                        _inputDecoration("Enter your name"),
                                    validator: (v) =>
                                        v!.isEmpty ? 'Name is required' : null,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: isTablet
                                  ? MediaQuery.of(context).size.width * 0.4
                                  : double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gender',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600])),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<int>(
                                    value: _selectedGender == 0
                                        ? null
                                        : _selectedGender,
                                    dropdownColor: Colors.white,
                                    decoration: _inputDecoration("Select"),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 1, child: Text('Male')),
                                      DropdownMenuItem(
                                          value: 2, child: Text('Female')),
                                      DropdownMenuItem(
                                          value: 3, child: Text('Other')),
                                    ],
                                    onChanged: (v) => setModalState(
                                        () => _selectedGender = v ?? 0),
                                    validator: (v) => v == null
                                        ? 'Please select gender'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // DOB + TOB (Fully Responsive Wrap)
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            // DATE OF BIRTH FIELD
                            SizedBox(
                              width: isTablet
                                  ? MediaQuery.of(context).size.width * 0.4
                                  : double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date of Birth',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600])),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _birthDateController,
                                    readOnly: true,
                                    decoration:
                                        _inputDecoration("DD/MM/YYYY").copyWith(
                                      suffixIcon: Icon(Icons.calendar_today,
                                          size: 20, color: Colors.grey),
                                    ),
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1920),
                                        lastDate: DateTime.now(),
                                        builder: (context, child) =>
                                            AppDateTimePickerTheme.wrap(
                                                context, child),
                                      );
                                      if (pickedDate != null) {
                                        String formattedDate =
                                            DateFormat('dd/MM/yyyy')
                                                .format(pickedDate);
                                        setModalState(() {
                                          _birthDateController.text =
                                              formattedDate;
                                        });
                                      }
                                    },
                                    validator: (v) =>
                                        v!.isEmpty ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),

                            // TIME OF BIRTH
                            SizedBox(
                              width: isTablet
                                  ? MediaQuery.of(context).size.width * 0.4
                                  : double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Time of Birth',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600])),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _birthTimeController,
                                    readOnly: true,
                                    decoration:
                                        _inputDecoration("HH:MM:SS").copyWith(
                                      suffixIcon: Icon(Icons.access_time,
                                          size: 20, color: Colors.grey),
                                    ),
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (context, child) =>
                                            AppDateTimePickerTheme.wrap(
                                                context, child),
                                      );

                                      if (pickedTime != null) {
                                        String formattedTime =
                                            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00";
                                        setModalState(() => _birthTimeController
                                            .text = formattedTime);
                                      }
                                    },
                                    validator: (v) =>
                                        v!.isEmpty ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // PLACE OF BIRTH
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Place of Birth',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _birthPlaceController,
                              decoration:
                                  _inputDecoration("Type to search location",
                                      suffixIcon: Icons.location_on)
                                      .copyWith(
                                suffixIcon: Icon(Icons.location_on,
                                    size: 20, color: Colors.grey),
                              ),
                              onChanged: (v) =>
                                  _searchLocation(v, setModalState),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Please enter birth place';
                                if (_selectedLocation == null)
                                  return 'Please select a valid place from the list';
                                return null;
                              },
                            ),
                            _buildLocationDropdown(setModalState),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // MARITAL STATUS
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Marital Status',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedMaritalStatus,
                              decoration: _inputDecoration("Select"),
                              dropdownColor: Colors.white,
                              items: maritalStatusMap.keys
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) => setModalState(
                                  () => selectedMaritalStatus = v),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // OCCUPATION
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Occupation',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedOccupation,
                              decoration: _inputDecoration("Select"),
                              dropdownColor: Colors.white,
                              items: occupationMap.keys
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) =>
                                  setModalState(() => selectedOccupation = v),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // SUBMIT BUTTON
                        _isBottomSheetLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomStyles.pinki,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setModalState(
                                          () => _isBottomSheetLoading = true);

                                      final BookAiConsultationResponse?
                                          consultation = await AstroApiService
                                              .bookAiConsultation(
                                        astrologerId: astrologer.id,
                                        name: _nameController.text,
                                        email: _emailController.text.isEmpty
                                            ? "user@example.com"
                                            : _emailController.text,
                                        birthPlace: _birthPlaceController.text,
                                        mobile: _mobileController.text.isEmpty
                                            ? "1234567890"
                                            : _mobileController.text,
                                        birthDate: _birthDateController.text,
                                        birthTime: _birthTimeController.text,
                                        gender: _selectedGender,
                                        occupation:
                                            occupationMap[selectedOccupation] ??
                                                "",
                                        maritalstatus: maritalStatusMap[
                                                selectedMaritalStatus] ??
                                            "",
                                      );

                                      if (mounted) {
                                        setModalState(() =>
                                            _isBottomSheetLoading = false);
                                      }

                                      if (consultation != null &&
                                          consultation.success) {
                                        Navigator.pop(context);

                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                KundliAIChatScreen(
                                              consultationId:
                                                  consultation.consultationId,
                                              astrologerName: astrologer.name,
                                            ),
                                          ),
                                        );

                                        _fetchInitialData();
                                      }
                                    }
                                  },
                                  child: const Text(
                                    "Proceed to chat",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: "AI Astrologer Lists",
        automaticallyImplyLeading: false,
        backgroundColor: CustomStyles.whiteColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),

        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BottomAppBarScreen())),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        //title: Text("AI Astrologer list"),
      ),
      body: Column(
        children: [
          _buildServiceFilterBar(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceFilterBar() {
    if (areServicesLoading) {
      return Container(
        height: 60,
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (astrologerServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 10),
          scrollDirection: Axis.horizontal,
          itemCount: astrologerServices.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              bool isSelected = selectedServiceValues.isEmpty;
              return GestureDetector(
                onTap: () => _updateAndApplyFilters(null),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: isSelected ? Colors.grey.shade400 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              isSelected ? Colors.transparent : Colors.grey)),
                  child: Center(
                    child: Text(
                      "All",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }

            final service = astrologerServices[index - 1];
            final bool isSelected =
                selectedServiceValues.contains(service.value);

            return GestureDetector(
              onTap: () => _updateAndApplyFilters(service.value),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.shade300 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.grey),
                ),
                child: Row(
                  children: [
                    Image.network(
                      service.icon,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      service.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
          child: CircularProgressIndicator(color: CustomStyles.bgcolor));
    }

    if (filteredAiAstrologerList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_search_outlined,
                size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              selectedServiceValues.isEmpty
                  ? "No AI Astrologers Found"
                  : "No astrologers match all selected services",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            if (selectedServiceValues.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ElevatedButton.icon(
                  onPressed: _resetServiceFilters,
                  icon: const Icon(Icons.clear_all, size: 20),
                  label: const Text("Clear All Filters"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    foregroundColor: Colors.orange.shade800,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 2.2,
            ),
            itemCount: filteredAiAstrologerList.length,
            itemBuilder: (context, index) {
              final astrologer = filteredAiAstrologerList[index];
              return _buildAiAstrologerCard(astrologer);
            },
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: filteredAiAstrologerList.length,
            itemBuilder: (context, index) {
              final astrologer = filteredAiAstrologerList[index];
              return _buildAiAstrologerCard(astrologer);
            },
          );
        }
      },
    );
  }

  Widget _buildAiAstrologerCard(AiAstrologer astrologer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Aiastrologer(
              astrologer: astrologer,
              allAstrologers: mainAiAstrologerList,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 8), // Consistent margin
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            // Main layout is now a Column
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Profile Image and Rating ---
                  Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(astrologer.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -3,
                            right: -3,
                            child:
                                AstrologerStatusDot(status: astrologer.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              astrologer.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // --- Astrologer Details ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 60.0),
                          child: Text(
                            astrologer.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8), // Spacing adjusted
                        _buildAlignedDetailRow(
                            "assets/award.png", astrologer.services.join(', ')),
                        const SizedBox(height: 10), // Spacing adjusted
                        _buildAlignedDetailRow("assets/hindieng.png",
                            astrologer.languages.join(', ')),
                        const SizedBox(height: 10), // Spacing adjusted
                        _buildPriceInfo(
                            astrologer), // Price is now part of the details column
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Space before the button row
              // --- ACTION BUTTON ROW ---
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Aligns button to the right
                children: [
                  _buildStyledChatButton(astrologer),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// --- Helper widget for equal spacing ---
  Widget _buildAlignedDetailRow(String imagePath, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          width: 18,
          height: 18,
          fit: BoxFit.contain,
          color: Colors.black,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              height: 1.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInfo(AiAstrologer astrologer) {
    bool hasSpecialPrice = astrologer.chatSpecialPrice > 0 &&
        astrologer.chatSpecialPrice < astrologer.chatPrice;
    String originalPrice = astrologer.chatPrice.toString();
    String specialPrice =
        (hasSpecialPrice ? astrologer.chatSpecialPrice : astrologer.chatPrice)
            .toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic, // Ensures proper alignment
      children: [
        Image.asset("assets/currency-rupee.png",
            color: Colors.black, height: 16),
        const SizedBox(width: 4),
        Text(
          "₹$specialPrice/Min",
          style: const TextStyle(
              fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600),
        ),
        if (hasSpecialPrice)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "₹$originalPrice",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStyledChatButton(AiAstrologer astrologer) {
    final bool hasActiveChat = (astrologer.consultation?.id ?? 0) != 0;
    final String buttonText = hasActiveChat ? "Join" : "Chat";

    return ElevatedButton.icon(
      onPressed: () async {
        if (hasActiveChat) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KundliAIChatScreen(
                consultationId: astrologer.consultation!.id,
                astrologerName: astrologer.name,
              ),
            ),
          );
          _fetchInitialData();
          return;
        }
        bool isTokenNumeric(String? token) {
          if (token == null || token.isEmpty) return false;
          return int.tryParse(token) != null;
        }

        final bool isUserGuest =
            (apiToken == null || apiToken!.isEmpty || isTokenNumeric(apiToken));

        if (isUserGuest) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginScreen(
                      redirectScreen: const AiAstrologerListScreen())));
          return;
        }

        const int minChatDurationInMinutes = 5;
        final double pricePerMinute = (astrologer.chatSpecialPrice > 0
                ? astrologer.chatSpecialPrice
                : astrologer.chatPrice)
            .toDouble();
        final double requiredBalance =
            minChatDurationInMinutes * pricePerMinute;

        if (_walletBalance < requiredBalance) {
          _showRechargeBottomSheet(
              context, astrologer, requiredBalance, minChatDurationInMinutes);
        } else {
          _showAiConsultationForm(context, astrologer);
        }
      },
      icon: Image.asset(
        "assets/chat-dots-fill.png",
        width: 18,
        height: 18,
        color: Colors.white,
      ),
      label: Text(
        buttonText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomStyles.chatActionGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      ),
    );
  }

  Widget _buildLocationDropdown(StateSetter setState) {
    if (!_showLocationDropdown) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5)
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: _isLoadingLocations
          ? const Center(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator()))
          : _locationSuggestions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('No locations found')))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _locationSuggestions.length,
                  itemBuilder: (context, index) {
                    final LocationData location = _locationSuggestions[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.location_on,
                          color: Colors.blue[600], size: 18),
                      title: Text(
                        location.name,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        location.fullName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _birthPlaceController.text = location.fullName;
                          _selectedLocation = location;
                          _showLocationDropdown = false;
                          _locationSuggestions = [];
                        });
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: Colors.grey[600])
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}

class RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width - 10, size.height / 2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
