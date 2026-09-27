import 'dart:async';
import 'dart:convert';

import 'package:astrokavach/api/dashboard/search_delegates.dart';
import 'package:astrokavach/api/product_api/faq/newfaqapi.dart';
import 'package:astrokavach/api/product_api/product_list_api.dart';
import 'package:astrokavach/api/youtubeapi/youtubeapi.dart';
import 'package:astrokavach/api/youtubereview/youtubereview.dart';
import 'package:astrokavach/model/faqmodel/faqmodel.dart';
import 'package:astrokavach/model/videoyoutube/videoyoutube.dart';
import 'package:astrokavach/model/youtubereview/youtubereview.dart';
import 'package:astrokavach/screen/youtubevideo/youtubevideo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:astrokavach/screen/zoomscreen.dart';
import 'package:html_tags_cleaner/html_tags_cleaner.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/addtocart_api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_decrease_Api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_increase_Api.dart';
import 'package:astrokavach/api/product_api/WishlistApi.dart/wishlist_add_api.dart';
import 'package:astrokavach/api/product_api/canreview_api.dart';
import 'package:astrokavach/api/product_api/faq/faq_api.dart';
import 'package:astrokavach/api/product_api/product_detail_api.dart';
import 'package:astrokavach/api/product_api/review_Api.dart';
import 'package:astrokavach/api/product_api/similar_product_api.dart';
import 'package:astrokavach/api/product_api/submit_review_api.dart';
import 'package:astrokavach/custom_widgets/app_date_time_picker_theme.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/cutsom_textfield.dart';
import 'package:astrokavach/custom_widgets/detail_screen_shimmers.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/addtocart_model.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cart_decrease_model.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cart_increasemodel.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/faqmodel.dart';
import 'package:astrokavach/model/Product_Api_Model/WishlistModel.dart/addtowishlist_model.dart';
import 'package:astrokavach/model/Product_Api_Model/product_Detail_api_model.dart'
    hide Form;
