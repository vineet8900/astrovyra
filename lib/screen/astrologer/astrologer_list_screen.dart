import 'dart:async';
import 'dart:convert';
import 'package:astrokavach/api/astro_listing_api.dart';
import 'package:astrokavach/api/auth_api/user_data_api.dart';
import 'package:astrokavach/api/consultation/chat_api/recharge_paynow_api.dart';
import 'package:astrokavach/api/consultation/consultation_form_api.dart';
import 'package:astrokavach/api/dashboard/search_delegates.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/api/payment/payment_verify_api.dart';
import 'package:astrokavach/controller/astrologer_controller/astrologer_list_controller.dart';
import 'package:astrokavach/custom_widgets/app_date_time_picker_theme.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/cutsom_textfield.dart';
import 'package:astrokavach/custom_widgets/offline_banner.dart';
import 'package:astrokavach/custom_widgets/payment_confirming_overlay.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/astro_list_model.dart';
import 'package:astrokavach/model/astrologer/chat_model/rechargepaynow_model.dart'
    hide Theme;
import 'package:astrokavach/model/kundalimodel/locationkundali.dart';
import 'package:astrokavach/model/services/services.dart';
import 'package:astrokavach/model/sortbymodel/sortbymodel.dart';
import 'package:astrokavach/screen/astrologer/astrologer_detail_screen.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/auth/profile_screen.dart';
import 'package:astrokavach/screen/walletupdate.dart';
import 'package:astrokavach/screen/astrologer/consultation/blinkingscreen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ----- vvv NEW IMPORTS ADDED vvv -----
import 'package:astrokavach/api/consultation/chat_api/recharge_wallet_api.dart';
import 'package:astrokavach/model/astrologer/chat_model/recharge_wallet_model.dart';
import 'package:astrokavach/screen/wallet/wallet_screen.dart';
import 'package:astrokavach/utils/network_connectivity.dart';
import 'package:shimmer/shimmer.dart';
// ----- ^^^ NEW IMPORTS ADDED ^^^ -----

class AstrologerListScreen extends StatefulWidget {
  final int? serviceId;
  final String? mode;
  final bool popToPreviousOnBack;
  const AstrologerListScreen(
      {super.key, this.serviceId, this.mode, this.popToPreviousOnBack = false});

  @override
  State<AstrologerListScreen> createState() => _AstrologerListScreenState();
}

class _AstrologerListScreenState extends State<AstrologerListScreen> {
  // Services & Controllers
  final AstrologerApiService astrologerApiService = AstrologerApiService();
  final ReusableFunction reusableFunction = ReusableFunction();
  final ConsultationApiService consultationApiService =
      ConsultationApiService();
  final AstrologerController controller = Get.put(AstrologerController());
  final RechargeWalletApiService rechargeWalletApiService =
      RechargeWalletApiService();

  // NEW VARIABLES - ADD THESE
  final RechargePaynowApiService rechargePaynowApiService =
      RechargePaynowApiService();
  final PaymentVerifyApi paymentVerifyApi = PaymentVerifyApi();
  late Razorpay razorpay;
  String? callbackurl;
  int? selectedRechargeId;

  // Service Filter Variables
  List<AstrologerService> astrologerServices = [];
  bool areServicesLoading = true;
  List<int> selectedServiceValues = [];

  // State
  List<AstroDataList> _masterAstrologerList = [];
  List<AstroDataList> _filteredAstrologerList = [];
  bool isloading = true;
  String? apiToken;
  double _walletBalance = 0.0;
  List<RechargeWalletList> _rechargePlans = [];
  String? _resumeModeAfterRecharge;
  int? _resumeAstrologerIdAfterRecharge;
  AstroDataList? _resumeAstrologerAfterRecharge;
  double? _resumeRequiredBalanceAfterRecharge;
  int? _resumeMinutesAfterRecharge;
  bool _arePlansLoading = true;

  // Search Controller
  final TextEditingController _searchController = TextEditingController();

  // Filter and Sort State
  List<SortByOption> _sortOptions = [];
  bool _isSortOptionsLoading = true;

  final Map<String, int> _languageApiMap = {'Hindi': 1, 'English': 2};
  List<String> get _allLanguages => _languageApiMap.keys.toList();
  final List<String> _experienceOptions = ["0-5", "5-10", "15+"];

  // User's selected filter values
  String? _selectedSortValue;
  List<String> _selectedLanguages = [];
  List<String> _selectedExperience = [];

  // Consultation Form State
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController phonecontrollercontroller =
      TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthTimeController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();

