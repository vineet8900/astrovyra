import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/addtocart_api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_decrease_Api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_increase_Api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_list_api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_ramove_api.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/addtocart_model.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cart_decrease_model.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cart_increasemodel.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cartlistmodel.dart';
import 'package:astrokavach/screen/product/checkout_screen.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  AddtoCartApiService addtoCartApiService = AddtoCartApiService();
  AddtoCartModel? addtoCartModel;
  AddtoCartDatum? addtoCartDatum;
  CartListApiService cartListApiService = CartListApiService();
  CartListModel? cartListModel;
  List<CartListingDatum> cartlist = [];
  AddtoCartRemoveApiService addtoCartRemoveApiService =
      AddtoCartRemoveApiService();
  String? apiToken;
  String? cartuniqueid;
  String? quantity;
  String? quantitycart;
  bool isloading = false;
  int? itemquantity;
  int? totalamount;
  CartIncreaseModel? cartIncreaseModel;
  CartDecreaseModel? cartDecreaseModel;
  CartListIncreaseApiService cartListIncreaseApiService =
      CartListIncreaseApiService();
  CartListDecreaseApiService cartListDecreaseApiService =
      CartListDecreaseApiService();
  ReusableFunction reusableFunction = ReusableFunction();
  gettoken() async {
    await ensureGuestToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');
    return apiToken;
  }

  getcartlist() async {
    setState(() {
      isloading = true;
    });
    await ensureGuestToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiToken = prefs.getString('api_token');

    if (apiToken == null || apiToken.isEmpty) {
      setState(() => isloading = false);
      return;
    }

    final isGuest = await isGuestUser();
    cartListModel = await cartListApiService.getCartlistapi(
        apiToken.toString(), 0,
        showErrorToast: !isGuest);
    if (!mounted) return;

    if (cartListModel == null) {
      print("Cart list model is empty");
      cartlist = [];
    } else {
      cartlist = cartListModel!.data ?? [];
      totalamount = cartListModel!.total;
      print(cartlist);
      quantity = cartListModel!.totalQuantity?.toString() ?? '0';

      if (cartListModel?.totalQuantity != null) {
        cartQuantityNotifier.value = cartListModel!.totalQuantity.toString();
        totalamount = cartListModel!.total;
      } else {
        cartQuantityNotifier.value = '0';
      }
      setState(() {});
    }
    setState(() {
      isloading = false;
    });
  }

  removeItemFromCart(String cartUniqueId) async {
    try {
     
      setState(() {
        cartlist.removeWhere((item) => item.id.toString() == cartUniqueId);
      });

      await addtoCartRemoveApiService.addToCartRemoveApi(cartUniqueId);
      final isGuest = await isGuestUser();
      cartListModel = await cartListApiService.getCartlistapi(apiToken, 0,
          showErrorToast: !isGuest);

    
      if (!mounted) return;

      totalamount = cartListModel!.total;
      if (cartListModel == null) {
        cartlist = [];
      } else {
        cartlist = cartListModel!.data ?? [];
        quantity = cartListModel!.totalQuantity?.toString() ?? '0';
        cartQuantityNotifier.value = cartListModel!.totalQuantity.toString();
        setState(() {});
      }
    } catch (e) {
      print("Error removing item: $e");
   
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Failed to remove item: $e",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }


  Map<String, dynamic>? user;
  String? address;
  dynamic pincode;
  void fetchUserData() async {
    if (!mounted) return;

    setState(() {
      isloading = true;
    });

    var userData = await reusableFunction.getUserDataFromPrefs();

    if (userData != null) {
      address = userData['address'];
      pincode = userData['pincode'];
    }

    if (!mounted) return;

    setState(() {
      isloading = false;
      user = userData;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettoken();

    getcartlist();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          // automaticallyImplyLeading: false,
          backgroundColor: CustomStyles.whiteColor,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () async {
          
                Navigator.pop(context);
               
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
          ),
          title: "Cart",
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
          actions: [],
        ),
        body: isloading
            ? Center(child: CircularProgressIndicator())
            : cartlist.isEmpty
                ? Center(child: Text('Your cart is empty'))
                : SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(height: 10,),
                        Expanded(
                          child: ListView.builder(
                            itemCount: cartlist.length,
                            itemBuilder: (context, index) {
                              final item = cartlist[index];
                              itemquantity = cartlist[index].quantity;
                              String cartUniqueId = item.id.toString();
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailScreen(
                                                productname: item.name,
                                                parentid: 0,
                                                itemId: item.itemid,
                                                slug: item.slug,
                                                attributevalue: [],
                                              )));
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.black38))),
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(item.image ?? ''),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name ?? '',
                                              style: CustomStyles.black14400,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                            (item.salePrice == 0 ||
                                                    item.salePrice == null)
                                                ? Text(
                                                    '₹${item.basePrice ?? ''}',
                                                    style: TextStyle(
                                                      color: Color(0xff000000),
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  )
                                                : RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              ' ₹${item.basePrice ?? ''}',
                                                          style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            decorationThickness:
                                                                2,
                                                            color: Color(
                                                                0xff7A7A7A),
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              ' ₹${item.salePrice ?? ''}',
                                                          style: CustomStyles
                                                              .red13500,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            Row(
                                              children: [
                                                Text("Quantity : "),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 2),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          cartDecreaseModel =
                                                              await cartListDecreaseApiService
                                                                  .getCartDecreaseapi(
                                                                      apiToken,
                                                                      item.id!);
                                                          if (cartDecreaseModel !=
                                                              null) {
                                                            setState(() {
                                                              itemquantity =
                                                                  cartDecreaseModel!
                                                                          .qunatity ??
                                                                      0;
                                                            });
                                                            cartListModel =
                                                                await cartListApiService
                                                                    .getCartlistapi(
                                                                        apiToken,
                                                                        0);
                                                            totalamount =
                                                                cartListModel!
                                                                    .total;
                                                            if (cartListModel ==
                                                                null) {
                                                              cartlist = [];
                                                            } else {
                                                              cartlist =
                                                                  cartListModel!
                                                                          .data ??
                                                                      [];
                                                              print(cartlist);
                                                              quantity = cartListModel!
                                                                      .totalQuantity
                                                                      ?.toString() ??
                                                                  '0';
                                                              cartQuantityNotifier
                                                                      .value =
                                                                  cartListModel!
                                                                      .totalQuantity
                                                                      .toString();

                                                              setState(() {});
                                                            }
                                                          }
                                                        },
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: 20,
                                                        child: VerticalDivider(
                                                            width: 1)),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      child: Text(
                                                        itemquantity.toString(),
                                                        style: CustomStyles
                                                            .black14600,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: 20,
                                                        child: VerticalDivider(
                                                            width: 1)),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 2),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          cartIncreaseModel =
                                                              await cartListIncreaseApiService
                                                                  .getCartincreaseapi(
                                                                      apiToken,
                                                                      item.id!);
                                                          if (cartIncreaseModel !=
                                                              null) {
                                                            setState(() {
                                                              itemquantity =
                                                                  cartIncreaseModel!
                                                                          .qunatity ??
                                                                      0;
                                                            });
                                                            cartListModel =
                                                                await cartListApiService
                                                                    .getCartlistapi(
                                                                        apiToken
                                                                            .toString(),
                                                                        0);
                                                            totalamount =
                                                                cartListModel!
                                                                    .total;
                                                            if (cartListModel ==
                                                                null) {
                                                              cartlist = [];
                                                            } else {
                                                              cartlist =
                                                                  cartListModel!
                                                                          .data ??
                                                                      [];

                                                              quantity = cartListModel!
                                                                      .totalQuantity
                                                                      ?.toString() ??
                                                                  '0';
                                                              cartQuantityNotifier
                                                                      .value =
                                                                  cartListModel!
                                                                      .totalQuantity
                                                                      .toString();

                                                              setState(() {});
                                                            }
                                                          }
                                                        },
                                                        child: Icon(Icons.add,
                                                            color:
                                                                Colors.green),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              await removeItemFromCart(
                                                  cartUniqueId);
                                              setState(() {});
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 70,
                        )
                      ],
                    ),
                  ),
        floatingActionButton: cartlist.isEmpty
            ? SizedBox()
            : Container(
                height: 70,
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  title: Text(
                    "Subtotal",
                    style: CustomStyles.black16600,
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '₹ ${totalamount!.toDouble()}',
                          style: CustomStyles.black14400,
                        ),
                        // Uncomment below if discount is to be shown
                        // TextSpan(
                        //   text: '(${cartListModel!.discount} OFF)',
                        //   style: CustomStyles.red15600,
                        // ),
                      ],
                    ),
                  ),
                  trailing: SizedBox(
                    width: 120,
                    child: CustomElevatedButton(
                      text: "Checkout",
                      backgroundColor: CustomStyles.pinki,
                      textStyle: CustomStyles.white,
                      onPressed: () async {
                        if (!mounted) return;
                        reusableFunction.navigateIfNotLoggedIn(
                            context,
                            CheckoutScreen(
                              itemType: 0,
                            ),
                            null, (newUserData) {
                          if (!mounted) return;
                          setState(() {
                            user = newUserData;
                          });
                          fetchUserData();
                        });
                      },
                    ),
                  ),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

