import 'package:astrokavach/api/dashboard/search_delegates.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/addtocart_api.dart';
import 'package:astrokavach/api/product_api/WishlistApi.dart/wishlist_add_api.dart';
import 'package:astrokavach/api/product_api/product_category_api.dart';
import 'package:astrokavach/api/product_api/product_list_api.dart';
import 'package:astrokavach/api/product_api/product_sortby_api.dart';
import 'package:astrokavach/api/product_api/product_typeapi.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/addtocart_model.dart';
import 'package:astrokavach/model/Product_Api_Model/WishlistModel.dart/addtowishlist_model.dart';
import 'package:astrokavach/model/Product_Api_Model/product_category_api_model.dart';
import 'package:astrokavach/model/Product_Api_Model/product_list_api_model.dart';
import 'package:astrokavach/model/Product_Api_Model/product_sortby_model.dart';
import 'package:astrokavach/model/Product_Api_Model/product_type_model.dart';
import 'package:astrokavach/screen/Countdown/Servicecount.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class AstroServiceListScreen extends StatefulWidget {
  String? slugcategory;
  String? categoryname;
  AstroServiceListScreen({super.key, this.slugcategory, this.categoryname});
  @override
  State<AstroServiceListScreen> createState() => _AstroServiceListScreenState();
}

class _AstroServiceListScreenState extends State<AstroServiceListScreen> {
  bool isMoreDataAvailable = true;
  int currentPage = 1;
  int _selectedFilterIndex = 0;
  int? _selectedslug = 0;
  int? selecttedtype = 0;
  int? _selectedsortby = 0;
  String? selectedSlug;
  String? selectedcategoryname;
  String? selectedtype = 'service';
  String? selectedsortby = 'a_to_z';
  ReusableFunction reusableFunction = ReusableFunction();

  ProductCategoryApiService productApiService = ProductCategoryApiService();
  ProducSortbyApiService producSortbyApiService = ProducSortbyApiService();
  ProducTypeApiService producTypeApiService = ProducTypeApiService();
  bool isloading = false;
  ProductCategoryModel? productApiModel;
  ProductSortByApiModel? productsortbyApiModel;
  List<ProductCategoryDatum> productcategorylist = [];
  ProductTypeApiModel? productTypeApiModel;
  List<ProductTypeDatumn> productTypelist = [];
  List<ProductSortbyDatum> productsortlist = [];
  ProducListApiService producListApiService = ProducListApiService();
  ProductListApiModel? productListApiModel;
  List<ProductListsDatum> productlists = [];
  AddtoWishlistApiService addtoWishlistApiService = AddtoWishlistApiService();
  AddtoWishlistModel? addtoWishlistModel;
  AddWishlistDatum? addWishlistDatum;

  List<bool> isHeartFilledList = [];
  String? minPrice;
  String? maxPrice;
  double min = 0.0;
  double max = 100.0;
  String? pricefrom = '0';
  String? priceto = '0';
  RangeValues currentRangeValues = RangeValues(0.0, 100.0);

  filtergetdata() async {
    setState(() {
      currentPage = 1;
      productlists.clear();
      isMoreDataAvailable = true;
      isloading = true;
    });

    productListApiModel = await producListApiService.fetchproductlistapidata(
        _selectedslug,
        selectedtype,
        selectedsortby,
        pricefrom,
        priceto,
        currentPage,
        0);

    productTypeApiModel = await producTypeApiService.fetchproducttypeapidata();
    productsortbyApiModel =
        await producSortbyApiService.fetchproductsortbyapidata();

    productTypelist = productTypeApiModel?.data ?? [];
    productsortlist = productsortbyApiModel?.data ?? [];

    if (productListApiModel?.data?.products != null &&
        productListApiModel!.data!.products!.isNotEmpty) {
      productlists.addAll(productListApiModel!.data!.products!);
      currentPage++;
      isHeartFilledList = List.generate(productlists.length, (index) => false);
    } else {
      isMoreDataAvailable = false;
    }

   

    setState(() {
      isloading = false;
    });
  }

