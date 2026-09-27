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
import 'package:astrokavach/model/astrologer/astro_detail_model.dart';
import 'package:astrokavach/model/astrologer/chat_model/recharge_wallet_model.dart';
import 'package:astrokavach/model/astrologer/chat_model/rechargepaynow_model.dart'
    hide Theme;
import 'package:astrokavach/model/kundalimodel/locationkundali.dart';
import 'package:astrokavach/model/reviewmodel/productmodelreview.dart';
import 'package:astrokavach/screen/Ai_astrologer_list.dart';
import 'package:astrokavach/screen/aichatscreen.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/hellocahat.dart';
import 'package:astrokavach/screen/wallet/wallet_screen.dart';
import 'package:astrokavach/screen/walletupdate.dart';
import 'package:astrokavach/screen/astrologer/consultation/blinkingscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:rating_summary/rating_summary.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Aiastrologer extends StatefulWidget {
  final AiAstrologer astrologer;
  final List<AiAstrologer> allAstrologers; // List of all AI astrologers

  const Aiastrologer({
    super.key,
    required this.astrologer,
    required this.allAstrologers, // Make it required
  });

  @override
  State<Aiastrologer> createState() => _AiastrologerState();
}

class _AiastrologerState extends State<Aiastrologer>
    with SingleTickerProviderStateMixin {
  AstroDetailDatum? astroDetailDatum;
  bool _isReviewsLoading = true;
  bool canReview = false;
  final TextEditingController _reviewController = TextEditingController();
  List<ProductReview> _astrologerReviews = [];
  bool _isTryingToSubmit = false;
  late AiAstrologer _currentAstrologer;
  double _currentRating = 0.0;
  final _reviewFormKey = GlobalKey<FormState>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthTimeController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();

  final ReusableFunction reusableFunction = ReusableFunction();
  int _selectedGender = 0;
  String? selectedMaritalStatus;
  String? selectedOccupation;
  final Map<String, String> maritalStatusMap = {
    'Single': 'single',
    'Married': 'married',
    'Divorced': 'divorced',
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

  LocationData? _selectedLocation;
  List<LocationData> _locationSuggestions = [];
  bool _isLoadingLocations = false;
  bool _showLocationDropdown = false;
  bool _isBottomSheetLoading = false;
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
  bool _bookAiAstrologerAfterRecharge = false;

  // late AiAstrologer _currentAstrologer;

  @override
  void initState() {
    super.initState();
    _loadApiToken();
    _fetchRechargePlans();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalChatService.hideFloatingChatButton();
    });

    _currentAstrologer = widget.astrologer;
    _checkCanUserReview();
    _fetchAstrologerReviews();
  }

  Future<void> _refreshAstrologerData() async {
    // Fetch the latest list of all AI astrologers from the API
    final freshAstrologerList = await AstroApiService.fetchAiAstrologers();
    if (mounted && freshAstrologerList != null) {
      try {
        // Find the updated data for the current astrologer from the fresh list
        final updatedAstrologer = freshAstrologerList
            .firstWhere((astro) => astro.id == _currentAstrologer.id);
        setState(() {
          // Update the local state with the new data
          _currentAstrologer = updatedAstrologer;
        });
      } catch (e) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        GlobalChatService.showFloatingChatButton(context);
      }
    });
    razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchAstrologerReviews() async {
    if (!mounted) return;
    setState(() => _isReviewsLoading = true);

    final reviews = await AstroApiService.fetchAstrologerReviews(
        astrologerId: _currentAstrologer.id);

    if (mounted && reviews != null) {
      setState(() {
        _astrologerReviews = reviews;
      });
    }
    setState(() => _isReviewsLoading = false);
  }

  Future<void> _checkCanUserReview() async {
    final response = await AstroApiService.canReview(
      page: 'astrologer',
      id: _currentAstrologer.id,
    );
    if (mounted && response != null) {
      setState(() {
        canReview = response.success && response.message.toLowerCase() == 'yes';
      });
    }
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

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    var userData = await reusableFunction.getUserDataFromPrefs();
    if (userData != null) {
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _mobileController.text = userData['phone'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _selectedGender = userData['gender_id'] ?? 0;
        _walletBalance =
            double.tryParse(userData['wallet']?.toString() ?? '0.0') ?? 0.0;
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

  void _showWalletRechargeNeedMoreBalanceSnack() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Wallet updated. Add a bit more balance to start this chat.',
        ),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _continueAiChatFlowAfterRecharge() async {
    await _refreshAstrologerData();
    if (!mounted) return;
    final hasActiveChat = (_currentAstrologer.consultation?.id ?? 0) != 0;
    if (hasActiveChat) {
      _showWalletRechargeSuccessOnPage();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KundliAIChatScreen(
            consultationId: _currentAstrologer.consultation!.id,
            astrologerName: _currentAstrologer.name,
          ),
        ),
      );
      if (mounted) _refreshAstrologerData();
      return;
    }
    const int minChatDurationInMinutes = 5;
    final double pricePerMinute =
        (_currentAstrologer.chatSpecialPrice > 0
                ? _currentAstrologer.chatSpecialPrice
                : _currentAstrologer.chatPrice)
            .toDouble();
    final double requiredBalance =
        minChatDurationInMinutes * pricePerMinute;
    if (_walletBalance >= requiredBalance) {
      _showWalletRechargeSuccessOnPage();
      _showAiConsultationForm(context, _currentAstrologer);
    } else {
      _showWalletRechargeNeedMoreBalanceSnack();
    }
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

      final bool continueBook = _bookAiAstrologerAfterRecharge;
      if (continueBook && mounted) {
        setState(() => _bookAiAstrologerAfterRecharge = false);
      }

      setState(() {
        _walletBalance =
            double.tryParse(newWalletAmount?.toString() ?? '0.0') ?? 0.0;
      });

      if (continueBook && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _continueAiChatFlowAfterRecharge();
        });
      } else if (mounted) {
        _showWalletRechargeSuccessOnPage();
      }
    } else {
      if (_bookAiAstrologerAfterRecharge && mounted) {
        setState(() => _bookAiAstrologerAfterRecharge = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment verification failed")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_bookAiAstrologerAfterRecharge && mounted) {
      setState(() => _bookAiAstrologerAfterRecharge = false);
    }
    Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  Future<void> _initiateRazorpayPayment(int planId,
      {bool bookAiAstrologerAfterRecharge = false}) async {
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

      if (bookAiAstrologerAfterRecharge && mounted) {
        setState(() => _bookAiAstrologerAfterRecharge = true);
      }
      razorpay.open(options);
    } else {
      if (bookAiAstrologerAfterRecharge && mounted) {
        await _fetchUserData();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _continueAiChatFlowAfterRecharge();
        });
      } else {
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
                                        selectedRechargeId!,
                                        bookAiAstrologerAfterRecharge: true,
                                      );
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
                                color: Colors.white,
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
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              builder: (_, scrollController) => Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    left: 20,
                    right: 20,
                    top: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // --- Name Field ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                decoration: _inputDecoration("Enter your name"),
                                validator: (v) =>
                                    v!.isEmpty ? 'Name is required' : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // --- Gender Field ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Gender',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: _selectedGender == 0
                                    ? null
                                    : _selectedGender,
                                decoration: _inputDecoration("Select"),
                                dropdownColor: Colors.white,
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
                                validator: (v) =>
                                    v == null ? 'Please select gender' : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

// --- Date of Birth (Full Width) ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Date of Birth',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _birthDateController,
                                readOnly: true,
                                decoration:
                                    _inputDecoration("DD/MM/YYYY").copyWith(
                                  suffixIcon: const Icon(Icons.calendar_today,
                                      color: Colors.grey, size: 20),
                                ),
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  DateTime? pickedDate = await showDatePicker(
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
                                    setModalState(() => _birthDateController
                                        .text = formattedDate);
                                  }
                                },
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

