import 'package:astrokavach/api/astro_list_detail_api.dart';
import 'package:astrokavach/api/astro_listing_api.dart';
import 'package:astrokavach/api/consultation/chat_api/recharge_paynow_api.dart';
import 'package:astrokavach/api/consultation/chat_api/recharge_wallet_api.dart';
import 'package:astrokavach/api/consultation/consultation_form_api.dart';
import 'package:astrokavach/api/dashboard/search_delegates.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/api/payment/payment_verify_api.dart';
import 'package:astrokavach/api/product_api/faq/newfaqapi.dart';
import 'package:astrokavach/api/youtubeapi/youtubeapi.dart';
import 'package:astrokavach/api/youtubereview/youtubereview.dart';
import 'package:astrokavach/custom_widgets/app_date_time_picker_theme.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/cutsom_textfield.dart';
import 'package:astrokavach/custom_widgets/detail_screen_shimmers.dart';
import 'package:astrokavach/custom_widgets/payment_confirming_overlay.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/astro_detail_model.dart';
import 'package:astrokavach/model/astrologer/astro_list_model.dart';
import 'package:astrokavach/model/astrologer/chat_model/recharge_wallet_model.dart';
import 'package:astrokavach/model/astrologer/chat_model/rechargepaynow_model.dart'
    hide Theme;
import 'package:astrokavach/model/faqmodel/faqmodel.dart';
import 'package:astrokavach/model/kundalimodel/locationkundali.dart';
import 'package:astrokavach/model/reviewmodel/productmodelreview.dart';
import 'package:astrokavach/model/videoyoutube/videoyoutube.dart';
import 'package:astrokavach/model/youtubereview/youtubereview.dart';
import 'package:astrokavach/screen/Ai_astrologer_list.dart';
import 'package:astrokavach/screen/astrologer/consultation/chat_screen.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/wallet/wallet_screen.dart';
import 'package:astrokavach/screen/walletupdate.dart';
import 'package:astrokavach/screen/astrologer/consultation/blinkingscreen.dart';
import 'package:astrokavach/screen/youtubevideo/youtubevideo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:html_tags_cleaner/html_tags_cleaner.dart';
import 'package:intl/intl.dart';

import 'package:rating_summary/rating_summary.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AstrologerDetailScreen extends StatefulWidget {
  final String? slug;
  final int? astrologerId;

  AstrologerDetailScreen({super.key, this.slug, this.astrologerId});

  @override
  State<AstrologerDetailScreen> createState() => _AstrologerDetailScreenState();
}