  getproductlistdata() async {
    if (!isloading && isMoreDataAvailable) {
      setState(() {
        isloading = true;
      });

      await Future.delayed(Duration(milliseconds: 300));

      productApiModel =
          await productApiService.fetchproductcategory(type: 'service');

      productTypeApiModel =
          await producTypeApiService.fetchproducttypeapidata();
      productcategorylist = productApiModel!.data ?? [];
      int i = 0;
      productcategorylist.forEach((element) async {
        if (element.slug == widget.slugcategory) {
          setState(() {
            _selectedslug = i;
          });
        }
        i++;
      });
      productsortbyApiModel =
          await producSortbyApiService.fetchproductsortbyapidata();
      productListApiModel = await producListApiService.fetchproductlistapidata(
          0, "service", 'a_to_z', '0', '0', currentPage, 0);

      if (productListApiModel!.data!.products != null &&
          productListApiModel!.data!.products!.isNotEmpty) {
        productlists.addAll(productListApiModel!.data!.products!);
        currentPage++;
      } else {
        isMoreDataAvailable = false;
      }

      isHeartFilledList = List.generate(productlists.length, (index) => false);

      String minPrice = productListApiModel!.data!.minPrice ?? '';
      String maxPrice = productListApiModel!.data!.maxPrice ?? '';

      setState(() {
        min = double.tryParse(minPrice) ?? 0.0;
        max = double.tryParse(maxPrice) ?? 100.0;
        if (max <= min) max = min + 100;
        currentRangeValues = RangeValues(min, max);
        isloading = false;
      });

      productTypelist = productTypeApiModel!.data ?? [];
      productsortlist = productsortbyApiModel!.data ?? [];
    }
  }

