import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:astrokavach/api/auth_api/banner_api.dart';
import 'package:astrokavach/api/dashboard/search_delegates.dart';
import 'package:astrokavach/api/product_api/product_category_api.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/offline_banner.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/product_category_api_model.dart';
import 'package:astrokavach/model/banner_api_model.dart';
import 'package:astrokavach/screen/product/product_list_screen.dart';
import 'package:astrokavach/utils/network_connectivity.dart';

class ProductCategoryScreen extends StatefulWidget {
  const ProductCategoryScreen({super.key});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  int _selectedFilterIndex = 0;
  int? _selectedOption;
  ReusableFunction reusableFunction = ReusableFunction();
  List<ProductCategoryDatum> productcategorylist = [];
  ProductCategoryModel? productcategorymodel;
  ProductCategoryApiService productcategoryapiservice =
      ProductCategoryApiService();
  bool isNetworkError = false;
  Timer? _connectivityTimer;
  List<String> filterexperience = [
    'Popularity',
    'Experience: High to Low',
    'Experience: Low to High',
  ];
  List<String> filterprice = ['Price: High to Low', 'Price: Low to High'];
  List<String> filterrating = [
    'Rating: High to Low',
    'Rating: Low to High',
  ];
  bool isloading = false;
  BannerApiModel? bannerApiModel;
  List<BannerDatum> bannerList = [];
  final BannerApiService bannerapiService = BannerApiService();
  getalldata() async {
    setState(() {
      isloading = true;
    });
    bannerApiModel = await bannerapiService.getbannerApi("products");
    bannerList = bannerApiModel?.data ?? [];
    productcategorymodel =
        await productcategoryapiservice.fetchproductcategory(type: "product");
    productcategorylist = productcategorymodel!.data ?? [];
    if (mounted) {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getalldata();
    _checkNetworkConnectivity();
    setupNetworkListener();
  }

  void setupNetworkListener() {
    // Check immediately on start
    _checkNetworkConnectivity();

    // Then check periodically
    _connectivityTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _checkNetworkConnectivity();
      } else {
        timer.cancel();
      }
    });
  }

  void retryConnection() async {
    // Show loading indicator
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
        });
        await getalldata();

        Fluttertoast.showToast(
          msg: 'Connection restored!',
          backgroundColor: Colors.green,
        );

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

  Future<void> _checkNetworkConnectivity() async {
    final ok = await checkDeviceHasInternet();
    if (!mounted) return;
    setState(() {
      isNetworkError = !ok;
    });
  }

  @override
  void dispose() {

    // _walletSubscription.cancel();
    // _refreshTimer?.cancel();
    _connectivityTimer?.cancel(); // <-- ADD THIS LINE
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Scaffold(
        appBar: CustomAppBar(
          backgroundColor: CustomStyles.whiteColor,
          title: 'product_category'.tr,
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
        body: isloading && productcategorylist.isEmpty
            ? reusableFunction.loadingRow()
            : SafeArea(
                child: productcategorylist.isEmpty
                    ? Center(
                        child: Text("No Data List",
                            style: CustomStyles.black14600),
                      )
                    : SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Column(
                          children: [
                            //  ( bannerList.isEmpty||bannerList==null) ?SizedBox.shrink() :     CarouselSlider.builder(
                            //             itemCount: bannerList.length,
                            //             options: CarouselOptions(
                            //               height: 150,
                            //               autoPlay: true,
                            //               enlargeCenterPage: true,
                            //               viewportFraction: 0.9,
                            //               onPageChanged: (index, reason) {},
                            //             ),
                            //             itemBuilder: (context, index, realIndex) {
                            //               final banner = bannerList[index];
                            //               return Container(
                            //                 width: MediaQuery.of(context).size.width,
                            //                 decoration: BoxDecoration(
                            //                   image: DecorationImage(
                            //                     image: NetworkImage(banner.image ?? ''),
                            //                     fit: BoxFit.cover,
                            //                   ),
                            //                   borderRadius: BorderRadius.circular(10),
                            //                 ),
                            //               );
                            //             },
                            //           ),

                            //     SizedBox(height: 10),
                            GridView.builder(
                              itemCount: productcategorylist.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5,
                                childAspectRatio: 0.79,
                              ),
                              itemBuilder: (context, index) {
                                final category = productcategorylist[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductListScreen(
                                          categoryid: category.id,
                                          categoryname: category.name,
                                          productType: "product",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          category.image ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.35),
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
                                            category.name ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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

  showFilterSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      shape: BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ListTile(
                            tileColor: _selectedFilterIndex == 0
                                ? Colors.white
                                : Color(0xffD9D9D9),
                            minTileHeight: 40,
                            title: Text("Experience",
                                style: CustomStyles.black14500),
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = 0;
                              });
                            },
                          ),
                          ListTile(
                            tileColor: _selectedFilterIndex == 1
                                ? Colors.white
                                : Color(0xffD9D9D9),
                            minTileHeight: 40,
                            title:
                                Text("Price", style: CustomStyles.black14500),
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = 1;
                              });
                            },
                          ),
                          ListTile(
                            tileColor: _selectedFilterIndex == 2
                                ? Colors.white
                                : Color(0xffD9D9D9),
                            minTileHeight: 40,
                            title:
                                Text("Rating", style: CustomStyles.black14500),
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = 2;
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
                    SizedBox(
                        width: 200,
                        height: 180,
                        child: Column(
                          children: [
                            if (_selectedFilterIndex == 0) ...[
                              SizedBox(
                                width: 200,
                                height: 150,
                                child: ListView.builder(
                                  itemCount: 3,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: Radio<int>(
                                              activeColor: Color(0xffFFAF12),
                                              value: index,
                                              groupValue: _selectedOption,
                                              onChanged: (val) {
                                                setState(() {
                                                  _selectedOption = val;
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            filterexperience[index],
                                            style: CustomStyles.black14400,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            ] else if (_selectedFilterIndex == 1) ...[
                              SizedBox(
                                width: 200,
                                height: 150,
                                child: ListView.builder(
                                  itemCount: 2,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: Radio<int>(
                                              activeColor: Color(0xffFFAF12),
                                              value: index,
                                              groupValue: _selectedOption,
                                              onChanged: (val) {
                                                setState(() {
                                                  _selectedOption = val;
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            filterprice[index],
                                            style: CustomStyles.black14400,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            ] else if (_selectedFilterIndex == 2) ...[
                              SizedBox(
                                width: 200,
                                height: 150,
                                child: ListView.builder(
                                  itemCount: 2,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: Radio<int>(
                                              activeColor: Color(0xffFFAF12),
                                              value: index,
                                              groupValue: _selectedOption,
                                              onChanged: (val) {
                                                setState(() {
                                                  _selectedOption = val;
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            filterrating[index],
                                            style: CustomStyles.black14400,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            ]
                          ],
                        ))
                  ],
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomElevatedButton(
                          backgroundColor: CustomStyles.bgcolor,
                          text: "Apply",
                          onPressed: () {
                            setState(() {
                              // applyPriceFilter();
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: CustomElevatedButton(
                          backgroundColor: CustomStyles.bgcolor,
                          text: "Reset",
                          onPressed: () {
                            setState(() {
                              _selectedOption = null;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