  LocationData? _selectedLocation;
  List<LocationData> _locationSuggestions = [];

  bool _isLoadingLocations = false;
  bool _showLocationDropdown = false;
  bool _isBottomSheetLoading = false;
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

  // Network State
  bool isNetworkError = false;
  Timer? _connectivityTimer;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _searchController.addListener(_applySearchFilter);
    setupNetworkListener();

    // NEW - Initialize Razorpay
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void setupNetworkListener() {
    _checkNetworkConnectivity();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _checkNetworkConnectivity();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkNetworkConnectivity() async {
    final ok = await checkDeviceHasInternet();
    if (!mounted) return;
    setState(() => isNetworkError = !ok);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearchFilter);
    _searchController.dispose();
    namecontroller.dispose();
    phonecontrollercontroller.dispose();
    emailcontroller.dispose();
    _birthDateController.dispose();
    _birthPlaceController.dispose();
    _birthTimeController.dispose();
    _connectivityTimer?.cancel();
    razorpay.clear();
    super.dispose();
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

    final dynamic result =
        await PaymentConfirmingOverlay.run(context, () async {
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
      final resumeMode = _resumeModeAfterRecharge;
      final resumeId = _resumeAstrologerIdAfterRecharge;
      final resumeAstro = _resumeAstrologerAfterRecharge;
      final resumeRequired = _resumeRequiredBalanceAfterRecharge;
      final resumeMinutes = _resumeMinutesAfterRecharge;
      _resumeModeAfterRecharge = null;
      _resumeAstrologerIdAfterRecharge = null;
      _resumeAstrologerAfterRecharge = null;
      _resumeRequiredBalanceAfterRecharge = null;
      _resumeMinutesAfterRecharge = null;
      if (resumeMode != null && resumeId != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (resumeRequired != null &&
              resumeMinutes != null &&
              _walletBalance < resumeRequired) {
            final astro = resumeAstro ??
                _filteredAstrologerList.firstWhere(
                  (a) => a.id == resumeId,
                  orElse: () => _masterAstrologerList.firstWhere(
                    (a) => a.id == resumeId,
                    orElse: () => _filteredAstrologerList.isNotEmpty
                        ? _filteredAstrologerList.first
                        : _masterAstrologerList.first,
                  ),
                );
            _showRechargeBottomSheet(
                context, astro, resumeRequired, resumeMinutes);
            return;
          }
          _showConsultationBottomSheet(context, resumeMode, resumeId);
        });
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

  void _initializeScreen() async {
    if (mounted) setState(() => isloading = true);

    await _loadApiToken();

    if (widget.serviceId != null) {
      if (mounted) {
        setState(() => selectedServiceValues = [widget.serviceId!]);
      }
      await _fetchServices();
    }

    final secondaryFutures = <Future<void>>[
      _fetchUserData(),
      _fetchSortByOptions(),
      _fetchRechargePlans(),
    ];
    if (widget.serviceId == null) {
      secondaryFutures.add(_fetchServices());
    }

    await Future.wait<void>([
      getAstrologerData(),
      Future.wait<void>(secondaryFutures),
    ]);
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

  Future<void> _fetchServices() async {
    if (mounted) setState(() => areServicesLoading = true);
    try {
      final services = await AstroApiService.fetchAstrologerServices();
      if (mounted && services != null) {
        setState(() => astrologerServices = services);
      }
    } catch (e) {}
    if (mounted) setState(() => areServicesLoading = false);
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
        setState(() {
          _locationSuggestions = locationResponse.data;
          _isLoadingLocations = false;
        });
      } else {
        setState(() {
          _locationSuggestions = [];
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocations = false;
        _locationSuggestions = [];
      });
    }
  }

  Future<void> _loadApiToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => apiToken = prefs.getString('api_token'));
  }

  Future<void> _fetchUserData() async {
    if (apiToken == null || apiToken!.isEmpty) return;

    try {
      UserDataApi userDataApi = UserDataApi();
      var userModel = await userDataApi.fetchUserData(apiToken!);

      if (userModel.success == true && userModel.data != null) {
        var data = userModel.data!;

        setState(() {
          namecontroller.text = data.name ?? '';
          phonecontrollercontroller.text = data.phone ?? '';
          emailcontroller.text = data.email ?? '';

          _birthDateController.text = data.birthDate ?? '';
          _birthTimeController.text = data.birthTime ?? '';
          _birthPlaceController.text = data.birthPlace ?? '';

          if (_birthPlaceController.text.isNotEmpty) {
            _selectedLocation = LocationData(
              name: _birthPlaceController.text,
              fullName: _birthPlaceController.text,
            );
          }

          _selectedGender = data.genderId ?? 0;
          _walletBalance =
              double.tryParse(data.wallet?.toString() ?? '0.0') ?? 0.0;
        });
      }
    } catch (e) {
      print("Error fetching user data from API: $e");

      var userData = await reusableFunction.getUserDataFromPrefs();
      if (mounted && userData != null) {
        setState(() {
          _birthDateController.text = userData['birth_date']?.toString() ?? '';
          _birthTimeController.text = userData['birth_time']?.toString() ?? '';
          _birthPlaceController.text =
              userData['birth_place']?.toString() ?? '';
        });
      }
    }
  }

