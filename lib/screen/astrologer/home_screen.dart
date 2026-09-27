import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:astrokavach/Services/get_service_key.dart';
import 'package:astrokavach/Services/notifationmodel.dart';
import 'package:astrokavach/api/astro_listing_api.dart';
import 'package:astrokavach/api/auth_api/banner_api.dart';
import 'package:astrokavach/api/blog_api/blog_list_api.dart';
import 'package:astrokavach/api/dashboard/search_delegates.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/api/notificationfile.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_list_api.dart';
import 'package:astrokavach/api/product_api/product_category_api.dart';
import 'package:astrokavach/api/product_api/product_list_api.dart';
import 'package:astrokavach/api/youtubeapi/youtubeapi.dart';
import 'package:astrokavach/api/youtubereview/youtubereview.dart';
import 'package:astrokavach/controller/astrologer_controller/home_controller.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/livestatuswiget.dart';
import 'package:astrokavach/custom_widgets/offline_banner.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/AIastrologermodel/aiastrologer.dart';
import 'package:astrokavach/model/Gemstonemodel.dart';
import 'package:astrokavach/model/Livemodelstream/livemodelstream.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cartlistmodel.dart';
import 'package:astrokavach/model/Product_Api_Model/product_category_api_model.dart';
import 'package:astrokavach/model/Product_Api_Model/product_list_api_model.dart';
import 'package:astrokavach/model/astrologer/astro_list_model.dart';
import 'package:astrokavach/model/banner_api_model.dart';
import 'package:astrokavach/model/blog_model/blog_list_model.dart';
import 'package:astrokavach/model/offerpayemet.dart/Kundalimatchingsd.dart';
import 'package:astrokavach/model/rudramodel.dart';
import 'package:astrokavach/model/services/services.dart';
import 'package:astrokavach/model/videoyoutube/videoyoutube.dart';
import 'package:astrokavach/model/youtubereview/youtubereview.dart';
import 'package:astrokavach/screen/AiAstrologer.dart';
import 'package:astrokavach/screen/Ai_astrologer_list.dart';
import 'package:astrokavach/screen/Comingsoon.dart';
import 'package:astrokavach/screen/Countdown/Servicecount.dart';
import 'package:astrokavach/screen/Countdown/poojacount.dart';
import 'package:astrokavach/screen/astrologer/astrologer_detail_screen.dart';
import 'package:astrokavach/screen/astrologer/astrologer_list_screen.dart';
import 'package:astrokavach/screen/astrologer/consultation/astrologerclass.dart';
import 'package:astrokavach/screen/astrologer/consultation/blinkingscreen.dart';
import 'package:astrokavach/screen/astrologer/kundliscreen.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/blog/blog_detail_screen.dart';
import 'package:astrokavach/screen/blog/bloglist_screen.dart';
import 'package:astrokavach/screen/bookpooja/astroservicescreen.dart';
import 'package:astrokavach/screen/bookpooja/pooja_list_screen.dart';
import 'package:astrokavach/screen/custom_dart.dart';
import 'package:astrokavach/screen/gemstonepart.dart';
import 'package:astrokavach/screen/hellocahat.dart';
import 'package:astrokavach/screen/horsescope/horsescope.dart';
import 'package:astrokavach/screen/live_page.dart';
import 'package:astrokavach/screen/livestreamscreen.dart';
import 'package:astrokavach/screen/notificationscreen.dart';
import 'package:astrokavach/screen/panchang1/panchangscreen.dart';
import 'package:astrokavach/screen/product/cart_screen.dart';
import 'package:astrokavach/screen/product/product_category_screen.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';
import 'package:astrokavach/screen/product/product_list_screen.dart';
import 'package:astrokavach/screen/rudrascreenlist.dart';
import 'package:astrokavach/screen/supportscreen.dart';
import 'package:astrokavach/screen/wallet/wallet_screen.dart' show WalletScreen;
import 'package:astrokavach/screen/walletupdate.dart';
import 'package:astrokavach/screen/youtubevideo/blinkingliveindicator.dart';
import 'package:astrokavach/screen/youtubevideo/youtubevideo.dart';
import 'package:astrokavach/utils/network_connectivity.dart';
import 'package:astrokavach/screen/astrologer/widgets/home_banner_section.dart';
import 'package:astrokavach/screen/astrologer/widgets/home_live_astrologer_section.dart';
import 'package:astrokavach/screen/astrologer/widgets/home_ai_astrologer_section.dart';
import 'package:astrokavach/screen/astrologer/widgets/home_astro_mall_section.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:astrokavach/core/providers/bottom_nav_provider.dart';
import 'package:html_tags_cleaner/html_tags_cleaner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Please wait...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomStyles.bgcolor),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ReusableFunction reusableFunction = ReusableFunction();
  Map<String, dynamic>? user;
  dynamic walletamount;
  bool isloading = false;
  String? phone;
  String? apiToken;

  bool _isDataLoaded = false;
  int notificationCount = 0; // <--- NEW VARIABLE FOR COUNT

  late StreamSubscription<Map<String, dynamic>> _walletSubscription;
  Timer? _refreshTimer;
  List<AstrologerService> astrologerServices = [];

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// [Scrollbar.thumbVisibility] ke liye horizontal scroll par controller zaroori hai.
  final ScrollController _quickServicesHScrollController = ScrollController();
  final controller = Get.put(HomeController());
  AstrologerApiService astrologerApiService = AstrologerApiService();
  AstrologerListModel? astrologerListModel;
  List<AstroDataList> astrologerlist = [];
  List<ProductCategoryDatum> productcategorylist = [];
  List<ProductCategoryDatum> productServicelist = [];
  ProductCategoryModel? productcategorymodel;
  ProductCategoryApiService productcategoryapiservice =
      ProductCategoryApiService();
  ProducListApiService poojaListApiService = ProducListApiService();
  ProductListApiModel? poojalistmodel;
  ProductListApiModel? servicemodel;
  List<ProductListsDatum> servicelist = [];
  List<ProductListsDatum> poojalist = [];
  List<BannerDatum> bannerlist = [];
  BannerApiModel? bannerApiModel;
  BannerApiService bannerApiService = BannerApiService();
  CartListApiService cartListApiService = CartListApiService();
  CartListModel? cartListModel;
  List<CartListingDatum> cartlist = [];
  String? quantity;
  BlogListApi blogListApi = BlogListApi();
  BlogListModel? blogListModel;
  List<BlogList> bloglist = [];
  List<LiveAstrologer> liveAstrologerList = [];
  bool isJoiningLive = false;
  List<AiAstrologer> aiAstrologerList = [];
  //add new youtube
  List<VideoItem> videoTestimonials = [];
  // ADD THIS NEW VARIABLE
  String? videoTestimonialsHeading;

  // ADD THESE TWO NEW VARIABLES
  List<TestimonialItem> textTestimonials = [];
  String? textTestimonialsHeading;

  bool isNetworkError = false;
  Timer? _connectivityTimer;
  VoidCallback? _refreshAfterLoginListener;

  @override
  void initState() {
    super.initState();
    gettoken();
    fetchUserData();
    getalldata();

    _setupWalletListener();
    _checkNetworkConnectivity();
    setupNetworkListener();

    _refreshAfterLoginListener = () {
      _reloadUserAfterLoginSilently();
    };
    refreshHomeAfterLoginNotifier.addListener(_refreshAfterLoginListener!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalChatService.showFloatingChatButton(context);
    });
  }

  void _onDrawerTap() {
    scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _reloadUserAfterLoginSilently() async {
    await gettoken();
    Map<String, dynamic>? data = await reusableFunction.getUserDataFromPrefs();
    if (data == null &&
        apiToken != null &&
        apiToken!.isNotEmpty &&
        apiToken!.length > 12) {
      data = await reusableFunction.getUserData();
    }
    if (!mounted) return;
    setState(() {
      if (data != null) {
        user = data;
        walletamount = data["wallet"] ?? 0;
      }
    });
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
    setState(() {
      isNetworkError = !ok;
    });
  }

  @override
  void dispose() {
    if (_refreshAfterLoginListener != null) {
      refreshHomeAfterLoginNotifier.removeListener(_refreshAfterLoginListener!);
    }
    _walletSubscription.cancel();
    _refreshTimer?.cancel();
    _connectivityTimer?.cancel();
    _quickServicesHScrollController.dispose();
    super.dispose();
  }

  void _setupWalletListener() {
    _walletSubscription = WalletEventBus().walletStream.listen((userData) {
      if (mounted) {
        setState(() {
          user = userData;
          walletamount = userData["wallet"] ?? 0;
        });
        print(
            "✅ HomeScreen received wallet update via EventBus: ${walletamount}");
      }
    });
  }

  Future<void> _refreshWalletSilently() async {
    try {
      if (apiToken != null && apiToken!.length > 12) {
        final serverData = await reusableFunction.getUserData();
        if (serverData != null && mounted) {
          final newWallet = serverData["wallet"];
          if (walletamount != newWallet) {
            setState(() {
              user = serverData;
              walletamount = newWallet;
            });
            print(
                "🔄 Wallet auto-refreshed silently: $walletamount -> $newWallet");
          }
        }
      }
    } catch (e) {
      print("Silent wallet refresh error: $e");
    }
  }

  String generateRandomNumberString(int length) {
    const digits = '0123456789';
    Random random = Random();
    String randomString = '';
    for (int i = 0; i < length; i++) {
      randomString += digits[random.nextInt(digits.length)];
    }
    return randomString;
  }

  Future<void> gettoken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');
    phone = prefs.getString('phone');
    if (apiToken == null || apiToken!.isEmpty) {
      apiToken = generateRandomNumberString(12);
      await prefs.setString('api_token', apiToken!);
    }
  }

  Future<void> fetchUserData() async {
    setState(() {
      isloading = true;
    });
    Map<String, dynamic>? data = await reusableFunction.getUserDataFromPrefs();
    if (data != null) {
      setState(() {
        user = data;
        walletamount = user?["wallet"] ?? 0;
        isloading = false;
      });
    } else {
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> getalldata() async {
    if (_isDataLoaded) return;
    if (!mounted) return;

    setState(() {
      isloading = true;
    });
    await gettoken();
    if (!mounted) return;

    try {
      final parallelMain = await Future.wait([
        // Banner is now handled individually by Riverpod in HomeBannerSection
        Future.value(null), // Placeholder to keep array index intact
        astrologerApiService.fetchAstrologers(
            "", "", '', [], [], [], [], [], [], '', 1,
            sortBy: ''),
        Future.value(null) /* Handled by Riverpod */,
        productcategoryapiservice.fetchproductcategory(type: "service"),
        poojaListApiService.fetchproductlistapidata(
            0, "service", "a_to_z", "", "", 0, 0),
        poojaListApiService.fetchproductlistapidata(
            0, "pooja", "a_to_z", "", "", 0, 0),
        AstroApiService.fetchLiveAstrologers(),
        AstroApiService.fetchAiAstrologers(),
        AstroApiService.fetchAstrologerServices(),
        blogListApi.fetchBolgApidata(0, 0, 0, 0),
        cartListApiService.getCartlistapi(apiToken, 0),
      ]);

      bannerApiModel = parallelMain[0] as BannerApiModel?;
      astrologerListModel = parallelMain[1] as AstrologerListModel?;
      productcategorymodel = parallelMain[2] as ProductCategoryModel?;
      final poojaCategoryModel = parallelMain[3] as ProductCategoryModel?;
      servicemodel = parallelMain[4] as ProductListApiModel?;
      poojalistmodel = parallelMain[5] as ProductListApiModel?;
      liveAstrologerList = (parallelMain[6] as List<LiveAstrologer>?) ?? [];
      aiAstrologerList = (parallelMain[7] as List<AiAstrologer>?) ?? [];
      astrologerServices = (parallelMain[8] as List<AstrologerService>?) ?? [];
      blogListModel = parallelMain[9] as BlogListModel;
      cartListModel = parallelMain[10] as CartListModel?;

      if (mounted) {
        setState(() {
          bannerlist = bannerApiModel?.data ?? [];
          astrologerlist = astrologerListModel?.data?.list ?? [];
          productcategorylist = productcategorymodel?.data ?? [];
          productServicelist = poojaCategoryModel?.data ?? [];
          servicelist = servicemodel?.data?.products ?? [];
          poojalist = poojalistmodel?.data?.products ?? [];
          bloglist = blogListModel?.data?.list ?? [];
          cartlist = cartListModel?.data ?? [];
          quantity = cartListModel?.totalQuantity?.toString() ?? '0';
        });
      }

      if (aiAstrologerList.isNotEmpty) {
        AiAstrologer? activeAstrologer;
        try {
          activeAstrologer = aiAstrologerList.firstWhere((astro) =>
              astro.consultation != null && astro.consultation!.id != 0);
        } catch (e) {
          activeAstrologer = null;
        }

        if (activeAstrologer != null) {
          GlobalChatService.showFloatingChatButton(context,
              astrologer: activeAstrologer);
        } else {
          GlobalChatService.hideFloatingChatButton();
        }
      }

      await Future.wait([
        Future(() async {
          try {
            final videoResponse =
                await VideoTestimonialService.fetchVideoTestimonials();
            if (mounted && videoResponse.success) {
              setState(() {
                videoTestimonials = videoResponse.data.data;
                videoTestimonialsHeading = videoResponse.data.heading;
              });
            }
          } catch (e) {
            print("Error fetching video testimonials: $e");
          }
        }),
        Future(() async {
          try {
            final textResponse =
                await TextTestimonialService.fetchTextTestimonials();
            if (mounted && textResponse.success) {
              setState(() {
                textTestimonials = textResponse.data.data;
                textTestimonialsHeading = textResponse.data.heading;
              });
            }
          } catch (e) {
            print("Error fetching text testimonials: $e");
          }
        }),
        Future(() async {
          try {
            NotificationResponse? notifyResponse =
                await NotificationApiService.fetchNotifications(page: 1);
            if (mounted &&
                notifyResponse != null &&
                notifyResponse.data != null) {
              setState(() {
                notificationCount = notifyResponse.data!.count;
              });
            }
          } catch (e) {
            print("Notification fetch error: $e");
          }
        }),
      ]);

      _isDataLoaded = true;
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  final List<Astrologer> astrologerlist1 = [
    Astrologer(
        name: "Amit Sharma",
        image: 'https://randomuser.me/api/portraits/men/1.jpg',
        rating: 4.9,
        originalPrice: 15,
        discountedPrice: 10),
    Astrologer(
        name: "Sunita Sharma",
        image: 'https://randomuser.me/api/portraits/men/1.jpg',
        rating: 4.9,
        originalPrice: 15,
        discountedPrice: 10),
    Astrologer(
        name: "Ram Sharma",
        image: 'https://randomuser.me/api/portraits/men/1.jpg',
        rating: 4.9,
        originalPrice: 15,
        discountedPrice: 10)
  ];
//  var kundliList = [
//     KundliItem(name:'panchang'.tr + '\n', iconPath: "assets/Panchang-1.png",color: Color(0xFF7EE48C)),

//     KundliItem(name:'horoscope'.tr+ '\n', iconPath: "assets/hari.png",color: Color(0xFFAF9AE1)),
//     KundliItem(name:'kundli'.tr +'\n', iconPath: "assets/akash12.png",color: Color(0XFF5AB8E6)),
//     KundliItem(name:'matching'.tr +'\n', iconPath: "assets/matchmaking.png",color:Colors.redAccent),

//     //KundliItem(name: "Panchang\n", iconPath: "assets/Panchang.png",color: Color(0xFF7EE48C)),
//     KundliItem(name: 'festival'.tr+'\n', iconPath: "assets/festi12.png",color: Color(0xFFF5D76B)),
//   ];

  void retryConnection() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        });

    try {
      final ok = await checkDeviceHasInternet();
      if (!mounted) return;
      if (ok) {
        setState(() {
          isNetworkError = false;
          _isDataLoaded = false;
        });
        await getalldata();

        Fluttertoast.showToast(
            msg: 'Connection restored!', backgroundColor: Colors.green);
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Network connection still unavailable. Please try again.',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Network connection still unavailable. Please try again.',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isNetworkError && !_isDataLoaded) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.signal_wifi_off_rounded,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                'Network Connection Issue',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: retryConnection,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SafeArea(
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.white,
            onDrawerChanged: (isOpened) {
ref.read(bottomNavProvider.notifier).setDrawerOpen(isOpened);
              if (isOpened) {
                GlobalChatService.hideFloatingChatButton();
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  GlobalChatService.showFloatingChatButton(context);
                });
              }
            },
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: user != null &&
                      user!['image'] != null &&
                      user!['image'].isNotEmpty
                  ? GestureDetector(
                      onTap: _onDrawerTap,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(user!['image']),
                                fit: BoxFit.fill),
                            border: Border.all(
                                color: Colors.grey.shade400, width: 2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2))
                            ],
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _onDrawerTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2))
                            ],
                          ),
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                      ),
                    ),
              title: Text(
                "Hi, ${user?['name'] ?? 'Welcome Guest!'}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    if (apiToken == null ||
                        apiToken!.isEmpty ||
                        apiToken!.length == 12) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WalletScreen()));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded,
                            size: 18, color: CustomStyles.darkgreen),
                        SizedBox(width: 2),
                        Text(
                          walletamount == null
                              ? ""
                              : "  ₹ ${walletamount.toString()}",
                          style: TextStyle(
                              color: CustomStyles.darkgreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.add_circle,
                            size: 18, color: CustomStyles.darkgreen)
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 0),
                GestureDetector(
                  onTap: () async {
                    // Open Notification Screen
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationListScreen()),
                    );

                    // Optional: List dekhne ke baad count refresh karne ke liye dobara call kar sakte hain
                    // getalldata();
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.notification_important_outlined,
                          color: CustomStyles.ctaColor, size: 28),

                      // Show Badge only if count is greater than 0
                      if (notificationCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 0),
                PopupMenuButton<String>(
                  color: Colors.white, // Popup background color
                  elevation: 4, // Adds slight shadow for depth
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  onSelected: (String locale) {
                    if (locale == 'en') {
                      Get.updateLocale(const Locale('en', 'US'));
                    } else if (locale == 'hi') {
                      Get.updateLocale(const Locale('hi', 'IN'));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Image.asset(
                      "assets/translate.png",
                      height: 30,
                    ),
                  ),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'en',
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/uk.png", // <-- Yahan apni image ka path lagao
                              height: 30,
                              width: 30,
                            ),
                          ),
                          // const Icon(Icons.language), // Add a small language icon
                          //  const SizedBox(width: 8),
                          Text(
                            'English', // Now plain English text
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'hi',
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/india.png", // <-- Yahan apni image ka path lagao
                              height: 30,
                              width: 30,
                            ),
                          ),
                          //const Icon(Icons.translate), // Different icon for Hindi
                          // const SizedBox(width: 14),
                          Text(
                            'हिंदी', // Hindi label
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
              // AppBar ke andar search bar add kiya
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: GestureDetector(
                    onTap: () {
                      showSearch(
                        context: context,
                        delegate: AppSearchDelegate(),
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'search'.tr,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.search, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            drawer: CustomDrawer(
              user: user,
              apiToken: apiToken,
              onUserDataUpdate: (Map<String, dynamic> newUserData) {
                setState(() {
                  user = newUserData;
                });
              },
            ),

            body: SafeArea(
              child: isloading
                  ? const CustomLoadingWidget()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildQuickServicesSection(),
                          SizedBox(height: 10),
                          const HomeBannerSection(),
                          //SizedBox(height: 16),
                          //_buildastroconsult(),

                          SizedBox(height: 10),
                          HomeLiveAstrologerSection(screenWidth: screenWidth, screenHeight: screenHeight),
                          SizedBox(height: 6),
                          HomeAiAstrologerSection(screenWidth: screenWidth, screenHeight: screenHeight),
                          SizedBox(height: 6),
                          ,

                          HomeAstroMallSection(screenWidth: screenWidth, screenHeight: screenHeight),
                          SizedBox(height: 6),
                          if (poojalist.isNotEmpty) ...[
                            _buildCardWrapper(
                                child: _buildBookPoojaSection(
                                    screenWidth, screenHeight)),
                            SizedBox(height: 6),
                          ],
                          if (servicelist.isNotEmpty) ...[
                            _buildCardWrapper(
                                child: _buildBookPoojaService(
                                    screenWidth, screenHeight)),
                            SizedBox(height: 6)
                          ],

                          if (bloglist.isNotEmpty) ...[
                            _buildCardWrapper(
                                child: _buildLatestBlogSection(
                                    screenWidth, screenHeight)),
                            SizedBox(height: 6),
                          ],

                          // ADD THE NEW VIDEO TESTIMONIALS SECTION HERE
                          if (videoTestimonials.isNotEmpty) ...[
                            _buildCardWrapper(
                                child: _buildVideoTestimonialsSection(
                                    screenWidth, screenHeight)),
                            SizedBox(height: 6),
                          ],
                          // +++ ADD THE NEW TEXT TESTIMONIALS SECTION HERE +++
                          if (textTestimonials.isNotEmpty) ...[
                            _buildCardWrapper(
                                child: _buildTextTestimonialsSection(
                                    screenWidth, screenHeight)),
                            const SizedBox(height: 6),
                          ],
                          //SizedBox(height: 2),
                          _buildFeedbackBanner(),
                          const SizedBox(height: 6),

                          buildTrustBadges(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,

            // This tells the Scaffold WHAT our combined widget is
            floatingActionButton: _buildCombinedFloatingButtons(),
          ),
        ),
        if (isNetworkError && _isDataLoaded)
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

  Widget _buildCardWrapper({required Widget child, bool showShadow = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        boxShadow: showShadow
            ? [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : [],
      ),
      child: child,
    );
  }

  Widget _buildQuickServicesSection() {
    // LIST KO YAHAN PAR DEFINE KAREIN
    final kundliList = [
      KundliItem(
          name: 'panchang'.tr + '\n',
          iconPath: "assets/Panchang-1.png",
          color: Color(0xFF7EE48C)),
      KundliItem(
          name: 'horoscope'.tr + '\n',
          iconPath: "assets/hari.png",
          color: Color(0xFF90CAF9)),
      KundliItem(
          name: 'kundli'.tr + '\n',
          iconPath: "assets/akash12.png",
          color: Color(0XFF5AB8E6)),
      KundliItem(
          name: 'matching'.tr + '\n',
          iconPath: "assets/matchmaking.png",
          color: Colors.redAccent),
      KundliItem(
          name: 'festival'.tr + '\n',
          iconPath: "assets/festi12.png",
          color: Color(0xFFF5D76B)),
    ];

    final List<Color> borderColors = [
      const Color.fromARGB(255, 76, 220, 83),
      const Color.fromARGB(255, 33, 150, 243),
      const Color.fromARGB(255, 11, 147, 220),
      Colors.red.shade600,
      const Color.fromARGB(255, 213, 197, 78),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Scrollbar(
        controller: _quickServicesHScrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: _quickServicesHScrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(kundliList.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () {
                    if (index == 0)
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PanchangScreen()));
                    else if (index == 1)
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HoroscopeScreen()));
                    else if (index == 2)
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewKundliScreen()));
                    else if (index == 3)
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Kundalimatching()));
                    else if (index == 4)
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BloglistScreen()));
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kundliList[index].color,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: borderColors[index], width: 4),
                        ),
                        child: Image.asset(kundliList[index].iconPath,
                            width: 40, height: 40),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kundliList[index].name,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildAiastrologerSection(double screenWidth, double screenHeight) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          children: [
            _buildSectionHeader('chat_with_astrologers'.tr, () {
              // Check if user is Guest or Not Logged In
              if (apiToken == null ||
                  apiToken!.isEmpty ||
                  apiToken!.length == 12) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                // User is Logged In -> Go to List
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AstrologerListScreen(mode: "chat")));
              }
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => ));
            }),
            Container(
              height: 200,
              child: astrologerlist.isEmpty
                  ? Center(child: Text("No astrologers available for chat"))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      itemCount: astrologerlist.length,
                      itemBuilder: (context, index) {
                        final astrologer = astrologerlist[index];
                        final hasSpecialPrice =
                            astrologer.chatSpecialPrice != null &&
                                astrologer.chatPrice != null &&
                                astrologer.chatSpecialPrice! > 0 &&
                                astrologer.chatSpecialPrice! <
                                    astrologer.chatPrice!;

                        return GestureDetector(
                          onTap: () {
                            if (apiToken == null ||
                                apiToken!.isEmpty ||
                                apiToken!.length == 12) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AstrologerDetailScreen(
                                      astrologerId: astrologer.id,
                                      slug: astrologer.slug),
                                ),
                              );
                            }
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>

                            // );
                          },
                          child: Container(
                            width: screenWidth * 0.28,
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 90,
                                  width: 90,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 45,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 48,
                                          backgroundColor: Colors.grey.shade300,
                                          child: astrologer.image != null &&
                                                  astrologer.image!.isNotEmpty
                                              ? CircleAvatar(
                                                  radius: 39,
                                                  backgroundImage: NetworkImage(
                                                      astrologer.image!),
                                                  backgroundColor: Colors.grey
                                                      .shade100, // fallback color
                                                )
                                              : CircleAvatar(
                                                  radius: 39,
                                                  backgroundColor: Colors
                                                      .white, // shown if image missing
                                                  child: Icon(Icons.person,
                                                      size: 40,
                                                      color: Colors.white),
                                                ),
                                        ),
                                      ),

                                      // CircleAvatar(
                                      //   radius: 45,
                                      //   backgroundColor: Colors.white,
                                      //   child: CircleAvatar(
                                      //     radius: 48,
                                      //     backgroundColor: Colors.grey.shade400,
                                      //     child: CircleAvatar(
                                      //       radius: 39,
                                      //       backgroundImage: NetworkImage(astrologer.image ?? 'https://via.placeholder.com/150'),
                                      //     ),
                                      //   ),
                                      // ),
                                      Positioned(
                                        top: 3,
                                        right: 10,
                                        child: AstrologerStatusDot(
                                            status: astrologer.status),
                                      ),
                                      // Verified icon center bottom
                                      if (astrologer.blueTick == true)
                                        Positioned(
                                          top: 75,
                                          bottom: 0,
                                          left: 2,
                                          right: 0,
                                          child: Center(
                                            child: Icon(Icons.verified,
                                                color: Colors.green, size: 24),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  astrologer.name ?? 'Astrologer',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (hasSpecialPrice) ...[
                                      Text(
                                        "₹${astrologer.chatPrice ?? ''}",
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey.shade500,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "₹${astrologer.chatSpecialPrice}/min",
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                    ] else
                                      Text(
                                        "₹${astrologer.chatPrice ?? ''}/min",
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     if (hasSpecialPrice)
                                //       Text("₹${astrologer.chatPrice ?? ''}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey.shade500, decoration: TextDecoration.lineThrough)),
                                //     SizedBox(width: 4),
                                //     Text(
                                //       "₹${hasSpecialPrice ? astrologer.chatSpecialPrice : astrologer.chatPrice ?? ''}/min",
                                //       style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red.shade600)
                                //     ),
                                //   ],
                                // ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: CustomStyles.chatActionGreen,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset("assets/chat-dots-fill.png",
                                          color: Colors.white,
                                          height: 12,
                                          width: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'chat'.tr,
                                        style: CustomStyles.chatPillTextWhite,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildastroconsult() {
    if (astrologerServices.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: List.generate(astrologerServices.length, (index) {
            final service = astrologerServices[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AstrologerListScreen(
                              serviceId: service.value,
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CustomStyles.ctaColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: CustomStyles.bgcolor.withOpacity(0.3),
                            width: 1),
                      ),
                      child: Image.network(
                        service.icon,
                        width: 42,
                        height: 42,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, size: 42);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.name,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      child: bannerlist.isEmpty
          ? SizedBox.shrink()
          : CarouselSlider.builder(
              itemCount: bannerlist.length,
              options: CarouselOptions(
                height: screenHeight * 0.22,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                autoPlayInterval: Duration(seconds: 4),
              ),
              itemBuilder: (context, index, realIndex) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      bannerlist[index].image ?? '',
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image, color: Colors.grey, size: 50),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: [
                Text(
                  'view_all'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    // fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                //Icon(Icons.play_arrow,size: 14,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAstrologerSection1(double screenWidth, double screenHeight) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      child: Column(
        children: [
          _buildSectionHeader('chat_with_ai_astrologers'.tr, () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => AiAstrologerListScreen()));
            if (apiToken == null ||
                apiToken!.isEmpty ||
                apiToken!.length == 12) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            } else {
              // User is Logged In -> Go to List
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AiAstrologerListScreen()));
            }
          }),
          Container(
            height: 200,
            child: aiAstrologerList.isEmpty
                ? Center(child: Text("No AI Astrologers available"))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: aiAstrologerList.length,
                    itemBuilder: (context, index) {
                      final astrologer = aiAstrologerList[index];
                      final hasSpecialPrice = astrologer.chatSpecialPrice > 0 &&
                          astrologer.chatSpecialPrice < astrologer.chatPrice;

                      return GestureDetector(
                        onTap: () async {
                          if (apiToken == null ||
                              apiToken!.isEmpty ||
                              apiToken!.length == 12) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Aiastrologer(
                                  astrologer: astrologer,
                                  allAstrologers: aiAstrologerList,
                                ),
                              ),
                            );
                          }
                        },
                        // onTap: () async {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => Aiastrologer(
                        //         astrologer: astrologer,
                        //         allAstrologers: aiAstrologerList,
                        //       ),
                        //     ),
                        //   );
                        // },
                        child: Container(
                          width: screenWidth * 0.28,
                          margin: EdgeInsets.only(right: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 90,
                                width: 90,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 48,
                                        backgroundColor: Colors.grey.shade300,
                                        child: astrologer.image != null &&
                                                astrologer.image!.isNotEmpty
                                            ? CircleAvatar(
                                                radius: 39,
                                                backgroundImage: NetworkImage(
                                                    astrologer.image!),
                                                backgroundColor: Colors.grey
                                                    .shade100, // fallback color
                                              )
                                            : CircleAvatar(
                                                radius: 39,
                                                backgroundColor: Colors
                                                    .white, // shown if image missing
                                                child: Icon(Icons.person,
                                                    size: 40,
                                                    color: Colors.white),
                                              ),
                                      ),
                                    ),
                                    // CircleAvatar(
                                    //   radius: 45,
                                    //   backgroundColor: Colors.white,
                                    //   child: CircleAvatar(
                                    //     radius: 48,
                                    //     backgroundColor: Colors.grey.shade400,
                                    //     child: CircleAvatar(
                                    //       radius: 39,
                                    //       backgroundImage: NetworkImage(astrologer.image),
                                    //     ),
                                    //   ),
                                    // ),
                                    Positioned(
                                      top: 3,
                                      right: 10,
                                      child: AstrologerStatusDot(
                                          status: astrologer.status),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(astrologer.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (hasSpecialPrice) ...[
                                    Text("₹${astrologer.chatPrice}",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey.shade500,
                                            decoration:
                                                TextDecoration.lineThrough)),
                                    SizedBox(width: 4),
                                    Text("₹${astrologer.chatSpecialPrice}/min",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red.shade600)),
                                  ] else
                                    Text("₹${astrologer.chatPrice}/min",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                decoration: BoxDecoration(
                                  color: CustomStyles.chatActionGreen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset("assets/chat-dots-fill.png",
                                        color: Colors.white,
                                        height: 12,
                                        width: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'chat'.tr,
                                      style: CustomStyles.chatPillTextWhite,
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
          ),
        ],
      ),
    );
  }

  Widget _buildBookPoojaSection(double screenWidth, double screenHeight) {
//   final cardWidth = screenWidth * 0.47; // Same as Reports section
//   return Column(
//     children: [
//       _buildSectionHeader("Book a Pooja", () => Get.to(PoojaListScreen())),
//       Container(
//         height: screenHeight * 0.35,
//          // Same height as Reports section
//         child: poojalist.isEmpty
//             ? Center(child: Text("No poojas available to book"))
//             : ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: poojalist.length,
//                 padding: EdgeInsets.symmetric(horizontal: 10), // Same as Reports
//                 itemBuilder: (context, index) {
//                   final pooja = poojalist[index];
//                   return Padding(
//                     padding: EdgeInsets.only(right: 8), // Same spacing as Reports
//                     child: PoojaCard(
//                       key: ValueKey(pooja.id),
//                       pooja: pooja,
//                       cardWidth: cardWidth,
//                       screenHeight: screenHeight,
//                     ),
//                   );
//                 },
//               ),
//       ),
//     ],
//   );
// }
  Widget _buildBookPoojaSection(double screenWidth, double screenHeight) {
    // 🔹 Responsive card width based on screen size
    final cardWidth = screenWidth < 600
        ? screenWidth * 0.47 // Mobile: 47% width
        : screenWidth < 900
            ? screenWidth * 0.32 // Tablet: 32% width
            : screenWidth * 0.24; // Desktop: 24% width

    // 🔹 Responsive height - Pooja cards need more height due to countdown timer
    final sectionHeight = screenWidth < 600
        ? screenHeight * 0.33 // Mobile
        : screenWidth < 900
            ? screenHeight * 0.38 // Tablet
            : screenHeight * 0.40; // Desktop

    // 🔹 Responsive padding
    final horizontalPadding = screenWidth < 600 ? 10.0 : 20.0;
    final cardSpacing = screenWidth < 600 ? 6.0 : 12.0;

    return Column(
      children: [
        _buildSectionHeader('book_a_pooja'.tr, () => Get.to(PoojaListScreen())),
        Container(
          height: sectionHeight,
          child: poojalist.isEmpty
              ? Center(
                  child: Text(
                    "No poojas available to book",
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 14.0 : 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: poojalist.length,
                  physics: BouncingScrollPhysics(), // 🔹 Smooth scrolling
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  itemBuilder: (context, index) {
                    final pooja = poojalist[index];
                    return Padding(
                      padding: EdgeInsets.only(right: cardSpacing),
                      child: PoojaCard(
                        key: ValueKey(pooja.id),
                        pooja: pooja,
                        cardWidth: cardWidth,
                        screenHeight: screenHeight,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFeedbackBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Card(
        // 👇 ADD THIS MARGIN TO CREATE SPACE ON THE LEFT AND RIGHT
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        // elevation: 2, // You can keep or remove elevation
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            // border: Border.all(color: Colors.blueGrey)
            // The border from the Card's shape is enough, so you can remove this one.
            // border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/vineetremover.png"),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Astrokavach",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // const Text(
                    //   "Have suggestions?",
                    //   textAlign: TextAlign.right,
                    //   style: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    //const SizedBox(height: 2),
                    Text(
                      'send_feedback_to_ceo'.tr,
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SupportScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        side:
                            BorderSide(color: Colors.grey.shade400, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'send_feedback'.tr,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestBlogSection(double screenWidth, double screenHeight) {
    // 🔹 Responsive card width based on screen size
    final cardWidth = screenWidth < 600
        ? screenWidth * 0.46 // Mobile: 46% width
        : screenWidth < 900
            ? screenWidth * 0.30 // Tablet: 30% width
            : screenWidth * 0.22; // Desktop: 22% width

    // 🔹 Responsive height
    final sectionHeight = screenWidth < 600
        ? screenHeight * 0.14 // Mobile
        : screenWidth < 900
            ? screenHeight * 0.16 // Tablet
            : screenHeight * 0.18; // Desktop

    // 🔹 Responsive padding
    final horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;
    final cardSpacing = screenWidth < 600 ? 8.0 : 12.0;

    // 🔹 Responsive font sizes
    final titleFontSize = screenWidth < 600
        ? 14.0
        : screenWidth < 900
            ? 16.0
            : 18.0;
    final titlePadding = screenWidth < 600
        ? EdgeInsets.fromLTRB(18, 2, 2, 2)
        : EdgeInsets.fromLTRB(12, 4, 12, 4);

    return Column(
      children: [
        _buildSectionHeader('latest_blogs'.tr, () => Get.to(BloglistScreen())),
        Container(
          height: sectionHeight,
          child: bloglist.isEmpty
              ? Center(
                  child: Text(
                    "No blogs available",
                    style: TextStyle(fontSize: titleFontSize * 0.9),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bloglist.length,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          Get.to(BlogDetailScreen(blogid: bloglist[index].id)),
                      child: Container(
                        width: cardWidth,
                        margin: EdgeInsets.only(right: cardSpacing),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                bloglist[index].image ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.grey.shade200),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.45),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 10,
                                right: 10,
                                bottom: 10,
                                child: Text(
                                  bloglist[index].title ?? '',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
      ],
    );
  }

  Widget _buildBadgeItem({
    required String imagePath,
    required String title,
    required String subtitle,
    required Color lightColor,
    required Color darkColor,
    bool isNetwork = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  lightColor.withOpacity(0.9),
                  darkColor,
                ],
                center: Alignment.center,
                radius: 0.9,
              ),
              border: Border.all(
                  color: darkColor, width: 5), // Border thicker banaya
              boxShadow: [
                BoxShadow(
                  color: darkColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                  20.0), // Padding badhaya taaki image chhoti dikhe aur border bada dikhe
              child: ClipOval(
                child: isNetwork
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.contain,
                        color: Colors.white,
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildTrustBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBadgeItem(
            imagePath: 'assets/shield-alt-solid.png',
            title: 'private_and'.tr,
            subtitle: 'confidential'.tr,
            lightColor: const Color(0xFF90CAF9),
            darkColor: const Color(0xFF1565C0),
          ),
          _buildBadgeItem(
            imagePath: 'assets/user-check-solid-full.png',
            title: 'verified'.tr,
            subtitle: 'astrologer'.tr,
            lightColor: const Color(0xFF81DAFA),
            darkColor: const Color(0xFF0288D1),
          ),
          _buildBadgeItem(
            imagePath: 'assets/credit-card-solid-full.png',
            title: 'secure'.tr,
            subtitle: 'payments'.tr,
            lightColor: const Color(0xFFA5D6A7),
            darkColor: const Color(0xFF388E3C),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTestimonialsSection(
      double screenWidth, double screenHeight) {
    // 🔹 Responsive values
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    final headingFontSize = isSmallScreen
        ? 18.0
        : isMediumScreen
            ? 20.0
            : 22.0;
    final titleFontSize = isSmallScreen
        ? 14.0
        : isMediumScreen
            ? 15.0
            : 16.0;
    final horizontalPadding = isSmallScreen
        ? 16.0
        : isMediumScreen
            ? 24.0
            : 32.0;
    final verticalMargin = isSmallScreen ? 8.0 : 12.0;
    final borderRadius = isSmallScreen ? 12.0 : 16.0;
    final playIconSize = isSmallScreen
        ? 50.0
        : isMediumScreen
            ? 60.0
            : 70.0;

    // 🔹 Video height responsive
    final videoHeight = isSmallScreen
        ? screenHeight * 0.25
        : isMediumScreen
            ? screenHeight * 0.28
            : screenHeight * 0.32;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, isSmallScreen ? 0 : 8,
              horizontalPadding, isSmallScreen ? 12 : 16),
          child: Text(
            videoTestimonialsHeading ?? "Video Testimonials",
            style: TextStyle(
              fontSize: headingFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        videoTestimonials.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                  child: Text(
                    "No testimonials available",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            : Column(
                children: videoTestimonials.map((video) {
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
                      margin: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalMargin,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: Colors.grey.shade500,
                          width: isSmallScreen ? 1 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(isSmallScreen ? 0.8 : 0.25),
                            spreadRadius: isSmallScreen ? 1 : 2,
                            blurRadius: isSmallScreen ? 5 : 8,
                            offset: Offset(0, isSmallScreen ? 3 : 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🎥 Video Thumbnail Section
                          SizedBox(
                            height: videoHeight,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(borderRadius),
                                  ),
                                  child: Image.network(
                                    video.thumbnail,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.video_call_outlined,
                                        size: playIconSize,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ),
                                // 🎬 Play Button Overlay
                                Container(
                                  padding:
                                      EdgeInsets.all(isSmallScreen ? 12 : 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: playIconSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 📝 Video Title Section
                          Padding(
                            padding:
                                EdgeInsets.all(isSmallScreen ? 10.0 : 14.0),
                            child: Text(
                              video.title,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                              maxLines: isSmallScreen ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildTextTestimonialsSection(
      double screenWidth, double screenHeight) {
    // 🔹 Responsive values
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    final headingFontSize = isSmallScreen
        ? 18.0
        : isMediumScreen
            ? 20.0
            : 22.0;
    final descriptionFontSize = isSmallScreen
        ? 14.0
        : isMediumScreen
            ? 15.0
            : 16.0;
    final authorFontSize = isSmallScreen
        ? 14.0
        : isMediumScreen
            ? 15.0
            : 16.0;
    final quoteFontSize = isSmallScreen
        ? 80.0
        : isMediumScreen
            ? 100.0
            : 120.0;

    final horizontalPadding = isSmallScreen
        ? 16.0
        : isMediumScreen
            ? 24.0
            : 32.0;
    final cardInnerPadding = isSmallScreen
        ? 16.0
        : isMediumScreen
            ? 18.0
            : 20.0;
    final cardSpacing = isSmallScreen ? 12.0 : 16.0;
    final borderRadius = isSmallScreen ? 12.0 : 16.0;

    // 🔹 Card width - responsive
    final cardWidth = isSmallScreen
        ? screenWidth * 0.85 // Mobile: 85%
        : isMediumScreen
            ? screenWidth * 0.65 // Tablet: 65%
            : screenWidth * 0.45; // Desktop: 45%

    // 🔹 Container height - responsive
    final containerHeight = isSmallScreen
        ? screenHeight * 0.18
        : isMediumScreen
            ? screenHeight * 0.20
            : screenHeight * 0.22;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, isSmallScreen ? 0 : 8,
              horizontalPadding, isSmallScreen ? 12 : 16),
          child: Text(
            textTestimonialsHeading ?? "Testimonials",
            style: TextStyle(
              fontSize: headingFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        textTestimonials.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                  child: Text(
                    "No testimonials available",
                    style: TextStyle(
                      fontSize: descriptionFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            : Container(
                height: containerHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(), // 🔹 Smooth scrolling
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  itemCount: textTestimonials.length,
                  itemBuilder: (context, index) {
                    final testimonial = textTestimonials[index];
                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(right: cardSpacing),
                      padding: EdgeInsets.all(cardInnerPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: isSmallScreen ? 1 : 1.5,
                        ),
                        boxShadow: isSmallScreen
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Stack(
                        children: [
                          // 💬 Background quote icon
                          Positioned(
                            top: isSmallScreen ? -10 : -15,
                            left: isSmallScreen ? -5 : -8,
                            child: Text(
                              '"',
                              style: TextStyle(
                                fontSize: quoteFontSize,
                                color: Colors.grey.shade100,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            ),
                          ),
                          // 📝 Main content
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: isSmallScreen ? 8.0 : 12.0,
                                      top: isSmallScreen ? 8.0 : 12.0,
                                      right: isSmallScreen ? 0 : 4.0,
                                    ),
                                    child: Text(
                                      // Clean HTML tags from the description
                                      HtmlTagsCleaner.clean(
                                          testimonial.description),
                                      style: TextStyle(
                                        fontSize: descriptionFontSize,
                                        color: Colors.black87,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              // 👤 Author name
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: isSmallScreen ? 0 : 4.0,
                                  ),
                                  child: Text(
                                    "- ${testimonial.title}",
                                    style: TextStyle(
                                      fontSize: authorFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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

  Widget _buildFloatingActionButtons(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      child: Row(
        children: <Widget>[
          // --- Button 1: Chat with Astrologer ---
          Expanded(
            child: InkWell(
              onTap: () {
                if (apiToken == null ||
                    apiToken!.isEmpty ||
                    apiToken!.length == 12) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AstrologerListScreen(mode: "chat")),
                  );
                }
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ,
                //   ),
                // );
              },
              child: Container(
                height: screenHeight * 0.055,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.08),
                  color: CustomStyles.chatActionGreen,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'chat_with_astrologers'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.032,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.025),

          // --- Button 2: Talk with Astrologer ---
          Expanded(
            child: InkWell(
              onTap: () {
                if (apiToken == null ||
                    apiToken!.isEmpty ||
                    apiToken!.length == 12) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AstrologerListScreen(mode: "call")),
                  );
                }
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ,
                //   ),
                // );
              },
              child: Container(
                height: screenHeight * 0.055,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  color: Colors.lightBlueAccent,
                  // 👇 YEH BHI ADD KARO
                  border: Border.all(
                    color: Colors.black, // Ya koi aur color
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.call_outlined,
                      color: Colors.black,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'talk_to_astrologer'.tr,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.032,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// This function builds BOTH the buttons and the cart icon together

// This function builds BOTH the buttons and the cart icon together
  Widget _buildCombinedFloatingButtons() {
    if (astrologerlist.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dimensions
    final double containerHeight = screenHeight * 0.13;
    final double buttonHeight = screenHeight * 0.048;
    final double buttonFontSize = screenWidth * 0.028;
    final double iconSize = screenWidth * 0.04;
    final double horizontalPadding = screenWidth * 0.024;
    final double borderRadius = screenWidth * 0.080; // ✅ Ab responsive
    final double callBorderRadius = screenWidth * 0.080; // ✅ Thoda chhota
    final double cartIconBottomPosition =
        buttonHeight * 1.25; // ✅ Thoda zyada space
    final double cartPadding = screenWidth * 0.03;
    final double cartShadowBlur = screenWidth * 0.015;
    final double shadowOffset = screenHeight * 0.004; // ✅ Responsive shadow
    final double finalIconSize = iconSize.clamp(10, 12);

    final bool isCartNotEmpty =
        quantity != null && quantity != '0' && quantity!.isNotEmpty;

    return SizedBox(
      height: containerHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 🔹 Chat & Talk buttons
          Positioned(
            bottom: 0,
            left: horizontalPadding,
            right: horizontalPadding,
            child: Row(
              children: <Widget>[
                // Chat Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (apiToken == null ||
                          apiToken!.isEmpty ||
                          apiToken!.length == 12) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      } else {
                        // User is Logged In -> Go to List
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AstrologerListScreen(mode: "chat")));
                      }
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         AstrologerListScreen(mode: "chat"),
                      //   ),
                      // );
                    },
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Container(
                      height: buttonHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        color: CustomStyles.chatActionGreen,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: cartShadowBlur,
                            offset: Offset(0, shadowOffset),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Image.asset(
                              "assets/chat-dots-fill.png",
                              color: Colors.white,
                              height: finalIconSize,
                              width: finalIconSize,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Flexible(
                            child: Text(
                              'chat_with_astrologers'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: buttonFontSize,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: screenWidth * 0.025),

                // Call Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (apiToken == null ||
                          apiToken!.isEmpty ||
                          apiToken!.length == 12) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AstrologerListScreen(mode: "call")),
                        );
                      }
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         AstrologerListScreen(mode: "call"),
                      //   ),
                      // );
                    },
                    borderRadius: BorderRadius.circular(callBorderRadius),
                    child: Container(
                      height: buttonHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(callBorderRadius),
                        color: CustomStyles.callActionBackground,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: cartShadowBlur,
                            offset: Offset(0, shadowOffset),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/callring.png",
                            color: Colors.white,
                            height: iconSize,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Flexible(
                            child: Text(
                              'talk_to_astrologer'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: buttonFontSize,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Floating Cart Icon
          if (isCartNotEmpty)
            Positioned(
              bottom: cartIconBottomPosition,
              right: screenWidth * 0.04,
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(cartPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius:
                            screenWidth * 0.005, // ✅ Responsive spread
                        blurRadius: cartShadowBlur,
                        offset: Offset(0, shadowOffset),
                      ),
                    ],
                  ),
                  child: const CartIcon(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class KundliItem {
  final String name;
  final String iconPath;
  final Color color;
  KundliItem({
    required this.name,
    required this.iconPath,
    this.color = Colors.white,
  });
}