class _AstrologerDetailScreenState extends State<AstrologerDetailScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonecontrollercontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();

  //new filed
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthTimeController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();

  LocationData? _selectedLocation;
  List<LocationData> _locationSuggestions = [];

  bool _isLoadingLocations = false;
  bool _showLocationDropdown = false;
  final RechargeWalletApiService rechargeWalletApiService =
      RechargeWalletApiService();
  final RechargePaynowApiService rechargePaynowApiService =
      RechargePaynowApiService();
  final PaymentVerifyApi paymentVerifyApi = PaymentVerifyApi();
  late Razorpay razorpay;

  double _walletBalance = 0.0;
  List<RechargeWalletList> _rechargePlans = [];
  bool _arePlansLoading = true;
  String? callbackurl;
  int? selectedRechargeId;
  String? _resumeModeAfterRecharge;
  double? _resumeRequiredBalanceAfterRecharge;
  int? _resumeMinutesAfterRecharge;

  // +++ ADD THESE NEW VARIABLES FOR REVIEWS +++
  bool _isReviewsLoading = true;
  bool canReview = false;
  final TextEditingController _reviewController = TextEditingController();
  double _currentRating = 0.0;
  List<ProductReview> _astrologerReviews = [];
  final _reviewFormKey = GlobalKey<FormState>(); // <-- ADD THIS LINE
  bool _isTryingToSubmit = false;
  bool _isNotifying =
      false; // <-- ADD THIS LINE for the notify button's loading state

  int _selectedGender = 0;
  String? selectedIndex;
  int selectedtime = 15;
  dynamic selectedslot;
  String? formattedavailaibledate;
  String? selectedMaritalStatus;
  String? selectedOccupation;
  final Map<String, String> maritalStatusMap = {
    'Single': 'single',
    'Married': 'married',
    'Divorced': 'divorced',
    'Widow': 'widow',
    'Not Specified': '',
  };

  final Map<String, String> occupationMap = {
    'Employed': 'employed',
    'Business Person': 'business_person',
    'Housewife': 'house_wife',
    'Retired': 'retaired',
    'Student': 'student',
    'Not Specified': '',
  };
  ReusableFunction reusableFunction = ReusableFunction();
  Map<String, dynamic>? user;
  void fetchUserData() async {
    if (!mounted) return;
    var userData = await reusableFunction.getUserDataFromPrefs();
    if (userData != null) {
      setState(() {
        user = userData;
        namecontroller.text = userData['name'] ?? '';
        phonecontrollercontroller.text = userData['phone'] ?? '';
        emailcontroller.text = userData['email'] ?? '';
        _selectedGender = userData['gender_id'] is int
            ? (userData['gender_id'] as int)
            : int.tryParse(userData['gender_id']?.toString() ?? '0') ?? 0;
        _birthDateController.text =
            userData['birth_date']?.toString().trim() ?? '';
        _birthTimeController.text =
            userData['birth_time']?.toString().trim() ?? '';
        _birthPlaceController.text =
            userData['birth_place']?.toString().trim() ??
                userData['place_of_birth']?.toString().trim() ??
                userData['address']?.toString().trim() ??
                '';
        if (_birthPlaceController.text.isNotEmpty) {
          _selectedLocation = LocationData(
            name: _birthPlaceController.text,
            fullName: _birthPlaceController.text,
          );
        }
        _walletBalance =
            double.tryParse(userData['wallet']?.toString() ?? '0.0') ?? 0.0;
      });
    } else {}
  }

  String? apiToken;

  ConsultationApiService consultationApiService = ConsultationApiService();

  bool isloading = false;
  bool _isBottomSheetLoading = false; // <-- ADDED: For bottom sheet state

  AstrologerApiService astrologerApiService = AstrologerApiService();
  AstrologerDetailApiService astrologerDetailApiService =
      AstrologerDetailApiService();
  AstroDetailModel? astroDetailModel;
  AstroDetailDatum? astroDetailDatum;
  AstrologerListModel? astrologerListModel;
  List<AstroDataList> similarastrologerlist = [];
  // ADD THESE TWO NEW VARIABLES
  List<VideoItem> videoTestimonials = [];
  String? videoTestimonialsHeading;
  // ADD THESE TWO NEW VARIABLES
  List<TestimonialItem> textTestimonials = [];
  String? textTestimonialsHeading;
  //add faq
  List<FaqItem> faqItems = [];
  String? faqHeading;
  String? faqSubHeading;
  bool _isFaqsLoading = true;
  gettoken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');
  }

  getAstrologerDetailListData() async {
    setState(() {
      isloading = true;
    });
    try {
      astroDetailModel =
          await astrologerDetailApiService.fetchAstroDetails(widget.slug);
      astroDetailDatum = astroDetailModel!.data!.detail;
      astrologerListModel = await astrologerApiService.fetchAstrologers(
          "", '', '', [], [], [], [], [], [], widget.slug.toString(), 1,
          sortBy: '');

      similarastrologerlist = astrologerListModel?.data?.list ?? [];
      _checkCanUserReview();
      _fetchAstrologerReviews();
      try {
        final videoresponse =
            await VideoTestimonialService.fetchVideoTestimonials(
                page: "astrologer");
        if (mounted && videoresponse.success) {
          setState(() {
            videoTestimonials = videoresponse.data.data;
            videoTestimonialsHeading = videoresponse.data.heading;
          });
        }
      } catch (e) {}
      try {
        final textResponse = await TextTestimonialService.fetchTextTestimonials(
            page: "astrologer");
        if (mounted && textResponse.success) {
          setState(() {
            textTestimonials = textResponse.data.data;
            textTestimonialsHeading = textResponse.data.heading;
          });
        }
      } catch (e) {}

      try {
        final faqResponse = await FaqService.fetchFaqs(page: "astrologer");
        if (mounted && faqResponse.success) {
          setState(() {
            faqItems = faqResponse.data.data;
            faqHeading = faqResponse.data.heading;
            faqSubHeading = faqResponse.data.subHeading;
            _isFaqsLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isFaqsLoading = false;
          });
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  // ... inside the _AstrologerDetailScreenState class

  // +++ ADD THIS ENTIRE FUNCTION +++
  void _handleNotifyMe() async {
    // Prevent action if the astrologer is already online or if a request is in progress
    if (astroDetailDatum?.status == 'online' || _isNotifying) return;

    // 1. Check if the user is logged in
    if (apiToken == null || apiToken!.isEmpty) {
      // If not, redirect to the login screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen(
                  redirectScreen: AstrologerDetailScreen(
                    astrologerId: widget.astrologerId,
                    slug: widget.slug,
                  ),
                )),
      );
      return;
    }

    // 2. Show the loading indicator
    if (mounted) {
      setState(() {
        _isNotifying = true;
      });
    }

    // 3. Call the API using your service
    final response = await AstroApiService.notifyUser(
      astrologerId: astroDetailDatum!.id!,
      type: "astrologer-online",
    );

    // 4. Hide the loading indicator
    if (mounted) {
      setState(() {
        _isNotifying = false;
      });
    }

    // The AstroApiService.notifyUser already shows a toast message,
    // so no extra success/failure message is needed here.
    if (response != null && response.success) {}
  }

  @override
  void initState() {
    super.initState();
    _fetchRechargePlans();
    gettoken();
    fetchUserData();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getAstrologerDetailListData();
  }

  @override
  void dispose() {
    namecontroller.dispose();
    phonecontrollercontroller.dispose();
    emailcontroller.dispose();
    _birthDateController.dispose();
    _birthPlaceController.dispose();
    _birthTimeController.dispose();
    _reviewController.dispose(); // +++ ADD THIS LINE +++
    razorpay.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AstrologerDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.slug != oldWidget.slug) {
      getAstrologerDetailListData();
    }
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
      final resumeRequired = _resumeRequiredBalanceAfterRecharge;
      final resumeMinutes = _resumeMinutesAfterRecharge;
      _resumeModeAfterRecharge = null;
      _resumeRequiredBalanceAfterRecharge = null;
      _resumeMinutesAfterRecharge = null;
      if (resumeMode != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (resumeRequired != null &&
              resumeMinutes != null &&
              _walletBalance < resumeRequired) {
            _showRechargeBottomSheet(
                context, astroDetailDatum!, resumeRequired, resumeMinutes);
            return;
          }
          showmodelbottamsheet(context, resumeMode);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment verification failed")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
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
      Fluttertoast.showToast(msg: "Please login to continue");
      return;
    }

    RechargePayNowModel? rechargePayNowModel = await rechargePaynowApiService
        .fetchrechargepaynowapidata(token, planId, "");

    if (rechargePayNowModel?.data == null) {
      Fluttertoast.showToast(msg: "Payment data could not be fetched");
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

  void _showRechargeBottomSheet(BuildContext context,
      AstroDetailDatum astrologer, double requiredBalance, int minutes) {
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
                    //
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            color: Colors.grey.shade600, size: 22),
                      ),
                    ),
                    const SizedBox(height: 4),

                    //
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

                    //
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
                                text:
                                    " is required to start the session with "),
                            TextSpan(
                              text: astrologer.name ??
                                  'the astrologer', // astrologer.n
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    //
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

                    //
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
                                          //
                                          if (hasExtra)
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              child: ClipPath(
                                                clipper: RibbonClipper(), //
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

                                          //
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

  // +++ ADD THIS ENTIRE METHOD +++
  Future<void> _fetchAstrologerReviews() async {
    if (astroDetailDatum == null || astroDetailDatum!.id == null) return;
    if (!mounted) return;
    setState(() => _isReviewsLoading = true);

    // This calls the API service method you created earlier
    final reviews = await AstroApiService.fetchAstrologerReviews(
        astrologerId: astroDetailDatum!.id!);

    if (mounted && reviews != null) {
      setState(() {
        _astrologerReviews = reviews;
      });
    }
    // Ensure loading is turned off, even if there's an error
    setState(() => _isReviewsLoading = false);
  }

  Future<void> _checkCanUserReview() async {
    if (astroDetailDatum == null || astroDetailDatum!.id == null) return;

    // NOTE: The 'page' type for an astrologer is assumed to be 'astrologer'.
    // Please confirm this key with your backend API documentation.
    final response = await AstroApiService.canReview(
      page: 'astrologer',
      id: astroDetailDatum!.id!,
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

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Exit'),
              content: const Text('Are you sure you want to go back?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // No
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomAppBarScreen()),
                    );
                  }, // Yes
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false; // Default false agar dialog dismiss ho jaye
  }
  // <-- ADDED: Function to check login status before opening form
  // void _handleConsultationRequest(String mode) {
  //   if (apiToken == null || apiToken!.isEmpty || apiToken!.length == 12) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginScreen(
  //         redirectScreen: AstrologerDetailScreen(astrologerId: widget.astrologerId,slug: widget.slug,),
  //       )),
  //     );
  //   } else {
  //     showmodelbottamsheet(context, mode);
  //   }
  // }

  void _handleConsultationRequest(String mode) {
    //
    if (apiToken == null || apiToken!.isEmpty || apiToken!.length < 15) {
      //
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen(
                  redirectScreen: AstrologerDetailScreen(
                      astrologerId: widget.astrologerId, slug: widget.slug),
                )),
      );
      return;
    }

    //
    if (astroDetailDatum == null) return; //

    const int minDurationInMinutes = 5;
    double pricePerMinute = 0.0;

    //
    switch (mode) {
      case 'chat':
        pricePerMinute = (astroDetailDatum!.chatPrice ?? 0).toDouble();
        break;
      case 'call':
        pricePerMinute = (astroDetailDatum!.callPrice ?? 0).toDouble();
        break;
      case 'video':
        pricePerMinute = (astroDetailDatum!.videoPrice ?? 0).toDouble();
        break;
    }

    final double requiredBalance = minDurationInMinutes * pricePerMinute;

    //
    if (_walletBalance < requiredBalance) {
      //
      _resumeModeAfterRecharge = mode;
      _resumeRequiredBalanceAfterRecharge = requiredBalance;
      _resumeMinutesAfterRecharge = minDurationInMinutes;
      _showRechargeBottomSheet(
          context, astroDetailDatum!, requiredBalance, minDurationInMinutes);
    } else {
      //
      showmodelbottamsheet(context, mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    // =================================================================
    // ========= RESPONSIVE VARIABLES STARTS HERE ======================
    // =================================================================
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // =================================================================
    // ========= RESPONSIVE VARIABLES ENDS HERE ========================
    // =================================================================

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: CustomStyles.whiteColor,
          elevation: 4,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () async {
              // AppBar back button ke liye bhi same confirmation
              //bool shouldPop = await _onWillPop();
              // if (shouldPop) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BottomAppBarScreen()),
              );
              // }
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            astroDetailDatum?.name?.trim().isNotEmpty == true
                ? astroDetailDatum!.name!
                : 'astrologer_details'.tr,
            style: CustomStyles.black18600,
          ),
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
        ),
        body: isloading && astroDetailDatum == null
            ? const AstrologerDetailLoadingShimmer()
            : astroDetailDatum == null
                ? Center(
                    child: Text(
                    'no_astrologer_detail_data'.tr,
                    style: CustomStyles.black14600,
                  ))
                : SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            // =================================================================
                            // ========= NEW UPDATED PROFILE CARD STARTS HERE ==================
                            // =================================================================
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    spreadRadius: 6,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Profile Image
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              astroDetailDatum?.image ??
                                                  'https://via.placeholder.com/100',
                                              fit: BoxFit.cover,
                                              height: 100,
                                              width: 90,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(Icons.person, size: 90),
                                            ),
                                          ),
                                          Positioned(
                                            top: -3,
                                            right: -3,
                                            child: AstrologerStatusDot(
                                                status:
                                                    astroDetailDatum?.status),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 12),
                                      // Details Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          astroDetailDatum
                                                                  ?.name ??
                                                              'Rohit Aggarwal',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(width: 4),
                                                      if (astroDetailDatum
                                                              ?.blueTick ==
                                                          true)
                                                        Icon(Icons.verified,
                                                            color: Colors.green,
                                                            size: 20),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start, //
                                              children: [
                                                Image.asset(
                                                  "assets/award.png",
                                                  color: Colors.black,
                                                  height: 18, //
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  //
                                                  child: ReadMoreText(
                                                    //
                                                    astroDetailDatum?.services
                                                            ?.map((service) =>
                                                                service.name)
                                                            .join(", ") ??
                                                        'Vedic Astrology, Tarot, Vastu, Face Reading, Gemology',

                                                    trimLines: 1,
                                                    colorClickableText:
                                                        Colors.blue,
                                                    trimMode: TrimMode.Line,
                                                    trimCollapsedText:
                                                        '...more',
                                                    trimExpandedText: ' less',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade900,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // SizedBox(height: 8),
                                            // Row(
                                            //   children: [
                                            //     Image.asset(
                                            //       "assets/award.png",
                                            //       color: Colors.deepPurple,
                                            //     ),
                                            //     SizedBox(
                                            //       width: 4,
                                            //     ),
                                            //     Wrap(
                                            //       spacing: 6.0,
                                            //       runSpacing: 6.0,
                                            //       children: astroDetailDatum
                                            //               ?.services
                                            //               ?.map((service) {
                                            //             return Text(
                                            //               service.name ?? '',
                                            //               style: TextStyle(
                                            //                   fontSize: 14,
                                            //                   color: Colors.grey
                                            //                       .shade900),
                                            //             );
                                            //           }).toList() ??
                                            //           // Fallback dummy data for display
                                            //           [
                                            //             'Vedic Astrology',
                                            //             'Tarot',
                                            //             'Vastu',
                                            //             'Face Reading',
                                            //             'Gemology'
                                            //           ].map((skill) {
                                            //             return Container(
                                            //               padding: EdgeInsets
                                            //                   .symmetric(
                                            //                       horizontal:
                                            //                           10,
                                            //                       vertical: 5),
                                            //               decoration:
                                            //                   BoxDecoration(
                                            //                 color: Colors.white,
                                            //                 borderRadius:
                                            //                     BorderRadius
                                            //                         .circular(
                                            //                             20),
                                            //                 border: Border.all(
                                            //                     color: Colors
                                            //                         .deepOrange
                                            //                         .shade200),
                                            //               ),
                                            //               child: Text(
                                            //                 skill,
                                            //                 style: TextStyle(
                                            //                     color: Colors
                                            //                         .deepOrange,
                                            //                     fontSize: 12),
                                            //               ),
                                            //             );
                                            //           }).toList(),
                                            //     ),
                                            //   ],
                                            // ),
                                            // Experience

                                            // Languages

                                            // SizedBox(height: 4),

                                            // Row(
                                            //   children: [
                                            //     Image.asset(
                                            //       "assets/hindieng.png",
                                            //       color: Colors.deepPurple,
                                            //     ),
                                            //     //Icon(Icons.translate, size: 16, color:Colors.deepPurple),
                                            //     SizedBox(width: 8),
                                            //     Expanded(
                                            //       child: Text(
                                            //         astroDetailDatum?.languages
                                            //                 ?.join(", ") ??
                                            //             'English, Hindi',
                                            //         style: TextStyle(
                                            //             fontSize: 14,
                                            //             color: Colors
                                            //                 .grey.shade900),
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                            SizedBox(height: 4),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  "assets/hindieng.png",
                                                  color: Colors.black,
                                                  height: 18,
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: ReadMoreText(
                                                    astroDetailDatum?.languages
                                                            ?.join(", ") ??
                                                        'English, Hindi',
                                                    trimLines: 1,
                                                    colorClickableText:
                                                        Colors.blue,
                                                    trimMode: TrimMode.Line,
                                                    trimCollapsedText:
                                                        '...more',
                                                    trimExpandedText: ' less',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade900,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                //Icon(Icons.school_outlined, size: 16, color: Colors.deepPurple),
                                                Image.asset(
                                                  "assets/mortarboard.png",
                                                  color: Colors.black,
                                                ),

                                                SizedBox(width: 8),
                                                Text(
                                                  '${astroDetailDatum?.experience ?? "8"} yrs',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade900),
                                                ),
                                              ],
                                            ),
                                            // Skills (Tags)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  // Chat, Call, Video Rate Section
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Chat Rate
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                            color: CustomStyles.chatActionGreen,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                  "assets/chat-dots-fill.png",
                                                  color: Colors.white,
                                                  height: 20),
                                              const SizedBox(height: 4),
                                              Text("chat".tr,
                                                  style: CustomStyles
                                                      .chatRateCardLabelWhite),
                                              if ((astroDetailDatum
                                                          ?.chatSpecialPrice ??
                                                      0) >
                                                  0)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        "₹${astroDetailDatum?.chatPrice}",
                                                        style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.65),
                                                            fontSize: 11,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                        "₹${astroDetailDatum?.chatSpecialPrice}/min",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                )
                                              else
                                                Text(
                                                    "₹${astroDetailDatum?.chatPrice ?? 0}/min",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Call Rate
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                            color: CustomStyles
                                                .callActionBackground,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              Image.asset("assets/callring.png",
                                                  color: Colors.white,
                                                  height: 20),
                                              const SizedBox(height: 4),
                                              Text("call".tr,
                                                  style: CustomStyles
                                                      .chatRateCardLabelWhite),
                                              if ((astroDetailDatum
                                                          ?.callSpecialPrice ??
                                                      0) >
                                                  0)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        "₹${astroDetailDatum?.callPrice}",
                                                        style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.65),
                                                            fontSize: 11,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                        "₹${astroDetailDatum?.callSpecialPrice}/min",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                )
                                              else
                                                Text(
                                                    "₹${astroDetailDatum?.callPrice ?? 0}/min",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                            color: CustomStyles
                                                .videoActionBackground,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                  "assets/camera-video-fill.png",
                                                  color: Colors.white,
                                                  height: 20),
                                              const SizedBox(height: 4),
                                              Text('video'.tr,
                                                  style: CustomStyles
                                                      .chatRateCardLabelWhite),
                                              if ((astroDetailDatum
                                                          ?.videoSpecialPrice ??
                                                      0) >
                                                  0)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        "₹${astroDetailDatum?.videoPrice}",
                                                        style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.65),
                                                            fontSize: 11,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                        "₹${astroDetailDatum?.videoSpecialPrice}/min",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                )
                                              else
                                                Text(
                                                    "₹${astroDetailDatum?.videoPrice ?? 0}/min",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     // Chat Rate
                                  //     Expanded(
                                  //       child: Container(
                                  //         padding:
                                  //             EdgeInsets.symmetric(vertical: 8),
                                  //         decoration: BoxDecoration(
                                  //           color: Color(0xffB1EAB8),
                                  //           borderRadius:
                                  //               BorderRadius.circular(10),
                                  //         ),
                                  //         child: Column(
                                  //           children: [
                                  //             Image.asset(
                                  //                 "assets/chat-dots-fill.png",
                                  //                 color: Colors.green),
                                  //             // Icon(Icons.chat_bubble_outline, color: Colors.green),
                                  //             SizedBox(height: 4),
                                  //             Text("chat".tr,
                                  //                 style: TextStyle(
                                  //                     fontWeight:
                                  //                         FontWeight.w500,
                                  //                     fontSize: 12)),
                                  //             Text(
                                  //                 "₹${astroDetailDatum?.chatPrice ?? 90}/min",
                                  //                 style: TextStyle(
                                  //                     color: Colors.red,
                                  //                     fontSize: 12,
                                  //                     fontWeight:
                                  //                         FontWeight.bold)),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     SizedBox(width: 10),
                                  //     // Call Rate
                                  //     Expanded(
                                  //       child: Container(
                                  //         padding:
                                  //             EdgeInsets.symmetric(vertical: 8),
                                  //         decoration: BoxDecoration(
                                  //           color: Color(0xffDDD7EA),
                                  //           borderRadius:
                                  //               BorderRadius.circular(10),
                                  //         ),
                                  //         child: Column(
                                  //           children: [
                                  //             Image.asset(
                                  //               "assets/callring.png",
                                  //               color: Colors.purple,
                                  //               height: 20,
                                  //             ),

                                  //             //Icon(Icons.call_outlined, color: Colors.blue),
                                  //             SizedBox(height: 4),
                                  //             Text("call".tr,
                                  //                 style: TextStyle(
                                  //                     fontWeight:
                                  //                         FontWeight.w500,
                                  //                     fontSize: 12)),
                                  //             Text(
                                  //                 "₹${astroDetailDatum?.callPrice ?? 90}/min",
                                  //                 style: TextStyle(
                                  //                     color: Colors.red,
                                  //                     fontSize: 12,
                                  //                     fontWeight:
                                  //                         FontWeight.bold)),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     // SizedBox(width: 10),
                                  //     // // Video Rate
                                  //     // Expanded(
                                  //     //   child: Container(
                                  //     //     padding:
                                  //     //         EdgeInsets.symmetric(vertical: 8),
                                  //     //     decoration: BoxDecoration(
                                  //     //       color: Color(0xffF9A4A6),
                                  //     //       borderRadius:
                                  //     //           BorderRadius.circular(10),
                                  //     //     ),
                                  //     //     child: Column(
                                  //     //       children: [
                                  //     //         // Icon(Icons.videocam_outlined, color: Colors.orange),
                                  //     //         Image.asset(

                                  //   ],
                                  // ),
                                  Divider(height: 20, thickness: 0.5),
                                  // Rating, Wishlist, Share Section
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Rating
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                ...List.generate(5, (index) {
                                                  double rating = double.tryParse(
                                                          astroDetailDatum
                                                                  ?.rating
                                                                  ?.toString() ??
                                                              "0") ??
                                                      0.0;
                                                  return Icon(
                                                    index < rating.floor()
                                                        ? Icons.star
                                                        : index < rating
                                                            ? Icons.star_half
                                                            : Icons.star_border,
                                                    color: Colors.amber,
                                                    size: 18,
                                                  );
                                                }),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              (double.tryParse(astroDetailDatum
                                                              ?.rating
                                                              ?.toString() ??
                                                          "0") ??
                                                      0.0)
                                                  .toStringAsFixed(1),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),

                                        // NOTIFY ME BUTTON - Styled like the screenshot

                                        if (astroDetailDatum?.status !=
                                            'online')
                                          InkWell(
                                            onTap: _isNotifying
                                                ? null
                                                : _handleNotifyMe,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.red,
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                // boxShadow: [
                                                //   BoxShadow(
                                                //     color: Colors.red.shade200,
                                                //     blurRadius: 8,
                                                //     offset: Offset(0, 2),
                                                //   ),
                                                // ],
                                              ),
                                              child: _isNotifying
                                                  ? SizedBox(
                                                      height: 12,
                                                      width: 12,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.pink
                                                                    .shade400),
                                                      ),
                                                    )
                                                  : Row(
                                                      children: [
                                                        const RingingBell(),
                                                        // Icon(
                                                        //   Icons
                                                        //       .notifications_active,
                                                        //   color: Colors.red,
                                                        // ),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          'Notify Me',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            letterSpacing: 0.3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),

                                        // Share
                                        InkWell(
                                          onTap: () {
                                            _showShareOptions();
                                          },
                                          child: Column(
                                            children: [
                                              Icon(Icons.share_outlined,
                                                  color: Colors.deepOrange,
                                                  size: 22),
                                              SizedBox(height: 2),
                                              Text('share'.tr,
                                                  style:
                                                      TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //                           Padding(
                                  // padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  // child: Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     // Rating - ✅ FIXED: Now showing stars with value below
                                  //     Column(
                                  //       children: [
                                  //         Row(
                                  //           children: [
                                  //             ...List.generate(5, (index) {
                                  //               double rating = double.tryParse(astroDetailDatum?.rating?.toString() ?? "0") ?? 0.0;
                                  //               return Icon(
                                  //                 index < rating.floor()
                                  //                     ? Icons.star
                                  //                     : index < rating
                                  //                         ? Icons.star_half
                                  //                         : Icons.star_border,
                                  //                 color: Colors.amber,
                                  //                 size: 18,
                                  //               );
                                  //             }),
                                  //           ],
                                  //         ),
                                  //         SizedBox(height: 4),
                                  //         Text(
                                  //           (double.tryParse(astroDetailDatum?.rating?.toString() ?? "0") ?? 0.0).toStringAsFixed(1),
                                  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     // Wishlist

                                  //     // Share
                                  //     InkWell(
                                  //       onTap: () {
                                  //         // Share profile functionality
                                  //          _showShareOptions();
                                  //       },
                                  //       child: Column(
                                  //         children: [
                                  //           Icon(Icons.share_outlined, color: Colors.blue, size: 22),
                                  //           SizedBox(height: 2),
                                  //           Text('share'.tr, style: TextStyle(fontSize: 11)),
                                  //         ],
                                  //       ),
                                  //                                 ),
                                  //                               ],
                                  //                             ),
                                  //                           ),
                                ],
                              ),
                            ),
                            // =================================================================
                            // ========= NEW UPDATED PROFILE CARD ENDS HERE ====================
                            // =================================================================

                            SizedBox(height: 10),
                            Divider(
                              color: Colors.grey.shade200,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment
                                  .topLeft, // 👈 container ka content top-left me
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // 👈 left align horizontally
                                  mainAxisAlignment: MainAxisAlignment
                                      .start, // 👈 top align vertically
                                  children: [
                                    Container(
                                      // Margin and decoration are copied from the FAQ's item container
                                      margin:
                                          const EdgeInsets.only(bottom: 8.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey.shade200)),
                                      child: ExpansionTile(
                                        // All styling properties are copied from the FAQ's ExpansionTile
                                        backgroundColor: Colors.white,
                                        collapsedBackgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        title: Text(
                                          "Description",
                                          // Using the same text style as the FAQ question for consistency
                                          style: CustomStyles.black14500,
                                        ),
                                        childrenPadding:
                                            const EdgeInsets.all(16)
                                                .copyWith(top: 0),
                                        iconColor: Colors.deepOrange,
                                        collapsedIconColor:
                                            Colors.grey.shade900,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              // The description text, cleaned of HTML tags
                                              HtmlTagsCleaner.clean(
                                                  astroDetailDatum?.about ??
                                                      ''),
                                              // Using the same text style as the FAQ answer
                                              style: CustomStyles.black12500
                                                  .copyWith(height: 1.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),

// +++ THIS IS THE CORRECT LOCATION FOR YOUR REVIEW FORM +++
                            if (canReview)
                              SizedBox(
                                height: 15,
                              ),
                            if (_astrologerReviews.isNotEmpty) ...[
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    // +++ DYNAMIC COUNT +++
                                    // "Rating and Reviews (${_astrologerReviews.length})",
                                    'rating_reviews'.trParams({
                                      'count':
                                          _astrologerReviews.length.toString(),
                                    }),
                                    style: CustomStyles.black14600,
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      // "Only ratings from verified purchases are included in the final evalution.",
                                      'verified_rating_note'.tr,
                                      style: CustomStyles.black12500,
                                    )),
                              ),

                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'customer_review'.tr,
                                  style: CustomStyles.black14600,
                                ),
                              ),

// =================================================================
// ========= UPDATED REVIEW LISTVIEW STARTS HERE ===================
// =================================================================
                              _isReviewsLoading
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  : _astrologerReviews.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20.0),
                                          child: Center(
                                              child: Text("No reviews yet.")),
                                        )
                                      : SizedBox(
                                          // ✅ RESPONSIVE HEIGHT: Uses 24% of the screen's height.
                                          height: screenHeight * 0.15,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                _astrologerReviews.length,
                                            itemBuilder: (context, index) {
                                              final review =
                                                  _astrologerReviews[index];
                                              // ✅ RESPONSIVE WIDTH: Each card uses 80% of the screen's width.
                                              final cardWidth =
                                                  screenWidth * 0.5;

                                              return Container(
                                                width: cardWidth,
                                                margin: const EdgeInsets.only(
                                                    right: 12,
                                                    top: 5,
                                                    bottom: 5),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.1),
                                                      spreadRadius: 1,
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 20,
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    review.userImageUrl ??
                                                                        ""),
                                                            onBackgroundImageError:
                                                                (_, __) {},
                                                            child: review
                                                                        .userImageUrl ==
                                                                    null
                                                                ? Icon(
                                                                    Icons
                                                                        .person,
                                                                    size: 20)
                                                                : null,
                                                          ),
                                                          SizedBox(width: 10),
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
                                                                      .black13600,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                SizedBox(
                                                                    height: 2),
                                                                RatingBarIndicator(
                                                                  rating: review
                                                                      .rating,
                                                                  itemBuilder:
                                                                      (context,
                                                                              _) =>
                                                                          Icon(
                                                                    Icons.star,
                                                                    color: Color(
                                                                        0xffFFAF12),
                                                                  ),
                                                                  itemCount: 5,
                                                                  itemSize: 15,
                                                                  direction: Axis
                                                                      .horizontal,
                                                                ),
                                                                SizedBox(
                                                                    height: 2),
                                                                Text(
                                                                  review.date ??
                                                                      '',
                                                                  style: CustomStyles
                                                                      .black12500,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                      // ✅ SCROLLABLE TEXT AREA: This part ensures that if the text is
                                                      // too long, it will scroll vertically inside the card without
                                                      // causing an overflow error.
                                                      Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                          child: ReadMoreText(
                                                            HtmlTagsCleaner.clean(
                                                                review.review ??
                                                                    ""),
                                                            trimLength: 150,
                                                            trimMode:
                                                                TrimMode.Length,
                                                            trimCollapsedText:
                                                                ' ...more',
                                                            trimExpandedText:
                                                                ' less',
                                                            colorClickableText:
                                                                Colors.blue,
                                                            style: CustomStyles
                                                                .black12500
                                                                .copyWith(
                                                                    height:
                                                                        1.4),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
// =================================================================
// ========= UPDATED REVIEW LISTVIEW ENDS HERE =====================
// =================================================================
                            ],
                            SizedBox(
                              height: 10,
                            ),

                            similarastrologerlist.isEmpty
                                ? SizedBox.shrink()
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        'similar_astrologers'.tr,
                                        style: CustomStyles.black14600,
                                      ),
                                    ),
                                  ),
                            SizedBox(height: 10),
                            similarastrologerlist.isEmpty
                                ? SizedBox.shrink()
                                : SizedBox(
                                    height: 310,
                                    child: ListView.builder(
                                      itemCount: similarastrologerlist.length,
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      itemBuilder: (context, index) {
                                        final cardWidth =
                                            (MediaQuery.of(context).size.width /
                                                    2) -
                                                15;
                                        final astrologer =
                                            similarastrologerlist[index];

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AstrologerDetailScreen(
                                                  slug: astrologer.slug,
                                                  astrologerId: astrologer.id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: cardWidth,
                                            margin: const EdgeInsets.only(
                                                right: 4, bottom: 8, top: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              // 🔹 Shadow + Black border updated
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .shade400, // soft grey shadow
                                                  spreadRadius: 0,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.grey
                                                    .shade400, // 🔹 Black border
                                                width: 1,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // --- Enhanced Image Section with Premium Gradient ---
                                                  Stack(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Image.network(
                                                            astrologer.image ??
                                                                '',
                                                            height: 160,
                                                            width:
                                                                double.infinity,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Container(
                                                              height: 160,
                                                              decoration:
                                                                  BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                  colors: [
                                                                    Colors.blue
                                                                        .shade50,
                                                                    Colors.blue
                                                                        .shade100,
                                                                  ],
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                Icons.person,
                                                                size: 60,
                                                                color: Colors
                                                                    .blue
                                                                    .shade300,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 160,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topCenter,
                                                                end: Alignment
                                                                    .bottomCenter,
                                                                colors: [
                                                                  Colors
                                                                      .transparent,
                                                                  Colors.black
                                                                      .withOpacity(
                                                                          0.03),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        height: 80,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                            colors: [
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0.85),
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0.4),
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                12, 8, 12, 10),
                                                        child: Text(
                                                          astrologer.name ?? '',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 15,
                                                            letterSpacing: 0.3,
                                                            shadows: [
                                                              Shadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.5),
                                                                blurRadius: 8,
                                                                offset: Offset(
                                                                    0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      if (astrologer.blueTick ==
                                                          true)
                                                        Positioned(
                                                          top: 10,
                                                          right: 10,
                                                          child: Icon(
                                                            Icons.verified,
                                                            size: 20,
                                                            color: Colors
                                                                .green.shade600,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              _buildInfoRow(
                                                                'assets/award.png',
                                                                astrologer
                                                                        .services
                                                                        ?.join(
                                                                            ", ") ??
                                                                    '',
                                                                null,
                                                              ),
                                                              SizedBox(
                                                                  height: 8),
                                                              _buildInfoRow(
                                                                'assets/hindieng.png',
                                                                astrologer
                                                                        .languages
                                                                        ?.join(
                                                                            ", ") ??
                                                                    "",
                                                                null,
                                                              ),
                                                              SizedBox(
                                                                  height: 8),
                                                              _buildInfoRow(
                                                                'assets/mortarboard.png',
                                                                "${astrologer.experience ?? ""} Years",
                                                                null,
                                                              ),
                                                              SizedBox(
                                                                  height: 8),
                                                              _buildInfoRow(
                                                                'assets/currency-rupee.png',
                                                                '',
                                                                (astrologer.chatSpecialPrice ??
                                                                            0) >
                                                                        0
                                                                    ? Row(
                                                                        children: [
                                                                          Text(
                                                                            "₹${astrologer.chatPrice}",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 11,
                                                                              color: Colors.grey.shade600,
                                                                              decoration: TextDecoration.lineThrough,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 4),
                                                                          Text(
                                                                            "₹${astrologer.chatSpecialPrice}/min",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.red.shade700,
                                                                              fontWeight: FontWeight.w700,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Text(
                                                                        "₹${astrologer.chatPrice}/min",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color: Colors
                                                                              .red
                                                                              .shade700,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                      ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

// ... rest of your code in the build method
                            if (videoTestimonials.isNotEmpty)
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 15.0),
                              //  // child: _buildVideoTestimonialsSection(),
                              // ),
                              //     if (textTestimonials.isNotEmpty)
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 15.0),
                              // //  child: _buildTextTestimonialsSection(),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: _buildFaqSection(),
                              ),
                            SizedBox(
                              height: 80,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isloading && astroDetailDatum == null
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Builder(builder: (context) {
                  final status = (astroDetailDatum?.status ?? '').toString();
                  final bool isOffline = status == 'offline';
                  final bool isBusy = status == 'busy';
                  final chatStatus =
                      (astroDetailDatum?.chatStatus ?? '').toString();
                  final callStatus =
                      (astroDetailDatum?.callStatus ?? '').toString();
                  final videoStatus =
                      (astroDetailDatum?.videoStatus ?? '').toString();

                  bool _isSvcDisabled(String svc) {
                    if (isOffline || isBusy) return true;
                    final s = svc.toLowerCase();
                    return s == 'offline' || s == 'busy';
                  }

                  final bool chatDisabled = _isSvcDisabled(chatStatus);
                  final bool callDisabled = _isSvcDisabled(callStatus);
                  final bool videoDisabled = _isSvcDisabled(videoStatus);
                  final Color disableColor = Colors.grey.shade200;
                  final TextStyle textStyleBase = CustomStyles.black12500;
                  final TextStyle disabledTextStyle =
                      textStyleBase.copyWith(color: Colors.grey.shade400);
                  final TextStyle textStyle = (chatDisabled && callDisabled && videoDisabled)
                      ? CustomStyles.black12500
                          .copyWith(color: Colors.grey.shade400)
                      : CustomStyles.black12500;

                  final Color offlineContentColor = Colors.grey.shade600;
                  final Color chatOnlineContentColor = Colors.white;
                  final Color callOnlineContentColor = Colors.white;

                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: chatDisabled
                              ? null
                              : () => {
                                    // <-- UPDATED with login check
                                    _handleConsultationRequest("chat")
                                  },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: chatDisabled
                                      ? Colors.grey
                                      : CustomStyles.chatActionGreen),
                              color: chatDisabled
                                  ? disableColor
                                  : CustomStyles.chatActionGreen,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/chat-dots-fill.png',
                                  height: 20,
                                  color: chatDisabled
                                      ? offlineContentColor
                                      : chatOnlineContentColor,
                                ),
                                SizedBox(width: 4),
                                Text('Chat',
                                    style: chatDisabled
                                        ? disabledTextStyle
                                        : CustomStyles.white12500),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: callDisabled
                              ? null
                              : () async {
                                  // <-- UPDATED with login check
                                  _handleConsultationRequest("call");
                                },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: callDisabled
                                      ? Colors.grey
                                      : CustomStyles.callActionBackground),
                              color: callDisabled
                                  ? disableColor
                                  : CustomStyles.callActionBackground,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/callring.png',
                                  height: 20,
                                  color: callDisabled
                                      ? offlineContentColor
                                      : callOnlineContentColor,
                                ),
                                SizedBox(width: 4),
                                Text('Call',
                                    style: callDisabled
                                        ? disabledTextStyle
                                        : CustomStyles.white12500),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: videoDisabled
                              ? null
                              : () => {
                                    // <-- UPDATED with login check
                                    _handleConsultationRequest("video")
                                  },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: videoDisabled
                                      ? Colors.grey
                                      : CustomStyles.videoActionBackground),
                              color: videoDisabled
                                  ? disableColor
                                  : CustomStyles.videoActionBackground,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/camera-video-fill.png",
                                  height: 20,
                                  color: videoDisabled
                                      ? offlineContentColor
                                      : Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text('Video',
                                    style: videoDisabled
                                        ? disabledTextStyle
                                        : CustomStyles.white12500),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
      ),
    );
  }

  void showConnectingPopup() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/logo.png", scale: 4),
                SizedBox(height: 6),
                Text("AstroKavach", style: CustomStyles.black25600),
                SizedBox(height: 15),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Text(
                    "We will connect your chat to the Astrologer",
                    style: CustomStyles.black13600,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/user.png", width: 50),
                          SizedBox(height: 6),
                          Text(
                            "Rohit Aggarwal",
                            style: CustomStyles.black13600,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: GFLoader(
                        loaderColorOne: CustomStyles.bgcolor,
                        loaderColorTwo: CustomStyles.bgredcolor,
                        loaderColorThree: CustomStyles.bgcolor,
                        size: 40,
                        type: GFLoaderType.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/astro.png", width: 50),
                          SizedBox(height: 6),
                          Text(
                            "Astro Aman Sharma",
                            style: CustomStyles.black13600,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    Future.delayed(Duration(seconds: 3), () {
      Get.back();
      Get.to(() => ChatScreen());
    });
  }

  InputDecoration _inputDecoration(String hint, {IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      //  labelText: hint,
      labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: Colors.grey[600])
          : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blueGrey)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildInfoRow(String iconPath, String text, Widget? priceWidget) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          color: Colors.black,
          height: 14,
          width: 14,
        ),
        SizedBox(width: 8),
        Expanded(
          child: priceWidget ??
              Text(
                text,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
        ),
      ],
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
        ],
      ),
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

  Widget _buildVideoTestimonialsSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Text(
            videoTestimonialsHeading ?? "Video Testimonials",
            style: CustomStyles.white12500,
          ),
        ),
        Container(
          height: screenHeight * 0.22, // You can adjust the height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videoTestimonials.length,
            itemBuilder: (context, index) {
              final video = videoTestimonials[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoPlayerScreen(videoId: video.videoId, title: video.title),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.7,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.network(
                                video.thumbnail,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.video_library_outlined,
                                    size: 40,
                                    color: Colors.grey),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 50),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          video.title,
                          style: CustomStyles.black13600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFaqSection() {
    if (_isFaqsLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (faqItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
          child: Text(
            faqHeading ?? "Frequently Asked Questions",
            style: CustomStyles.black16600,
          ),
        ),
        if (faqSubHeading != null && faqSubHeading!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            child: Text(
              faqSubHeading!,
              style: CustomStyles.grey12400,
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqItems.length,
          itemBuilder: (context, index) {
            final faq = faqItems[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ExpansionTile(
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                title: Text(
                  faq.question,
                  style: CustomStyles.black14500,
                ),
                childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
                iconColor: Colors.deepOrange,
                collapsedIconColor: Colors.grey.shade900,
                //
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      HtmlTagsCleaner.clean(faq.answer),
                      style: CustomStyles.black12500.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

// In AstrologerDetailScreen -> _AstrologerDetailScreenState class

// REPLACE your old widget with this one
// In AstrologerDetailScreen -> _AstrologerDetailScreenState class

// REPLACE your old text testimonial widget with this one
  Widget _buildTextTestimonialsSection() {
    // <-- CHANGE 1: REMOVED parameters
    // GET acreen size inside the widget
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Text(
            textTestimonialsHeading ?? "Testimonials",
            style: CustomStyles.black14600,
          ),
        ),
        Container(
          height: screenHeight * 0.18, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: textTestimonials.length,
            itemBuilder: (context, index) {
              final testimonial = textTestimonials[index];
              return Container(
                width: screenWidth * 0.85, // Adjust width of the card
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -10,
                      left: -5,
                      child: Text(
                        '“',
                        style: TextStyle(
                          fontSize: 80,
                          color: Colors.grey.shade100,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 8.0),
                              child: Text(
                                HtmlTagsCleaner.clean(testimonial.description),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "- ${testimonial.title}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRateButton({
    required String assetPath,
// String label,
    required dynamic originalPrice,
    required dynamic specialPrice,
    required Color color, // Color for border and background tint
  }) {
    bool hasSpecialPrice =
        specialPrice != null && specialPrice is num && specialPrice > 0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // Light background tint
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color), // Border with the main color
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetPath, height: 28, width: 28),
          SizedBox(height: 4),
          //Text(label, style: CustomStyles.black13600.copyWith(fontSize: 12)),
          SizedBox(height: 2),
          // --- THIS IS THE RESTORED PRICE LOGIC ---
          if (hasSpecialPrice)
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "₹${originalPrice ?? ''}",
                    style: CustomStyles.grey12400.copyWith(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 11,
                    ),
                  ),
                  TextSpan(
                    text: " ₹${specialPrice}/min",
                    style: CustomStyles.red13500.copyWith(fontSize: 12),
                  ),
                ],
              ),
            )
          else
            Text(
              "₹${originalPrice ?? ''}/min",
              style: CustomStyles.red13500.copyWith(fontSize: 12),
            ),
        ],
      ),
    );
  }

// Add these methods inside your _AstrologerDetailScreenState class

  String _getShareText() {
    if (astroDetailDatum == null) return "";
    final String profileUrl =
        "${CustomStyles.webBaseUrl}/astrologers/Astrologer/${astroDetailDatum!.slug}";
    return "${astroDetailDatum!.name}\n$profileUrl";
  }

  void _showShareOptions() {
    final String text = _getShareText();
    if (text.isEmpty) return;
    Share.share(text);
  }

  void showmodelbottamsheet(BuildContext context, String modetype) {
    final _formKey = GlobalKey<FormState>();
    final double scrollControlDisabledMaxHeightRatio = 0.85;

    // Reset dropdown selections when opening the sheet
    selectedMaritalStatus = null;
    selectedOccupation = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            initialChildSize: scrollControlDisabledMaxHeightRatio,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return StatefulBuilder(builder: (BuildContext context, setState) {
                return Form(
                  key: _formKey,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                                'Book Consultation for ${modetype[0].toUpperCase()}${modetype.substring(1)}',
                                style: CustomStyles.black16600),
                          ),
                          SizedBox(height: 20),
                          CustomTextField(
                            starsign: "*",
                            title: "Name",
                            label: "Enter Name",
                            controller: namecontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name is Required';
                              }
                              return null;
                            },
                          ),
                          Text('Birth Date', style: CustomStyles.black14500),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: _birthDateController,
                            readOnly: true,
                            decoration: _inputDecoration("Select Birth Date"),
                            style: TextStyle(fontSize: 12),
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
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                                setState(() {
                                  _birthDateController.text = formattedDate;
                                });
                              }
                            },
                            validator: (v) =>
                                v!.isEmpty ? 'Birth Date is required' : null,
                          ),
                          SizedBox(height: 12),
                          Text('Birth Time', style: CustomStyles.black14500),
                          SizedBox(height: 2),
                          TextFormField(
                            controller: _birthTimeController,
                            readOnly: true,
                            decoration: _inputDecoration(
                              "Select Birth Time",
                            ),
                            style: TextStyle(fontSize: 12),
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
                                final now = DateTime.now();

                                if (_birthDateController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Please select a birth date first.")),
                                  );
                                  return;
                                }

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
                                        toastLength: Toast.LENGTH_LONG, //
                                        gravity: ToastGravity.TOP, //
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(
                                    //     content: Text("You cannot select a future time for today's date."),
                                    //     backgroundColor: Colors.red,
                                    //   ),
                                    // );
                                    return;
                                  }
                                }

                                setState(() {
                                  _birthTimeController.text =
                                      pickedTime.format(context);
                                });
                              }
                            },
                            validator: (v) =>
                                v!.isEmpty ? 'Birth Time is required' : null,
                          ),
                          Text('Birth Place', style: CustomStyles.black14500),
                          SizedBox(height: 5),
                          Column(
                            children: [
                              TextFormField(
                                controller: _birthPlaceController,
                                decoration:
                                    _inputDecoration("Type to search location",
                                        suffixIcon: Icons.location_on),
                                style: TextStyle(fontSize: 12),
                                onChanged: (value) {
                                  _searchLocation(value, setState);
                                },
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
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'Gender',
                                    style: CustomStyles.black14500,
                                  )
                                ],
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _selectedGender = 1;
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: Radio<int>(
                                        activeColor: Colors.grey,
                                        value: 1,
                                        groupValue: _selectedGender,
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedGender = val!;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Male'),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _selectedGender = 2;
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: Radio(
                                        activeColor: Colors.grey,

                                        //activeColor: CustomStyles.bgcolor,
                                        value: 2,
                                        groupValue: _selectedGender,
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedGender = val as int;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Female'),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _selectedGender = 3;
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: Radio(
                                        activeColor: Colors.grey,

                                        // activeColor: CustomStyles.bgcolor,
                                        value: 3,
                                        groupValue: _selectedGender,
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedGender = val as int;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Other'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text('Marital Status',
                              style: CustomStyles.black14500),
                          SizedBox(height: 5),
                          DropdownButtonFormField<String>(
                            value: selectedMaritalStatus,
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: "Select Marital Status",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                // borderSide: BorderSide(
                                //     color: Theme.of(context).primaryColor),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            items:
                                maritalStatusMap.keys.map((String displayText) {
                              return DropdownMenuItem<String>(
                                value: displayText,
                                child: Text(displayText),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedMaritalStatus = value;
                              });
                            },
                          ),
                          SizedBox(height: 12),
                          Text('Occupation', style: CustomStyles.black14500),
                          SizedBox(height: 5),
                          DropdownButtonFormField<String>(
                            value: selectedOccupation,
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: "Select Occupation",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                // borderSide: BorderSide(
                                //     color: Theme.of(context).primaryColor),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            items: occupationMap.keys.map((String displayText) {
                              return DropdownMenuItem<String>(
                                value: displayText,
                                child: Text(displayText),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedOccupation = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          _isBottomSheetLoading
                              ? Center(child: CircularProgressIndicator())
                              : Center(
                                  child: CustomElevatedButton(
                                      text:
                                          "Proceed ${modetype[0].toUpperCase()}${modetype.substring(1)}",
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            _isBottomSheetLoading = true;
                                          });

                                          var response =
                                              await consultationApiService
                                                  .callapidata(
                                            context: context,
                                            token: apiToken,
                                            id: astroDetailDatum?.id,
                                            mode: modetype,
                                            when: "now",
                                            timeSlot: selectedtime,
                                            name: namecontroller.text,
                                            scheduledDate:
                                                selectedIndex == "now"
                                                    ? ""
                                                    : formattedavailaibledate,
                                            scheduledTimeSlot:
                                                selectedIndex == "later"
                                                    ? selectedslot.toString()
                                                    : "",
                                            gender: _selectedGender,
                                            occupation: occupationMap[
                                                    selectedOccupation] ??
                                                "",
                                            maritalstatus: maritalStatusMap[
                                                    selectedMaritalStatus] ??
                                                "",
                                            birthDate:
                                                _birthDateController.text,
                                            birthTime:
                                                _birthTimeController.text,
                                            birthPlace:
                                                _birthPlaceController.text,
                                          );
                                          if (response != null &&
                                              response["success"] == true) {
                                            Navigator.pop(context);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text('')));
                                          }
                                          // Note: You probably want to set this to false, not true
                                          if (mounted) {
                                            setState(() {
                                              _isBottomSheetLoading = false;
                                            });
                                          }
                                        }
                                      }),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            });
      },
    );
  }
}

class RingingBell extends StatefulWidget {
  const RingingBell({Key? key}) : super(key: key);

  @override
  State<RingingBell> createState() => _RingingBellState();
}

class _RingingBellState extends State<RingingBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200), // Speed of ringing
      vsync: this,
    )..repeat(reverse: true); // Loop animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: -0.05, end: 0.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: const Icon(
        Icons.notifications_active,
        color: Colors.red,
        size: 20, // Icon size adjust karein
      ),
    );
  }
}