  Future<void> _fetchSortByOptions() async {
    if (mounted) setState(() => _isSortOptionsLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${CustomStyles.apiBaseUrl}/astrologer/sort-by'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (apiToken != null) 'Authorization': 'Bearer $apiToken'
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          _sortOptions = (jsonData['data'] as List)
              .map((item) => SortByOption(
                  label: item['label'] ?? '', value: item['value'] ?? ''))
              .toList();
        }
      } else {
        _useFallbackSortOptions();
      }
    } catch (e) {
      _useFallbackSortOptions();
    }
    if (mounted) setState(() => _isSortOptionsLoading = false);
  }

  void _useFallbackSortOptions() {
    _sortOptions = [
      SortByOption(label: "A To Z", value: "a_to_z"),
      SortByOption(label: "What's New", value: "whats_new"),
      SortByOption(label: "Price Low To High", value: "price_low_to_high"),
      SortByOption(label: "Price High To Low", value: "price_high_to_low"),
    ];
  }

  Future<void> getAstrologerData() async {
    try {
      Map<String, dynamic> requestBody = {};
      if (widget.mode != null && widget.mode!.isNotEmpty) {
        requestBody['mode'] = widget.mode;
      }
      if (_selectedSortValue != null && _selectedSortValue!.isNotEmpty)
        requestBody['sort_by'] = _selectedSortValue;
      if (_selectedLanguages.isNotEmpty)
        requestBody['languages'] = _selectedLanguages
            .map((lang) => _languageApiMap[lang])
            .where((id) => id != null)
            .cast<int>()
            .toList();
      if (selectedServiceValues.isNotEmpty)
        requestBody['services'] = selectedServiceValues;
      if (_selectedExperience.isNotEmpty)
        requestBody['experiences'] = _selectedExperience;

      final response = await http.post(
        Uri.parse('${CustomStyles.apiBaseUrl}/astrologer/list'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (apiToken != null) 'Authorization': 'Bearer $apiToken'
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true &&
            jsonData['data'] != null &&
            jsonData['data']['list'] != null) {
          List<AstroDataList> fetched = (jsonData['data']['list'] as List)
              .map((item) => AstroDataList.fromJson(item))
              .toList();
          if (mounted) setState(() => _masterAstrologerList = fetched);
        } else {
          if (mounted) setState(() => _masterAstrologerList = []);
        }
      } else {
        if (mounted) setState(() => _masterAstrologerList = []);
      }
    } catch (e) {
      if (mounted) setState(() => _masterAstrologerList = []);
    }
    _applyAllFilters();
    if (mounted) setState(() => isloading = false);
  }

  void retryConnection() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const Center(child: CircularProgressIndicator()));
    try {
      final ok = await checkDeviceHasInternet();
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
        setState(() => isNetworkError = false);
        _initializeScreen();
        Fluttertoast.showToast(
            msg: 'Connection restored!', backgroundColor: Colors.green);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: 'Network connection still unavailable.',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Network connection still unavailable.',
          backgroundColor: Colors.red);
    }
  }

  void _applySearchFilter() => _applyAllFilters();

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedSortValue = null;
      _selectedLanguages.clear();
      _selectedExperience.clear();
      selectedServiceValues.clear();
      isloading = true;
    });
    getAstrologerData();
  }

  void _applyAllFilters() {
    List<AstroDataList> tempList = _masterAstrologerList;
    if (selectedServiceValues.isNotEmpty) {
      tempList = tempList.where((astrologer) {
        final Set<int> astrologerServiceValues =
            (astrologer.services ?? []).map((slug) {
          try {
            return astrologerServices
                .firstWhere((s) => s.slug.toLowerCase() == slug.toLowerCase())
                .value;
          } catch (e) {
            return -1;
          }
        }).toSet();
        return selectedServiceValues
            .every((val) => astrologerServiceValues.contains(val));
      }).toList();
    }
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      tempList = tempList
          .where((astro) => (astro.name ?? '').toLowerCase().contains(query))
          .toList();
    }
    setState(() => _filteredAstrologerList = tempList);
  }

  void _updateAndApplyServiceFilters(int? serviceValue) {
    setState(() {
      if (serviceValue == null) {
        selectedServiceValues.clear();
      } else {
        if (selectedServiceValues.contains(serviceValue)) {
          selectedServiceValues.remove(serviceValue);
        } else {
          selectedServiceValues.add(serviceValue);
        }
      }
    });
    _applyAllFilters();
  }

  @override
  Widget build(BuildContext context) {
    int totalFilters = _selectedLanguages.length +
        _selectedExperience.length +
        selectedServiceValues.length +
        (_selectedSortValue != null ? 1 : 0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        WillPopScope(
          onWillPop: () async {
            if (widget.popToPreviousOnBack) {
              return true;
            }
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => BottomAppBarScreen()));
            return false;
          },
          child: Scaffold(
            appBar: CustomAppBar(
              //  automaticallyImplyLeading: false,

              // backgroundColor: CustomStyles.whiteColor,

              // leading: IconButton(
              //   onPressed: () => Navigator.pushReplacement(context,
              //       MaterialPageRoute(builder: (context) => BottomAppBarScreen())),
              //   icon: const Icon(Icons.arrow_back_ios),
              // ),
              // title: 'astrologer_list'.tr,
              // bottom: PreferredSize(
              //   preferredSize: Size.fromHeight(1.0),
              //   child: Container(
              //     color: Colors.grey.shade300,
              //     height: 1.0,
              //   ),
              // ),
              backgroundColor: CustomStyles.whiteColor,
              title: 'astrologer_list'.tr,
              actions: [
                CartIcon.appBarAction(),
                IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: AppSearchDelegate(),
                    );
                  },
                  icon: const Icon(Icons.search, color: Colors.black),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(1.0),
                child: Container(
                  color: Colors.grey.shade300,
                  height: 1.0,
                ),
              ),
            ),
            // appBar: CustomAppBar(
            //   automaticallyImplyLeading: false,
            //   backgroundColor: CustomStyles.whiteColor,
            //   leading: IconButton(
            //     onPressed: () => Navigator.pushReplacement(context,
            //         MaterialPageRoute(builder: (context) => BottomAppBarScreen())),
            //     icon: const Icon(Icons.arrow_back_ios),
            //   ),
            //   title: 'astrologer_list'.tr,
            //   bottom: PreferredSize(
            //     preferredSize: Size.fromHeight(1.0),
            //     child: Container(
            //       color: Colors.grey.shade300,
            //       height: 1.0,
            //     ),
            //   ),
            // ),
            floatingActionButton: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom + 24,
              ),
              child: Badge(
                label: Text('$totalFilters'),
                isLabelVisible: totalFilters > 0,
                child: FloatingActionButton(
                  onPressed: _showFilterBottomSheet,
                  child: Icon(Icons.filter_alt_outlined, color: Colors.black),
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            // floatingActionButton: Badge(
            //   label: Text('$totalFilters'),
            //   isLabelVisible: totalFilters > 0,
            //   child: FloatingActionButton(
            //     onPressed: _showFilterBottomSheet,
            //     child: Icon(Icons.filter_alt_outlined, color: Colors.black),
            //     backgroundColor: Colors.grey.shade400,
            //   ),
            // ),
            body: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 60),
              child: Column(
                children: [
                  _buildServiceFilterBar(),
                  Expanded(
                    child: isloading
                        ? _buildAstrologerListShimmer()
                        : _filteredAstrologerList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off,
                                        size: 80, color: Colors.grey.shade400),
                                    SizedBox(height: 16),
                                    Text("No Astrologers Found",
                                        style: CustomStyles.black16600),
                                    SizedBox(height: 8),
                                    Text("Try adjusting your filters or search",
                                        style: TextStyle(
                                            color: Colors.grey.shade600)),
                                    SizedBox(height: 10),
                                    TextButton(
                                        onPressed: _resetFilters,
                                        child: Text("Clear All Filters")),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 32),
                                itemCount: _filteredAstrologerList.length,
                                itemBuilder: (context, index) =>
                                    _buildAstrologerCard(
                                        _filteredAstrologerList[index]),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isNetworkError && !isloading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: OfflineBanner(onRetry: retryConnection),
            ),
          ),
      ],
    );
  }

  Widget _buildAstrologerCard(AstroDataList astrologer) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AstrologerDetailScreen(
                  slug: astrologer.slug, astrologerId: astrologer.id))),
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                image: NetworkImage(astrologer.image ??
                                    'https://via.placeholder.com/100'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -3,
                            right: -3,
                            child: _buildStatusBadgeForAstrologer(astrologer),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              astrologer.rating?.toStringAsFixed(1) ?? 'N/A',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 60.0),
                          child: Text(
                            astrologer.name ?? 'No Name',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 6),
                        _buildDetailRow("assets/award.png",
                            astrologer.services?.join(', ') ?? 'N/A'),
                        SizedBox(height: 4),
                        _buildDetailRow("assets/hindieng.png",
                            astrologer.languages?.join(', ') ?? 'N/A'),
                        SizedBox(height: 4),
                        _buildDetailRow("assets/mortarboard.png",
                            "${astrologer.experience ?? 0} Years"),
                        SizedBox(height: 8),
                        _buildPriceRow(astrologer),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0),
              if (widget.mode == 'chat')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                        "chat", astrologer, 'chat'.tr, astrologer.status),
                  ],
                ),
              if (widget.mode == 'call')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: screenWidth * 0.28,
                      child: _buildActionButton(
                          "call", astrologer, 'call'.tr, astrologer.status),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: screenWidth * 0.38,
                      child: _buildActionButton("video", astrologer,
                          'video_call'.tr, astrologer.status),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String mode, AstroDataList astrologer, String label, String? status) {
    final String normalizedStatus = normalizeAstrologerStatusKey(status);
    final bool isDisabled =
        normalizedStatus == 'offline' || normalizedStatus == 'busy';

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double iconSize = screenWidth * 0.046;
    final double fontSize = screenWidth * 0.032;
    final double horizontalPadding = screenWidth * 0.030;
    final double verticalPadding = screenHeight * 0.012;
    final double borderWidth = screenWidth * 0.004;

    Widget iconWidget;
    Color color;

    switch (mode) {
      case 'chat':
        iconWidget = Image.asset("assets/chat-dots-fill.png",
            width: iconSize,
            height: iconSize,
            color: isDisabled ? Colors.grey.shade500 : Colors.white);
        color = CustomStyles.chatActionGreen;
        break;
      case 'call':
        iconWidget = Image.asset("assets/callring.png",
            width: iconSize,
            height: iconSize,
            color: isDisabled ? Colors.grey.shade500 : Colors.white);
        color = CustomStyles.callActionBackground;
        break;
      case 'video':
        iconWidget = Image.asset("assets/camera-video-fill.png",
            width: iconSize,
            height: iconSize,
            color: isDisabled ? Colors.grey.shade500 : Colors.white);
        color = CustomStyles.videoActionBackground;
        break;
      default:
        iconWidget =
            Icon(Icons.help_outline, size: iconSize, color: Colors.grey);
        color = Colors.grey;
    }

    if (mode == 'chat' || mode == 'call' || mode == 'video') {
      final Color fillColor = mode == 'chat'
          ? CustomStyles.chatActionGreen
          : mode == 'call'
              ? CustomStyles.callActionBackground
              : CustomStyles.videoActionBackground;
      return ElevatedButton(
        onPressed: isDisabled
            ? null
            : () => _handleConsultationRequest(mode, astrologer),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey.shade300 : fillColor,
          foregroundColor: isDisabled ? Colors.grey.shade500 : Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          minimumSize: Size(screenWidth * 0.22, screenHeight * 0.042),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDisabled ? Colors.grey.shade500 : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton(
      onPressed: isDisabled
          ? null
          : () => _handleConsultationRequest(mode, astrologer),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
            color: isDisabled ? Colors.grey.shade400 : color,
            width: borderWidth),
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding),
        minimumSize: Size(screenWidth * 0.22, screenHeight * 0.042),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDisabled ? Colors.grey.shade500 : color,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleConsultationRequest(String mode, AstroDataList astrologer) {
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
              builder: (context) =>
                  LoginScreen(redirectScreen: AstrologerListScreen())));
      return;
    }

    const int minChatDurationInMinutes = 5;

    // ** THE FIX IS HERE for 'int' is not a subtype of type 'double' error **
    final double pricePerMinute =
        ((mode == 'chat' ? astrologer.chatPrice : astrologer.callPrice) ?? 0)
            .toDouble();

    final double requiredBalance = minChatDurationInMinutes * pricePerMinute;

    if (_walletBalance < requiredBalance) {
      _resumeModeAfterRecharge = mode;
      _resumeAstrologerIdAfterRecharge = astrologer.id;
      _resumeAstrologerAfterRecharge = astrologer;
      _resumeRequiredBalanceAfterRecharge = requiredBalance;
      _resumeMinutesAfterRecharge = minChatDurationInMinutes;
      _showRechargeBottomSheet(
          context, astrologer, requiredBalance, minChatDurationInMinutes);
    } else {
      // We pass the astrologer.id from the object here
      _showConsultationBottomSheet(context, mode, astrologer.id);
    }
  }

  void _showRechargeBottomSheet(BuildContext context, AstroDataList astrologer,
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
                    // Close button at top right
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            color: Colors.grey.shade600, size: 22),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 100% Cashback banner
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

                    // Message with pink background
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
                            // const TextSpan(text: "Minimum balance of $minutes minutes "),
                            TextSpan(
                              text: "(₹ ${requiredBalance.toStringAsFixed(0)})",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F)),
                            ),
                            const TextSpan(
                                text: " is required to start chat with "),
                            TextSpan(
                              text: astrologer.name ?? 'the astrologer',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Recharge Now heading
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

                    // Recharge plans grid - COMPACT SIZE
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
                                          // Green ribbon for extra offer
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

                                          // Amount display
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

                    // Proceed to Pay button
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
                                      setModalState(() => isProcessing = false);
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
    if (userData == null || userData["country"] == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
      return;
    }

    // Call recharge pay now API
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

  Widget _buildAstrologerListShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 14,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 12,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceFilterBar() {
    if (areServicesLoading)
      return Container(
          height: 50, child: Center(child: CircularProgressIndicator()));
    if (astrologerServices.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: astrologerServices.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              bool isSelected = selectedServiceValues.isEmpty;
              return GestureDetector(
                onTap: () => _updateAndApplyServiceFilters(null),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey.shade400 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey),
                  ),
                  child: Center(
                      child: Text("All",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500))),
                ),
              );
            }
            final service = astrologerServices[index - 1];
            final isSelected = selectedServiceValues.contains(service.value);
            return GestureDetector(
              onTap: () => _updateAndApplyServiceFilters(service.value),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.shade400 : Colors.white,
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
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 5),
                    Text(service.name,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    String? tempSortValue = _selectedSortValue;
    List<String> tempSelectedLanguages = List.from(_selectedLanguages);
    List<String> tempSelectedExperience = List.from(_selectedExperience);
    String selectedSection = 'Sort by';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade400))),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sort & Filter",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.close))
                        ]),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.grey
                                .shade200, // Sidebar ka background halka sa grey rakha hai (optional)
                            border: Border(
                              right: BorderSide(
                                // 👈 YE HAI WO LINE
                                color: Colors.grey.shade400, // Line ka color
                                width: 1.5, // Line ki motai (thickness)
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildSidebarItem(
                                  'Sort by',
                                  selectedSection == 'Sort by',
                                  () => setModalState(
                                      () => selectedSection = 'Sort by')),
                              _buildSidebarItem(
                                  'Experience',
                                  selectedSection == 'Experience',
                                  () => setModalState(
                                      () => selectedSection = 'Experience')),
                              _buildSidebarItem(
                                  'Languages',
                                  selectedSection == 'Languages',
                                  () => setModalState(
                                      () => selectedSection = 'Languages')),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (selectedSection == 'Sort by')
                                  _buildSortByContent(
                                      tempSortValue,
                                      setModalState,
                                      (value) => tempSortValue = value),
                                if (selectedSection == 'Experience')
                                  _buildExperienceContent(
                                      tempSelectedExperience, setModalState),
                                if (selectedSection == 'Languages')
                                  _buildLanguagesContent(
                                      tempSelectedLanguages, setModalState),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade400))),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempSortValue = null;
                                tempSelectedLanguages.clear();
                                tempSelectedExperience.clear();
                              });
                            },
                            child: Text("Reset",
                                style: TextStyle(color: Colors.black87)),
                            style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSortValue = tempSortValue;
                                _selectedLanguages = tempSelectedLanguages;
                                _selectedExperience = tempSelectedExperience;
                                isloading = true;
                              });
                              Navigator.pop(context);
                              getAstrologerData();
                            },
                            child: Text("Apply",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CustomStyles.pinki,
                                padding: EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSidebarItem(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? CustomStyles.whiteColor : Colors.transparent,
        child: Text(title,
            style: TextStyle(
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }

  Widget _buildStatusBadgeForAstrologer(AstroDataList astrologer) {
    return AstrologerStatusDot(status: astrologer.status);
  }

  Widget _buildSortByContent(String? tempSortValue, StateSetter setModalState,
      Function(String?) onSortChanged) {
    return Expanded(
      child: _isSortOptionsLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: _sortOptions.map((option) {
                bool isSelected = tempSortValue == option.value;
                return _buildFilterOption(
                  label: option.label,
                  isSelected: isSelected,
                  onTap: () => setModalState(
                      () => onSortChanged(isSelected ? null : option.value)),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildExperienceContent(
      List<String> tempSelectedExperience, StateSetter setModalState) {
    return Expanded(
      child: ListView(
        children: _experienceOptions.map((exp) {
          bool isSelected = tempSelectedExperience.contains(exp);
          return _buildFilterOption(
            label: "$exp Years",
            isSelected: isSelected,
            onTap: () => setModalState(() => isSelected
                ? tempSelectedExperience.remove(exp)
                : tempSelectedExperience.add(exp)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguagesContent(
      List<String> tempSelectedLanguages, StateSetter setModalState) {
    return Expanded(
      child: ListView(
        children: _allLanguages.map((language) {
          bool isSelected = tempSelectedLanguages.contains(language);
          return _buildFilterOption(
            label: language,
            isSelected: isSelected,
            onTap: () => setModalState(() => isSelected
                ? tempSelectedLanguages.remove(language)
                : tempSelectedLanguages.add(language)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterOption(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                    width: 2),
                color: isSelected ? Colors.grey.shade300 : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.circle, size: 14, color: Colors.black)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400))),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String imagePath, String text) {
    return Row(
      children: [
        Image.asset(
          imagePath,
          width: 16,
          height: 16,
          color: Colors.black,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(AstroDataList astrologer) {
    double originalPrice = 0;
    double specialPrice = 0;

    if (widget.mode == 'chat') {
      originalPrice = (astrologer.chatPrice ?? 0).toDouble();
      specialPrice = (astrologer.chatSpecialPrice ?? 0).toDouble();
    } else {
      originalPrice = (astrologer.callPrice ?? 0).toDouble();
      specialPrice = (astrologer.callSpecialPrice ?? 0).toDouble();
    }

    bool hasSpecialPrice = specialPrice > 0 && specialPrice < originalPrice;

    String mainDisplayPrice = hasSpecialPrice
        ? specialPrice.toStringAsFixed(0)
        : originalPrice.toStringAsFixed(0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Row(
          children: [
            Image.asset(
              "assets/currency-rupee.png",
              color: Colors.black,
              height: 16,
            ),
            const SizedBox(width: 4),
            if (hasSpecialPrice)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "₹${originalPrice.toStringAsFixed(0)}/Min",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            Text(
              "₹$mainDisplayPrice/Min",
              style: const TextStyle(
                  fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  void _showConsultationBottomSheet(
      BuildContext context, String modetype, int? astrologerId) {
    final _formKey = GlobalKey<FormState>();
    selectedMaritalStatus = null;
    selectedOccupation = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(builder: (BuildContext context, setState) {
              return Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Text(
                                'Book Consultation for ${modetype[0].toUpperCase()}${modetype.substring(1)}',
                                style: CustomStyles.black16600)),
                        SizedBox(height: 20),
                        CustomTextField(
                            starsign: "*",
                            title: "Name",
                            label: "Enter Name",
                            controller: namecontroller,
                            validator: (v) =>
                                v!.isEmpty ? 'Name is Required' : null),
                        SizedBox(height: 12),
                        Text('Birth Date', style: CustomStyles.black14500),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: _birthDateController,
                          style: TextStyle(fontSize: 12),
                          readOnly: true,
                          decoration: _inputDecoration("Select Birth Date"),
                          onTap: () async {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1920),
                              lastDate: DateTime.now(),
                              builder: (context, child) =>
                                  AppDateTimePickerTheme.wrap(context, child),
                            );
                            if (pickedDate != null) {
                              setState(() => _birthDateController.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate));
                            }
                          },
                          validator: (v) =>
                              v!.isEmpty ? 'Birth Date is required' : null,
                        ),
                        SizedBox(height: 12),
                        Text('Birth Time', style: CustomStyles.black14500),
                        SizedBox(height: 2),
                        TextFormField(
                          style: TextStyle(fontSize: 12),
                          controller: _birthTimeController,
                          readOnly: true,
                          decoration: _inputDecoration("Select Birth Time"),
                          onTap: () async {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) =>
                                  AppDateTimePickerTheme.wrap(context, child),
                            );
                            if (pickedTime != null) {
                              if (_birthDateController.text.isNotEmpty) {
                                final now = DateTime.now();
                                final selectedDate = DateFormat('yyyy-MM-dd')
                                    .parse(_birthDateController.text);
                                bool isToday = selectedDate.year == now.year &&
                                    selectedDate.month == now.month &&
                                    selectedDate.day == now.day;
                                if (isToday) {
                                  final currentTimeInMinutes =
                                      now.hour * 60 + now.minute;
                                  final pickedTimeInMinutes =
                                      pickedTime.hour * 60 + pickedTime.minute;
                                  if (pickedTimeInMinutes >
                                      currentTimeInMinutes) {
                                    Fluttertoast.showToast(
                                        msg: "You cannot select a future time",
                                        gravity: ToastGravity.TOP,
                                        backgroundColor: Colors.red);
                                    return;
                                  }
                                }
                              }
                              setState(() => _birthTimeController.text =
                                  pickedTime.format(context));
                            }
                          },
                          validator: (v) =>
                              v!.isEmpty ? 'Birth Time is required' : null,
                        ),
                        SizedBox(height: 12),
                        Text('Birth Place', style: CustomStyles.black14500),
                        SizedBox(height: 5),
                        Column(
                          children: [
                            TextFormField(
                              style: TextStyle(fontSize: 12),
                              controller: _birthPlaceController,
                              decoration:
                                  _inputDecoration("Type to search location",
                                      suffixIcon: Icons.location_on),
                              onChanged: (value) =>
                                  _searchLocation(value, setState),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Please enter birth place';
                                if (_selectedLocation == null)
                                  return 'Please select a valid place from the list';
                                return null;
                              },
                            ),
                            _buildLocationDropdown(setState),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text('Gender', style: CustomStyles.black14500),
                        SizedBox(height: 5),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _genderRadio(setState, 'Male', 1),
                              _genderRadio(setState, 'Female', 2),
                              _genderRadio(setState, 'Other', 3),
                            ]),
                        SizedBox(height: 12),
                        Text('Marital Status', style: CustomStyles.black14500),
                        SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            value: selectedMaritalStatus,
                            decoration:
                                _inputDecoration("Select Marital Status"),
                            items: maritalStatusMap.keys
                                .map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedMaritalStatus = v)),
                        SizedBox(height: 12),
                        Text('Occupation', style: CustomStyles.black14500),
                        SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            value: selectedOccupation,
                            decoration: _inputDecoration("Select Occupation"),
                            items: occupationMap.keys
                                .map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedOccupation = v)),
                        SizedBox(height: 20),
                        _isBottomSheetLoading
                            ? Center(child: CircularProgressIndicator())
                            : Center(
                                child: CustomElevatedButton(
                                  backgroundColor: CustomStyles.pinki,
                                  text:
                                      "Proceed ${modetype[0].toUpperCase()}${modetype.substring(1)}",
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(
                                          () => _isBottomSheetLoading = true);
                                      var response =
                                          await consultationApiService
                                              .callapidata(
                                        context: context,
                                        token: apiToken,
                                        id: astrologerId,
                                        mode: modetype,
                                        when: "now",
                                        timeSlot: 15,
                                        name: namecontroller.text,
                                        scheduledTimeSlot: "",
                                        gender: _selectedGender,
                                        occupation:
                                            occupationMap[selectedOccupation] ??
                                                "",
                                        maritalstatus: maritalStatusMap[
                                                selectedMaritalStatus] ??
                                            "",
                                        birthDate: _birthDateController.text,
                                        birthTime: _birthTimeController.text,
                                        birthPlace: _birthPlaceController.text,
                                      );
                                      if (response != null &&
                                          response["success"] == true) {
                                        Navigator.pop(context);
                                      }
                                      if (mounted)
                                        setState(() =>
                                            _isBottomSheetLoading = false);
                                    }
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }

  Widget _buildLocationDropdown(StateSetter setState) {
    if (!_showLocationDropdown) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5)
          ]),
      constraints: BoxConstraints(maxHeight: 200),
      child: _isLoadingLocations
          ? Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator()))
          : _locationSuggestions.isEmpty
              ? Padding(
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

  Widget _genderRadio(StateSetter setState, String title, int value) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Row(
        children: [
          Radio<int>(
            value: value,
            groupValue: _selectedGender,
            onChanged: (v) => setState(() => _selectedGender = v!),
            activeColor: Colors.grey,
          ),
          Text(title),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      labelStyle: TextStyle(fontSize: 10, color: Colors.grey),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: Colors.grey[600])
          : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blueGrey)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