// --- Time of Birth (Full Width) ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Time of Birth',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _birthTimeController,
                                readOnly: true,
                                decoration:
                                    _inputDecoration("HH:MM:SS").copyWith(
                                  suffixIcon: const Icon(Icons.access_time,
                                      color: Colors.grey, size: 20),
                                ),
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  TimeOfDay? pickedTime = await showTimePicker(
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
                          const SizedBox(height: 20),

                          // --- Place of Birth ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Place of Birth',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _birthPlaceController,
                                decoration:
                                    _inputDecoration("Type to search location",
                                        suffixIcon: Icons.location_on)
                                        .copyWith(
                                  suffixIcon: const Icon(Icons.location_on,
                                      color: Colors.grey, size: 20),
                                ),
                                onChanged: (value) =>
                                    _searchLocation(value, setModalState),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter birth place';
                                  }
                                  if (_selectedLocation == null) {
                                    return 'Please select a valid place from the list';
                                  }
                                  return null;
                                },
                              ),
                              _buildLocationDropdown(setModalState),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // --- Marital Status ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Marital Status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
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

                          // --- Occupation ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Occupation',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
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

                          _isBottomSheetLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CustomStyles.ctaColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        setModalState(
                                            () => _isBottomSheetLoading = true);
                                        final consultation =
                                            await AstroApiService
                                                .bookAiConsultation(
                                          astrologerId: astrologer.id,
                                          name: _nameController.text,
                                          email: _emailController.text.isEmpty
                                              ? "user@example.com"
                                              : _emailController.text,
                                          birthPlace:
                                              _birthPlaceController.text,
                                          mobile: _mobileController.text.isEmpty
                                              ? "1234567890"
                                              : _mobileController.text,
                                          birthDate: _birthDateController.text,
                                          birthTime: _birthTimeController.text,
                                          gender: _selectedGender,
                                          occupation: occupationMap[
                                                  selectedOccupation] ??
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
                                          Navigator.push(
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
                                          _refreshAstrologerData();
                                        }
                                      }
                                    },
                                    child: const Text(
                                      "Proceed to chat",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  )),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomAppBarScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          backgroundColor: CustomStyles.whiteColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BottomAppBarScreen()),
              );
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: _currentAstrologer.name.trim().isNotEmpty
              ? _currentAstrologer.name.trim()
              : 'ai_astrologer_details'.tr,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
          actions: [
            GestureDetector(
                onTap: () {
                  Get.to(WalletScreen());
                },
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 25,
                  color: Colors.green,
                )),
            SizedBox(width: 10)
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: Colors.white, // Ensures a solid background
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Builder(
              builder: (context) {
                final bool hasActiveChat =
                    (_currentAstrologer.consultation?.id ?? 0) != 0;
                final String buttonText =
                    hasActiveChat ? 'join_chat'.tr : 'start_chat'.tr;
                final String buttonImage = hasActiveChat
                    ? 'assets/chat-dots-fill.png'
                    : 'assets/chat-dots-fill.png'; // ✅ Your same asset

                return ElevatedButton.icon(
                  onPressed: () async {
                    if (hasActiveChat) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KundliAIChatScreen(
                            consultationId: _currentAstrologer.consultation!.id,
                            astrologerName: _currentAstrologer.name,
                          ),
                        ),
                      );
                      _refreshAstrologerData();
                    } else {
                      bool isTokenNumeric(String? token) {
                        if (token == null || token.isEmpty) return false;
                        return int.tryParse(token) != null;
                      }

                      final bool isUserGuest = (apiToken == null ||
                          apiToken!.isEmpty ||
                          isTokenNumeric(apiToken));

                      if (isUserGuest) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen(
                                    redirectScreen: Aiastrologer(
                                        astrologer: widget.astrologer,
                                        allAstrologers:
                                            widget.allAstrologers))));
                        return;
                      }

                      const int minChatDurationInMinutes = 5;
                      final double pricePerMinute =
                          (_currentAstrologer.chatSpecialPrice > 0
                                  ? _currentAstrologer.chatSpecialPrice
                                  : _currentAstrologer.chatPrice)
                              .toDouble();
                      final double requiredBalance =
                          minChatDurationInMinutes * pricePerMinute;

                      if (_walletBalance < requiredBalance) {
                        _showRechargeBottomSheet(context, _currentAstrologer,
                            requiredBalance, minChatDurationInMinutes);
                      } else {
                        _showAiConsultationForm(context, _currentAstrologer);
                      }
                    }
                  },
                  icon: Image.asset(
                    buttonImage,
                    height: 22,
                    width: 22,
                    color: Colors.white,
                  ),
                  label: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomStyles.chatActionGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                    shadowColor: Colors.black26,
                  ),
                );
              },
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildAiAstrologerCard(_currentAstrologer),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'rating_reviews'
                          .trArgs([_astrologerReviews.length.toString()]),
                      style: CustomStyles.black14600,
                    ),
                    const SizedBox(height: 5),
                    Text('verified_rating_note'.tr,
                        style: CustomStyles.black12500),
                    const SizedBox(height: 10),
                    const SizedBox(height: 15),
                    Text('customer_review'.tr, style: CustomStyles.black14600),
                    const SizedBox(height: 10),
                    _isReviewsLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _astrologerReviews.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(child: Text('no_reviews'.tr)),
                              )
                            : SizedBox(
                                height: 160,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _astrologerReviews.length,
                                  itemBuilder: (context, index) {
                                    final review = _astrologerReviews[index];
                                    return Container(
                                      width: 220,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage:
                                                        NetworkImage(review
                                                                .userImageUrl ??
                                                            "")),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          review.userName ??
                                                              "User",
                                                          style: CustomStyles
                                                              .black14400,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      const SizedBox(height: 2),
                                                      RatingBarIndicator(
                                                        rating: review.rating,
                                                        itemBuilder: (context,
                                                                _) =>
                                                            const Icon(
                                                                Icons.star,
                                                                color: Color(
                                                                    0xffFFAF12)),
                                                        itemCount: 5,
                                                        itemSize: 15,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(review.date ?? '',
                                                          style: CustomStyles
                                                              .black12500),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Text(review.review ?? "",
                                                    style: CustomStyles
                                                        .black12500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
                //   child: _buildSimilarAstrologersSection(),
                ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarAstrologersSection() {
    final similarAstrologers = widget.allAstrologers
        .where((astro) => astro.id != _currentAstrologer.id)
        .toList();

    if (similarAstrologers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Similar AI Astrologers",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: similarAstrologers.length,
              itemBuilder: (context, index) {
                final astrologer = similarAstrologers[index];
                return _buildSimilarAstrologerCard(astrologer);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarAstrologerCard(AiAstrologer astrologer) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hasSpecialPrice = astrologer.chatSpecialPrice > 0 &&
        astrologer.chatSpecialPrice < astrologer.chatPrice;

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Aiastrologer(
              astrologer: astrologer,
              allAstrologers: widget.allAstrologers,
            ),
          ),
        );
      },
      child: Container(
        width: screenWidth * 0.35,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(astrologer.image),
                ),
                Positioned(
                  top: -3,
                  right: -3,
                  child: AstrologerStatusDot(status: astrologer.status),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              astrologer.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasSpecialPrice)
                  Text("₹${astrologer.chatPrice}",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough)),
                SizedBox(width: hasSpecialPrice ? 4 : 0),
                Text(
                    "₹${hasSpecialPrice ? astrologer.chatSpecialPrice : astrologer.chatPrice}/min",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
              ],
            ),
          ],
        ),
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
              ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('no_locations_found'.tr)))
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
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildAiAstrologerCard(AiAstrologer astrologer) {
    final hasSpecialPrice = astrologer.chatSpecialPrice > 0 &&
        astrologer.chatSpecialPrice < astrologer.chatPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==== LEFT SIDE (IMAGE + RATING BELOW) ====
          Column(
            children: [
              // Profile Image
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
                        onError: (error, stackTrace) {},
                      ),
                    ),
                  ),
                  Positioned(
                    top: -3,
                    right: -3,
                    child: AstrologerStatusDot(status: astrologer.status),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ⭐ Rating Below Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.orange.shade600),
                    const SizedBox(width: 2),
                    Text(
                      astrologer.rating.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // ==== RIGHT SIDE (DETAILS) ====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Astrologer Name + Status Badge
                Text(
                  astrologer.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Services Row
                Row(
                  children: [
                    Image.asset("assets/award.png",
                        height: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        astrologer.services.join(', '),
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Languages Row
                Row(
                  children: [
                    Image.asset("assets/hindieng.png",
                        height: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        astrologer.languages.join(', '),
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Pricing Row
                Row(
                  children: [
                    Image.asset("assets/currency-rupee.png",
                        height: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    if (hasSpecialPrice) ...[
                      Text(
                        "₹${astrologer.chatPrice}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      "₹${hasSpecialPrice ? astrologer.chatSpecialPrice : astrologer.chatPrice}/min",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
