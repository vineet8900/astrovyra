import 'package:flutter/material.dart';
import 'package:astrokavach/api/dashboard/search_delegates.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
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
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ProductListScreen extends StatefulWidget {
  int? categoryid;
  String? categoryname;
  String? productType;
  ProductListScreen(
      {super.key, this.categoryid, this.categoryname, this.productType});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool isMoreDataAvailable = true;
  int currentPage = 1;
  int _selectedFilterIndex = 0;
  int? _selectedslug = 0;
  int? selecttedtype = 0;
  int? _selectedsortby = 0;
  int? selectedSlug;
  String? selectedcategoryname;
  String? selectedtype = 'all';
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
  // AddtoWishlistApiService addtoWishlistApiService = AddtoWishlistApiService();
  // AddtoWishlistModel? addtoWishlistModel;
  // AddWishlistDatum? addWishlistDatum;

  Set<int> addingToCartSet = <int>{};

  List<bool> isHeartFilledList = [];
  String? minPrice;
  String? maxPrice;
  double min = 0.0;
  double max = 100.0;
  String? pricefrom = '0';
  String? priceto = '0';
  RangeValues currentRangeValues = RangeValues(0.0, 100.0);
  // 1. Add loading state variable in _ProductListScreenState class
//Set<String> addingToCartSet = <String>{};

  filtergetdata() async {
    setState(() {
      currentPage = 1;
      productlists.clear();
      isMoreDataAvailable = true;
      isloading = true;
    });

    productListApiModel = await producListApiService.fetchproductlistapidata(
        selectedSlug ?? widget.categoryid,
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

    print("Filtered productsortlist length: ${productsortlist.length}");

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
          await productApiService.fetchproductcategory(type: 'product');

      productTypeApiModel =
          await producTypeApiService.fetchproducttypeapidata();
      productcategorylist = productApiModel!.data ?? [];
      int i = 0;
      productcategorylist.forEach((element) async {
        if (element.slug == widget.categoryid) {
          setState(() {
            _selectedslug = i;
          });
        }
        i++;
      });
      productsortbyApiModel =
          await producSortbyApiService.fetchproductsortbyapidata();
      productListApiModel = await producListApiService.fetchproductlistapidata(
          widget.categoryid, "0", 'a_to_z', '0', '0', currentPage, 0);

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
    print("apiToken$apiToken");
  }

  // getaddtowishlistdata(String productslug) async {
  //   addtoWishlistModel = await addtoWishlistApiService.addToWishlistApi(
  //       apiToken, productslug, "add");
  //   addWishlistDatum = addtoWishlistModel!.data;

  //   setState(() {});
  // }

  // getremovetowishlistdata(String productslug) async {
  //   addtoWishlistModel = await addtoWishlistApiService.addToWishlistApi(
  //       apiToken, productslug, "remove");
  //   addWishlistDatum = addtoWishlistModel!.data;
  //   setState(() {});
  // }

  AddtoCartApiService addtoCartApiService = AddtoCartApiService();
  AddtoCartModel? addtoCartModel;
  // getaddtocartdata(String slug) async {
  //   if (apiToken == null || apiToken!.isEmpty) {
  //     print("API Token is missing");
  //     return;
  //   }
  //   addtoCartModel =
  //       await addtoCartApiService.addToCartApi(apiToken, slug, "shop", null);

  //   setState(() {
  //     cartQuantityNotifier.value = addtoCartModel!.totalQuantity.toString();
  //   });
  // }

  // En tu archivo product_list_screen.dart

  // Make sure you import your AstroApiService file
  // Example: import 'package:astrokavach/api/kundalichart/Allapi.dart';

  // This is the new function to handle both adding and removing from the wishlist.
  Future<void> _toggleWishlistStatus(
      int index, ProductListsDatum product) async {
    if (apiToken == null || apiToken!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    // Determine the action based on the current state
    final originalState = isHeartFilledList[index];
    final action = originalState ? 'remove' : 'add';

    // Optimistic UI Update: Change the heart icon immediately
    setState(() {
      isHeartFilledList[index] = !originalState;
    });

    try {
      // Call the new, centralized API service
      await AstroApiService.updateWishlist(
        itemId: product.id ?? 0, // Use the integer product ID
        action: action,
      );
      // The API service already shows a toast message on success
    } catch (e) {
      // If the API call fails, revert the icon to its original state
      setState(() {
        isHeartFilledList[index] = originalState;
      });
      print("Failed to update wishlist: $e");
    }
  }

  getaddtocartdata(int id) async {
    if (apiToken == null || apiToken!.isEmpty) {
      print("API Token is missing");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    final stockIdx = productlists.indexWhere((p) => p.id == id);
    if (stockIdx >= 0 && productlists[stockIdx].isOutOfStock) {
      return;
    }

    if (addingToCartSet.contains(id)) {
      return;
    }

    try {
      setState(() {
        addingToCartSet.add(id);
      });

      addtoCartModel =
          await addtoCartApiService.addToCartApi(apiToken, id, "shop", null);

      if (addtoCartModel != null) {
        // DEBUG: Imprime la respuesta completa de la API
        print(
            "reponse AddToCart: totalQuantity = ${addtoCartModel!.totalQuantity}");

        // Actualiza el notificador
        cartQuantityNotifier.value = addtoCartModel!.totalQuantity.toString();

        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   //SnackBar(
          //   // //  content: Text('Item added to cart successfully!'),
          //   //   duration: Duration(seconds: 2),
          //   //   backgroundColor: Colors.green,
          //   // ),
          // );
        }
      }
    } catch (e) {
      print("Error adding to cart: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item to cart'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          addingToCartSet.remove(id);
        });
      }
    }
  }

//   getaddtocartdata(String slug) async {
//   if (apiToken == null || apiToken!.isEmpty) {
//     print("API Token is missing");
//     // Redirect to login if no token
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//     );
//     return;
//   }

//   // Prevent multiple simultaneous requests for the same product
//   if (addingToCartSet.contains(slug)) {
//     return;
//   }

//   try {
//     // Add to loading set
//     setState(() {
//       addingToCartSet.add(slug);
//     });

//     addtoCartModel = await addtoCartApiService.addToCartApi(
//         apiToken, slug, "shop", null);

//     if (addtoCartModel != null) {
//       // Update the global cart quantity notifier immediately
//       cartQuantityNotifier.value = addtoCartModel!.totalQuantity.toString();

//       // Show a success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Item added to cart successfully!'),
//             duration: Duration(seconds: 2),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     }
//   } catch (e) {
//     print("Error adding to cart: $e");
//     // Show error message
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to add item to cart'),
//           duration: Duration(seconds: 2),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   } finally {
//     // Remove from loading set
//     if (mounted) {
//       setState(() {
//         addingToCartSet.remove(slug);
//       });
//     }
//   }
// }

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

    // getaddtocartdata(widget.slugcategory ?? '');
    currentRangeValues = RangeValues(min, max);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using LayoutBuilder to make the GridView responsive
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
        title: selectedSlug == null
            ? "${widget.categoryname}"
            : selectedcategoryname.toString(),
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
      body: isloading && productlists.isEmpty
          ? reusableFunction.loadingRow()
          : SafeArea(
              child: productlists.isEmpty
                  ? Center(
                      child:
                          Text("No Data List", style: CustomStyles.black14600),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Determine the number of columns based on screen width
                                int crossAxisCount = 2;
                                if (constraints.maxWidth > 1200) {
                                  crossAxisCount = 5;
                                } else if (constraints.maxWidth > 800) {
                                  crossAxisCount = 4;
                                } else if (constraints.maxWidth > 600) {
                                  crossAxisCount = 3;
                                }
                                // Calculate the aspect ratio to maintain a consistent item size
                                double aspectRatio =
                                    (constraints.maxWidth / crossAxisCount) /
                                        235;

                                return GridView.builder(
                                  controller: scrollController,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: aspectRatio * 0.79,
                                  ),
                                  itemCount: productlists.length,
                                  itemBuilder: (context, index) {
                                    final product = productlists[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetailScreen(
                                                      slug: product.slug,
                                                      // parentid: 0,
                                                      parentid:
                                                          widget.categoryid,
                                                      attributevalue: [],
                                                      itemId: product.id,
                                                      type: "product",
                                                      productname:
                                                          product.name)),
                                        );
                                      },
                                      child: Card(
                                        elevation: 2,
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            )),
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            AspectRatio(
                                              aspectRatio:
                                                  1, // 🔥 PERFECT SQUARE
                                              child: Stack(
                                                children: [
                                                  // 🖼 IMAGE
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      product.image ?? '',
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit
                                                          .cover, // ❌ fill hatao, ✅ cover rakho
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          color: const Color(
                                                              0xffF7F7F7),
                                                          child: const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color: Colors.grey,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  // ❤️ HEART ICON (TOP RIGHT)
                                                  Positioned(
                                                    top: 6,
                                                    right: 6,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        _toggleWishlistStatus(
                                                            index, product);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.85),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          (isHeartFilledList
                                                                          .length >
                                                                      index &&
                                                                  isHeartFilledList[
                                                                      index])
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          size: 20,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Expanded(
                                            //   flex: 5,
                                            //   // child: Container(
                                            //   //     alignment: Alignment.topRight,
                                            //   //     decoration: BoxDecoration(
                                            //   //       color: Color(0xffF7F7F7),
                                            //   //       image: DecorationImage(
                                            //   //         image: NetworkImage(
                                            //   //             product.image ?? '',
                                            //   //             scale: 2),
                                            //   //         fit: BoxFit.fill,
                                            //   //       ),
                                            //   //     ),
                                            //   //     child: GestureDetector(
                                            //   //       onTap: () {
                                            //   //         // This single function call handles everything for you.
                                            //   //         // It will first check if the user is logged in.
                                            //   //         // If not, it redirects to the LoginScreen.
                                            //   //         // If logged in, it will add/remove the item from the wishlist.
                                            //   //         _toggleWishlistStatus(
                                            //   //             index, product);
                                            //   //       },
                                            //   //       child: Padding(
                                            //   //         padding:
                                            //   //             const EdgeInsets.all(
                                            //   //                 5),
                                            //   //         child: Icon(
                                            //   //           size: 22,
                                            //   //           // A safety check to prevent "RangeError" while data is loading
                                            //   //           (isHeartFilledList
                                            //   //                           .length >
                                            //   //                       index &&
                                            //   //                   isHeartFilledList[
                                            //   //                       index])
                                            //   //               ? Icons.favorite
                                            //   //               : Icons
                                            //   //                   .favorite_border,
                                            //   //           color: Colors.red,
                                            //   //         ),
                                            //   //       ),
                                            //   //     )),
                                            // ),
                                            Expanded(
                                              flex: 5,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(product.name ?? '',
                                                        style: CustomStyles
                                                            .black14600,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    if (!product
                                                        .hasActiveSaleOffer)
                                                      Text(
                                                        '₹ ${product.basePrice}',
                                                        style: CustomStyles
                                                            .red15600,
                                                      )
                                                    else
                                                      RichText(
                                                        textAlign:
                                                            TextAlign.center,
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  '₹ ${product.basePrice}',
                                                              style:
                                                                  CustomStyles
                                                                      .grey14400
                                                                      .copyWith(
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '  ₹ ${product.salePrice}',
                                                              style:
                                                                  CustomStyles
                                                                      .red15600,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    // if (product.canaddtocart ==
                                                    //     true)
                                                    //   SizedBox(
                                                    //     height: 40,
                                                    //     width: double.infinity,
                                                    //     child:
                                                    //         CustomElevatedButton(
                                                    //       text: "Add to Cart",
                                                    //       onPressed: () {
                                                    //         getaddtocartdata(
                                                    //             product.slug ??
                                                    //                 '');
                                                    //       },
                                                    //     ),
                                                    //   )

                                                    if (product.isOutOfStock)
                                                      const OutOfStockStyledButton(
                                                        height: 40,
                                                      )
                                                    else if (product
                                                            .canaddtocart ==
                                                        true)
                                                      SizedBox(
                                                        height: 40,
                                                        width: double.infinity,
                                                        child: Opacity(
                                                          opacity: addingToCartSet
                                                                  .contains(
                                                                      product
                                                                          .slug)
                                                              ? 0.6
                                                              : 1.0,
                                                          child:
                                                              CustomElevatedButton(
                                                            backgroundColor:
                                                                CustomStyles
                                                                    .pinki,
                                                            text: addingToCartSet
                                                                    .contains(
                                                                        product
                                                                            .slug)
                                                                ? "Adding..."
                                                                : "add_to_cart"
                                                                    .tr,
                                                            onPressed: () {
                                                              if (addingToCartSet
                                                                  .contains(product
                                                                      .slug)) {
                                                                return;
                                                              }

                                                              getaddtocartdata(
                                                                  product.id ??
                                                                      0);
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      SizedBox(
                                                        height: 40,
                                                        width: double.infinity,
                                                        child:
                                                            CustomElevatedButton(
                                                          text: "View",
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => ProductDetailScreen(
                                                                      slug: product
                                                                          .slug,
                                                                      parentid:
                                                                          0,
                                                                      attributevalue: [],
                                                                      itemId:
                                                                          product
                                                                              .id,
                                                                      productname:
                                                                          product
                                                                              .name)),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                  ],
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
                            ),
                          ),
                        ),
                        if (isloading && isMoreDataAvailable)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                      ],
                    ),
            ),
    );
  }

  showFilterSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      shape: BeveledRectangleBorder(),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Wrap(
                  children: [
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
                          flex: 2,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                tileColor: _selectedFilterIndex == 0
                                    ? CustomStyles.pinki
                                    : Colors.white,
                                minTileHeight: 40,
                                title: Text("Sort by",
                                    style: _selectedFilterIndex != 0
                                        ? CustomStyles.black14500
                                        : CustomStyles.white),
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
                                minTileHeight: 40,
                                title: Text("Category",
                                    style: _selectedFilterIndex != 1
                                        ? CustomStyles.black14500
                                        : CustomStyles.white),
                                onTap: () {
                                  setState(() {
                                    _selectedFilterIndex = 1;
                                  });
                                },
                              ),
                              ListTile(
                                tileColor: _selectedFilterIndex == 2
                                    ? CustomStyles.pinki
                                    : Colors.white,
                                minTileHeight: 40,
                                title: Text("Price",
                                    style: _selectedFilterIndex != 2
                                        ? CustomStyles.black14500
                                        : CustomStyles.white),
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
                        Expanded(
                          flex: 3,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                            ),
                            child: SingleChildScrollView(
                              child: Column(children: [
                                if (_selectedFilterIndex == 0)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: productsortlist.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Row(
                                          children: [
                                            Radio<int>(
                                              activeColor: CustomStyles.pinki,
                                              value: index,
                                              groupValue: _selectedsortby,
                                              onChanged: (val) {
                                                setState(() {
                                                  _selectedsortby = val;
                                                  print(_selectedsortby);
                                                  selectedsortby =
                                                      productsortlist[val!]
                                                          .slug;
                                                  print(
                                                      "Selected sortby: $selectedsortby");
                                                });
                                              },
                                            ),
                                            Expanded(
                                                child: Text(
                                                    productsortlist[index]
                                                            .name ??
                                                        '',
                                                    style: CustomStyles
                                                        .black12500)),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                else if (_selectedFilterIndex == 1)
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: productcategorylist.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Row(
                                            children: [
                                              Radio<int>(
                                                activeColor: CustomStyles.pinki,
                                                value: index,
                                                groupValue: _selectedslug,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _selectedslug = val;
                                                    print(_selectedslug);
                                                    selectedSlug =
                                                        productcategorylist[
                                                                val!]
                                                            .id;
                                                    print(
                                                        "Selected Slug: $selectedSlug");
                                                    selectedcategoryname =
                                                        productcategorylist[val]
                                                            .name;
                                                  });
                                                },
                                              ),
                                              Expanded(
                                                child: Text(
                                                    productcategorylist[index]
                                                            .name ??
                                                        '',
                                                    style: CustomStyles
                                                        .black12500),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                else if (_selectedFilterIndex == 2)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Price Range: ₹${currentRangeValues.start.round()} - ₹${currentRangeValues.end.round()}',
                                          style: CustomStyles.black14400,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        RangeSlider(
                                          values: currentRangeValues,
                                          min: min,
                                          max: max,
                                          activeColor: CustomStyles.pinki,
                                          divisions: max > min
                                              ? (max - min)
                                                  .toInt()
                                                  .clamp(1, 100)
                                              : 1,
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
                                  )
                              ]),
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomElevatedButton(
                              backgroundColor: CustomStyles.grey,
                              text: "Reset",
                              onPressed: () {
                                setState(() {
                                  _selectedslug = 0;
                                  selecttedtype = 0;
                                  _selectedsortby = 0;
                                  selectedSlug = null;
                                  selectedtype = 'all';
                                  selectedsortby = 'a_to_z';
                                  currentRangeValues = RangeValues(min, max);
                                  pricefrom = '0';
                                  priceto = '0';
                                });
                                filtergetdata();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
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