  String? apiToken;
  gettoken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');
    
  }

  getaddtowishlistdata(String productslug) async {
    addtoWishlistModel = await addtoWishlistApiService.addToWishlistApi(
      apiToken,
      productslug,
      "add",
    );
    addWishlistDatum = addtoWishlistModel!.data;

    setState(() {});
  }

  getremovetowishlistdata(String productslug) async {
    addtoWishlistModel = await addtoWishlistApiService.addToWishlistApi(
      apiToken,
      productslug,
      "remove",
    );
    addWishlistDatum = addtoWishlistModel!.data;
    setState(() {});
  }

  AddtoCartApiService addtoCartApiService = AddtoCartApiService();
  AddtoCartModel? addtoCartModel;
  getaddtocartdata(int id) async {
    if (apiToken == null || apiToken!.isEmpty) {
      
      return;
    }
    final stockIdx = productlists.indexWhere((p) => p.id == id);
    if (stockIdx >= 0 && productlists[stockIdx].isOutOfStock) {
      return;
    }
    addtoCartModel =
        await addtoCartApiService.addToCartApi(apiToken, id, "shop", null);

    setState(() {
      cartQuantityNotifier.value = addtoCartModel!.totalQuantity.toString();
    });
  }

  ScrollController scrollController = ScrollController();
  onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 30 &&
        !isloading &&
        isMoreDataAvailable) {
      getproductlistdata();
    }
  }

  @override
  void initState() {
    super.initState();
    gettoken();
    scrollController = ScrollController();
    scrollController.addListener(onScroll);
    getproductlistdata();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.025;
    final cardWidth = screenWidth - horizontalPadding * 2;
    final sectionHeight = screenHeight * 0.32;
    final itemSpacing = screenHeight * 0.015;
    final gridSpacing = screenWidth < 600 ? 10.0 : 12.0;
    final gridCardWidth = (cardWidth - gridSpacing) / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        title: 'astro_service_list'.tr,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showFilterSortBottomSheet(context);
            },
            icon: const Icon(Icons.filter_alt, color: Colors.black),
            tooltip: 'Filter',
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
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        child: isloading && productlists.isEmpty
            ? reusableFunction.loadingRow()
            : SafeArea(
                child: productlists.isEmpty
                    ? Container(
                        height: screenHeight * 0.7,
                        child: Center(
                          child: Text("No Data List",
                              style: CustomStyles.black14600),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: horizontalPadding,
                        ),
                        child: Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: productlists.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: gridSpacing,
                                mainAxisSpacing: gridSpacing,
                                childAspectRatio: gridCardWidth / sectionHeight,
                              ),
                              itemBuilder: (context, index) {
                                final p = productlists[index];
                                return SizedBox(
                                  height: sectionHeight,
                                  width: gridCardWidth,
                                  child: AstroServiceCard(
                                    key: ValueKey(p.id),
                                    service: p,
                                    cardWidth: gridCardWidth,
                                    screenHeight: screenHeight,
                                  ),
                                );
                              },
                            ),
                            if (isloading && isMoreDataAvailable)
                              Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: Center(
                                  child: SizedBox(
                                    height: screenHeight * 0.04,
                                    width: screenHeight * 0.04,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
              ),
      ),
    );
  }

  showFilterSortBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      shape: BeveledRectangleBorder(),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                color: Colors.white,
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: screenHeight * 0.012),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      child: Row(
                        children: [
                          Text(
                            'Sort & Filter',
                            style: CustomStyles.black16600,
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.close, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.35,
                            child: Column(
                              children: [
                                ListTile(
                                  tileColor: _selectedFilterIndex == 0
                                      ? CustomStyles.pinki
                                      : Colors.white,
                                  minTileHeight: screenHeight * 0.05,
                                  title: Text("Sort by",
                                      style: _selectedFilterIndex != 0
                                          ? CustomStyles.black14500
                                          : CustomStyles.black14600),
                                  onTap: () {
                                    setState(() {
                                      _selectedFilterIndex = 0;
                                    });
                                  },
                                ),
                                ListTile(
                                  tileColor: _selectedFilterIndex == 1
                                      ? CustomStyles.pinki
                                      : Colors.white,
                                  minTileHeight: screenHeight * 0.05,
                                  title: Text("Price",
                                      style: _selectedFilterIndex != 1
                                          ? CustomStyles.black14500
                                          : CustomStyles.black14600),
                                  onTap: () {
                                    setState(() {
                                      _selectedFilterIndex = 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.black12,
                            thickness: 1,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: screenHeight * 0.01,
                                ),
                                constraints: BoxConstraints(
                                  minHeight: screenHeight * 0.25,
                                ),
                                child: Column(
                                  children: [
                                    if (_selectedFilterIndex == 0) ...[
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: productsortlist.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: screenHeight * 0.008,
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  height: screenHeight * 0.03,
                                                  width: screenHeight * 0.03,
                                                  child: Radio<int>(
                                                    activeColor:
                                                        CustomStyles.pinki,
                                                    value: index,
                                                    groupValue: _selectedsortby,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _selectedsortby = val;
                                                       
                                                        selectedsortby =
                                                            productsortlist[
                                                                    val!]
                                                                .slug;
                                                        
                                                      });
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.025),
                                                Expanded(
                                                  child: Text(
                                                    productsortlist[index]
                                                            .name ??
                                                        '',
                                                    style:
                                                        CustomStyles.black12500,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    ] else if (_selectedFilterIndex == 1) ...[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Price Range: ₹${currentRangeValues.start.round()} - ₹${currentRangeValues.end.round()}',
                                            style: CustomStyles.black14500,
                                          ),
                                          SizedBox(height: screenHeight * 0.01),
                                          RangeSlider(
                                            values: currentRangeValues,
                                            min: min,
                                            max: max,
                                            activeColor: CustomStyles.pinki,
                                            labels: RangeLabels(
                                              '₹${currentRangeValues.start.round()}',
                                              '₹${currentRangeValues.end.round()}',
                                            ),
                                            onChanged: (RangeValues values) {
                                              setState(() {
                                                currentRangeValues = values;
                                                pricefrom = currentRangeValues
                                                    .start
                                                    .toString();
                                                priceto = currentRangeValues.end
                                                    .toString();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomElevatedButton(
                              backgroundColor: CustomStyles.pinki,
                              text: "Apply",
                              onPressed: () {
                                filtergetdata();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.025),
                          Expanded(
                            child: CustomElevatedButton(
                              backgroundColor: CustomStyles.pinki,
                              text: "Reset",
                              onPressed: () {
                                setState(() {
                                  _selectedsortby = 0;
                                  selectedsortby = 'a_to_z';
                                  currentRangeValues = RangeValues(min, max);
                                  pricefrom = '0';
                                  priceto = '0';
                                });
                                filtergetdata(); // Apply reset filters
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