import 'package:astrokavach/model/Product_Api_Model/recent_views_model.dart';
import 'package:astrokavach/model/Product_Api_Model/review_model.dart';
import 'package:astrokavach/model/Product_Api_Model/similar_product_model.dart';
import 'package:astrokavach/model/kundalimodel/locationkundali.dart';
import 'package:astrokavach/model/reviemproduct.dart';
import 'package:astrokavach/model/reviewmodel/productmodelreview.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/astrologer/astrologer_list_screen.dart';
import 'package:astrokavach/screen/product/checkout_screen.dart';
import 'package:astrokavach/api/Address_Api/address_api.dart';
import 'package:astrokavach/api/Address_Api/add_address_Api.dart';
import 'package:astrokavach/api/auth_api/place_api.dart';
import 'package:astrokavach/model/AddressModel/address_api_model.dart';
import 'package:astrokavach/model/places_model.dart/state_api_model.dart';
import 'package:astrokavach/model/places_model.dart/city_api_model.dart';
import 'package:astrokavach/Services/buy_now_cart.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rating_summary/rating_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ProductDetailScreen extends StatefulWidget {
  int? itemId;
  String? productname;
  int? parentid;
  String? slug;
  List<dynamic>? attributevalue = [];
  String? type;
  final bool goHomeOnBack;
  ProductDetailScreen({
    super.key,
    this.itemId,
    this.productname,
    this.parentid = 0,
    this.attributevalue,
    this.slug,
    this.type,
    this.goHomeOnBack = false,
  });
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Future<Map<String, dynamic>?> _fetchPujaParticipateSchema({
    required String apiToken,
    required int productId,
    required int variationId,
    required String pujaFlow,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse(AstroApiService.pujaParticipateSchemaEndpoint),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'api_token': apiToken,
          'product_id': productId,
          'variation_id': variationId,
          'puja_flow': pujaFlow,
        }),
      );
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  void _handleBackNavigation() {
    if (widget.goHomeOnBack) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    Navigator.pop(context);
  }

  static const String _recentViewsCacheKey = 'recent_views_cache_v1';
  static const double _kDetailIconSize = 18;
  static const double _kDetailIconSlot = 22;
  ReusableFunction reusableFunction = ReusableFunction();
  int currentIndex = 0;
  PageController pageController = PageController();
  ScrollController scrollController = ScrollController();
  Map<int, bool> _isExpanded = {};
  TextEditingController reviewcontroller = TextEditingController();
  bool isSelected = false;
  ProductDetailModel? productDetailModel;
  ProductDetailDatum? productDetailDatum;

  bool isloading = false;
  ProductDetailApiService productDetailApiService = ProductDetailApiService();
  List<Specification> specificationlist = [];
  List<String> gallerylist = [];
  List<Attributedatum> colorlist = [];
  List<Attributedatum> sizelist = [];
  List<Attributedatum> weigthlist = [];
  List<Attributedatum> typelist = [];
  SimilarProductModel? similarProductModel;
  SimilarproductApi similarproductApi = SimilarproductApi();
  List<SimilarProduct> similarproductlist = [];
  ReviewModel? reviewModel;
  CartIncreaseModel? cartIncreaseModel;
  CartDecreaseModel? cartDecreaseModel;
  CartListIncreaseApiService cartListIncreaseApiService =
      CartListIncreaseApiService();
  CartListDecreaseApiService cartListDecreaseApiService =
      CartListDecreaseApiService();
  double? currentrating = 0;
  bool canformshow = false;
  bool? canaddmore;
  bool canReview = false;
  String? apiToken;
  List<FAQDatum> Faqlist = [];
  FaqModel? faqModel;
  FAQApiService faqApiService = FAQApiService();
  String? selectedColor;
  String? selectedSize;
  String? selectedweigth;
  String? selectedtype;
  String? currentSlug; //new field
  Attribute? selectattribute;
  bool _isUpdatingAttributes = false;
  bool _isReviewsLoading = true;

  List<ReviewData> productReviews = [];
  List<VideoItem> videoTestimonials = [];
  String? videoTestimonialsHeading;
  List<TestimonialItem> textTestimonials = [];
  String? textTestimonialsHeading;
  List<FaqItem> faqItems = [];
  String? faqHeading;
  String? faqSubHeading;
  bool _isFaqsLoading = true;
  Timer? _timer;
  Duration? _remainingTime;
  bool _isExpired = false;
  List<Attributedatum> caratlist = [];
  List<Attributedatum> originlist = [];
  String? selectedCarat;
  String? selectedOrigin;
  List<Attributedatum> stylelist = [];
  List<RecentViewDatum> recentViews = [];
  bool _isRecentViewsLoading = false;

  String? selectedStyle;

  ProducListApiService productListApiService = ProducListApiService();
  int? _getItemIdFromSelectedAttributes() {
    if (selectedCarat != null && selectedCarat!.isNotEmpty) {
      final id =
          caratlist.where((e) => e.name == selectedCarat).firstOrNull?.itemId;
      if (id != null) return id;
    }
    if (selectedOrigin != null && selectedOrigin!.isNotEmpty) {
      final id =
          originlist.where((e) => e.name == selectedOrigin).firstOrNull?.itemId;
      if (id != null) return id;
    }
    if (selectedStyle != null && selectedStyle!.isNotEmpty) {
      final id =
          stylelist.where((e) => e.name == selectedStyle).firstOrNull?.itemId;
      if (id != null) return id;
    }
    if (selectedColor != null && selectedColor!.isNotEmpty) {
      final id =
          colorlist.where((e) => e.name == selectedColor).firstOrNull?.itemId;
      if (id != null) return id;
    }
    if (selectedSize != null && selectedSize!.isNotEmpty) {
      final id =
          sizelist.where((e) => e.name == selectedSize).firstOrNull?.itemId;
      if (id != null) return id;
    }
    if (selectedweigth != null && selectedweigth!.isNotEmpty) {
      final id =
          weigthlist.where((e) => e.name == selectedweigth).firstOrNull?.itemId;
      if (id != null) return id;
    }
    if (selectedtype != null && selectedtype!.isNotEmpty) {
      final id =
          typelist.where((e) => e.name == selectedtype).firstOrNull?.itemId;
      if (id != null) return id;
    }
    return null;
  }

  String _normalizeProductType(String? rawType) {
    final t = rawType?.toLowerCase().trim();
    const valid = {
      'product',
      'gemstone',
      'rudraksha',
      'service',
      'report',
      'pooja'
    };
    if (t == null || t.isEmpty) return 'product';
    return valid.contains(t) ? t : 'product';
  }

  getProductDetailListData() async {
    setState(() {
      isloading = true;
      _isReviewsLoading = true;
      _isFaqsLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      apiToken = prefs.getString('api_token');
      productDetailModel =
          await productDetailApiService.fetchproductDetailsdata(
              widget.itemId,
              apiToken.toString(),
              widget.parentid,
              widget.attributevalue ?? []);
      productDetailDatum = productDetailModel!.data;
      widget.type =
          _normalizeProductType(productDetailDatum?.type ?? widget.type);
      gallerylist = productDetailDatum?.galleries ?? [];
      sizelist = productDetailDatum?.attributes?.size ?? [];
      colorlist = productDetailDatum?.attributes?.color ?? [];
      typelist = productDetailDatum?.attributes?.type ?? [];
      weigthlist = productDetailDatum?.attributes?.weight ?? [];
      caratlist = productDetailDatum?.attributes?.carat ?? [];
      originlist = productDetailDatum?.attributes?.origin ?? [];
      selectedColor = productDetailDatum?.attribute?.color;
      selectedSize = productDetailDatum?.attribute?.size;
      selectedtype = productDetailDatum?.attribute?.type;
      selectedweigth = productDetailDatum?.attribute?.weight;
      productitemid = productDetailDatum!.id;
      selectedCarat = productDetailDatum?.attribute?.carat;
      selectedOrigin = productDetailDatum?.attribute?.origin;
      stylelist = productDetailDatum?.attributes?.style ?? [];
      selectedStyle = productDetailDatum?.attribute?.style;

      final bool isOfferEnded =
          productDetailDatum?.offerEnd?.toString().trim() == '1';

      if (widget.type == 'pooja' && !isOfferEnded) {
        _initializeCountdown();
      } else if ((widget.type == 'gemstone' ||
              widget.type == 'rudraksha' ||
              widget.type == 'service' ||
              widget.type == 'report') &&
          !isOfferEnded) {
        _initializeCountdown();
      }
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
      await _saveCurrentProductToLocalRecent();
      await _loadSecondaryProductData();
    } catch (e) {
      print('DEBUG: An error occurred in getProductDetailListData: $e');
      if (mounted) {
        setState(() {
          isloading = false;
          _isReviewsLoading = false;
          _isFaqsLoading = false;
        });
      }
    }
  }

  Future<void> _loadSecondaryProductData() async {
    if (productDetailDatum == null) return;

    try {
      // 1) Reviews
      if (productDetailDatum!.id != null) {
        print(
            'DEBUG: Fetching reviews for Product ID: ${productDetailDatum!.id}');
        final reviews = await AstroApiService.fetchProductReviews(
          productId: productDetailDatum!.id,
        );
        print('DEBUG: Raw API response for reviews: $reviews');

        if (reviews != null && mounted) {
          print(
              'DEBUG: API returned ${reviews.length} reviews. Calling setState...');
          setState(() {
            productReviews = reviews;
          });
        }
      }
    } catch (e) {
      print('DEBUG: Error while fetching reviews: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isReviewsLoading = false;
        });
      }
    }

    // 2) Video testimonials
    try {
      final videoResponse =
          await VideoTestimonialService.fetchVideoTestimonials(page: 'product');
      if (mounted && videoResponse.success) {
        setState(() {
          videoTestimonials = videoResponse.data.data;
          videoTestimonialsHeading = videoResponse.data.heading;
        });
      }
    } catch (e) {
      print("Error fetching astrologer testimonials: $e");
    }

    // 3) Text testimonials
    try {
      final textResponse =
          await TextTestimonialService.fetchTextTestimonials(page: "product");
      if (mounted && textResponse.success) {
        setState(() {
          textTestimonials = textResponse.data.data;
          textTestimonialsHeading = textResponse.data.heading;
        });
      }
    } catch (e) {
      print("Error fetching text testimonials: $e");
    }

    // 4) FAQ + related products
    try {
      String pageType = _normalizeProductType(widget.type);
      print("krte raho $pageType ");
      int? newCategoryId = productDetailDatum?.parentId;

      await getCategoryBasedRelatedProducts(newCategoryId);

      await _fetchRecentViews();

      final faqResponse = await FaqService.fetchFaqs(page: pageType);
      if (mounted && faqResponse.success) {
        setState(() {
          faqItems = faqResponse.data.data;
          faqHeading = faqResponse.data.heading;
          faqSubHeading = faqResponse.data.subHeading;
        });
      }
    } catch (e) {
      print("Error fetching FAQs for product: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFaqsLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRecentViews() async {
    final int? productId = productDetailDatum?.id ?? widget.itemId;
    if (productId == null) return;
    print('recent-views start for product_id: $productId');
    final localList = await _getLocalRecentViews();
    final localFiltered =
        localList.where((e) => e.id != null && e.id != productId).toList();
    if (mounted && localFiltered.isNotEmpty) {
      setState(() {
        recentViews = localFiltered;
      });
    }
    if (mounted) {
      setState(() {
        _isRecentViewsLoading = true;
      });
    }
    try {
      final response = await AstroApiService.fetchRecentViews(productId);
      final apiList = response?.data ?? [];
      print('recent-views api list count: ${apiList.length}');
      final mergedMap = <int, RecentViewDatum>{};
      for (final item in localList) {
        if (item.id != null) {
          mergedMap[item.id!] = item;
        }
      }
      for (final item in apiList) {
        if (item.id != null) {
          mergedMap[item.id!] = item;
        }
      }
      List<RecentViewDatum> parsed = mergedMap.values
          .where((e) => e.id != null && e.id != productId)
          .toList();
      print('recent-views filtered count (without current): ${parsed.length}');
      if (parsed.isEmpty && mergedMap.isNotEmpty) {
        parsed = mergedMap.values.where((e) => e.id != null).toList();
        print('recent-views fallback count (with current): ${parsed.length}');
      }
      if (mounted) {
        setState(() {
          recentViews = parsed;
        });
      }
    } catch (_) {
      print('recent-views screen exception');
      if (mounted) {
        setState(() {
          recentViews = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRecentViewsLoading = false;
        });
      }
      print('recent-views final visible count: ${recentViews.length}');
    }
  }

  Future<void> _saveCurrentProductToLocalRecent() async {
    final int? id = productDetailDatum?.id ?? widget.itemId;
    if (id == null) return;
    final String title =
        productDetailDatum?.title?.toString() ?? widget.productname ?? '';
    final String image = gallerylist.isNotEmpty ? gallerylist.first : '';
    final String slug =
        productDetailDatum?.slug?.toString() ?? widget.slug ?? '';
    final prefs = await SharedPreferences.getInstance();
    final existing = await _getLocalRecentViews();
    final current = RecentViewDatum(
      id: id,
      title: title,
      image: image,
      slug: slug,
      type: _normalizeProductType(productDetailDatum?.type ?? widget.type),
    );
    final merged = <RecentViewDatum>[current];
    for (final item in existing) {
      if (item.id != null && item.id != id) {
        merged.add(item);
      }
    }
    final trimmed = merged.take(20).toList();
    final encoded = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    await prefs.setString(_recentViewsCacheKey, encoded);
    print('recent-views local cache updated count: ${trimmed.length}');
  }

  Future<List<RecentViewDatum>> _getLocalRecentViews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_recentViewsCacheKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .map((e) => RecentViewDatum.fromJson(e as Map<String, dynamic>))
          .where((e) => e.id != null)
          .toList();
    } catch (_) {
      return [];
    }
  }

  getCategoryBasedRelatedProducts(int? dynamicCategoryId) async {
    try {
      List<SimilarProduct> tempRelatedList = [];
      int categoryIdToFetch = dynamicCategoryId ?? widget.parentid ?? 0;
      final currentType =
          _normalizeProductType(productDetailDatum?.type ?? widget.type);

      if (currentType == 'gemstone') {
        var response = await AstroApiService.fetchCertifiedGemstones();
        if (response != null) {
          tempRelatedList = response
              .map((e) => SimilarProduct(
                    id: e.id,
                    name: e.name,
                    slug: e.slug,
                    image: e.image,
                    type: 'gemstone',
                    avaibility: e.avaibility,
                    basePrice: e.basePrice != null
                        ? double.tryParse(e.basePrice.toString())
                        : 0,
                    salePrice: e.salePrice != null
                        ? double.tryParse(e.salePrice.toString())
                        : 0,
                    offerEnd: e.offerEnd,
                    salePriceEndDate: e.salePriceEndDate,
                  ))
              .toList();
        }
      } else if (currentType == 'rudraksha') {
        var response = await AstroApiService.fetchCertifiedRudraksha();
        if (response != null) {
          tempRelatedList = response
              .map((e) => SimilarProduct(
                    id: e.id,
                    name: e.name,
                    slug: e.slug,
                    image: e.image,
                    type: 'rudraksha',
                    avaibility: e.avaibility,
                    basePrice: e.basePrice != null
                        ? double.tryParse(e.basePrice.toString())
                        : 0,
                    salePrice: e.salePrice != null
                        ? double.tryParse(e.salePrice.toString())
                        : 0,
                    offerEnd: e.offerEnd,
                    salePriceEndDate: e.salePriceEndDate,
                  ))
              .toList();
        }
      } else if (currentType == 'service') {
        var response = await productListApiService.fetchproductlistapidata(
            0, "service", "a_to_z", "", "", 0, 0);
        if (response?.data?.products != null) {
          tempRelatedList = response!.data!.products!
              .map((e) => SimilarProduct(
                    id: e.id,
                    name: e.name,
                    slug: e.slug,
                    image: e.image,
                    type: 'service',
                    avaibility: e.avaibility,
                    basePrice: e.basePrice != null
                        ? double.tryParse(e.basePrice.toString())
                        : 0,
                    salePrice: e.salePrice != null
                        ? double.tryParse(e.salePrice.toString())
                        : 0,
                    offerEnd: e.offerEnd,
                    salePriceEndDate: e.salePriceEndDate,
                  ))
              .toList();
        }
      } else if (currentType == "product") {
        int categoryIdToFetch = widget.parentid ?? 0;
        var response = await productListApiService.fetchproductlistapidata(
            categoryIdToFetch, "product", "a_to_z", "", "", 0, 0);

        if (response?.data?.products != null) {
          tempRelatedList = response!.data!.products!.map((e) {
            double safeBasePrice = 0.0;
            if (e.basePrice != null) {
              safeBasePrice =
                  double.tryParse(e.basePrice.toString().replaceAll(',', '')) ??
                      0.0;
            }

            double safeSalePrice = 0.0;
            if (e.salePrice != null) {
              safeSalePrice =
                  double.tryParse(e.salePrice.toString().replaceAll(',', '')) ??
                      0.0;
            }

            return SimilarProduct(
              id: e.id,
              name: e.name,
              slug: e.slug,
              image: e.image,
              type: 'product',
              avaibility: e.avaibility,
              basePrice: safeBasePrice,
              salePrice: safeSalePrice,
              offerEnd: e.offerEnd,
              salePriceEndDate: e.salePriceEndDate,
            );
          }).toList();
        }
      }

      tempRelatedList.removeWhere((element) => element.id == widget.itemId);

      if (mounted) {
        setState(() {
          similarproductlist = tempRelatedList;
        });
      }
    } catch (e) {
      print("Error fetching related products: $e");
    }
  }

  void _initializeCountdown() {
    String? rawDate;
    DateFormat dateFormat;

    if (widget.type == 'pooja') {
      rawDate = productDetailDatum?.expireAt;
      dateFormat = DateFormat("dd-MM-yyyy hh:mm a");
    } else {
      rawDate = productDetailDatum?.salePriceEndDate;

      dateFormat = DateFormat("yyyy-MM-dd");
    }

    if (rawDate == null || rawDate.isEmpty) {
      print("DEBUG TIMER: No date found for ${widget.type}");
      return;
    }

    try {
      DateTime expireDate;

      try {
        expireDate = dateFormat.parse(rawDate);
        if (widget.type != 'pooja') {
          expireDate = DateTime(
              expireDate.year, expireDate.month, expireDate.day, 23, 59, 59);
        }
      } catch (e) {
        print("Primary format failed, trying fallback: $e");

        expireDate = DateTime.parse(rawDate);
      }

      final now = DateTime.now();

      if (expireDate.isBefore(now)) {
        if (mounted) setState(() => _isExpired = true);
      } else {
        if (mounted) {
          setState(() {
            _remainingTime = expireDate.difference(now);
          });
          _startTimer();
        }
      }
    } catch (e) {
      print("Date parse error in ProductDetailScreen: $e");
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == null || _remainingTime!.inSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _isExpired = true);
      } else {
        if (mounted) {
          setState(() =>
              _remainingTime = _remainingTime! - const Duration(seconds: 1));
        }
      }
    });
  }

  updateProductForAttributes() async {
    if (_isUpdatingAttributes) return;
    setState(() {
      _isUpdatingAttributes = true;
    });

    try {
      List<dynamic> attributeValues = [
        selectedColor,
        selectedSize,
        selectedweigth,
        selectedtype,
        selectedCarat,
        selectedOrigin,
        selectedStyle
      ].where((value) => value != null && value.toString().isNotEmpty).toList();

      final itemIdToUse = _getItemIdFromSelectedAttributes() ??
          productDetailDatum?.id ??
          widget.itemId;
      productDetailModel =
          await productDetailApiService.fetchproductDetailsdata(
              itemIdToUse,
              apiToken.toString(),
              widget.parentid ?? productDetailDatum?.parentId,
              attributeValues);

      if (!mounted) return;
      productDetailDatum = productDetailModel!.data;
      currentSlug = productDetailDatum!.slug;
      productitemid = productDetailDatum!.id;
      itemquantity =
          int.tryParse(productDetailDatum!.avaibility?.toString() ?? '0');
      canaddmore = productDetailDatum!.canAddMore;
      gallerylist = productDetailDatum!.galleries ?? [];

      setState(() {});
    } catch (e) {
      print('Error updating product: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAttributes = false;
        });
      }
    }
  }

  final Map<String, TextEditingController> controllers = {};
  OverlayEntry? _buyFormLocationOverlay;
  List<LocationData> _buyFormLocationSuggestions = [];
  bool _buyFormLoadingLocations = false;
  final Map<String, FocusNode> _buyFormPlaceFocusNodes = {};

  int? productitemid;
  int? itemquantity;
  AddtoCartApiService addtoCartApiService = AddtoCartApiService();
  AddtoCartModel? addtoCartModel;
  CartIcon cartIcon = CartIcon();
  getaddtocartdata({bool forBuyNow = false}) async {
    await ensureGuestToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    final cartType = (widget.type == 'service' || widget.type == 'report')
        ? 'service'
        : 'shop';
    addtoCartModel = await addtoCartApiService.addToCartApi(
        apiToken, productDetailDatum?.id, cartType, null,
        buyNow: forBuyNow ? 1 : 0);
    if (addtoCartModel != null) {
      setState(() {
        productitemid = addtoCartModel!.itemid;
        if (!forBuyNow) {
          cartQuantityNotifier.value = addtoCartModel!.totalQuantity.toString();
        }
      });
    }
  }

  Future<void> addRelatedProductToCart(int? productId) async {
    if (productId == null) return;

    try {
      await ensureGuestToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      apiToken = prefs.getString('api_token');

      var result = await addtoCartApiService.addToCartApi(
          apiToken, productId, "shop", null);

      if (result != null) {
        setState(() {
          cartQuantityNotifier.value = result.totalQuantity.toString();
        });
        Fluttertoast.showToast(
          msg: "Product added to cart",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print("Error adding related product to cart: $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  bool isFavorite = false;

  void toggleFavorite() async {
    if (apiToken == null || apiToken!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    final originalState = isFavorite;
    setState(() {
      isFavorite = !isFavorite;
    });

    final action = isFavorite ? 'add' : 'remove';

    try {
      await AstroApiService.updateWishlist(
        itemId: productDetailDatum!.id!,
        action: action,
      );
    } catch (e) {
      setState(() {
        isFavorite = originalState;
      });
      print("Failed to update wishlist: $e");
    }
  }

  Widget _buildStarRatingBar(int starCount, int value, int totalCount) {
    double percentage = totalCount == 0 ? 0 : value / totalCount;
    return Row(
      children: [
        Text(
          "$starCount",
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600]),
        ),
        Icon(Icons.star, size: 12, color: Colors.grey[400]),
        SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xffFFAF12),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          "$value",
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSpecificationSection() {
    if (productDetailDatum?.specifications == null ||
        productDetailDatum!.specifications!.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Specifications",
            style: CustomStyles.black16600
                .copyWith(fontSize: MediaQuery.of(context).size.width * 0.045),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: productDetailDatum!.specifications!
                  .asMap()
                  .entries
                  .map((entry) {
                int idx = entry.key;
                var spec = entry.value;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: idx % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                    border:
                        idx != productDetailDatum!.specifications!.length - 1
                            ? Border(
                                bottom: BorderSide(color: Colors.grey.shade200))
                            : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(spec.heading ?? "",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                fontSize: 14)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(spec.text ?? "",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                fontSize: 14)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    if (productDetailDatum?.avaibility == null) {
      return const SizedBox.shrink();
    }

    final int? stock = int.tryParse(productDetailDatum!.avaibility.toString());

    if (stock == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 203, 196, 227),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/boxes.png"),
          const SizedBox(width: 8),
          Text(
            "Available Units: $stock",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  bool get _isProductInStock {
    final stock =
        int.tryParse(productDetailDatum?.avaibility?.toString() ?? '0') ?? 0;
    return stock > 0;
  }

  bool _shouldHideSalePrice() {
    final saleValue = double.tryParse(
            productDetailDatum?.salePrice?.toString().replaceAll(',', '') ??
                '') ??
        0;
    if (saleValue <= 0) return true;
    if (_isExpired) return true;
    if (productDetailDatum?.offerEnd?.toString().trim() == '1') return true;
    return false;
  }

  bool _shouldHidePercentOff() {
    if (productDetailDatum?.offerEnd?.toString().trim() == '1') return true;
    if (_isExpired) return true;
    return false;
  }

  int? _getRoundedPercentOff() {
    if (productDetailDatum?.percentOff == null) return null;

    final dynamic raw = productDetailDatum!.percentOff;
    double? value;

    if (raw is num) {
      value = raw.toDouble();
    } else {
      value = double.tryParse(raw.toString());
    }

    if (value == null) return null;

    return value.round();
  }

  Widget _buildFeaturesSection() {
    if (productDetailDatum?.features == null ||
        productDetailDatum!.features!.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Color> featureColors = [
      const Color(0xFFFDE8D7), // Peach
      const Color(0xFFE2F5D8), // Light Green
      const Color(0xFFE3F2FD),
      const Color(0xFFE9ECEF), // Light Grey
    ];

    final features = productDetailDatum!.features!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];

            return Container(
              width: MediaQuery.of(context).size.width / 4,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: featureColors[index % featureColors.length],
                borderRadius: BorderRadius.circular(12), // Thoda zyada rounded
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    child: Image.network(
                      feature.image ?? '',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.shield_outlined,
                            size: 40, color: Colors.black54);
                      },
                    ),
                  ),
                  Text(
                    feature.heading ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.2, // Text lines ke beech thodi spacing
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            videoTestimonialsHeading ?? "What Our Customers Say",
            style:
                CustomStyles.black16600.copyWith(fontSize: screenWidth * 0.04),
          ),
        ),
        Container(
          height: screenHeight * 0.22,
          padding: const EdgeInsets.only(left: 10),
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
                      builder: (context) => VideoPlayerScreen(
                          videoId: video.videoId, title: video.title),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.7,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                      )
                    ],
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (faqHeading != null && faqHeading!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              child: Text(
                faqHeading!,
                style: CustomStyles.black16600.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.04),
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
                  collapsedIconColor: Colors.grey.shade700,
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
      ),
    );
  }

  bool _isNumericGuestToken(String? token) {
    if (token == null || token.isEmpty) return false;
    return int.tryParse(token) != null;
  }

  String? _productYoutubeVideoId() {
    final v = productDetailDatum?.video;
    if (v == null) return null;
    if ((v.type ?? '').toLowerCase() != 'youtube') return null;
    final id = v.videoId?.trim();
    if (id != null && id.isNotEmpty) return id;
    final url = v.videoUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return YoutubePlayer.convertUrlToId(url);
  }

  DateTime? _parseDeliveryDdMmYyyy(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return DateFormat('dd-MM-yyyy').parseStrict(raw.trim());
    } catch (_) {
      return null;
    }
  }

  String _formatDeliveryDate(DateTime d) {
    return DateFormat('EEE, d MMM y').format(d);
  }

  bool _shouldShowEstimatedDelivery() {
    final t = widget.type;
    if (t == 'pooja' || t == 'report') return false;
    final ed = productDetailDatum?.estimatedDelivery;
    if (ed == null) return false;
    final from = ed.from?.trim() ?? '';
    final to = ed.to?.trim() ?? '';
    return from.isNotEmpty && to.isNotEmpty;
  }

  Future<void> _openAstrologerList(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');
    if (!mounted) return;
    if (apiToken == null ||
        apiToken!.isEmpty ||
        apiToken!.length == 12 ||
        _isNumericGuestToken(apiToken)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            redirectScreen: AstrologerListScreen(mode: mode),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AstrologerListScreen(mode: mode),
        ),
      );
    }
  }

  Widget _buildProductYoutubeAboveFaqSection() {
    final id = _productYoutubeVideoId();
    if (id == null) return const SizedBox.shrink();
    final screenWidth = MediaQuery.of(context).size.width;
    final v = productDetailDatum!.video!;
    final customThumb = v.image?.trim();
    final thumbUrl = (customThumb != null && customThumb.isNotEmpty)
        ? customThumb
        : 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    final title = v.title?.trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: CustomStyles.black16600
                    .copyWith(fontSize: screenWidth * 0.04),
              ),
            ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      videoId: id,
                      title: v.title,
                    ),
                  ),
                );
              },
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      thumbUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.play_circle_outline, size: 56),
                      ),
                    ),
                    Container(
                      color: Colors.black26,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 52),
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

  Widget _buildEstimatedDeliveryAndGuidanceSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const accentGreen = Color(0xFF1BAF1A);
    const chatGreen = CustomStyles.chatActionGreen;
    const callBlue = CustomStyles.callActionBlue;
    final double buttonHeight = screenHeight * 0.048;
    final double buttonFontSize = screenWidth * 0.028;
    final double iconSize = screenWidth * 0.04;
    final double cartShadowBlur = screenWidth * 0.015;
    final double shadowOffset = screenHeight * 0.004;
    final double finalIconSize = iconSize.clamp(10, 12);
    final double borderRadius = screenWidth * 0.080;
    final showDelivery = _shouldShowEstimatedDelivery();
    final ed = productDetailDatum?.estimatedDelivery;
    DateTime? dFrom;
    DateTime? dTo;
    String? fromLabel;
    String? toLabel;
    if (showDelivery && ed != null) {
      dFrom = _parseDeliveryDdMmYyyy(ed.from);
      dTo = _parseDeliveryDdMmYyyy(ed.to);
      fromLabel =
          dFrom != null ? _formatDeliveryDate(dFrom) : (ed.from ?? '').trim();
      toLabel = dTo != null ? _formatDeliveryDate(dTo) : (ed.to ?? '').trim();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDelivery && fromLabel != null && toLabel != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 22, color: Colors.grey.shade900),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expected Delivery',
                          style: CustomStyles.black14500.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.038,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: CustomStyles.black12500.copyWith(
                              fontSize: screenWidth * 0.034,
                              height: 1.35,
                              color: Colors.black87,
                            ),
                            children: [
                              const TextSpan(text: 'Between '),
                              TextSpan(
                                text: fromLabel,
                                style: const TextStyle(
                                  color: accentGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' to '),
                              TextSpan(
                                text: toLabel,
                                style: const TextStyle(
                                  color: accentGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Guidance Before Buying?',
                  style: CustomStyles.black14500.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.036,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _openAstrologerList('chat'),
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Container(
                          height: buttonHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            color: chatGreen,
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
                                  'assets/chat-dots-fill.png',
                                  color: Colors.white,
                                  height: finalIconSize,
                                  width: finalIconSize,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Flexible(
                                child: Text(
                                  'Chat With Astrologers',
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => _openAstrologerList('call'),
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Container(
                          height: buttonHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            color: callBlue,
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
                                'assets/callring.png',
                                color: Colors.white,
                                height: iconSize,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Flexible(
                                child: Text(
                                  'Talk To Astrologers',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTestimonialsSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Text(
            textTestimonialsHeading ?? "Testimonials",
            style:
                CustomStyles.black16600.copyWith(fontSize: screenWidth * 0.04),
          ),
        ),
        Container(
          height: screenHeight * 0.18,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: textTestimonials.length,
            itemBuilder: (context, index) {
              final testimonial = textTestimonials[index];
              return Container(
                width: screenWidth * 0.85,
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

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }

    try {
      final DateTime parsedDate = DateTime.parse(dateString);

      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  List<List<Field>> structureFormFields(List<Field> flatFields) {
    if (flatFields.isEmpty) {
      return [];
    }

    final Set<String> uniqueKeys = {};
    int fieldsPerPerson = 0;

    for (final field in flatFields) {
      if (uniqueKeys.contains(field.key)) {
        break;
      }
      uniqueKeys.add(field.key!);
      fieldsPerPerson++;
    }

    if (fieldsPerPerson == 0) {
      return [];
    }

    final List<List<Field>> structuredForm = [];
    for (int i = 0; i < flatFields.length; i += fieldsPerPerson) {
      structuredForm.add(flatFields.sublist(i, i + fieldsPerPerson));
    }

    return structuredForm;
  }

  String? _poojaExpireDisplayLine() {
    final raw = productDetailDatum?.expireAt?.trim();
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateFormat("dd-MM-yyyy hh:mm a").parse(raw);
      return DateFormat("d MMM, yyyy").format(dt);
    } catch (_) {
      try {
        final dt = DateFormat("dd-MM-yyyy").parse(raw);
        return DateFormat("d MMM, yyyy").format(dt);
      } catch (_) {
        try {
          final dt = DateTime.parse(raw);
          return DateFormat("d MMM, yyyy").format(dt);
        } catch (_) {
          return raw;
        }
      }
    }
  }

  Widget _buildDetailIconTextRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _kDetailIconSlot,
          height: _kDetailIconSlot,
          child: Center(
            child: Icon(
              icon,
              size: _kDetailIconSize,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.25,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPoojaPlaceDateBlock() {
    if (widget.type != 'pooja') return const SizedBox.shrink();
    final pl = productDetailDatum?.place?.trim() ?? '';
    final dtLine = _poojaExpireDisplayLine();
    if (pl.isEmpty && dtLine == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pl.isNotEmpty)
            _buildDetailIconTextRow(
              icon: Icons.location_on_rounded,
              text: pl,
            ),
          if (pl.isNotEmpty && dtLine != null) const SizedBox(height: 4),
          if (dtLine != null)
            _buildDetailIconTextRow(
              icon: Icons.calendar_today_rounded,
              text: dtLine,
            ),
        ],
      ),
    );
  }

  Widget _buildOfferEndCountdownLabel() {
    final String label = widget.type == 'pooja'
        ? 'Puja Booking Will Close In :'
        : 'Offer End in :';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _kDetailIconSlot,
          height: _kDetailIconSlot,
          child: const Center(
            child: Icon(
              Icons.access_time_rounded,
              color: Colors.black87,
              size: _kDetailIconSize,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              height: 1.25,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _buyFormFieldKeyNorm(String? k) {
    if (k == null || k.isEmpty) return '';
    return k.toLowerCase().replaceAll('-', '_');
  }

  InputDecoration _buyFormInputDecoration(
      {Widget? suffixIcon, String? hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      isDense: false,
      hintText: hintText,
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
        maxHeight: 40,
      ),
      errorStyle: const TextStyle(fontSize: 11, height: 1.2),
      errorMaxLines: 2,
      contentPadding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blueGrey, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade700),
      ),
    );
  }

  void _removeBuyFormLocationOverlay() {
    _buyFormLocationOverlay?.remove();
    _buyFormLocationOverlay = null;
  }

  FocusNode _buyFormPlaceFocus(String uniqueKey) {
    return _buyFormPlaceFocusNodes.putIfAbsent(uniqueKey, () {
      final n = FocusNode();
      n.addListener(() {
        if (!n.hasFocus) {
          _removeBuyFormLocationOverlay();
        }
      });
      return n;
    });
  }

  Future<void> _searchBuyFormLocation(
    String query,
    String uniqueKey,
    BuildContext fieldContext,
    StateSetter setDialogState,
  ) async {
    if (query.length < 2) {
      _removeBuyFormLocationOverlay();
      return;
    }
    _removeBuyFormLocationOverlay();
    setState(() {
      _buyFormLoadingLocations = true;
      _buyFormLocationSuggestions = [];
    });
    _showBuyFormLocationOverlay(uniqueKey, fieldContext, setDialogState);
    try {
      final response = await AstroApiService.searchLocations(query);
      if (!mounted) return;
      setState(() {
        _buyFormLoadingLocations = false;
        _buyFormLocationSuggestions = response?.data ?? [];
      });
      _showBuyFormLocationOverlay(uniqueKey, fieldContext, setDialogState);
      setDialogState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _buyFormLoadingLocations = false;
        _buyFormLocationSuggestions = [];
      });
      _showBuyFormLocationOverlay(uniqueKey, fieldContext, setDialogState);
      setDialogState(() {});
    }
  }

  void _showBuyFormLocationOverlay(
    String uniqueKey,
    BuildContext fieldContext,
    StateSetter setDialogState,
  ) {
    _removeBuyFormLocationOverlay();
    final overlayState = Overlay.of(context);
    final renderBox = fieldContext.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _buyFormLocationOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.white,
            constraints: BoxConstraints(maxHeight: 200),
            child: _buyFormLoadingLocations
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _buyFormLocationSuggestions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No locations found'),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _buyFormLocationSuggestions.length,
                        separatorBuilder: (_, __) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final location = _buyFormLocationSuggestions[index];
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
                              controllers[uniqueKey]?.text = location.fullName;
                              _removeBuyFormLocationOverlay();
                              setDialogState(() {});
                            },
                          );
                        },
                      ),
          ),
        ),
      ),
    );
    overlayState.insert(_buyFormLocationOverlay!);
  }

  void _shareProduct() {
    final name = productDetailDatum?.title ?? widget.productname ?? '';
    final slug = currentSlug ?? productDetailDatum?.slug ?? widget.slug ?? '';
    final url = slug.isNotEmpty
        ? '${CustomStyles.webBaseUrl}/products/$slug'
        : CustomStyles.webBaseUrl;
    final text = name.isNotEmpty ? '$name\n$url' : url;
    Share.share(text);
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
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomAppBarScreen()),
                    );
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();

    getProductDetailListData();
  }

  final ScrollController _outerScrollController = ScrollController();
  final List<ScrollController> _innerScrollControllers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _removeBuyFormLocationOverlay();
    for (final n in _buyFormPlaceFocusNodes.values) {
      n.dispose();
    }
    _buyFormPlaceFocusNodes.clear();
    _timer?.cancel();
    _outerScrollController.dispose();
    pageController.dispose();
    for (final controller in _innerScrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool showBookingClosed =
        _isExpired || productDetailDatum?.canPurchase != true;
    return WillPopScope(
      onWillPop: () async {
        _handleBackNavigation();
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            backgroundColor: CustomStyles.whiteColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () async {
                  _handleBackNavigation();
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ),
            title:
                productDetailDatum?.title ?? widget.productname ?? 'details'.tr,
            actions: [
              if (widget.type != 'service')
                IconButton(
                  onPressed: _shareProduct,
                  icon: const Icon(Icons.share_outlined,
                      color: Colors.deepOrange),
                ),
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
          body: isloading
              ? const ProductDetailLoadingShimmer()
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: 10,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: gallerylist.length,
                              onPageChanged: (index) {
                                setState(() => currentIndex = index);
                              },
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ZoomableImageGallery(
                                              images: gallerylist,
                                              initialIndex: index,
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          gallerylist[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.error,
                                                size: 40,
                                                color: Colors.red,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ZoomableImageGallery(
                                                images: gallerylist,
                                                initialIndex: index,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.zoom_in,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        if (gallerylist.length > 1)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: screenHeight * 0.06,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: gallerylist.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        currentIndex = index;
                                        pageController.animateToPage(
                                          index,
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      width: screenWidth * 0.12,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: currentIndex == index
                                              ? Colors.blue
                                              : Colors.black,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        image: DecorationImage(
                                          image:
                                              NetworkImage(gallerylist[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productDetailDatum?.title ?? '',
                                style: CustomStyles.black18600.copyWith(
                                    fontSize: screenWidth *
                                        0.045), // Responsive font size
                                maxLines: 2,
                              ),
                              SizedBox(height: 10),
                              if (productDetailDatum?.shortDescription !=
                                      null &&
                                  productDetailDatum!
                                      .shortDescription!.isNotEmpty) ...[
                                Text(
                                  'short_description'.tr,
                                  style: CustomStyles.black16600.copyWith(
                                      fontSize: screenWidth *
                                          0.04), // Responsive font size
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                HtmlWidget(
                                  productDetailDatum?.shortDescription ?? '',
                                  textStyle: CustomStyles.black14500
                                      .copyWith(fontSize: screenWidth * 0.035),
                                ),
                              ],
                              SizedBox(height: 6),
                              if (productDetailDatum?.rating != null &&
                                  productDetailDatum!.rating! > 0)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RatingBarIndicator(
                                      rating: productDetailDatum!.rating!
                                          .toDouble(),
                                      itemBuilder: (context, index) =>
                                          const Icon(
                                        Icons.star,
                                        color: Color(0xffFFAF12),
                                      ),
                                      itemCount: 5,
                                      itemSize: 18,
                                      direction: Axis.horizontal,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "(${productDetailDatum!.rating!.toStringAsFixed(1)})",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              if (productDetailDatum?.rating != null &&
                                  productDetailDatum!.rating! > 0)
                                SizedBox(height: 4),
                              _buildPoojaPlaceDateBlock(),
                              if (((widget.type == 'pooja' &&
                                          productDetailDatum?.offerEnd
                                                  ?.toString()
                                                  .trim() !=
                                              '1') ||
                                      ((widget.type == 'gemstone' ||
                                              widget.type == 'rudraksha' ||
                                              widget.type == 'service' ||
                                              widget.type == 'report') &&
                                          productDetailDatum?.offerEnd
                                                  ?.toString()
                                                  .trim() !=
                                              '1')) &&
                                  !showBookingClosed &&
                                  !_isExpired &&
                                  _remainingTime != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4, bottom: 4, left: 2, right: 2),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildOfferEndCountdownLabel(),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          _buildTimeUnit(
                                            _remainingTime!.inDays.toString(),
                                            "Days",
                                            CustomStyles.offerCountdownDaysBg,
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          _buildTimeUnit(
                                            (_remainingTime!.inHours
                                                    .remainder(24))
                                                .toString(),
                                            "Hours",
                                            CustomStyles.offerCountdownHoursBg,
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          _buildTimeUnit(
                                            (_remainingTime!.inMinutes
                                                    .remainder(60))
                                                .toString(),
                                            "Minutes",
                                            CustomStyles
                                                .offerCountdownMinutesBg,
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          _buildTimeUnit(
                                            (_remainingTime!.inSeconds
                                                    .remainder(60))
                                                .toString(),
                                            "Seconds",
                                            CustomStyles
                                                .offerCountdownSecondsBg,
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: 2,
                              ),
                              if (widget.type != 'pooja' &&
                                  widget.type != 'service')
                                _buildAvailabilitySection(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _shouldHideSalePrice()
                                      ? Text(
                                          '₹ ${productDetailDatum?.basePrice}',
                                          style: CustomStyles.red15600.copyWith(
                                              fontSize: screenWidth * 0.04),
                                        )
                                      : RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'price'.tr,
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              TextSpan(
                                                  text:
                                                      '₹ ${productDetailDatum?.basePrice ?? ''}',
                                                  style: CustomStyles.grey14600
                                                      .copyWith(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    color: Colors.grey,
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                  )),
                                              TextSpan(
                                                text:
                                                    "  ₹ ${productDetailDatum?.salePrice ?? ''}",
                                                style: CustomStyles.red15600
                                                    .copyWith(
                                                        fontSize:
                                                            screenWidth * 0.04),
                                              ),
                                            ],
                                          ),
                                        ),
                                  const SizedBox(width: 8),
                                  Builder(builder: (context) {
                                    if (_shouldHidePercentOff()) {
                                      return const SizedBox.shrink();
                                    }
                                    final int? roundedPercent =
                                        _getRoundedPercentOff();
                                    if (roundedPercent == null ||
                                        roundedPercent <= 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "$roundedPercent% OFF",
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.032,
                                        ),
                                      ),
                                    );
                                  }),
                                  if (_isUpdatingAttributes) ...[
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ],
                                ],
                              ),

                              if (productDetailDatum?.hasVariation == true &&
                                  originlist.isNotEmpty) ...[
                                SizedBox(height: 10),
                                Text('Origin',
                                    style: CustomStyles.black16600.copyWith(
                                        fontSize: screenWidth * 0.04)),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12, //
                                  children: originlist.map((originItem) {
                                    bool isSelected =
                                        selectedOrigin == originItem.name;
                                    bool isAvailable =
                                        originItem.available == true;

                                    return GestureDetector(
                                      onTap: _isUpdatingAttributes
                                          ? null
                                          : () {
                                              if (isAvailable) {
                                                setState(() {
                                                  selectedOrigin =
                                                      originItem.name;
                                                });
                                                updateProductForAttributes();
                                              }
                                            },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.red
                                              : (isAvailable
                                                  ? Colors.white
                                                  : Colors.grey.shade100),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.red
                                                : Colors.grey.shade400,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4), //
                                        ),
                                        child: Text(
                                          originItem.name.toString(),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],

// ------
                              if (productDetailDatum?.hasVariation == true &&
                                  caratlist.isNotEmpty) ...[
                                SizedBox(height: 15),
                                Text('Carat',
                                    style: CustomStyles.black16600.copyWith(
                                        fontSize: screenWidth * 0.04)),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12, //
                                  children: caratlist.map((caratItem) {
                                    bool isSelected =
                                        selectedCarat == caratItem.name;
                                    bool isAvailable =
                                        caratItem.available == true;

                                    return GestureDetector(
                                      onTap: _isUpdatingAttributes
                                          ? null
                                          : () {
                                              if (isAvailable) {
                                                setState(() {
                                                  selectedCarat =
                                                      caratItem.name;
                                                });
                                                updateProductForAttributes();
                                              }
                                            },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.red
                                              : (isAvailable
                                                  ? Colors.white
                                                  : Colors.grey.shade100),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.red
                                                : Colors.grey.shade400,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          caratItem.name.toString(),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                              if (productDetailDatum?.hasVariation == true &&
                                  colorlist.isNotEmpty) ...[
                                SizedBox(height: 10),
                                Text('select_color'.tr,
                                    style: CustomStyles.black16600.copyWith(
                                        fontSize: screenWidth * 0.04)), //
                                SizedBox(height: 5),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: colorlist.map((colorName) {
                                    bool isSelected =
                                        selectedColor == colorName.name;
                                    bool isAvailable =
                                        colorName.available == true;
                                    return GestureDetector(
                                      onTap: _isUpdatingAttributes
                                          ? null
                                          : () {
                                              if (isAvailable) {
                                                setState(() {
                                                  selectedColor =
                                                      colorName.name;
                                                });
                                                updateProductForAttributes();
                                              }
                                            },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? CustomStyles
                                                  .callActionBackground
                                              : (isAvailable
                                                  ? Colors.white
                                                  : Colors.grey.shade100),
                                          border: Border.all(
                                            color: isSelected
                                                ? CustomStyles
                                                    .callActionBackground
                                                : Colors.grey.shade400,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          colorName.name.toString(),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                              if (productDetailDatum?.hasVariation == true &&
                                  sizelist.isNotEmpty) ...[
                                SizedBox(height: 10),
                                Text('select_size'.tr,
                                    style: CustomStyles.black16600.copyWith(
                                        fontSize: screenWidth * 0.04)), //
                                SizedBox(height: 5),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: sizelist.map((size) {
                                    bool isSelected = selectedSize == size.name;
                                    bool isAvailable = size.available == true;
                                    return GestureDetector(
                                      onTap: _isUpdatingAttributes
                                          ? null
                                          : () {
                                              if (isAvailable) {
                                                setState(() {
                                                  selectedSize = size.name;
                                                });
                                                updateProductForAttributes();
                                              }
                                            },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? CustomStyles
                                                  .callActionBackground
                                              : (isAvailable
                                                  ? Colors.white
                                                  : Colors.grey.shade100),
                                          border: Border.all(
                                            color: isSelected
                                                ? CustomStyles
                                                    .callActionBackground
                                                : Colors.grey.shade400,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          size.name.toString(),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],

                              if (productDetailDatum?.hasVariation == true &&
                                  stylelist.isNotEmpty) ...[
                                SizedBox(height: 15),
                                Text('Style',
                                    style: CustomStyles.black16600.copyWith(
                                        fontSize: screenWidth * 0.04)),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: stylelist.map((styleItem) {
                                    bool isSelected =
                                        selectedStyle == styleItem.name;
                                    bool isAvailable =
                                        styleItem.available == true;

                                    return GestureDetector(
                                      onTap: _isUpdatingAttributes
                                          ? null
                                          : () {
                                              if (isAvailable) {
                                                setState(() {
                                                  selectedStyle =
                                                      styleItem.name;
                                                });
                                                updateProductForAttributes();
                                              }
                                            },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.red
                                              : (isAvailable
                                                  ? Colors.white
                                                  : Colors.grey.shade100),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.red
                                                : Colors.grey.shade400,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          styleItem.name.toString(),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                              if (productDetailDatum?.hasVariation == true &&
                                  weigthlist.isNotEmpty) ...[
                                SizedBox(height: 10),
                                Text('select_weight'.tr,
                                    style: CustomStyles.black16600.copyWith(
                                        fontSize: screenWidth * 0.04)), //
                                SizedBox(height: 5),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: weigthlist.map((weight) {
                                    bool isSelected =
                                        selectedweigth == weight.name;
                                    bool isAvailable = weight.available == true;
                                    return GestureDetector(
                                      onTap: _isUpdatingAttributes
                                          ? null
                                          : () {
                                              if (isAvailable) {
                                                setState(() {
                                                  selectedweigth = weight.name;
                                                });
                                                updateProductForAttributes();
                                              }
                                            },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.red
                                              : (isAvailable
                                                  ? Colors.white
                                                  : Colors.grey.shade100),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.red
                                                : Colors.grey.shade400,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          weight.name.toString(),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],

                              if (productDetailDatum?.hasVariation == true &&
                                  typelist.isNotEmpty) ...[
                                SizedBox(height: 10),
                                Text('select_type'.tr,
                                    style: CustomStyles.black16600.copyWith(
                                        fontSize: screenWidth *
                                            0.04)), // Responsive font size
                                SizedBox(height: 5),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: typelist.map((type) {
                                    bool isSelected = selectedtype == type.name;
                                    bool isAvailable = type.available == true;
                                    return GestureDetector(
                                      onTap: _isUpdatingAttributes
                                          ? null
                                          : () {
                                              if (isAvailable) {
                                                setState(() {
                                                  selectedtype = type.name;
                                                });
                                                updateProductForAttributes();
                                              }
                                            },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? CustomStyles
                                                  .callActionBackground
                                              : (isAvailable
                                                  ? Colors.white
                                                  : Colors.grey.shade100),
                                          border: Border.all(
                                            color: isSelected
                                                ? CustomStyles
                                                    .callActionBackground
                                                : Colors.grey.shade400,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          type.name.toString(),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: widget.type == 'gemstone' ||
                                        widget.type == 'rudraksha'
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          //
                                          Expanded(
                                            child: _isProductInStock
                                                ? CustomOutlinedButton(
                                                    bordercolor:
                                                        CustomStyles.pinki,
                                                    backgroundColor:
                                                        CustomStyles.pinki,
                                                    text: 'add_to_cart'.tr,
                                                    onPressed: () {
                                                      getaddtocartdata();
                                                    },
                                                  )
                                                : CustomOutlinedButton(
                                                    bordercolor: Colors.grey,
                                                    text: 'out_of_stock'.tr,
                                                    onPressed: null,
                                                  ),
                                          ),
                                          if (_isProductInStock) ...[
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: CustomOutlinedButton(
                                                bordercolor: CustomStyles.pinki,
                                                backgroundColor:
                                                    CustomStyles.pinki,
                                                text: 'buy_now'.tr,
                                                onPressed: () async {
                                                  await getaddtocartdata(
                                                      forBuyNow: true);
                                                  if (!mounted) return;
                                                  BuyNowCart.activate();
                                                  final cartItemId =
                                                      addtoCartModel?.data?.id;
                                                  final guest =
                                                      await isGuestUser();
                                                  if (guest) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            LoginScreen(
                                                          redirectScreen:
                                                              CheckoutScreen(
                                                            itemType: 0,
                                                            isBuyNow: true,
                                                            buyNowProductId:
                                                                productitemid,
                                                            buyNowCartItemId:
                                                                cartItemId,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CheckoutScreen(
                                                          itemType: 0,
                                                          isBuyNow: true,
                                                          buyNowProductId:
                                                              productitemid,
                                                          buyNowCartItemId:
                                                              cartItemId,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                          // 3. Wishlist
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: toggleFavorite,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color:
                                                        CustomStyles.whiteColor,
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade400)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Flexible(
                                                      child: Text('wishlist'.tr,
                                                          style: CustomStyles
                                                              .black14600,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      isFavorite
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: Colors.red,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : widget.type == 'pooja'
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: !showBookingClosed
                                                    ? CustomOutlinedButton(
                                                        bordercolor:
                                                            CustomStyles.pinki,
                                                        backgroundColor:
                                                            CustomStyles.pinki,
                                                        text: 'participate'.tr,
                                                        onPressed: () async {
                                                          if (productDetailDatum
                                                                  ?.form
                                                                  ?.fields
                                                                  ?.isNotEmpty ==
                                                              true) {
                                                            showBuyNowDialog();
                                                          } else {
                                                            await getaddtocartdata();
                                                            if (!mounted)
                                                              return;
                                                            final guest =
                                                                await isGuestUser();
                                                            if (guest) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          LoginScreen(
                                                                    redirectScreen:
                                                                        CheckoutScreen(
                                                                            itemType:
                                                                                1),
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      CheckoutScreen(
                                                                          itemType:
                                                                              1),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                      )
                                                    : CustomOutlinedButton(
                                                        bordercolor:
                                                            Colors.grey,
                                                        backgroundColor: Colors
                                                            .grey.shade300,
                                                        text:
                                                            'booking_closed'.tr,
                                                        onPressed: null,
                                                      ),
                                              ),
                                            ],
                                          )
                                        : widget.type == 'service'
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if (productDetailDatum
                                                              ?.canPurchase !=
                                                          false &&
                                                      _isProductInStock) ...[
                                                    Expanded(
                                                      child:
                                                          CustomOutlinedButton(
                                                        backgroundColor:
                                                            CustomStyles.pinki,
                                                        bordercolor:
                                                            CustomStyles.pinki,
                                                        text: 'buy_now'.tr,
                                                        onPressed: () async {
                                                          if (productDetailDatum
                                                                  ?.form
                                                                  ?.fields
                                                                  ?.isNotEmpty ==
                                                              true) {
                                                            showBuyNowDialog();
                                                          } else {
                                                            await getaddtocartdata();
                                                            if (!mounted)
                                                              return;
                                                            final guest =
                                                                await isGuestUser();
                                                            if (guest) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          LoginScreen(
                                                                    redirectScreen:
                                                                        CheckoutScreen(
                                                                            itemType:
                                                                                1),
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      CheckoutScreen(
                                                                          itemType:
                                                                              1),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],

                                                  SizedBox(width: 10),

                                                  // 2. Share Button
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: _shareProduct,
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 16,
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: CustomStyles
                                                              .whiteColor,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade400),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                'share'.tr,
                                                                style: CustomStyles
                                                                    .black14600,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Icon(
                                                              Icons.share,
                                                              size: 20,
                                                              color: Colors
                                                                  .deepOrange,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : widget.type == 'report'
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      if (productDetailDatum
                                                                  ?.canPurchase !=
                                                              false &&
                                                          _isProductInStock) ...[
                                                        Expanded(
                                                          child:
                                                              CustomOutlinedButton(
                                                            backgroundColor:
                                                                CustomStyles
                                                                    .pinki,
                                                            bordercolor:
                                                                CustomStyles
                                                                    .pinki,
                                                            text: 'buy_now'.tr,
                                                            onPressed:
                                                                () async {
                                                              if (productDetailDatum
                                                                      ?.form
                                                                      ?.fields
                                                                      ?.isNotEmpty ==
                                                                  true) {
                                                                showBuyNowDialog();
                                                              } else {
                                                                await getaddtocartdata();
                                                                if (!mounted)
                                                                  return;
                                                                final guest =
                                                                    await isGuestUser();
                                                                if (guest) {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              LoginScreen(
                                                                        redirectScreen:
                                                                            CheckoutScreen(itemType: 1),
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          CheckoutScreen(
                                                                              itemType: 1),
                                                                    ),
                                                                  );
                                                                }
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: _shareProduct,
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: CustomStyles
                                                                  .whiteColor,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    'share'.tr,
                                                                    style: CustomStyles
                                                                        .black14600,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 8),
                                                                Icon(
                                                                  Icons.share,
                                                                  size: 20,
                                                                  color: Colors
                                                                      .deepOrange,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    //
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      //
                                                      Expanded(
                                                        child: _isProductInStock
                                                            ? CustomOutlinedButton(
                                                                bordercolor:
                                                                    CustomStyles
                                                                        .pinki,
                                                                backgroundColor:
                                                                    CustomStyles
                                                                        .pinki,
                                                                text:
                                                                    'add_to_cart'
                                                                        .tr,
                                                                onPressed: () {
                                                                  getaddtocartdata();
                                                                },
                                                              )
                                                            : CustomOutlinedButton(
                                                                bordercolor:
                                                                    Colors.grey,
                                                                text:
                                                                    'out_of_stock'
                                                                        .tr,
                                                                onPressed: null,
                                                              ),
                                                      ),
                                                      if (_isProductInStock) ...[
                                                        SizedBox(width: 10),
                                                        Expanded(
                                                          child:
                                                              CustomOutlinedButton(
                                                            bordercolor:
                                                                CustomStyles
                                                                    .pinki,
                                                            backgroundColor:
                                                                CustomStyles
                                                                    .pinki,
                                                            text: 'buy_now'.tr,
                                                            onPressed:
                                                                () async {
                                                              await getaddtocartdata(
                                                                  forBuyNow:
                                                                      true);
                                                              if (!mounted)
                                                                return;
                                                              BuyNowCart
                                                                  .activate();
                                                              final cartItemId =
                                                                  addtoCartModel
                                                                      ?.data
                                                                      ?.id;
                                                              final guest =
                                                                  await isGuestUser();
                                                              if (guest) {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            LoginScreen(
                                                                      redirectScreen: CheckoutScreen(
                                                                          itemType:
                                                                              0,
                                                                          isBuyNow:
                                                                              true,
                                                                          buyNowProductId:
                                                                              productitemid,
                                                                          buyNowCartItemId:
                                                                              cartItemId),
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => CheckoutScreen(
                                                                        itemType:
                                                                            0,
                                                                        isBuyNow:
                                                                            true,
                                                                        buyNowProductId:
                                                                            productitemid,
                                                                        buyNowCartItemId:
                                                                            cartItemId),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                      //
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: toggleFavorite,
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        10),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                color: CustomStyles
                                                                    .whiteColor,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade400)),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                      'wishlist'
                                                                          .tr,
                                                                      style: CustomStyles
                                                                          .black14600,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                ),
                                                                SizedBox(
                                                                    width: 8),
                                                                Icon(
                                                                  isFavorite
                                                                      ? Icons
                                                                          .favorite
                                                                      : Icons
                                                                          .favorite_border,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 20,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                              ),
                              _buildEstimatedDeliveryAndGuidanceSection(),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  //
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade200)),
                                  child: ExpansionTile(
                                    //
                                    backgroundColor: Colors.white,
                                    collapsedBackgroundColor:
                                        Colors.grey.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    collapsedShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    title: Text(
                                      'Description',
                                      //
                                      style: CustomStyles.black14500,
                                    ),

                                    childrenPadding: const EdgeInsets.all(16)
                                        .copyWith(top: 0),
                                    iconColor: Colors.deepOrange,
                                    collapsedIconColor: Colors.grey.shade700,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: HtmlWidget(
                                          productDetailDatum?.description ?? '',
                                          //
                                          textStyle: CustomStyles.black12500
                                              .copyWith(height: 1.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (widget.type != 'pooja' &&
                                  widget.type != 'service') ...[
                                // const SizedBox(height: 8),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade200)),
                                  child: ExpansionTile(
                                    backgroundColor: Colors.white,
                                    collapsedBackgroundColor:
                                        Colors.grey.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    collapsedShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    title: Text(
                                      'Kilograms',
                                      style: CustomStyles.black14500,
                                    ),
                                    childrenPadding: const EdgeInsets.all(16)
                                        .copyWith(top: 0),
                                    iconColor: Colors.deepOrange,
                                    collapsedIconColor: Colors.grey.shade700,
                                    children: [
                                      Builder(builder: (context) {
                                        final specs =
                                            productDetailDatum?.specifications;
                                        if (specs == null || specs.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        String? kilogramValue;
                                        for (final spec in specs) {
                                          final heading = (spec.heading ?? '')
                                              .toLowerCase();
                                          if (heading == 'kilograms' ||
                                              heading == 'kilogram' ||
                                              heading == 'kg') {
                                            kilogramValue = spec.text;
                                            break;
                                          }
                                        }

                                        if (kilogramValue == null ||
                                            kilogramValue.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            kilogramValue,
                                            style: CustomStyles.black12500,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                // _buildAvailabilitySection(),

                                _buildFeaturesSection(),
                              ],
                            ],
                          ),
                        ),
                        if (productDetailDatum?.reviewsCount != null &&
                            productDetailDatum!.reviewsCount! > 0) ...[
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'rating_reviews'.trParams(),
                                  style: CustomStyles.black16600.copyWith(
                                      fontSize: screenWidth *
                                          0.04), // Responsive font size
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  //
                                  "verified_rating_note".tr,
                                  style: CustomStyles.black12500.copyWith(
                                      fontSize: screenWidth * 0.03), //
                                )),
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  //
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    //
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: (productDetailDatum
                                                              ?.rating ??
                                                          0)
                                                      .toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    fontSize: 42,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: "/5",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          RatingBarIndicator(
                                            rating:
                                                (productDetailDatum?.rating ??
                                                        0)
                                                    .toDouble(),
                                            itemBuilder: (context, index) =>
                                                const Icon(
                                              Icons.star_rounded,
                                              color: Color(0xffFFAF12),
                                            ),
                                            itemCount: 5,
                                            itemSize: 22.0,
                                            direction: Axis.horizontal,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "${productDetailDatum?.reviewsCount} Reviews",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    //
                                    Container(
                                      height: 100,
                                      width: 1,
                                      color: Colors.grey.shade300,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                    ),

                                    //
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildStarRatingBar(
                                              5,
                                              productDetailDatum
                                                      ?.ratingOverview!.five ??
                                                  0,
                                              productDetailDatum
                                                      ?.reviewsCount ??
                                                  1),
                                          _buildStarRatingBar(
                                              4,
                                              productDetailDatum
                                                      ?.ratingOverview!.four ??
                                                  0,
                                              productDetailDatum
                                                      ?.reviewsCount ??
                                                  1),
                                          _buildStarRatingBar(
                                              3,
                                              productDetailDatum
                                                      ?.ratingOverview!.three ??
                                                  0,
                                              productDetailDatum
                                                      ?.reviewsCount ??
                                                  1),
                                          _buildStarRatingBar(
                                              2,
                                              productDetailDatum
                                                      ?.ratingOverview!.two ??
                                                  0,
                                              productDetailDatum
                                                      ?.reviewsCount ??
                                                  1),
                                          _buildStarRatingBar(
                                              1,
                                              productDetailDatum
                                                      ?.ratingOverview!.one ??
                                                  0,
                                              productDetailDatum
                                                      ?.reviewsCount ??
                                                  1),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (canReview) ...[
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              decoration: BoxDecoration(
                                  border: Border.all(color: CustomStyles.pinki),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                      height: screenHeight * 0.1,
                                      title: "Submit a Review",
                                      label: "Write a Review",
                                      controller: reviewcontroller,
                                      maxline: 3),
                                  RatingBar.builder(
                                    initialRating: 0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 20,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Color(0xffFFAF12),
                                    ),
                                    onRatingUpdate: (rating) {
                                      setState(() {
                                        currentrating = rating;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  Center(
                                    child: CustomElevatedButton(
                                      text: "Submit Review",
                                      onPressed: () async {
                                        if (reviewcontroller.text.isEmpty) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'Kindly write your review before submitting.');
                                          return;
                                        }
                                        if (currentrating == null ||
                                            currentrating == 0) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'Kindly provide a rating before submitting.');
                                          return;
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ],
                        productReviews.isEmpty
                            ? SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  'clients_feedback'.tr,
                                  style: CustomStyles.black16600
                                      .copyWith(fontSize: screenWidth * 0.04),
                                ),
                              ),
                        productReviews.isEmpty
                            ? SizedBox.shrink()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                  height: screenHeight * 0.2,
                                  child: ListView.builder(
                                    controller: _outerScrollController,
                                    itemCount: productReviews.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      if (_innerScrollControllers.length <=
                                          index) {
                                        _innerScrollControllers
                                            .add(ScrollController());
                                      }
                                      final innerController =
                                          _innerScrollControllers[index];
                                      final reviewItem = productReviews[index];

                                      return SizedBox(
                                        width: screenWidth * 0.75,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: Card(
                                            elevation: 2,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CircleAvatar(
                                                        radius:
                                                            screenWidth * 0.06,
                                                        backgroundImage:
                                                            NetworkImage(reviewItem
                                                                .userImageUrl),
                                                        onBackgroundImageError:
                                                            (_, __) {},
                                                        backgroundColor: Colors
                                                            .grey.shade200,
                                                      ),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              reviewItem
                                                                  .userName,
                                                              style: CustomStyles
                                                                  .black14600
                                                                  .copyWith(
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.038,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            SizedBox(height: 4),
                                                            RatingBarIndicator(
                                                              rating: (reviewItem
                                                                      .rating)
                                                                  .toDouble(),
                                                              itemBuilder:
                                                                  (context,
                                                                          index) =>
                                                                      Icon(
                                                                Icons.star,
                                                                color: Color(
                                                                    0xffFFAF12),
                                                              ),
                                                              itemCount: 5,
                                                              itemSize: 18.0,
                                                              direction: Axis
                                                                  .horizontal,
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              reviewItem.date,
                                                              style: CustomStyles
                                                                  .black12500
                                                                  .copyWith(
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.03,
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(height: 12),
                                                  Expanded(
                                                    child: Scrollbar(
                                                      controller:
                                                          innerController,
                                                      thumbVisibility: true,
                                                      interactive: true,
                                                      thickness: 3,
                                                      child: ListView(
                                                        controller:
                                                            innerController,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 5),
                                                        children: [
                                                          Text(
                                                            HtmlTagsCleaner
                                                                .clean(reviewItem
                                                                    .review),
                                                            style: CustomStyles
                                                                .black12500
                                                                .copyWith(
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.035,
                                                              height: 1.4,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                        // _buildEstimatedDeliveryAndGuidanceSection(),
                        _buildProductYoutubeAboveFaqSection(),
                        _buildFaqSection(),
                        if (similarproductlist.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Text(
                              widget.type == 'service'
                                  ? "Related Services"
                                  : "Related Products",
                              style: CustomStyles.black16600
                                  .copyWith(fontSize: screenWidth * 0.04),
                            ),
                          ),
                        if (similarproductlist.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              height: screenHeight * 0.30, //
                              child: ListView.builder(
                                itemCount: similarproductlist.length,
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final similarItem = similarproductlist[index];

                                  double bPrice = double.tryParse(
                                          similarItem.basePrice.toString()) ??
                                      0;
                                  double sPrice = double.tryParse(
                                          similarItem.salePrice.toString()) ??
                                      0;
                                  final bool useSalePrice =
                                      similarItem.hasActiveSaleOffer;
                                  final double displayPrice =
                                      useSalePrice ? sPrice : bPrice;

                                  return GestureDetector(
                                    onTap: () {
                                      final nextType = _normalizeProductType(
                                          similarItem.type ?? widget.type);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailScreen(
                                                  slug: similarItem.slug,
                                                  itemId: similarItem.id,
                                                  productname: similarItem.name,
                                                  type: nextType,
                                                  parentid: 0,
                                                  goHomeOnBack: true,
                                                )),
                                      );
                                    },
                                    child: Container(
                                      width: screenWidth * 0.4,
                                      margin:
                                          EdgeInsets.only(right: 10, bottom: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                                offset: Offset(0, 2))
                                          ]),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      top: Radius.circular(10)),
                                              child: Image.network(
                                                similarItem.image ?? "",
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                        color: Colors
                                                            .grey.shade200,
                                                        child: const Icon(Icons
                                                            .image_not_supported)),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    similarItem.name ?? "",
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Expanded(
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              if (useSalePrice) ...[
                                                                Text("₹$bPrice",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        decoration:
                                                                            TextDecoration
                                                                                .lineThrough,
                                                                        color: Colors
                                                                            .grey)),
                                                                SizedBox(
                                                                    width: 4),
                                                              ],
                                                              Text(
                                                                  "₹$displayPrice",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .red)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      if (_normalizeProductType(
                                                                  similarItem
                                                                          .type ??
                                                                      widget
                                                                          .type) !=
                                                              'service' &&
                                                          !similarItem
                                                              .isOutOfStock) ...[
                                                        GestureDetector(
                                                          onTap: () =>
                                                              addRelatedProductToCart(
                                                                  similarItem
                                                                      .id),
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  CustomStyles
                                                                      .pinki,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Text(
                                                              "Add",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        if (_isRecentViewsLoading || recentViews.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Text(
                              "Recent Views",
                              style: CustomStyles.black16600
                                  .copyWith(fontSize: screenWidth * 0.04),
                            ),
                          ),
                        if (_isRecentViewsLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        if (recentViews.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              height: screenHeight * 0.30,
                              child: ListView.builder(
                                itemCount: recentViews.length,
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final recentItem = recentViews[index];
                                  return GestureDetector(
                                    onTap: () {
                                      final nextType = _normalizeProductType(
                                          recentItem.type ?? 'product');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailScreen(
                                            slug: recentItem.slug,
                                            itemId: recentItem.id,
                                            productname: recentItem.title,
                                            type: nextType,
                                            parentid: 0,
                                            goHomeOnBack: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: screenWidth * 0.4,
                                      margin: const EdgeInsets.only(
                                          right: 10, bottom: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              recentItem.image ?? "",
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 0,
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black87,
                                                    ],
                                                  ),
                                                ),
                                                child: Text(
                                                  recentItem.title ?? "",
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
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
                          ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // Gender options for form (key: gender) - value sent as standard code
  static const List<Map<String, String>> _genderOptions = [
    {"label": "Male", "value": "male"},
    {"label": "Female", "value": "female"},
    {"label": "Other", "value": "other"},
  ];

  // Indian languages with standard ISO 639-1 codes for form (key: language)
  static const List<Map<String, String>> _indianLanguageOptions = [
    {"label": "English", "value": "en"},
    {"label": "Hindi", "value": "hi"},
    {"label": "Bengali", "value": "bn"},
    {"label": "Telugu", "value": "te"},
    {"label": "Marathi", "value": "mr"},
    {"label": "Tamil", "value": "ta"},
    {"label": "Gujarati", "value": "gu"},
    {"label": "Kannada", "value": "kn"},
    {"label": "Malayalam", "value": "ml"},
    {"label": "Punjabi", "value": "pa"},
    {"label": "Odia", "value": "or"},
    {"label": "Urdu", "value": "ur"},
  ];

  String _buyFormProductImageUrl() {
    final d = productDetailDatum;
    if (d == null) return '';
    final m = d.image?.toString().trim() ?? '';
    if (m.isNotEmpty) return m;
    final g = d.galleries;
    if (g != null && g.isNotEmpty) return g.first.toString();
    return '';
  }

  Widget _buildBuyFormPoojaSummary(bool isSmallScreen, double fontSizeLabel) {
    final d = productDetailDatum;
    if (d == null) return const SizedBox.shrink();
    final typeSel = (selectedtype ?? d.attribute?.type ?? '').toString().trim();
    final imgUrl = _buyFormProductImageUrl();
    if (typeSel.isEmpty && imgUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    final double imgSide = isSmallScreen ? 76 : 88;
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: typeSel.isNotEmpty
                    ? Text(
                        typeSel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CustomStyles.black18600.copyWith(
                          fontSize: fontSizeLabel + 2,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212121),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (imgUrl.isNotEmpty) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imgUrl,
                    width: imgSide,
                    height: imgSide,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: imgSide,
                      height: imgSide,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey.shade500, size: 28),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child:
                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyFormServiceReportSummary(
      bool isSmallScreen, double fontSizeLabel) {
    final d = productDetailDatum;
    if (d == null) return const SizedBox.shrink();
    final titleRaw = (d.title ?? widget.productname ?? '').trim();
    final priceRaw = d.basePrice?.toString().trim() ?? '';
    final imgUrl = _buyFormProductImageUrl();
    if (titleRaw.isEmpty && priceRaw.isEmpty && imgUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    final double imgSide = isSmallScreen ? 72 : 82;
    final orange = CustomStyles.detailsOrange;
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titleRaw.isNotEmpty)
                      Text(
                        titleRaw,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CustomStyles.black18600.copyWith(
                          fontSize: fontSizeLabel + 3,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212121),
                          height: 1.2,
                        ),
                      ),
                    if (priceRaw.isNotEmpty) ...[
                      SizedBox(height: titleRaw.isNotEmpty ? 10 : 0),
                      Text(
                        '₹ $priceRaw',
                        style: TextStyle(
                          fontSize: fontSizeLabel + 6,
                          fontWeight: FontWeight.w700,
                          color: orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (imgUrl.isNotEmpty) ...[
                const SizedBox(width: 12),
                ClipOval(
                  child: Image.network(
                    imgUrl,
                    width: imgSide,
                    height: imgSide,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: imgSide,
                      height: imgSide,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey.shade500, size: 26),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child:
                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
          ),
        ],
      ),
    );
  }

  showBuyNowDialog() {
    _removeBuyFormLocationOverlay();
    for (final f in _buyFormPlaceFocusNodes.values) {
      f.dispose();
    }
    _buyFormPlaceFocusNodes.clear();
    controllers.clear();
    final bool isPooja = widget.type?.toLowerCase() == 'pooja';
    final List<Field> apiFields =
        isPooja ? <Field>[] : (productDetailDatum?.form?.fields ?? []);
    final List<List<Field>> structuredFields =
        isPooja ? <List<Field>>[] : structureFormFields(apiFields);

    if (!isPooja && structuredFields.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Form Not Available"),
          content: Text("No form fields are available for this product."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("OK"))
          ],
        ),
      );
      return;
    }

    final GlobalKey<FormState> buyFormKey = GlobalKey<FormState>();
    final ScrollController buyDialogScrollController = ScrollController();
    final AddressApiService addressApiService = AddressApiService();
    final SubmitAddressApiService submitAddressApiService =
        SubmitAddressApiService();
    final StateApiService stateApiService = StateApiService();
    final CityApiService cityApiService = CityApiService();

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        final bool isSmallScreen = screenWidth < 360;
        final double fontSizeTitle = isSmallScreen ? 16 : screenWidth * 0.045;
        final double fontSizeLabel = isSmallScreen ? 12 : screenWidth * 0.035;
        final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;
        final double verticalPadding = isSmallScreen ? 10.0 : 14.0;

        int _schemaProductId() {
          final pIdRaw = productDetailDatum?.parentId;
          final pid =
              (pIdRaw is int) ? pIdRaw : int.tryParse('${pIdRaw ?? ''}');
          final selfIdRaw = productDetailDatum?.id;
          final selfId = (selfIdRaw is int)
              ? selfIdRaw
              : int.tryParse('${selfIdRaw ?? ''}');
          if (pid != null && pid > 0) return pid;
          final widRaw = widget.itemId;
          final wid = (widRaw is int) ? widRaw : int.tryParse('$widRaw');
          return selfId ?? wid ?? 0;
        }

        int _schemaVariationId() {
          final selfParent = productDetailDatum?.parentId;
          final hasParent = (selfParent is int && selfParent > 0) ||
              (int.tryParse('${selfParent ?? ''}') ?? 0) > 0;
          if (hasParent) {
            final raw = productDetailDatum?.id;
            return (raw is int) ? raw : (int.tryParse('$raw') ?? 0);
          }
          final attr = _getItemIdFromSelectedAttributes();
          if (attr != null) return attr;
          final raw = productDetailDatum?.id;
          return (raw is int) ? raw : (int.tryParse('$raw') ?? 0);
        }

        final Future<Map<String, dynamic>?> schemaFuture = isPooja
            ? (() async {
                final prefs = await SharedPreferences.getInstance();
                final tok = (prefs.getString('api_token') ?? '').trim();
                if (tok.isEmpty) return null;
                final pid = _schemaProductId();
                final vid = _schemaVariationId();
                if (vid <= 0) return null;
                return _fetchPujaParticipateSchema(
                  apiToken: tok,
                  productId: pid,
                  variationId: vid,
                  pujaFlow: 'group',
                );
              })()
            : Future<Map<String, dynamic>?>.value(null);

        final TextEditingController gotraController =
            TextEditingController(text: '');
        final TextEditingController addressController =
            TextEditingController(text: '');
        final TextEditingController pincodeController =
            TextEditingController(text: '');
        StateDatum? selectedState;
        CityDatum? selectedCity;
        bool dontKnowGotra = false;
        bool wantsAshirwadBox = false;
        bool showAddAddressForm = false;
        int? selectedAddressId;
        List<AddressDatum> addressList = [];
        bool addressLoading = false;
        List<StateDatum> stateList = [];
        List<CityDatum> cityList = [];
        bool stateLoading = false;
        bool cityLoading = false;

        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : screenWidth * 0.06,
            vertical: screenHeight * 0.06,
          ),
          title: Text(
            isPooja ? '' : "Please Fill the Form",
            style: CustomStyles.black18600.copyWith(fontSize: fontSizeTitle),
            textAlign: TextAlign.center,
          ),
          content: Container(
            color: Colors.white,
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.9,
              maxHeight: screenHeight * 0.7,
            ),
            width: double.infinity,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                Future<void> loadStates() async {
                  if (stateLoading) return;
                  setDialogState(() {
                    stateLoading = true;
                  });
                  final model = await stateApiService.fetchstatedata('101');
                  stateList = model?.data ?? [];
                  setDialogState(() {
                    stateLoading = false;
                  });
                }

                Future<void> loadCities(String stateId) async {
                  if (cityLoading) return;
                  setDialogState(() {
                    cityLoading = true;
                  });
                  final model = await cityApiService.fetchcitydata(stateId);
                  cityList = model?.data ?? [];
                  setDialogState(() {
                    cityLoading = false;
                  });
                }

                Future<void> loadAddressesIfNeeded() async {
                  if (!wantsAshirwadBox) return;
                  if (addressLoading) return;
                  setDialogState(() {
                    addressLoading = true;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  final tok = (prefs.getString('api_token') ?? '').trim();
                  final model =
                      await addressApiService.getaddressapidata(tok.toString());
                  addressList = model?.data ?? [];
                  if (selectedAddressId == null && addressList.isNotEmpty) {
                    selectedAddressId = addressList.first.addressId;
                  }
                  setDialogState(() {
                    addressLoading = false;
                  });
                }

                return PrimaryScrollController(
                  controller: buyDialogScrollController,
                  child: SingleChildScrollView(
                    controller: buyDialogScrollController,
                    child: Form(
                      key: buyFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPooja)
                            FutureBuilder<Map<String, dynamic>?>(
                              future: schemaFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    snapshot.data == null) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            CustomStyles.callActionBackground,
                                      ),
                                    ),
                                  );
                                }
                                final schema = snapshot.data;
                                if (schema == null ||
                                    schema['success'] != true) {
                                  int persons = 1;
                                  final sel =
                                      (selectedtype ?? '').toLowerCase().trim();
                                  if (sel == 'family') persons = 4;
                                  if (sel == 'couple') persons = 2;
                                  final variationLabel =
                                      (selectedtype ?? '').toString().trim();

                                  final List<Map<String, dynamic>> nameFields =
                                      List.generate(persons, (i) {
                                    final idx = i + 1;
                                    final uniqueKey = 'pooja_name_$idx';
                                    controllers.putIfAbsent(uniqueKey,
                                        () => TextEditingController());
                                    return {
                                      'label': 'Name $idx',
                                      'required': true,
                                      '_uniqueKey': uniqueKey,
                                    };
                                  });
                                  controllers.putIfAbsent(
                                      'pooja_gotra', () => gotraController);

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (variationLabel.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 14),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      variationLabel,
                                                      style: CustomStyles
                                                          .black18600
                                                          .copyWith(
                                                        fontSize: fontSizeTitle,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox.shrink(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ...List.generate(
                                          (nameFields.length / 2).ceil(),
                                          (rowIndex) {
                                        final start = rowIndex * 2;
                                        final end = (start + 2)
                                            .clamp(0, nameFields.length);
                                        final row =
                                            nameFields.sublist(start, end);
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: row
                                                .asMap()
                                                .entries
                                                .map<Widget>((e) {
                                              final idx = e.key;
                                              final f = e.value;
                                              final label =
                                                  (f['label'] ?? 'Name')
                                                      .toString();
                                              final required =
                                                  f['required'] == true;
                                              final uniqueKey =
                                                  (f['_uniqueKey'] ?? '')
                                                      .toString();
                                              return Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      right:
                                                          idx < row.length - 1
                                                              ? 10
                                                              : 0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              label,
                                                              style: CustomStyles
                                                                  .black14500
                                                                  .copyWith(
                                                                      fontSize:
                                                                          fontSizeLabel),
                                                            ),
                                                          ),
                                                          if (required)
                                                            Text(
                                                              ' *',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize:
                                                                    fontSizeLabel,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      TextFormField(
                                                        controller: controllers[
                                                            uniqueKey],
                                                        style: CustomStyles
                                                            .black14400,
                                                        decoration:
                                                            _buyFormInputDecoration(),
                                                        validator: (v) {
                                                          if (required &&
                                                              (v == null ||
                                                                  v
                                                                      .trim()
                                                                      .isEmpty)) {
                                                            return '$label is required';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      }),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 6, bottom: 10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Gotra',
                                                    style: CustomStyles
                                                        .black14500
                                                        .copyWith(
                                                            fontSize:
                                                                fontSizeLabel),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  TextFormField(
                                                    controller: gotraController,
                                                    enabled: !dontKnowGotra,
                                                    style:
                                                        CustomStyles.black14400,
                                                    decoration:
                                                        _buyFormInputDecoration(
                                                      hintText: 'Enter Gotra',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 22),
                                                child: Row(
                                                  children: [
                                                    Checkbox(
                                                      value: dontKnowGotra,
                                                      onChanged: (v) {
                                                        setDialogState(() {
                                                          dontKnowGotra =
                                                              v == true;
                                                          if (dontKnowGotra) {
                                                            gotraController
                                                                    .text =
                                                                'I do not know my gotra';
                                                          } else {
                                                            gotraController
                                                                .clear();
                                                          }
                                                        });
                                                      },
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'I do not know my gotra',
                                                        style: CustomStyles
                                                            .black14400
                                                            .copyWith(
                                                                fontSize:
                                                                    fontSizeLabel),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Would you like to receive the Ashirwad box?',
                                              style: CustomStyles.black16600
                                                  .copyWith(
                                                      fontSize:
                                                          fontSizeLabel + 1),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'The Ashirwad Box Will Contain Divine Blessing Elements\nSuch As Ganga Jal, And More, Sourced From Sacred Tirth\nLocations.',
                                              style: CustomStyles.black14400
                                                  .copyWith(
                                                fontSize: fontSizeLabel,
                                                height: 1.35,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomOutlinedButton(
                                                    bordercolor: wantsAshirwadBox
                                                        ? CustomStyles
                                                            .callActionBackground
                                                        : Colors.grey.shade400,
                                                    backgroundColor:
                                                        wantsAshirwadBox
                                                            ? CustomStyles
                                                                .callActionBackground
                                                            : Colors.white,
                                                    text: 'Yes',
                                                    textstyle: TextStyle(
                                                      color: wantsAshirwadBox
                                                          ? Colors.white
                                                          : Colors.black87,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    onPressed: () async {
                                                      setDialogState(() {
                                                        wantsAshirwadBox = true;
                                                      });
                                                      await loadAddressesIfNeeded();
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: CustomOutlinedButton(
                                                    bordercolor: !wantsAshirwadBox
                                                        ? CustomStyles
                                                            .callActionBackground
                                                        : Colors.grey.shade400,
                                                    backgroundColor:
                                                        !wantsAshirwadBox
                                                            ? CustomStyles
                                                                .callActionBackground
                                                            : Colors.white,
                                                    text: 'No',
                                                    textstyle: TextStyle(
                                                      color: !wantsAshirwadBox
                                                          ? Colors.white
                                                          : Colors.black87,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    onPressed: () {
                                                      setDialogState(() {
                                                        wantsAshirwadBox =
                                                            false;
                                                        showAddAddressForm =
                                                            false;
                                                        selectedAddressId =
                                                            null;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (wantsAshirwadBox) ...[
                                              const SizedBox(height: 14),
                                              Text(
                                                'Select Delivery Address',
                                                style: CustomStyles.black16600
                                                    .copyWith(
                                                        fontSize:
                                                            fontSizeLabel + 1),
                                              ),
                                              const SizedBox(height: 10),
                                              if (addressLoading)
                                                Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: CustomStyles
                                                          .callActionBackground,
                                                    ),
                                                  ),
                                                )
                                              else ...[
                                                ...addressList.map((a) {
                                                  final id = a.addressId;
                                                  final isSel =
                                                      selectedAddressId !=
                                                              null &&
                                                          id != null &&
                                                          selectedAddressId ==
                                                              id;
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                        color: isSel
                                                            ? Colors.black87
                                                            : Colors
                                                                .grey.shade300,
                                                      ),
                                                    ),
                                                    child: RadioListTile<int>(
                                                      value: id ?? 0,
                                                      groupValue:
                                                          selectedAddressId ??
                                                              -1,
                                                      onChanged: (v) {
                                                        setDialogState(() {
                                                          selectedAddressId = v;
                                                        });
                                                      },
                                                      activeColor: CustomStyles
                                                          .callActionBackground,
                                                      title: Text(
                                                        (a.name ?? '')
                                                            .toString(),
                                                        style: CustomStyles
                                                            .black16600
                                                            .copyWith(
                                                                fontSize:
                                                                    fontSizeLabel +
                                                                        1),
                                                      ),
                                                      subtitle: Text(
                                                        '${a.address ?? ''}\n${a.city ?? ''}, ${a.state ?? ''} - ${a.zipcode ?? ''}',
                                                        style: CustomStyles
                                                            .black14400
                                                            .copyWith(
                                                                fontSize:
                                                                    fontSizeLabel),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ],
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                final data = (schema['data'] as Map?)
                                    ?.cast<String, dynamic>();
                                final variations = (data?['variations']
                                            as List?)
                                        ?.cast<dynamic>()
                                        .map((e) =>
                                            (e as Map).cast<String, dynamic>())
                                        .toList() ??
                                    [];
                                final target = (data?['target_product'] as Map?)
                                    ?.cast<String, dynamic>();
                                final tId = target?['id'];
                                final targetId =
                                    (tId is int) ? tId : int.tryParse('$tId');
                                final currentVariation = variations.firstWhere(
                                  (v) {
                                    final id = v['id'];
                                    final vid =
                                        (id is int) ? id : int.tryParse('$id');
                                    return vid != null && vid == targetId;
                                  },
                                  orElse: () => {},
                                );
                                final variationLabel =
                                    (currentVariation['variation_label'] ?? '')
                                        .toString();
                                final variationImage =
                                    (currentVariation['image'] ?? '')
                                        .toString()
                                        .trim();
                                final fallbackImg =
                                    (productDetailDatum?.image ?? '')
                                        .toString()
                                        .trim();
                                final dynamicFields = (data?['dynamic_fields']
                                            as List?)
                                        ?.cast<dynamic>()
                                        .map((e) =>
                                            (e as Map).cast<String, dynamic>())
                                        .toList() ??
                                    [];
                                final nameFields = dynamicFields
                                    .where((e) =>
                                        (e['name'] ?? '')
                                            .toString()
                                            .toLowerCase() ==
                                        'name')
                                    .toList();
                                for (final f in nameFields) {
                                  final slotRaw = f['person_slot'];
                                  final slot = (slotRaw is int)
                                      ? slotRaw
                                      : int.tryParse('$slotRaw');
                                  final uniqueKey = 'pooja_name_${slot ?? ''}';
                                  controllers.putIfAbsent(
                                      uniqueKey, () => TextEditingController());
                                  f['_uniqueKey'] = uniqueKey;
                                }
                                controllers.putIfAbsent(
                                    'pooja_gotra', () => gotraController);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 14),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (variationLabel
                                                    .trim()
                                                    .isNotEmpty)
                                                  Text(
                                                    variationLabel,
                                                    style: CustomStyles
                                                        .black18600
                                                        .copyWith(
                                                      fontSize: fontSizeTitle,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                const SizedBox.shrink(),
                                              ],
                                            ),
                                          ),
                                          if (variationImage.isNotEmpty ||
                                              fallbackImg.isNotEmpty)
                                            ClipOval(
                                              child: Image.network(
                                                variationImage.isNotEmpty
                                                    ? variationImage
                                                    : fallbackImg,
                                                width: 46,
                                                height: 46,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  width: 46,
                                                  height: 46,
                                                  color: Colors.grey.shade200,
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                    color: Colors.grey.shade500,
                                                    size: 22,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    ...List.generate(
                                        (nameFields.length / 2).ceil(),
                                        (rowIndex) {
                                      final start = rowIndex * 2;
                                      final end = (start + 2)
                                          .clamp(0, nameFields.length);
                                      final row =
                                          nameFields.sublist(start, end);
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children:
                                              row.asMap().entries.map((e) {
                                            final idx = e.key;
                                            final f = e.value;
                                            final label = (f['label'] ?? 'Name')
                                                .toString();
                                            final required = true;
                                            final uniqueKey =
                                                (f['_uniqueKey'] ?? '')
                                                    .toString();
                                            return Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: idx < row.length - 1
                                                        ? 10
                                                        : 0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            label,
                                                            style: CustomStyles
                                                                .black14500
                                                                .copyWith(
                                                                    fontSize:
                                                                        fontSizeLabel),
                                                          ),
                                                        ),
                                                        if (required)
                                                          Text(
                                                            ' *',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize:
                                                                  fontSizeLabel,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    TextFormField(
                                                      controller: controllers[
                                                          uniqueKey],
                                                      style: CustomStyles
                                                          .black14400,
                                                      decoration:
                                                          _buyFormInputDecoration(),
                                                      validator: (v) {
                                                        if (required &&
                                                            (v == null ||
                                                                v
                                                                    .trim()
                                                                    .isEmpty)) {
                                                          return '$label is required';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 6, bottom: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Gotra',
                                                  style: CustomStyles.black14500
                                                      .copyWith(
                                                          fontSize:
                                                              fontSizeLabel),
                                                ),
                                                const SizedBox(height: 6),
                                                TextFormField(
                                                  controller: gotraController,
                                                  enabled: !dontKnowGotra,
                                                  style:
                                                      CustomStyles.black14400,
                                                  decoration:
                                                      _buyFormInputDecoration(
                                                    hintText: 'Enter Gotra',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 22),
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: dontKnowGotra,
                                                    onChanged: (v) {
                                                      setDialogState(() {
                                                        dontKnowGotra =
                                                            v == true;
                                                        if (dontKnowGotra) {
                                                          gotraController.text =
                                                              'I do not know my gotra';
                                                        } else {
                                                          gotraController
                                                              .clear();
                                                        }
                                                      });
                                                    },
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      'I do not know my gotra',
                                                      style: CustomStyles
                                                          .black14400
                                                          .copyWith(
                                                              fontSize:
                                                                  fontSizeLabel),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Would you like to receive the Ashirwad box?',
                                            style: CustomStyles.black16600
                                                .copyWith(
                                                    fontSize:
                                                        fontSizeLabel + 1),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'The Ashirwad Box Will Contain Divine Blessing Elements\nSuch As Ganga Jal, And More, Sourced From Sacred Tirth\nLocations.',
                                            style: CustomStyles.black14400
                                                .copyWith(
                                              fontSize: fontSizeLabel,
                                              height: 1.35,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomOutlinedButton(
                                                  bordercolor: wantsAshirwadBox
                                                      ? CustomStyles
                                                          .callActionBackground
                                                      : Colors.grey.shade400,
                                                  backgroundColor: wantsAshirwadBox
                                                      ? CustomStyles
                                                          .callActionBackground
                                                      : Colors.white,
                                                  text: 'Yes',
                                                  textstyle: TextStyle(
                                                    color: wantsAshirwadBox
                                                        ? Colors.white
                                                        : Colors.black87,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  onPressed: () async {
                                                    setDialogState(() {
                                                      wantsAshirwadBox = true;
                                                    });
                                                    await loadAddressesIfNeeded();
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: CustomOutlinedButton(
                                                  bordercolor: !wantsAshirwadBox
                                                      ? CustomStyles
                                                          .callActionBackground
                                                      : Colors.grey.shade400,
                                                  backgroundColor:
                                                      !wantsAshirwadBox
                                                          ? CustomStyles
                                                              .callActionBackground
                                                          : Colors.white,
                                                  text: 'No',
                                                  textstyle: TextStyle(
                                                    color: !wantsAshirwadBox
                                                        ? Colors.white
                                                        : Colors.black87,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  onPressed: () {
                                                    setDialogState(() {
                                                      wantsAshirwadBox = false;
                                                      showAddAddressForm =
                                                          false;
                                                      selectedAddressId = null;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (wantsAshirwadBox) ...[
                                            const SizedBox(height: 14),
                                            Text(
                                              'Select Delivery Address',
                                              style: CustomStyles.black16600
                                                  .copyWith(
                                                      fontSize:
                                                          fontSizeLabel + 1),
                                            ),
                                            const SizedBox(height: 10),
                                            if (addressLoading)
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: CustomStyles
                                                        .callActionBackground,
                                                  ),
                                                ),
                                              )
                                            else ...[
                                              ...addressList.map((a) {
                                                final id = a.addressId;
                                                final isSel =
                                                    selectedAddressId != null &&
                                                        id != null &&
                                                        selectedAddressId == id;
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color: isSel
                                                          ? Colors.black87
                                                          : Colors
                                                              .grey.shade300,
                                                    ),
                                                  ),
                                                  child: RadioListTile<int>(
                                                    value: id ?? 0,
                                                    groupValue:
                                                        selectedAddressId ?? -1,
                                                    onChanged: (v) {
                                                      setDialogState(() {
                                                        selectedAddressId = v;
                                                      });
                                                    },
                                                    activeColor: CustomStyles
                                                        .callActionBackground,
                                                    title: Text(
                                                      (a.name ?? '').toString(),
                                                      style: CustomStyles
                                                          .black16600
                                                          .copyWith(
                                                              fontSize:
                                                                  fontSizeLabel +
                                                                      1),
                                                    ),
                                                    subtitle: Text(
                                                      '${a.address ?? ''}\n${a.city ?? ''}, ${a.state ?? ''} - ${a.zipcode ?? ''}',
                                                      style: CustomStyles
                                                          .black14400
                                                          .copyWith(
                                                              fontSize:
                                                                  fontSizeLabel),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              InkWell(
                                                onTap: () async {
                                                  setDialogState(() {
                                                    showAddAddressForm =
                                                        !showAddAddressForm;
                                                  });
                                                  if (showAddAddressForm) {
                                                    await loadStates();
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 6),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .add_circle_outline,
                                                          color: CustomStyles
                                                              .callActionBackground),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Add a new delivery address',
                                                        style: TextStyle(
                                                          color: CustomStyles
                                                              .callActionBackground,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize:
                                                              fontSizeLabel + 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (showAddAddressForm) ...[
                                                const SizedBox(height: 10),
                                                Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'New delivery address',
                                                        style: CustomStyles
                                                            .black16600
                                                            .copyWith(
                                                                fontSize:
                                                                    fontSizeLabel +
                                                                        2),
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              'Street/House Address',
                                                              style: CustomStyles
                                                                  .black14500
                                                                  .copyWith(
                                                                      fontSize:
                                                                          fontSizeLabel),
                                                            ),
                                                          ),
                                                          Text(' *',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize:
                                                                      fontSizeLabel)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      TextFormField(
                                                        controller:
                                                            addressController,
                                                        maxLines: 3,
                                                        style: CustomStyles
                                                            .black14400,
                                                        decoration:
                                                            _buyFormInputDecoration(
                                                          hintText:
                                                              'Enter your address',
                                                        ),
                                                        validator: (v) {
                                                          if (!showAddAddressForm) {
                                                            return null;
                                                          }
                                                          if (v == null ||
                                                              v
                                                                  .trim()
                                                                  .isEmpty) {
                                                            return 'Street/House Address is required';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        'State',
                                                                        style: CustomStyles
                                                                            .black14500
                                                                            .copyWith(fontSize: fontSizeLabel)),
                                                                    Text(' *',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize: fontSizeLabel)),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 6),
                                                                DropdownButtonFormField<
                                                                    StateDatum>(
                                                                  value:
                                                                      selectedState,
                                                                  items: stateList
                                                                      .map((s) => DropdownMenuItem(
                                                                            value:
                                                                                s,
                                                                            child:
                                                                                Text(
                                                                              s.name ?? '',
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ))
                                                                      .toList(),
                                                                  onChanged:
                                                                      (v) async {
                                                                    setDialogState(
                                                                        () {
                                                                      selectedState =
                                                                          v;
                                                                      selectedCity =
                                                                          null;
                                                                      cityList =
                                                                          [];
                                                                    });
                                                                    if (v?.id !=
                                                                        null) {
                                                                      await loadCities(v!
                                                                          .id
                                                                          .toString());
                                                                    }
                                                                  },
                                                                  decoration:
                                                                      _buyFormInputDecoration(
                                                                    hintText: stateLoading
                                                                        ? 'Loading...'
                                                                        : 'Select State',
                                                                  ),
                                                                  validator:
                                                                      (v) {
                                                                    if (!showAddAddressForm) {
                                                                      return null;
                                                                    }
                                                                    if (v ==
                                                                        null) {
                                                                      return 'State is required';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text('City',
                                                                        style: CustomStyles
                                                                            .black14500
                                                                            .copyWith(fontSize: fontSizeLabel)),
                                                                    Text(' *',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize: fontSizeLabel)),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 6),
                                                                DropdownButtonFormField<
                                                                    CityDatum>(
                                                                  value:
                                                                      selectedCity,
                                                                  items: cityList
                                                                      .map((c) => DropdownMenuItem(
                                                                            value:
                                                                                c,
                                                                            child:
                                                                                Text(
                                                                              c.name ?? '',
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ))
                                                                      .toList(),
                                                                  onChanged:
                                                                      (v) {
                                                                    setDialogState(
                                                                        () {
                                                                      selectedCity =
                                                                          v;
                                                                    });
                                                                  },
                                                                  decoration:
                                                                      _buyFormInputDecoration(
                                                                    hintText: cityLoading
                                                                        ? 'Loading...'
                                                                        : 'Select City',
                                                                  ),
                                                                  validator:
                                                                      (v) {
                                                                    if (!showAddAddressForm) {
                                                                      return null;
                                                                    }
                                                                    if (v ==
                                                                        null) {
                                                                      return 'City is required';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      Row(
                                                        children: [
                                                          Text('Pincode',
                                                              style: CustomStyles
                                                                  .black14500
                                                                  .copyWith(
                                                                      fontSize:
                                                                          fontSizeLabel)),
                                                          Text(' *',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize:
                                                                      fontSizeLabel)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      TextFormField(
                                                        controller:
                                                            pincodeController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        style: CustomStyles
                                                            .black14400,
                                                        decoration:
                                                            _buyFormInputDecoration(
                                                          hintText:
                                                              'Enter pincode',
                                                        ),
                                                        validator: (v) {
                                                          if (!showAddAddressForm) {
                                                            return null;
                                                          }
                                                          if (v == null ||
                                                              v
                                                                  .trim()
                                                                  .isEmpty) {
                                                            return 'Pincode is required';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          height: 14),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: SizedBox(
                                                          width: 150,
                                                          child:
                                                              CustomOutlinedButton(
                                                            bordercolor:
                                                                CustomStyles
                                                                    .callActionBackground,
                                                            backgroundColor:
                                                                CustomStyles
                                                                    .callActionBackground,
                                                            text:
                                                                'Save Address',
                                                            onPressed:
                                                                () async {
                                                              if (!buyFormKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                return;
                                                              }
                                                              final prefs =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              final tok =
                                                                  (prefs.getString(
                                                                              'api_token') ??
                                                                          '')
                                                                      .trim();
                                                              final phone =
                                                                  (prefs.getString(
                                                                              'phone') ??
                                                                          '9999999999')
                                                                      .trim();
                                                              final fullName =
                                                                  (controllers['pooja_name_1']
                                                                              ?.text ??
                                                                          '')
                                                                      .trim();
                                                              await submitAddressApiService
                                                                  .submitAddress(
                                                                token: tok,
                                                                addressId: 0,
                                                                fullName: fullName
                                                                        .isEmpty
                                                                    ? 'User'
                                                                    : fullName,
                                                                email: '',
                                                                phone: phone
                                                                        .isEmpty
                                                                    ? '9999999999'
                                                                    : phone,
                                                                countryId: 101,
                                                                stateId:
                                                                    selectedState
                                                                        ?.id,
                                                                cityId:
                                                                    selectedCity
                                                                        ?.id,
                                                                zipcode:
                                                                    pincodeController
                                                                        .text,
                                                                address:
                                                                    addressController
                                                                        .text,
                                                              );
                                                              await loadAddressesIfNeeded();
                                                              setDialogState(
                                                                  () {
                                                                showAddAddressForm =
                                                                    false;
                                                                addressController
                                                                    .clear();
                                                                pincodeController
                                                                    .clear();
                                                                selectedCity =
                                                                    null;
                                                                selectedState =
                                                                    null;
                                                                cityList = [];
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          else if (widget.type?.toLowerCase() == 'service' ||
                              widget.type?.toLowerCase() == 'report')
                            _buildBuyFormServiceReportSummary(
                                isSmallScreen, fontSizeLabel),
                          if (!isPooja)
                            ...List.generate(structuredFields.length,
                                (personIndex) {
                              final personFields =
                                  structuredFields[personIndex];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (structuredFields.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15, bottom: 5),
                                    ),
                                  ...List.generate(
                                    (personFields.length / 2).ceil(),
                                    (rowIndex) {
                                      final startIndex = rowIndex * 2;
                                      final endIndex = (startIndex + 2)
                                          .clamp(0, personFields.length);
                                      final rowFields = personFields.sublist(
                                          startIndex, endIndex);

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: rowFields
                                              .asMap()
                                              .entries
                                              .map<Widget>((entry) {
                                            final fieldIndex = entry.key;
                                            final field = entry.value;

                                            final String uniqueKey =
                                                "person_${personIndex}_${field.key}";
                                            final String label =
                                                field.label ?? "Field";
                                            final bool required =
                                                field.required ?? false;
                                            final String fieldtype =
                                                field.type ?? "text";
                                            final String? fieldKey = field.key;

                                            controllers.putIfAbsent(uniqueKey,
                                                () => TextEditingController());

                                            final String nk =
                                                _buyFormFieldKeyNorm(fieldKey);
                                            Widget fieldWidget;
                                            if (nk == 'birth_date' ||
                                                nk == 'birthdate') {
                                              fieldWidget = Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          label,
                                                          style: CustomStyles
                                                              .black14500
                                                              .copyWith(
                                                                  fontSize:
                                                                      fontSizeLabel),
                                                        ),
                                                      ),
                                                      if (required)
                                                        Text(
                                                          ' *',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize:
                                                                  fontSizeLabel),
                                                        ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6),
                                                  TextFormField(
                                                    controller:
                                                        controllers[uniqueKey],
                                                    readOnly: true,
                                                    style: CustomStyles
                                                        .black14400
                                                        .copyWith(
                                                      fontSize: 13,
                                                      height: 1.25,
                                                    ),
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .disabled,
                                                    onTap: () async {
                                                      final DateTime? picked =
                                                          await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(1920),
                                                        lastDate:
                                                            DateTime.now(),
                                                        builder: (context,
                                                                child) =>
                                                            AppDateTimePickerTheme
                                                                .wrap(context,
                                                                    child),
                                                      );
                                                      if (picked != null) {
                                                        controllers[uniqueKey]!
                                                            .text = DateFormat(
                                                                'yyyy-MM-dd')
                                                            .format(picked);
                                                        setDialogState(() {});
                                                      }
                                                    },
                                                    decoration:
                                                        _buyFormInputDecoration(
                                                      suffixIcon: Icon(
                                                        Icons
                                                            .calendar_today_outlined,
                                                        color: Colors.grey[600],
                                                        size: 18,
                                                      ),
                                                    ),
                                                    validator: (value) {
                                                      if (required &&
                                                          (value == null ||
                                                              value.isEmpty)) {
                                                        return "$label is required";
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              );
                                            } else if (nk == 'birth_time') {
                                              fieldWidget = Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          label,
                                                          style: CustomStyles
                                                              .black14500
                                                              .copyWith(
                                                                  fontSize:
                                                                      fontSizeLabel),
                                                        ),
                                                      ),
                                                      if (required)
                                                        Text(
                                                          ' *',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize:
                                                                  fontSizeLabel),
                                                        ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6),
                                                  TextFormField(
                                                    controller:
                                                        controllers[uniqueKey],
                                                    readOnly: true,
                                                    style:
                                                        CustomStyles.black14400,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .disabled,
                                                    onTap: () async {
                                                      final TimeOfDay? picked =
                                                          await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            TimeOfDay.now(),
                                                        builder: (context,
                                                                child) =>
                                                            AppDateTimePickerTheme
                                                                .wrap(context,
                                                                    child),
                                                      );
                                                      if (picked != null) {
                                                        controllers[uniqueKey]!
                                                                .text =
                                                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                                        setDialogState(() {});
                                                      }
                                                    },
                                                    decoration:
                                                        _buyFormInputDecoration(
                                                      suffixIcon: Icon(
                                                        Icons
                                                            .access_time_outlined,
                                                        color: Colors.grey[600],
                                                        size: 20,
                                                      ),
                                                    ),
                                                    validator: (value) {
                                                      if (required &&
                                                          (value == null ||
                                                              value.isEmpty)) {
                                                        return "$label is required";
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              );
                                            } else if (nk == 'birth_place' ||
                                                nk == 'place_of_birth' ||
                                                nk == 'birthplace' ||
                                                nk == 'place') {
                                              fieldWidget = Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          label,
                                                          style: CustomStyles
                                                              .black14500
                                                              .copyWith(
                                                                  fontSize:
                                                                      fontSizeLabel),
                                                        ),
                                                      ),
                                                      if (required)
                                                        Text(
                                                          ' *',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize:
                                                                  fontSizeLabel),
                                                        ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6),
                                                  Builder(
                                                    builder: (fieldContext) {
                                                      return TextFormField(
                                                        controller: controllers[
                                                            uniqueKey],
                                                        focusNode:
                                                            _buyFormPlaceFocus(
                                                                uniqueKey),
                                                        style: CustomStyles
                                                            .black14400,
                                                        autovalidateMode:
                                                            AutovalidateMode
                                                                .disabled,
                                                        onChanged: (value) {
                                                          _searchBuyFormLocation(
                                                            value,
                                                            uniqueKey,
                                                            fieldContext,
                                                            setDialogState,
                                                          );
                                                        },
                                                        decoration:
                                                            _buyFormInputDecoration(
                                                          suffixIcon: Icon(
                                                            Icons.location_on,
                                                            color: Colors
                                                                .grey[600],
                                                            size: 20,
                                                          ),
                                                        ),
                                                        validator: (value) {
                                                          if (required &&
                                                              (value == null ||
                                                                  value
                                                                      .trim()
                                                                      .isEmpty)) {
                                                            return "$label is required";
                                                          }
                                                          return null;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              );
                                            } else if (nk == 'gender') {
                                              final currentVal =
                                                  controllers[uniqueKey]!.text;
                                              final String? genderDropdownVal =
                                                  currentVal.isEmpty
                                                      ? null
                                                      : _genderOptions.any(
                                                              (e) =>
                                                                  e["value"] ==
                                                                  currentVal)
                                                          ? currentVal
                                                          : null;
                                              fieldWidget = Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(label,
                                                            style: CustomStyles
                                                                .black14500
                                                                .copyWith(
                                                                    fontSize:
                                                                        fontSizeLabel)),
                                                      ),
                                                      if (required)
                                                        Text(' *',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize:
                                                                    fontSizeLabel)),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6),
                                                  DropdownButtonFormField<
                                                      String>(
                                                    value: genderDropdownVal,
                                                    isExpanded: true,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .disabled,
                                                    dropdownColor: Colors.white,
                                                    style: TextStyle(
                                                        fontSize: fontSizeLabel,
                                                        color: Colors.black87),
                                                    decoration:
                                                        _buyFormInputDecoration(),
                                                    items: _genderOptions
                                                        .map((e) =>
                                                            DropdownMenuItem<
                                                                String>(
                                                              value: e["value"],
                                                              child: Text(
                                                                e["label"]!,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        fontSizeLabel),
                                                              ),
                                                            ))
                                                        .toList(),
                                                    onChanged: (value) {
                                                      if (value != null) {
                                                        controllers[uniqueKey]!
                                                            .text = value;
                                                        setDialogState(() {});
                                                      }
                                                    },
                                                    validator: (value) {
                                                      if (required &&
                                                          (value == null ||
                                                              value.isEmpty)) {
                                                        return "$label is required";
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              );
                                            } else if (nk == 'language') {
                                              final currentVal =
                                                  controllers[uniqueKey]!.text;
                                              final String?
                                                  languageDropdownVal =
                                                  currentVal.isEmpty
                                                      ? null
                                                      : _indianLanguageOptions
                                                              .any((e) =>
                                                                  e["value"] ==
                                                                  currentVal)
                                                          ? currentVal
                                                          : null;
                                              fieldWidget = Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(label,
                                                            style: CustomStyles
                                                                .black14500
                                                                .copyWith(
                                                                    fontSize:
                                                                        fontSizeLabel)),
                                                      ),
                                                      if (required)
                                                        Text(' *',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize:
                                                                    fontSizeLabel)),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6),
                                                  DropdownButtonFormField<
                                                      String>(
                                                    value: languageDropdownVal,
                                                    isExpanded: true,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .disabled,
                                                    dropdownColor: Colors.white,
                                                    style: TextStyle(
                                                        fontSize: fontSizeLabel,
                                                        color: Colors.black87),
                                                    decoration:
                                                        _buyFormInputDecoration(),
                                                    items:
                                                        _indianLanguageOptions
                                                            .map((e) =>
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value: e[
                                                                      "value"],
                                                                  child: Text(
                                                                    e["label"]!,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            fontSizeLabel),
                                                                  ),
                                                                ))
                                                            .toList(),
                                                    onChanged: (value) {
                                                      if (value != null) {
                                                        controllers[uniqueKey]!
                                                            .text = value;
                                                        setDialogState(() {});
                                                      }
                                                    },
                                                    validator: (value) {
                                                      if (required &&
                                                          (value == null ||
                                                              value.isEmpty)) {
                                                        return "$label is required";
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              );
                                            } else {
                                              fieldWidget = Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          label,
                                                          style: CustomStyles
                                                              .black14500
                                                              .copyWith(
                                                                  fontSize:
                                                                      fontSizeLabel),
                                                        ),
                                                      ),
                                                      if (required)
                                                        Text(
                                                          ' *',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize:
                                                                  fontSizeLabel),
                                                        ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6),
                                                  TextFormField(
                                                    controller:
                                                        controllers[uniqueKey],
                                                    style:
                                                        CustomStyles.black14400,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .disabled,
                                                    keyboardType: fieldtype ==
                                                            "number"
                                                        ? TextInputType.number
                                                        : TextInputType.text,
                                                    decoration:
                                                        _buyFormInputDecoration(),
                                                    validator: (value) {
                                                      if (required &&
                                                          (value == null ||
                                                              value.isEmpty)) {
                                                        return "$label is required";
                                                      }
                                                      if (fieldtype ==
                                                              "number" &&
                                                          value != null &&
                                                          value.isNotEmpty) {
                                                        if (int.tryParse(
                                                                value) ==
                                                            null) {
                                                          return "$label must be a valid number";
                                                        }
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              );
                                            }

                                            return Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  right: fieldIndex <
                                                          rowFields.length - 1
                                                      ? 8.0
                                                      : 0.0,
                                                ),
                                                child: fieldWidget,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: CustomOutlinedButton(
                      backgroundColor: Colors.grey.shade300,
                      bordercolor: Colors.grey,
                      text: "Cancel",
                      textstyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      onPressed: () {
                        controllers.forEach((key, controller) {
                          controller.clear();
                        });
                        Navigator.pop(context);
                      }),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: CustomOutlinedButton(
                      bordercolor: CustomStyles.pinki,
                      text: "Buy Now",
                      onPressed: () async {
                        if (buyFormKey.currentState!.validate()) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          apiToken = prefs.getString('api_token');

                          bool isTokenNumeric(String? token) {
                            if (token == null || token.isEmpty) return false;
                            return int.tryParse(token) != null;
                          }

                          final bool isUserGuest = (apiToken == null ||
                              apiToken!.isEmpty ||
                              isTokenNumeric(apiToken));

                          if (isUserGuest) {
                            // Guest: ensure token, add to cart with form data, then go to login → checkout
                            await ensureGuestToken();
                            final prefs = await SharedPreferences.getInstance();
                            apiToken = prefs.getString('api_token');
                            List<Map<String, String>> formDataList = [];
                            if (isPooja) {
                              final sortedNameKeys = controllers.keys
                                  .where((k) => k.startsWith('pooja_name_'))
                                  .toList()
                                ..sort((a, b) => a.compareTo(b));
                              int idx = 1;
                              for (final k in sortedNameKeys) {
                                final v = controllers[k]?.text.trim() ?? '';
                                if (v.isNotEmpty) {
                                  formDataList.add({
                                    "key": "name",
                                    "label": "Name $idx",
                                    "value": v,
                                  });
                                }
                                idx++;
                              }
                              final gotra =
                                  controllers['pooja_gotra']?.text.trim() ?? '';
                              if (gotra.isNotEmpty) {
                                formDataList.add({
                                  "key": "gotra",
                                  "label": "Gotra",
                                  "value": gotra,
                                });
                              }
                              formDataList.add({
                                "key": "ashirwad_box",
                                "label": "Ashirwad Box",
                                "value": wantsAshirwadBox ? "1" : "0",
                              });
                            } else {
                              for (int i = 0;
                                  i < structuredFields.length;
                                  i++) {
                                final personFields = structuredFields[i];
                                for (final field in personFields) {
                                  final uniqueKey = "person_${i}_${field.key}";
                                  final controller = controllers[uniqueKey];
                                  if (controller != null &&
                                      controller.text.isNotEmpty) {
                                    formDataList.add({
                                      "key": field.key!,
                                      "label": field.label!,
                                      "value": controller.text,
                                    });
                                  }
                                }
                              }
                            }
                            final cartType = (widget.type == 'service' ||
                                    widget.type == 'report')
                                ? 'service'
                                : 'shop';
                            final productIdForPending =
                                productDetailDatum?.id ?? productitemid;
                            addtoCartModel =
                                await addtoCartApiService.addToCartApi(apiToken,
                                    productitemid, cartType, formDataList);
                            if (addtoCartModel != null) {
                              setState(() {
                                productitemid = addtoCartModel!.itemid;
                                cartQuantityNotifier.value =
                                    addtoCartModel!.totalQuantity.toString();
                              });
                            }
                            // Save pending report so after login CheckoutScreen can add with user token
                            await prefs.setInt('pending_buy_now_item_id',
                                productIdForPending ?? 0);
                            await prefs.setString('pending_buy_now_form_data',
                                jsonEncode(formDataList));
                            await prefs.setString(
                                'pending_buy_now_type', cartType);
                            controllers.forEach(
                                (key, controller) => controller.clear());
                            Navigator.pop(context);
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(
                                  redirectScreen: CheckoutScreen(
                                    itemType: (widget.type == 'service' ||
                                            widget.type == 'report')
                                        ? 1
                                        : 0,
                                  ),
                                ),
                              ),
                            );
                            return;
                          }
                          // +++ ADD THIS ENTIRE WIDGET METHOD +++

                          List<Map<String, String>> formDataList = [];
                          if (isPooja) {
                            final sortedNameKeys = controllers.keys
                                .where((k) => k.startsWith('pooja_name_'))
                                .toList()
                              ..sort((a, b) => a.compareTo(b));
                            int idx = 1;
                            for (final k in sortedNameKeys) {
                              final v = controllers[k]?.text.trim() ?? '';
                              if (v.isNotEmpty) {
                                formDataList.add({
                                  "key": "name",
                                  "label": "Name $idx",
                                  "value": v,
                                });
                              }
                              idx++;
                            }
                            final gotra =
                                controllers['pooja_gotra']?.text.trim() ?? '';
                            if (gotra.isNotEmpty) {
                              formDataList.add({
                                "key": "gotra",
                                "label": "Gotra",
                                "value": gotra,
                              });
                            }
                            formDataList.add({
                              "key": "ashirwad_box",
                              "label": "Ashirwad Box",
                              "value": wantsAshirwadBox ? "1" : "0",
                            });
                          } else {
                            for (int i = 0; i < structuredFields.length; i++) {
                              final personFields = structuredFields[i];

                              for (final field in personFields) {
                                final uniqueKey = "person_${i}_${field.key}";
                                final controller = controllers[uniqueKey];

                                if (controller != null &&
                                    controller.text.isNotEmpty) {
                                  formDataList.add({
                                    "key": field.key!,
                                    "label": field.label!,
                                    "value": controller.text,
                                  });
                                }
                              }
                            }
                          }

                          print(
                              "Form data being sent: ${jsonEncode(formDataList)}");

                          addtoCartModel =
                              await addtoCartApiService.addToCartApi(apiToken,
                                  productitemid, "shop", formDataList);

                          if (addtoCartModel != null) {
                            setState(() {
                              productitemid = addtoCartModel!.itemid;
                              cartQuantityNotifier.value =
                                  addtoCartModel!.totalQuantity.toString();
                            });

                            controllers.forEach(
                                (key, controller) => controller.clear());
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CheckoutScreen(itemType: 1),
                              ),
                            );
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg:
                                'Please fill all required fields before proceeding.',
                            textColor: Colors.white,
                            backgroundColor: Colors.red,
                          );
                        }
                      }),
                ),
              ],
            )
          ],
        );
      },
    ).then((_) {
      buyDialogScrollController.dispose();
      _removeBuyFormLocationOverlay();
      for (final f in _buyFormPlaceFocusNodes.values) {
        f.dispose();
      }
      _buyFormPlaceFocusNodes.clear();
    });
  }
}
