import 'package:astrokavach/api/product_api/product_list_api.dart';
import 'package:astrokavach/api/product_api/product_sortby_api.dart';
import 'package:astrokavach/api/product_api/product_typeapi.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/product_list_api_model.dart';
import 'package:astrokavach/model/Product_Api_Model/product_sortby_model.dart';
import 'package:astrokavach/model/Product_Api_Model/product_type_model.dart';
import 'package:astrokavach/screen/Countdown/poojacount.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class PoojaListScreen extends StatefulWidget {
  final String? slugcategory;
  final String? categoryname;
  PoojaListScreen({super.key, this.slugcategory, this.categoryname});
  @override
  State<PoojaListScreen> createState() => _GemstonesScreenState();
}

class _GemstonesScreenState extends State<PoojaListScreen> {
  bool isMoreDataAvailable = true;
  int currentPage = 1;
  int _selectedFilterIndex = 0;
  int? _selectedsortby = 0;
  String? selectedtype = 'pooja';
  String? selectedsortby = 'a_to_z';
  ReusableFunction reusableFunction = ReusableFunction();

  ProducSortbyApiService producSortbyApiService = ProducSortbyApiService();
  ProducTypeApiService producTypeApiService = ProducTypeApiService();
  bool isloading = false;
  ProductSortByApiModel? productsortbyApiModel;
  ProductTypeApiModel? productTypeApiModel;
  List<ProductTypeDatumn> productTypelist = [];
  List<ProductSortbyDatum> productsortlist = [];
  ProducListApiService producListApiService = ProducListApiService();
  ProductListApiModel? productListApiModel;
  List<ProductListsDatum> productlists = [];

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
        0, // Using 0 as _selectedslug is not needed for pooja type
        selectedtype,
        selectedsortby,
        pricefrom,
        priceto,
        currentPage,
        0);

    if (productListApiModel?.data?.products != null &&
        productListApiModel!.data!.products!.isNotEmpty) {
      productlists.addAll(productListApiModel!.data!.products!);
      currentPage++;
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

      productsortbyApiModel =
          await producSortbyApiService.fetchproductsortbyapidata();
      productTypeApiModel =
          await producTypeApiService.fetchproducttypeapidata();

      productListApiModel = await producListApiService.fetchproductlistapidata(
          0, selectedtype, 'a_to_z', '0', '0', currentPage, 0);

      if (productListApiModel?.data?.products != null &&
          productListApiModel!.data!.products!.isNotEmpty) {
        productlists.addAll(productListApiModel!.data!.products!);
        currentPage++;
      } else {
        isMoreDataAvailable = false;
      }

      String minPriceStr = productListApiModel?.data?.minPrice ?? '0';
      String maxPriceStr = productListApiModel?.data?.maxPrice ?? '100';

      setState(() {
        min = double.tryParse(minPriceStr) ?? 0.0;
        max = double.tryParse(maxPriceStr) ?? 100.0;
        if (max <= min)
          max = min + 100; // Ensure max is always greater than min
        currentRangeValues = RangeValues(min, max);

        productTypelist = productTypeApiModel?.data ?? [];
        productsortlist = productsortbyApiModel?.data ?? [];
        isloading = false;
      });
    }
  }

  ScrollController scrollController = ScrollController();

  void onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
        !isloading &&
        isMoreDataAvailable) {
      getproductlistdata();
    }
  }

  @override
  void initState() {
    super.initState();
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
    final horizontalPadding = screenWidth < 600 ? 10.0 : 20.0;
    final cardWidth = screenWidth - horizontalPadding * 2;
    final sectionHeight = screenWidth < 600
        ? screenHeight * 0.33
        : screenWidth < 900
            ? screenHeight * 0.38
            : screenHeight * 0.40;
    final cardSpacing = screenWidth < 600 ? 6.0 : 12.0;
    final gridSpacing = screenWidth < 600 ? 10.0 : 12.0;
    final gridCardWidth = (cardWidth - gridSpacing) / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        title: 'pooja_list'.tr,
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
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: isloading && productlists.isEmpty
            ? Center(heightFactor: 10, child: CircularProgressIndicator())
            : SafeArea(
                child: productlists.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.3),
                          child: Text("No Poojas Available",
                              style: CustomStyles.black14600),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: screenWidth * 0.025,
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
                                  child: PoojaCard(
                                    key: ValueKey(p.id),
                                    pooja: p,
                                    cardWidth: gridCardWidth,
                                    screenHeight: screenHeight,
                                  ),
                                );
                              },
                            ),
                            if (isloading && isMoreDataAvailable)
                              Padding(
                                padding: EdgeInsets.all(screenHeight * 0.015),
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

  void showFilterSortBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    SizedBox(height: screenHeight * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01,
                      ),
                      child: Row(
                        children: [
                          Text('Sort & Filter', style: CustomStyles.black16600),
                          Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.close, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    //Divider(),
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
                                            style: CustomStyles.black13600,
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
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: screenHeight * 0.055,
                              child: CustomElevatedButton(
                                backgroundColor: CustomStyles.pinki,
                                text: "Apply",
                                onPressed: () {
                                  filtergetdata();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.025),
                          Expanded(
                            child: SizedBox(
                              height: screenHeight * 0.055,
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
                                  Navigator.pop(context);
                                },
                              ),
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
