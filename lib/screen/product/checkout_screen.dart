import 'dart:convert';

import 'package:astrokavach/api/product_api/WishlistApi.dart/paymentshow.dart';
import 'package:astrokavach/model/offerpayemet.dart/offerpayment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:astrokavach/api/Address_Api/add_address_Api.dart';
import 'package:astrokavach/api/Address_Api/address_api.dart';
import 'package:astrokavach/api/Address_Api/delete_address_Api.dart';
import 'package:astrokavach/api/auth_api/place_api.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/api/payment/checkout_couponcode_api.dart';
import 'package:astrokavach/api/payment/checkout_order_summary_api.dart';
import 'package:astrokavach/api/payment/payment_verify_api.dart';
import 'package:astrokavach/api/payment/place_order_api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/addtocart_api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_decrease_Api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_increase_Api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_list_api.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_ramove_api.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_dropdown.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/cutsom_textfield.dart';
import 'package:astrokavach/custom_widgets/payment_confirming_overlay.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/AddressModel/address_api_model.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/addtocart_model.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cart_decrease_model.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cart_increasemodel.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cartlistmodel.dart';
import 'package:astrokavach/model/cardupdatemodel/cartupdate.dart';
import 'package:astrokavach/model/payment_model/checkput_order_summary_model.dart';
import 'package:astrokavach/model/payment_model/place_order_api_model.dart';
import 'package:astrokavach/model/places_model.dart/city_api_model.dart';
import 'package:astrokavach/model/places_model.dart/country_Api_model.dart';
import 'package:astrokavach/model/places_model.dart/state_api_model.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/thankyou_screen.dart';
import 'package:astrokavach/Services/buy_now_cart.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutScreen extends StatefulWidget {
  final dynamic itemType;
  final int? buyNowProductId;

  final int? buyNowCartItemId;

  final bool isBuyNow;

  CheckoutScreen({
    super.key,
    this.itemType,
    this.buyNowProductId,
    this.buyNowCartItemId,
    this.isBuyNow = false,
  });
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool ispaybtnloading = false;
  bool showShippingForm = false;
  int billingShippingSame = 0;
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool light = false;
  final FocusNode _focusNode = FocusNode();
  Color borderColor = Color(0xffFFAF12);
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController placeofbirthcontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController pincodecontroller = TextEditingController();
  TextEditingController landmarkcontroller = TextEditingController();
  TextEditingController couponcodecontroller = TextEditingController();
  List<CountryDatum> countrydatalist = [];
  List<StateDatum> statedatalist = [];
  List<CityDatum> citydatalist = [];
  CountryModel? countryModel;
  StateModel? stateModel;
  CityModel? cityModel;
  CountryDatum? selectcountry;
  StateDatum? selectstate;
  CityDatum? selectcity;
  CountryApiService countryApiService = CountryApiService();
  StateApiService stateApiService = StateApiService();
  CityApiService cityApiService = CityApiService();
  PlaceOrderApi placeOrderApi = PlaceOrderApi();
  PlacerOrderApiModel? placerOrderApiModel;
  String? apiToken;
  CheckoutOrderSummaryApiModel? checkoutOrderSummaryApiModel;
  CheckoutOrderSummaryApi checkoutOrderSummaryApi = CheckoutOrderSummaryApi();
  CheckoutCouponcodeApi checkoutCouponcodeApi = CheckoutCouponcodeApi();

  List<dynamic> buyNowList = []; // NEW
  List<dynamic> mergedCartList = []; //

  bool isloading = false;

  Razorpay razorpay = Razorpay();
  PaymentVerifyApi paymentVerifyApi = PaymentVerifyApi();

  int _billingAddressSelection = 1;
  int _paymentMethodSelection = 2;

  final OrderApiService _orderApiService = OrderApiService();
  List<PaymentType> paymentMethods = [];
  bool isPaymentLoading = true;
  String? _selectedPaymentValue;
  final TextEditingController billingFullNameController =
      TextEditingController();
  final TextEditingController billingEmailController = TextEditingController();
  final TextEditingController billingPhoneController = TextEditingController();
  final TextEditingController billingAddressController =
      TextEditingController();
  final TextEditingController billingPinCodeController =
      TextEditingController();
  final TextEditingController billingLandmarkController =
      TextEditingController();

  List<StateDatum> billingStateList = [];
  List<CityDatum> billingCityList = [];
  StateDatum? selectBillingState;
  CityDatum? selectBillingCity;

  final GlobalKey<FormState> _billingFormKey = GlobalKey<FormState>();
  bool _showBillingForm = false;

  var options;
  String? callbackurl;
  int? addressid;

  bool _isAddressComplete(AddressDatum? addr) {
    if (addr == null) return false;
    final name = addr.name?.toString().trim() ?? '';
    final phone = addr.phone?.toString().trim() ?? '';
    final email = addr.email?.toString().trim() ?? '';
    final address = addr.address?.toString().trim() ?? '';
    final city = addr.city?.toString().trim() ?? '';
    final state = addr.state?.toString().trim() ?? '';
    final zip = addr.zipcode?.toString().trim() ?? '';
    return name.isNotEmpty &&
        phone.isNotEmpty &&
        email.isNotEmpty &&
        address.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        zip.isNotEmpty;
  }

  Future<void> getpaymentdata() async {
    if (widget.itemType == 0) {
      if (addressid == null) {
        Fluttertoast.showToast(msg: "Please select a delivery address.");
        setState(() => ispaybtnloading = false);
        return;
      }

      AddressDatum? selectedAddr;
      for (final a in addresslist) {
        if (a.addressId == addressid) {
          selectedAddr = a;
          break;
        }
      }
      if (selectedAddr == null || !_isAddressComplete(selectedAddr)) {
        Fluttertoast.showToast(
          msg:
              "Please fill Name, Phone, Email, State, City, Address and Zipcode to place order.",
          backgroundColor: Colors.orange,
        );
        if (addressid != null) {
          showAddressFormPopup(context, addressid!);
        } else {
          showAddressFormPopup(context, 0);
        }
        setState(() => ispaybtnloading = false);
        return;
      }
    }

    if (_billingAddressSelection == 2) {
      if (!_billingFormKey.currentState!.validate()) {
        Fluttertoast.showToast(
            msg: "Please fill all billing details correctly.");
        setState(() => ispaybtnloading = false);
        return;
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    String billingAddressValue;
    if (_billingAddressSelection == 1) {
      billingAddressValue = widget.itemType == 0 ? 'shipping' : 'profile';
    } else {
      billingAddressValue = 'different';
    }

    PlacerOrderApiModel? placerOrderApiModel =
        await placeOrderApi.fetchplaceorderdata(
      apiToken: apiToken.toString(),
      itemType: widget.itemType,
      addressid: addressid,
      couponcode: couponcodecontroller.text,
      paymentOption: _selectedPaymentValue ?? 'now',
      billingAddress: billingAddressValue,
      buyNow: widget.isBuyNow ? 1 : 0,
      cartitemid: widget.buyNowCartItemId,
      billingFullName:
          _billingAddressSelection == 2 ? billingFullNameController.text : null,
      billingEmail:
          _billingAddressSelection == 2 ? billingEmailController.text : null,
      billingPhone:
          _billingAddressSelection == 2 ? billingPhoneController.text : null,
      billingAddr:
          _billingAddressSelection == 2 ? billingAddressController.text : null,
      billingPinCode:
          _billingAddressSelection == 2 ? billingPinCodeController.text : null,
      billingCityId:
          _billingAddressSelection == 2 ? selectBillingCity?.id : null,
      billingStateId:
          _billingAddressSelection == 2 ? selectBillingState?.id : null,
      billingAddressLandmark: _billingAddressSelection == 2
          ? (billingLandmarkController.text.trim().isEmpty
              ? null
              : billingLandmarkController.text.trim())
          : null,
    );

    if (placerOrderApiModel != null && placerOrderApiModel.success == true) {
      if (widget.isBuyNow) {
        BuyNowCart.clear();
      }
      if (_selectedPaymentValue == 'cod') {
        print("Order placed with COD. Navigating to Thank You screen.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ThankyouScreen(
                msg: placerOrderApiModel.message ??
                    'Order Placed Successfully!'),
          ),
        );
      } else {
        int amount = placerOrderApiModel.data?.amount ?? 0;
        callbackurl = placerOrderApiModel.data?.callbackUrl;

        if (amount > 0) {
          options = {
            'key': placerOrderApiModel.data?.key ?? '',
            'amount': amount,
            'name': placerOrderApiModel.data?.name ?? '',
            'order_id': placerOrderApiModel.data?.orderId ?? '',
            'description': placerOrderApiModel.data?.description ?? '',
            'prefill': {
              'contact': placerOrderApiModel.data?.prefill!.contact ?? '',
              'email': placerOrderApiModel.data?.prefill!.email ?? '',
            },
            'theme': {'color': '#F37254'}
          };
          razorpay.open(options);
        } else {
          print("Order placed with 0 amount. Navigating to Thank You screen.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ThankyouScreen(msg: placerOrderApiModel.message ?? ''),
            ),
          );
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: placerOrderApiModel?.message ??
            "Failed to place order. Please try again.",
        backgroundColor: Colors.red,
      );
      if (mounted) {
        setState(() {
          ispaybtnloading = false;
        });
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (widget.isBuyNow) {
      BuyNowCart.clear();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');
    print(response);

    final dynamic data = await PaymentConfirmingOverlay.run(context, () async {
      return paymentVerifyApi.fetchpaymentapidata(
          context, apiToken, response, callbackurl.toString());
    });
    print("data$data");
    if (!mounted) return;
    if (data != null) {
      String msg = data['message'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ThankyouScreen(msg: msg)),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      ispaybtnloading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Payment Failed!"),
      backgroundColor: Colors.red,
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("External Wallet: ${response.walletName}"),
    ));
  }

  void _loadInitialBillingData() {
    billingStateList = statedatalist;
  }

  Future<void> _fetchBillingCities(int stateId) async {
    setState(() {
      billingCityList = [];
      selectBillingCity = null;
    });

    cityModel = await cityApiService.fetchcitydata(stateId.toString());
    if (mounted) {
      setState(() {
        billingCityList = cityModel?.data ?? [];
      });
    }
  }

  // 24-04-2025
  bool couponapply = false;
  int _selectedAddress = 0;
  AddtoCartApiService addtoCartApiService = AddtoCartApiService();
  AddtoCartModel? addtoCartModel;
  AddtoCartDatum? addtoCartDatum;
  CartListApiService cartListApiService = CartListApiService();
  CartListModel? cartListModel;
  List<CartListingDatum> cartlist = [];
  int? itemquantity;
  CartIncreaseModel? cartIncreaseModel;
  CartDecreaseModel? cartDecreaseModel;
  CartListIncreaseApiService cartListIncreaseApiService =
      CartListIncreaseApiService();
  CartListDecreaseApiService cartListDecreaseApiService =
      CartListDecreaseApiService();
  AddtoCartRemoveApiService addtoCartRemoveApiService =
      AddtoCartRemoveApiService();
  String? cartuniqueid;
  String? quantity;
  String? quantitycart;

  gettoken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');
    if (apiToken == null || apiToken!.isEmpty) {
      print("Generated API Token: $apiToken");
      return apiToken;
    }
    return apiToken;
  }

  dynamic subtotal;
  dynamic total;
  dynamic discount;
  dynamic tax;
  dynamic couponamount = 0;
  dynamic shippingcharges;
  dynamic codcharge = 0;

  void _recalcBuyNowTotals() {
    if (!widget.isBuyNow || cartlist.isEmpty) return;
    double buyNowSub = 0.0;
    for (var item in cartlist) {
      double price =
          (double.tryParse(item.salePrice?.toString() ?? '0') ?? 0.0);
      if (price <= 0)
        price = (double.tryParse(item.basePrice?.toString() ?? '0') ?? 0.0);
      buyNowSub += price * (item.quantity ?? 1);
    }
    subtotal = buyNowSub;
    final coup = double.tryParse(couponamount?.toString() ?? '0') ?? 0.0;
    total = buyNowSub - coup;
    if (total < 0) total = 0.0;
  }

  getcartlist() async {
    if (!mounted) return;
    setState(() {
      isloading = true;
    });

    await ensureGuestToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    if (apiToken == null || apiToken!.isEmpty) {
      if (!mounted) return;
      setState(() {
        isloading = false;
      });
      return;
    }

    final isGuest = await isGuestUser();

    if (isGuest && widget.itemType == 1) {
      if (!mounted) return;
      setState(() {
        cartlist = [];
        isloading = false;
      });
      return;
    }

    if (widget.itemType == 1 && !isGuest) {
      final pendingItemId = prefs.getInt('pending_buy_now_item_id');
      if (pendingItemId != null && pendingItemId > 0) {
        final formDataStr = prefs.getString('pending_buy_now_form_data');
        List<Map<String, String>>? formDataList;
        if (formDataStr != null && formDataStr.isNotEmpty) {
          try {
            final decoded = jsonDecode(formDataStr) as List<dynamic>?;
            formDataList = decoded
                ?.map(
                    (e) => Map<String, String>.from(e as Map<dynamic, dynamic>))
                .toList();
          } catch (_) {}
        }
        // Use "shop" so report adds same as dialog (backend shows it in item_type 1 list)
        final addResult = await AddtoCartApiService()
            .addToCartApi(apiToken, pendingItemId, 'shop', formDataList ?? []);
        // Clear pending only when add succeeded so user can retry after login
        if (addResult != null) {
          await prefs.remove('pending_buy_now_item_id');
          await prefs.remove('pending_buy_now_form_data');
          await prefs.remove('pending_buy_now_type');
        }
      }
    }

    final buyNow = widget.isBuyNow ? 1 : 0;
    cartListModel = await cartListApiService.getCartlistapi(
        apiToken.toString(), widget.itemType,
        showErrorToast: !isGuest, buyNow: buyNow);

    if (!mounted) return;

    if (cartListModel != null && cartListModel!.data != null) {
      List<CartListingDatum> apiList = cartListModel!.data!;

      setState(() {
        if (widget.isBuyNow && widget.buyNowProductId != null) {
          cartlist = apiList
              .where((item) =>
                  item.id == widget.buyNowProductId ||
                  item.itemid == widget.buyNowProductId)
              .toList();
        } else if (widget.buyNowProductId != null) {
          cartlist = apiList
              .where((item) => item.id == widget.buyNowProductId)
              .toList();
        } else {
          cartlist = apiList;
        }

        quantity = cartListModel!.totalQuantity?.toString() ?? '0';
        cartQuantityNotifier.value = quantity!;
      });
    } else {
      setState(() {
        cartlist = [];
      });
    }

    if (!mounted) return;
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
      cartListModel =
          await cartListApiService.getCartlistapi(apiToken, widget.itemType);

      discount = cartListModel!.discount;
      tax = cartListModel!.tax;
      if (cartListModel == null) {
        print("Cart list model is empty");
        cartlist = [];
      } else {
        cartlist = cartListModel!.data ?? [];
        print(cartlist);
        quantity = cartListModel!.totalQuantity?.toString() ?? '0';
        cartQuantityNotifier.value = cartListModel!.totalQuantity.toString();

        setState(() {});
      }
    } catch (e) {
      print("Error removing item: $e");
      Fluttertoast.showToast(
        msg: "Failed to remove item: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  ReusableFunction reusableFunction = ReusableFunction();
  AddressApiService addressApiService = AddressApiService();
  DeleteAddressApiService deleteAddressApiService = DeleteAddressApiService();
  AddressApiModel? addressApiModel;
  List<AddressDatum> addresslist = [];

  SubmitAddressApiService submitAddressApiService = SubmitAddressApiService();
  dynamic stateid;
  dynamic cityid;
  // int addreesid=0;
  getuserdata() async {
    if (!mounted) return;
    setState(() {
      isloading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    final buyNow = widget.isBuyNow ? 1 : 0;

    final paymentOpt = _selectedPaymentValue ?? 'now';
    checkoutOrderSummaryApiModel = await checkoutOrderSummaryApi
        .fetchchekoutorderdata(context, apiToken.toString(), widget.itemType,
            buyNow: buyNow,
            cartitemid: widget.buyNowCartItemId,
            paymentOption: paymentOpt);

    if (!mounted) return;
    setState(() {
      if (checkoutOrderSummaryApiModel?.data != null) {
        subtotal = checkoutOrderSummaryApiModel!.data!.subTotal ?? 0;
        total = checkoutOrderSummaryApiModel!.data!.total ?? 0;
        discount = checkoutOrderSummaryApiModel!.data!.discount;
        tax = checkoutOrderSummaryApiModel!.data!.taxes ?? 0;
        couponamount = checkoutOrderSummaryApiModel!.data!.couponAmount ?? 0;
        shippingcharges =
            checkoutOrderSummaryApiModel!.data!.shippingPrice ?? 0;
        codcharge = checkoutOrderSummaryApiModel!.data!.codCharge ?? 0;
      }
      if (widget.isBuyNow && checkoutOrderSummaryApiModel?.data == null)
        _recalcBuyNowTotals();
    });

    print("print after setstate ${checkoutOrderSummaryApiModel?.data?.taxes}");

    addressApiModel =
        await addressApiService.getaddressapidata(apiToken.toString());
    addresslist = addressApiModel?.data ?? [];
    if (addresslist.isNotEmpty) {
      addressid = addresslist.first.addressId;
    }

    stateModel = await stateApiService.fetchstatedata("101");
    statedatalist = stateModel?.data ?? [];

    try {
      selectstate = statedatalist.isNotEmpty
          ? statedatalist.firstWhere((state) => state.id == stateid)
          : null;
    } catch (e) {
      selectstate = null;
    }

    if (selectstate != null) {
      cityModel =
          await cityApiService.fetchcitydata(selectstate!.id.toString());
      citydatalist = cityModel?.data ?? [];

      try {
        selectcity = citydatalist.isNotEmpty
            ? citydatalist.firstWhere((city) => city.id == cityid)
            : null;
      } catch (e) {
        selectcity = null;
      }

      if (!mounted) return;
      setState(() {});
    }

    if (!mounted) return;
    setState(() {
      isloading = false;
    });
  }

  Future<void> _refreshCheckoutForPaymentOption() async {
    if (apiToken == null || _selectedPaymentValue == null) return;
    final buyNow = widget.isBuyNow ? 1 : 0;
    final couponApplied =
        couponapply && couponcodecontroller.text.trim().isNotEmpty;

    if (couponApplied) {
      final res = await checkoutCouponcodeApi.fetchvheckoutCouponcodeApi(
        context,
        apiToken.toString(),
        'order',
        couponcodecontroller.text.trim(),
        0,
        widget.itemType ?? 0,
        addressid,
        buyNow: buyNow,
        cartitemid: widget.buyNowCartItemId,
        paymentOption: _selectedPaymentValue,
      );
      if (!mounted || res?.data == null) return;
      setState(() {
        checkoutOrderSummaryApiModel = res;
        subtotal = res!.data!.subTotal ?? 0;
        total = res.data!.total ?? 0;
        discount = res.data!.discount;
        tax = res.data!.taxes ?? 0;
        couponamount = res.data!.couponAmount ?? 0;
        shippingcharges = res.data!.shippingPrice ?? 0;
        codcharge = res.data!.codCharge ?? 0;
      });
    } else {
      final res = await checkoutOrderSummaryApi.fetchchekoutorderdata(
        context,
        apiToken.toString(),
        widget.itemType,
        buyNow: buyNow,
        cartitemid: widget.buyNowCartItemId,
        paymentOption: _selectedPaymentValue,
      );
      if (!mounted || res?.data == null) return;
      setState(() {
        checkoutOrderSummaryApiModel = res;
        subtotal = res!.data!.subTotal ?? 0;
        total = res.data!.total ?? 0;
        discount = res.data!.discount;
        tax = res.data!.taxes ?? 0;
        couponamount = res.data!.couponAmount ?? 0;
        shippingcharges = res.data!.shippingPrice ?? 0;
        codcharge = res.data!.codCharge ?? 0;
      });
    }
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final methods =
          await _orderApiService.getPaymentTypes(widget.itemType ?? 0);
      if (mounted) {
        setState(() {
          paymentMethods = methods;

          if (paymentMethods.isNotEmpty) {
            final payOnlineList = paymentMethods
                .where((m) => m.value.toLowerCase() == 'now')
                .toList();
            _selectedPaymentValue = payOnlineList.isNotEmpty
                ? payOnlineList.first.value
                : paymentMethods.first.value;
          }
          isPaymentLoading = false;
        });

        if (paymentMethods.isNotEmpty &&
            _selectedPaymentValue?.toLowerCase() == 'cod') {
          await _refreshCheckoutForPaymentOption();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isPaymentLoading = false;
        });
        Fluttertoast.showToast(msg: "Payment methods could not be loaded.");
        print("Error fetching payment methods: $e");
      }
    }
  }

  Future<bool?> showEditCartItemDialog(
    BuildContext context, {
    required int itemId,
    required List<dynamic> initialFormData,
    required String? apiToken,
  }) async {
    final Map<String, TextEditingController> controllers = {};

    for (var fieldData in initialFormData) {
      final key = fieldData['key'] as String;
      final value = fieldData['value'] as String;
      controllers[key] = TextEditingController(text: value);
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: const Text('Edit Details'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: isLoading
                      ? [const Center(child: CircularProgressIndicator())]
                      : initialFormData.map<Widget>((fieldData) {
                          final key = fieldData['key'] as String;
                          final label = fieldData['label'] as String;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TextField(
                              controller: controllers[key],
                              decoration: InputDecoration(
                                labelText: label,
                                filled: true,
                                fillColor: Colors.white,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          );
                        }).toList(),
                ),
              ),
              actions: isLoading
                  ? []
                  : <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomStyles.pinki,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                          shadowColor: CustomStyles.pinki,
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });

                          final List<FormDataItem> updatedFormData = [];
                          for (var fieldData in initialFormData) {
                            final key = fieldData['key'] as String;
                            final label = fieldData['label'] as String;
                            updatedFormData.add(FormDataItem(
                              key: key,
                              label: label,
                              value: controllers[key]!.text,
                            ));
                          }

                          final response = await AstroApiService.updateCartItem(
                            itemId: itemId,
                            formData: updatedFormData,
                            apiToken: apiToken,
                          );

                          setState(() {
                            isLoading = false;
                          });

                          if (response != null) {
                            if (response.success ||
                                response.message
                                    .toLowerCase()
                                    .contains('success')) {
                              Navigator.of(dialogContext).pop(true);
                            } else {
                              Navigator.of(dialogContext).pop(false);
                            }
                          } else {
                            Navigator.of(dialogContext).pop(false);
                          }
                        },
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  Future<void> submitaddressform(int addressId) async {
    setState(() {
      isloading = true;
    });

    try {
      await submitAddressApiService.submitAddress(
        token: apiToken.toString(),
        fullName: usernamecontroller.text,
        phone: phonecontroller.text,
        email: emailcontroller.text,
        countryId: 101,
        stateId: selectstate!.id,
        cityId: selectcity!.id,
        zipcode: pincodecontroller.text,
        address: placeofbirthcontroller.text,
        addressId: addressId,
        landmark: landmarkcontroller.text.trim().isEmpty
            ? null
            : landmarkcontroller.text.trim(),
      );

      await getuserdata();
      couponcodecontroller.clear();
      usernamecontroller.clear();
      phonecontroller.clear();
      emailcontroller.clear();
      selectcity = null;
      selectstate = null;
      pincodecontroller.clear();
      placeofbirthcontroller.clear();
      landmarkcontroller.clear();

      Navigator.pop(context);
    } catch (e) {
      print("Submit failed: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    (() async {
      await getuserdata();
      if (!mounted) return;
      await getcartlist();
    })();
    _fetchPaymentMethods();
    _loadInitialBillingData();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _focusNode.addListener(() {
      setState(() {
        borderColor =
            _focusNode.hasFocus ? Colors.deepOrange : Color(0xffFFAF12);
      });
    });
  }

  @override
  void dispose() {
    if (widget.isBuyNow) {
      BuyNowCart.clear();
      SharedPreferences.getInstance().then((prefs) {
        apiToken = prefs.getString('api_token');
        if (apiToken != null && apiToken!.isNotEmpty) {
          cartListApiService.clearBuyNowCart(apiToken);
        }
      });
    }
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        title: "Checkout",
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
        actions: [],
      ),
      body: Stack(
        children: [
          isloading
              ? reusableFunction.loadingRow()
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.itemType == 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery Address',
                                    style: CustomStyles.black14600),
                                Container(
                                  height: 40,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: CustomStyles.pinki,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.add, color: Colors.white),
                                    onPressed: () {
                                      showAddressFormPopup(context, 0);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            ListView.builder(
                              itemCount: addresslist.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black38),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: Radio<int>(
                                          value: index,
                                          groupValue: _selectedAddress,
                                          onChanged: (val) {
                                            setState(() {
                                              _selectedAddress = val!;
                                              addressid =
                                                  addresslist[index].addressId;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              addresslist[index].name ?? '',
                                              style: CustomStyles.black13600,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              "${addresslist[index].address}, ${addresslist[index].city}, ${addresslist[index].state} - ${addresslist[index].zipcode}",
                                              style: CustomStyles.black14400,
                                              softWrap: true,
                                              maxLines: 3,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          showAddressFormPopup(context,
                                              addresslist[index].addressId!);
                                        },
                                        child: Icon(Icons.edit,
                                            color: Colors.blue, size: 20),
                                      ),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title:
                                                  const Text('Delete Address'),
                                              content: const Text(
                                                  'Do you want to delete this address?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  child: const Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  child: const Text('Yes'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm != true || !mounted)
                                            return;
                                          final deletedId =
                                              addresslist[index].addressId;
                                          await deleteAddressApiService
                                              .deleteaddressapi(
                                            token: apiToken.toString(),
                                            addressId: deletedId!,
                                          );
                                          if (!mounted) return;
                                          addressApiModel =
                                              await addressApiService
                                                  .getaddressapidata(
                                                      apiToken.toString());
                                          addresslist =
                                              addressApiModel?.data ?? [];
                                          if (addresslist.isNotEmpty) {
                                            if (addressid == deletedId) {
                                              addressid =
                                                  addresslist.first.addressId;
                                            }
                                            addressid ??=
                                                addresslist.first.addressId;
                                            final idx = addresslist.indexWhere(
                                                (a) =>
                                                    a.addressId == addressid);
                                            _selectedAddress =
                                                idx >= 0 ? idx : 0;
                                          } else {
                                            addressid = null;
                                            _selectedAddress = 0;
                                          }
                                          setState(() {});
                                        },
                                        child: Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            const SizedBox(height: 20),
                            const SizedBox(height: 20),
                          ],
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Billing Address',
                                style: CustomStyles.black16600,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.itemType == 0)
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          _billingAddressSelection = 1;
                                          _showBillingForm = false;
                                        }),
                                        child: Row(
                                          children: [
                                            Radio<int>(
                                              value: 1,
                                              groupValue:
                                                  _billingAddressSelection,
                                              onChanged: (value) =>
                                                  setState(() {
                                                _billingAddressSelection =
                                                    value!;
                                                _showBillingForm = false;
                                              }),
                                            ),
                                            const Text(
                                                'Same as shipping address'),
                                          ],
                                        ),
                                      )
                                    else if (addresslist.isNotEmpty)
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          _billingAddressSelection = 1;
                                          _showBillingForm = false;
                                        }),
                                        child: Row(
                                          children: [
                                            Radio<int>(
                                              value: 1,
                                              groupValue:
                                                  _billingAddressSelection,
                                              onChanged: (value) =>
                                                  setState(() {
                                                _billingAddressSelection =
                                                    value!;
                                                _showBillingForm = false;
                                              }),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      addresslist.first.name ??
                                                          '',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                    "${addresslist.first.address}, ${addresslist.first.city}, ${addresslist.first.state} - ${addresslist.first.zipcode}",
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        _billingAddressSelection = 2;
                                        _showBillingForm = true;
                                      }),
                                      child: Row(
                                        children: [
                                          Radio<int>(
                                            value: 2,
                                            groupValue:
                                                _billingAddressSelection,
                                            onChanged: (value) => setState(() {
                                              _billingAddressSelection = value!;
                                              _showBillingForm = true;
                                            }),
                                          ),
                                          Text(widget.itemType != 0 &&
                                                  addresslist.isEmpty
                                              ? 'Add a billing address'
                                              : 'Use a different billing address'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_showBillingForm)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Form(
                                    key: _billingFormKey,
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: CustomTextField(
                                                title: "Full name",
                                                label: "Full name",
                                                controller:
                                                    billingFullNameController,
                                                validator: (value) =>
                                                    value == null ||
                                                            value.isEmpty
                                                        ? 'Required'
                                                        : null,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: CustomTextField(
                                                title: "Email (Optional)",
                                                label: "Email (Optional)",
                                                textInputType:
                                                    TextInputType.emailAddress,
                                                controller:
                                                    billingEmailController,
                                                validator: (value) => null,
                                              ),
                                            ),
                                          ],
                                        ),
                                        CustomTextField(
                                          title: "Phone",
                                          label: "Phone",
                                          textInputType: TextInputType.phone,
                                          maxLength: 10,
                                          controller: billingPhoneController,
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                                  ? 'Required'
                                                  : null,
                                        ),
                                        CustomTextField(
                                          title: "Address",
                                          label: "Address",
                                          controller: billingAddressController,
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                                  ? 'Required'
                                                  : null,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: CustomDropdownField<
                                                  StateDatum>(
                                                title: "State",
                                                hintText: "Select State",
                                                value: selectBillingState,
                                                items:
                                                    statedatalist.map((state) {
                                                  return DropdownMenuItem<
                                                      StateDatum>(
                                                    value: state,
                                                    child:
                                                        Text(state.name ?? ''),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      selectBillingState =
                                                          value;
                                                      _fetchBillingCities(
                                                          value.id!);
                                                    });
                                                  }
                                                },
                                                validator: (value) =>
                                                    value == null
                                                        ? 'Required'
                                                        : null,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: CustomDropdownField<
                                                  CityDatum>(
                                                title: "City",
                                                hintText: "Select City",
                                                value: selectBillingCity,
                                                items:
                                                    billingCityList.map((city) {
                                                  return DropdownMenuItem<
                                                      CityDatum>(
                                                    value: city,
                                                    child:
                                                        Text(city.name ?? ''),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectBillingCity = value;
                                                  });
                                                },
                                                validator: (value) =>
                                                    value == null
                                                        ? 'Required'
                                                        : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                        CustomTextField(
                                          title: "Pin Code",
                                          label: "Pin Code",
                                          controller: billingPinCodeController,
                                          textInputType: TextInputType.number,
                                          maxLength: 6,
                                          validator: (value) =>
                                              value == null || value.length < 6
                                                  ? '6 digits required'
                                                  : null,
                                        ),
                                        CustomTextField(
                                          title: "Landmark (Optional)",
                                          label: "Landmark (Optional)",
                                          controller: billingLandmarkController,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Methods',
                                style: CustomStyles.black16600,
                              ),
                              const SizedBox(height: 8),
                              if (isPaymentLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (paymentMethods.isEmpty)
                                const Center(
                                    child:
                                        Text("No payment methods available."))
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: paymentMethods.length,
                                  itemBuilder: (context, index) {
                                    final paymentMethod = paymentMethods[index];
                                    return GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          _selectedPaymentValue =
                                              paymentMethod.value;
                                        });
                                        await _refreshCheckoutForPaymentOption();
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey.shade400),
                                        ),
                                        child: Row(
                                          children: [
                                            Radio<String>(
                                              value: paymentMethod.value,
                                              groupValue: _selectedPaymentValue,
                                              onChanged: (value) async {
                                                setState(() {
                                                  _selectedPaymentValue = value;
                                                });
                                                await _refreshCheckoutForPaymentOption();
                                              },
                                            ),
                                            Text(paymentMethod.name),
                                            const Spacer(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0),
                                              child: Icon(
                                                paymentMethod.value
                                                            .toLowerCase() ==
                                                        'cod'
                                                    ? Icons.payments_outlined
                                                    : Icons
                                                        .phone_android_rounded,
                                                color: paymentMethod.value
                                                            .toLowerCase() ==
                                                        'cod'
                                                    ? Colors.green[600]
                                                    : const Color(0xFF0E4677),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                          Text(
                            "Review your cart",
                            style: CustomStyles.black14600,
                          ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: cartlist.length,
                            itemBuilder: (context, index) {
                              final item = cartlist[index];
                              itemquantity = cartlist[index].quantity;
                              String cartUniqueId = item.id.toString();
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.black38))),
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(item.image ?? ''),
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
                                              ? Text('₹${item.basePrice ?? ''}',
                                                  style:
                                                      CustomStyles.black14600)
                                              : RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            ' ₹${item.basePrice ?? ''} ',
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          decorationThickness:
                                                              2,
                                                          color:
                                                              Color(0xff7A7A7A),
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            ' ₹${item.salePrice ?? ''}',
                                                        style: CustomStyles
                                                            .red15600,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          if (widget.itemType == 0) ...[
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
                                                            item.id!,
                                                          );

                                                          if (cartDecreaseModel !=
                                                              null) {
                                                            if (!mounted)
                                                              return;

                                                            setState(() {
                                                              itemquantity =
                                                                  cartDecreaseModel!
                                                                          .qunatity ??
                                                                      0;
                                                            });

                                                            cartListModel = await cartListApiService
                                                                .getCartlistapi(
                                                                    apiToken,
                                                                    widget
                                                                        .itemType,
                                                                    buyNow: widget
                                                                            .isBuyNow
                                                                        ? 1
                                                                        : 0);
                                                            var rawList =
                                                                cartListModel
                                                                        ?.data ??
                                                                    [];
                                                            if (widget
                                                                    .isBuyNow &&
                                                                widget.buyNowProductId !=
                                                                    null) {
                                                              cartlist = rawList
                                                                  .where((item) =>
                                                                      item.id ==
                                                                          widget
                                                                              .buyNowProductId ||
                                                                      item.itemid ==
                                                                          widget
                                                                              .buyNowProductId)
                                                                  .toList();
                                                            } else {
                                                              cartlist =
                                                                  rawList;
                                                            }

                                                            if (couponapply &&
                                                                couponcodecontroller
                                                                    .text
                                                                    .isNotEmpty) {
                                                              checkoutOrderSummaryApiModel =
                                                                  await checkoutCouponcodeApi
                                                                      .fetchvheckoutCouponcodeApi(
                                                                context,
                                                                apiToken
                                                                    .toString(),
                                                                'order',
                                                                couponcodecontroller
                                                                    .text,
                                                                0,
                                                                widget.itemType,
                                                                addressid,
                                                                buyNow: widget
                                                                        .isBuyNow
                                                                    ? 1
                                                                    : 0,
                                                                cartitemid: widget
                                                                    .buyNowCartItemId,
                                                                paymentOption:
                                                                    _selectedPaymentValue ??
                                                                        'now',
                                                              );
                                                            } else {
                                                              checkoutOrderSummaryApiModel =
                                                                  await checkoutOrderSummaryApi
                                                                      .fetchchekoutorderdata(
                                                                context,
                                                                apiToken
                                                                    .toString(),
                                                                widget.itemType,
                                                                buyNow: widget
                                                                        .isBuyNow
                                                                    ? 1
                                                                    : 0,
                                                                cartitemid: widget
                                                                    .buyNowCartItemId,
                                                                paymentOption:
                                                                    _selectedPaymentValue,
                                                              );
                                                            }

                                                            if (checkoutOrderSummaryApiModel == null ||
                                                                checkoutOrderSummaryApiModel!
                                                                        .data ==
                                                                    null ||
                                                                cartlist
                                                                    .isEmpty) {
                                                              Future.microtask(
                                                                  () {
                                                                if (mounted) {
                                                                  Navigator
                                                                      .pushAndRemoveUntil(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              BottomAppBarScreen(),
                                                                    ),
                                                                    (Route<dynamic>
                                                                            route) =>
                                                                        false,
                                                                  );
                                                                }
                                                              });
                                                              return;
                                                            }

                                                            if (!mounted)
                                                              return;

                                                            setState(() {
                                                              if (checkoutOrderSummaryApiModel
                                                                      ?.data !=
                                                                  null) {
                                                                subtotal =
                                                                    checkoutOrderSummaryApiModel!
                                                                            .data!
                                                                            .subTotal ??
                                                                        0.0;
                                                                total = checkoutOrderSummaryApiModel!
                                                                        .data!
                                                                        .total ??
                                                                    0.0;
                                                              }
                                                              discount =
                                                                  checkoutOrderSummaryApiModel!
                                                                      .data!
                                                                      .discount;
                                                              tax = checkoutOrderSummaryApiModel!
                                                                      .data!
                                                                      .taxes ??
                                                                  0.0;
                                                              couponamount =
                                                                  checkoutOrderSummaryApiModel!
                                                                          .data!
                                                                          .couponAmount ??
                                                                      0.0;
                                                              shippingcharges =
                                                                  checkoutOrderSummaryApiModel!
                                                                          .data!
                                                                          .shippingPrice ??
                                                                      0.0;
                                                              codcharge =
                                                                  checkoutOrderSummaryApiModel!
                                                                          .data!
                                                                          .codCharge ??
                                                                      0;

                                                              quantity = cartListModel
                                                                      ?.totalQuantity
                                                                      ?.toString() ??
                                                                  '0';
                                                              cartQuantityNotifier
                                                                  .value = cartListModel
                                                                      ?.totalQuantity
                                                                      ?.toString() ??
                                                                  '0';
                                                              if (widget
                                                                      .isBuyNow &&
                                                                  checkoutOrderSummaryApiModel
                                                                          ?.data ==
                                                                      null)
                                                                _recalcBuyNowTotals();
                                                            });
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
                                                            if (couponapply &&
                                                                couponcodecontroller
                                                                    .text
                                                                    .isNotEmpty) {
                                                              checkoutOrderSummaryApiModel =
                                                                  await checkoutCouponcodeApi
                                                                      .fetchvheckoutCouponcodeApi(
                                                                context,
                                                                apiToken
                                                                    .toString(),
                                                                'order',
                                                                couponcodecontroller
                                                                    .text,
                                                                0,
                                                                widget.itemType,
                                                                addressid,
                                                                buyNow: widget
                                                                        .isBuyNow
                                                                    ? 1
                                                                    : 0,
                                                                cartitemid: widget
                                                                    .buyNowCartItemId,
                                                                paymentOption:
                                                                    _selectedPaymentValue ??
                                                                        'now',
                                                              );
                                                            } else {
                                                              checkoutOrderSummaryApiModel =
                                                                  await checkoutOrderSummaryApi
                                                                      .fetchchekoutorderdata(
                                                                context,
                                                                apiToken
                                                                    .toString(),
                                                                widget.itemType,
                                                                buyNow: widget
                                                                        .isBuyNow
                                                                    ? 1
                                                                    : 0,
                                                                cartitemid: widget
                                                                    .buyNowCartItemId,
                                                                paymentOption:
                                                                    _selectedPaymentValue,
                                                              );
                                                            }

                                                            if (checkoutOrderSummaryApiModel
                                                                    ?.data !=
                                                                null) {
                                                              subtotal =
                                                                  checkoutOrderSummaryApiModel!
                                                                          .data!
                                                                          .subTotal ??
                                                                      0.0;
                                                              total =
                                                                  checkoutOrderSummaryApiModel!
                                                                          .data!
                                                                          .total ??
                                                                      0.0;
                                                            }
                                                            discount =
                                                                checkoutOrderSummaryApiModel!
                                                                        .data!
                                                                        .discount ??
                                                                    0.0;
                                                            tax =
                                                                checkoutOrderSummaryApiModel!
                                                                        .data!
                                                                        .taxes ??
                                                                    0.0;
                                                            couponamount =
                                                                checkoutOrderSummaryApiModel!
                                                                        .data!
                                                                        .couponAmount ??
                                                                    0.0;
                                                            shippingcharges =
                                                                checkoutOrderSummaryApiModel!
                                                                        .data!
                                                                        .shippingPrice ??
                                                                    0.0;
                                                            codcharge =
                                                                checkoutOrderSummaryApiModel!
                                                                        .data!
                                                                        .codCharge ??
                                                                    0;
                                                            if (widget
                                                                    .isBuyNow &&
                                                                checkoutOrderSummaryApiModel
                                                                        ?.data ==
                                                                    null)
                                                              _recalcBuyNowTotals();
                                                            cartListModel = await cartListApiService
                                                                .getCartlistapi(
                                                                    apiToken,
                                                                    widget
                                                                        .itemType,
                                                                    buyNow: widget
                                                                            .isBuyNow
                                                                        ? 1
                                                                        : 0);

                                                            if (cartListModel ==
                                                                null) {
                                                              print(
                                                                  "Cart list model is empty");
                                                              cartlist = [];
                                                            } else {
                                                              var rawList =
                                                                  cartListModel!
                                                                          .data ??
                                                                      [];
                                                              if (widget
                                                                      .isBuyNow &&
                                                                  widget.buyNowProductId !=
                                                                      null) {
                                                                cartlist = rawList
                                                                    .where((item) =>
                                                                        item.id ==
                                                                            widget
                                                                                .buyNowProductId ||
                                                                        item.itemid ==
                                                                            widget.buyNowProductId)
                                                                    .toList();
                                                              } else {
                                                                cartlist =
                                                                    rawList;
                                                              }
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

                                                              setState(() {
                                                                if (widget
                                                                        .isBuyNow &&
                                                                    checkoutOrderSummaryApiModel
                                                                            ?.data ==
                                                                        null)
                                                                  _recalcBuyNowTotals();
                                                              });
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
                                            ),
                                          ]
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

                                            checkoutOrderSummaryApiModel =
                                                await checkoutOrderSummaryApi
                                                    .fetchchekoutorderdata(
                                                        context,
                                                        apiToken.toString(),
                                                        widget.itemType,
                                                        buyNow: widget.isBuyNow
                                                            ? 1
                                                            : 0,
                                                        cartitemid: widget
                                                            .buyNowCartItemId,
                                                        paymentOption:
                                                            _selectedPaymentValue);

                                            if (checkoutOrderSummaryApiModel ==
                                                    null ||
                                                checkoutOrderSummaryApiModel!
                                                        .data ==
                                                    null ||
                                                cartlist == null ||
                                                cartlist.isEmpty) {
                                              Future.microtask(() {
                                                if (mounted) {
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BottomAppBarScreen(),
                                                    ),
                                                    (Route<dynamic> route) =>
                                                        false,
                                                  );
                                                }
                                              });
                                              return;
                                            }

                                            await getcartlist();

                                            if (checkoutOrderSummaryApiModel !=
                                                    null &&
                                                checkoutOrderSummaryApiModel!
                                                        .data !=
                                                    null) {
                                              setState(() {
                                                if (checkoutOrderSummaryApiModel
                                                        ?.data !=
                                                    null) {
                                                  subtotal =
                                                      checkoutOrderSummaryApiModel!
                                                              .data!.subTotal ??
                                                          0.0;
                                                  total =
                                                      checkoutOrderSummaryApiModel!
                                                              .data!.total ??
                                                          0.0;
                                                }
                                                discount =
                                                    checkoutOrderSummaryApiModel!
                                                        .data!.discount;
                                                tax =
                                                    checkoutOrderSummaryApiModel!
                                                            .data!.taxes ??
                                                        0.0;
                                                couponamount =
                                                    checkoutOrderSummaryApiModel!
                                                            .data!
                                                            .couponAmount ??
                                                        0.0;
                                                shippingcharges =
                                                    checkoutOrderSummaryApiModel!
                                                            .data!
                                                            .shippingPrice ??
                                                        0.0;
                                                if (widget.isBuyNow &&
                                                    checkoutOrderSummaryApiModel
                                                            ?.data ==
                                                        null)
                                                  _recalcBuyNowTotals();
                                              });
                                            }
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        if (widget.itemType == 1) ...[
                                          GestureDetector(
                                            onTap: () async {
                                              final dynamic itemFormData =
                                                  item.formData;

                                              if (itemFormData != null &&
                                                  itemFormData is List &&
                                                  itemFormData.isNotEmpty) {
                                                final bool? wasUpdated =
                                                    await showEditCartItemDialog(
                                                  context,
                                                  itemId: item.id!,
                                                  initialFormData: itemFormData,
                                                  apiToken: apiToken,
                                                );

                                                if (wasUpdated == true) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Item updated successfully!");
                                                  setState(() {
                                                    isloading = true;
                                                  });
                                                  await getcartlist();

                                                  if (couponapply &&
                                                      couponcodecontroller
                                                          .text.isNotEmpty) {
                                                    checkoutOrderSummaryApiModel =
                                                        await checkoutCouponcodeApi
                                                            .fetchvheckoutCouponcodeApi(
                                                      context,
                                                      apiToken.toString(),
                                                      'order',
                                                      couponcodecontroller.text,
                                                      0,
                                                      widget.itemType,
                                                      addressid,
                                                      buyNow: widget.isBuyNow
                                                          ? 1
                                                          : 0,
                                                      cartitemid: widget
                                                          .buyNowCartItemId,
                                                      paymentOption:
                                                          _selectedPaymentValue ??
                                                              'now',
                                                    );
                                                  } else {
                                                    await getuserdata();
                                                  }

                                                  if (checkoutOrderSummaryApiModel
                                                          ?.data !=
                                                      null) {
                                                    setState(() {
                                                      if (checkoutOrderSummaryApiModel!
                                                              .data !=
                                                          null) {
                                                        subtotal =
                                                            checkoutOrderSummaryApiModel!
                                                                    .data!
                                                                    .subTotal ??
                                                                0;
                                                        total =
                                                            checkoutOrderSummaryApiModel!
                                                                    .data!
                                                                    .total ??
                                                                0;
                                                      }
                                                      discount =
                                                          checkoutOrderSummaryApiModel!
                                                              .data!.discount;
                                                      tax =
                                                          checkoutOrderSummaryApiModel!
                                                                  .data!
                                                                  .taxes ??
                                                              0;
                                                      couponamount =
                                                          checkoutOrderSummaryApiModel!
                                                                  .data!
                                                                  .couponAmount ??
                                                              0;
                                                      shippingcharges =
                                                          checkoutOrderSummaryApiModel!
                                                                  .data!
                                                                  .shippingPrice ??
                                                              0;
                                                      codcharge =
                                                          checkoutOrderSummaryApiModel!
                                                                  .data!
                                                                  .codCharge ??
                                                              0;
                                                      isloading = false;
                                                      if (widget.isBuyNow &&
                                                          checkoutOrderSummaryApiModel
                                                                  ?.data ==
                                                              null)
                                                        _recalcBuyNowTotals();
                                                    });
                                                  } else {
                                                    setState(() {
                                                      isloading = false;
                                                    });
                                                  }
                                                }
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "No details to edit for this item.");
                                              }
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                              size: 22,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                              child: Text(
                            "Have a coupon code?\nEnter here",
                            textAlign: TextAlign.center,
                            style: CustomStyles.black14600,
                          )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1.5),
                                  ),
                                  child: CustomTextField(
                                      title: '',
                                      label: " Enter Coupon Code",
                                      controller: couponcodecontroller,
                                      suffixIcon: GestureDetector(
                                        onTap: () async {
                                          if (couponcodecontroller
                                              .text.isNotEmpty) {
                                            checkoutOrderSummaryApiModel =
                                                await checkoutCouponcodeApi
                                                    .fetchvheckoutCouponcodeApi(
                                                        context,
                                                        apiToken.toString(),
                                                        'order',
                                                        couponcodecontroller
                                                            .text,
                                                        0,
                                                        widget.itemType,
                                                        addressid,
                                                        buyNow: widget.isBuyNow
                                                            ? 1
                                                            : 0,
                                                        cartitemid: widget
                                                            .buyNowCartItemId,
                                                        paymentOption:
                                                            _selectedPaymentValue ??
                                                                'now');
                                            print(
                                                "dixi hello $checkoutCouponcodeApi");

                                            if (checkoutOrderSummaryApiModel !=
                                                    null &&
                                                checkoutOrderSummaryApiModel!
                                                        .data !=
                                                    null) {
                                              couponapply = true;
                                              print(
                                                  "Coupon applied successfully: SubTotal:${checkoutOrderSummaryApiModel!.data} ${checkoutOrderSummaryApiModel!.data!.subTotal}, Total: ${checkoutOrderSummaryApiModel!.data!.total}, Discount: ${checkoutOrderSummaryApiModel!.data!.discount}, Taxes: ${checkoutOrderSummaryApiModel!.data!.taxes}, CouponAmount: ${checkoutOrderSummaryApiModel!.data!.couponAmount}, ShippingPrice: ${checkoutOrderSummaryApiModel!.data!.shippingPrice}");

                                              setState(() {
                                                if (checkoutOrderSummaryApiModel
                                                        ?.data !=
                                                    null) {
                                                  subtotal =
                                                      checkoutOrderSummaryApiModel!
                                                              .data!.subTotal ??
                                                          0.0;
                                                  total =
                                                      checkoutOrderSummaryApiModel!
                                                              .data!.total ??
                                                          0.0;
                                                }
                                                if (widget.isBuyNow &&
                                                    checkoutOrderSummaryApiModel
                                                            ?.data ==
                                                        null)
                                                  _recalcBuyNowTotals();
                                                discount =
                                                    checkoutOrderSummaryApiModel!
                                                            .data!.discount ??
                                                        0.0;
                                                tax =
                                                    checkoutOrderSummaryApiModel!
                                                            .data!.taxes ??
                                                        0.0;
                                                couponamount =
                                                    checkoutOrderSummaryApiModel!
                                                        .data!.couponAmount;
                                                shippingcharges =
                                                    checkoutOrderSummaryApiModel!
                                                            .data!
                                                            .shippingPrice ??
                                                        0.0;
                                                codcharge =
                                                    checkoutOrderSummaryApiModel!
                                                            .data!.codCharge ??
                                                        0;
                                                print("discount$discount");
                                              });

                                              Fluttertoast.showToast(
                                                msg:
                                                    checkoutOrderSummaryApiModel!
                                                            .message ??
                                                        'Coupon applied!',
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                                fontSize: 14.0,
                                              );
                                            } else {
                                              Fluttertoast.showToast(
                                                msg:
                                                    checkoutOrderSummaryApiModel!
                                                            .message ??
                                                        '',
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                                fontSize: 14.0,
                                              );
                                            }
                                          } else {
                                            setState(() {
                                              couponapply = false;
                                            });
                                            Fluttertoast.showToast(
                                              msg: "Please enter a coupon code",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 14.0,
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 80,
                                          margin: EdgeInsets.all(1),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(3),
                                                  bottomRight:
                                                      Radius.circular(3)),
                                              color: CustomStyles.pinki),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Apply",
                                            style: CustomStyles.white,
                                          ),
                                        ),
                                      )),
                                ),
                              ),
                              couponcodecontroller.text.isEmpty ||
                                      couponcodecontroller.text == null ||
                                      couponapply == false
                                  ? SizedBox(
                                      height: 0,
                                      width: 0,
                                    )
                                  : SizedBox(width: 10),
                              couponcodecontroller.text.isEmpty ||
                                      couponcodecontroller.text == null ||
                                      couponapply == false
                                  ? SizedBox(
                                      height: 0,
                                      width: 0,
                                    )
                                  : Visibility(
                                      visible: couponapply,
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (couponcodecontroller
                                              .text.isNotEmpty) {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            apiToken =
                                                prefs.getString('api_token');

                                            checkoutOrderSummaryApiModel =
                                                await checkoutOrderSummaryApi
                                                    .fetchchekoutorderdata(
                                                        context,
                                                        apiToken.toString(),
                                                        widget.itemType,
                                                        buyNow: widget.isBuyNow
                                                            ? 1
                                                            : 0,
                                                        cartitemid: widget
                                                            .buyNowCartItemId,
                                                        paymentOption:
                                                            _selectedPaymentValue);
                                            total =
                                                checkoutOrderSummaryApiModel!
                                                    .data!.total;
                                            subtotal =
                                                checkoutOrderSummaryApiModel!
                                                    .data!.subTotal;
                                            if (checkoutOrderSummaryApiModel!
                                                    .data ==
                                                null) {
                                              Navigator.pop(context);
                                            }
                                            codcharge =
                                                checkoutOrderSummaryApiModel!
                                                        .data!.codCharge ??
                                                    0;
                                            discount =
                                                checkoutOrderSummaryApiModel!
                                                    .data!.discount;
                                            tax = checkoutOrderSummaryApiModel!
                                                .data!.taxes;
                                            couponamount =
                                                checkoutOrderSummaryApiModel!
                                                    .data!.couponAmount;
                                          }
                                          setState(() {
                                            couponcodecontroller.clear();
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(top: 10),
                                          decoration: BoxDecoration(
                                              color: CustomStyles.bgcolor,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Icon(Icons.close,
                                              size: 20, color: Colors.black),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          cartlist.isEmpty || cartlist == null
                              ? SizedBox()
                              : Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Order Summary",
                                        style: CustomStyles.black14600,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Subtotal",
                                            style: CustomStyles.black14600,
                                          ),
                                          Spacer(),
                                          Text(
                                            "₹ ${subtotal}",
                                            style: CustomStyles.black14400,
                                          ),
                                        ],
                                      ),
                                      if ((double.tryParse(
                                                  codcharge.toString()) ??
                                              0) >
                                          0)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "COD Charge",
                                              style: CustomStyles.black14600,
                                            ),
                                            Spacer(),
                                            Text(
                                              "₹ ${codcharge}",
                                              style: CustomStyles.black14400,
                                            ),
                                          ],
                                        ),
                                      if (double.tryParse(
                                              couponamount.toString())! >
                                          0) ...[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Coupon Amount",
                                              style: CustomStyles.black14600,
                                            ),
                                            Spacer(),
                                            Text(
                                              "₹ ${couponamount}",
                                              style: CustomStyles.black14400,
                                            ),
                                          ],
                                        ),
                                      ] else ...[
                                        SizedBox()
                                      ],
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Tax",
                                            style: CustomStyles.black14600,
                                          ),
                                          Spacer(),
                                          Text(
                                            "₹ ${tax}",
                                            style: CustomStyles.black14400,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      (double.tryParse(shippingcharges
                                                      .toString()) ??
                                                  0.0) <=
                                              0
                                          ? SizedBox(height: 0, width: 0)
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Shipping Charges",
                                                  style:
                                                      CustomStyles.black14600,
                                                ),
                                                Spacer(),
                                                Text(
                                                  "₹ ${shippingcharges}",
                                                  style:
                                                      CustomStyles.black14400,
                                                ),
                                              ],
                                            ),
                                      Divider(),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Total",
                                            style: CustomStyles.black16600,
                                          ),
                                          Spacer(),
                                          Text(
                                            "₹ ${checkoutOrderSummaryApiModel?.data?.total ?? total}",
                                            style: CustomStyles.black14500,
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                ),
                          ispaybtnloading
                              ? Center(child: CircularProgressIndicator())
                              : Center(
                                  child: CustomElevatedButton(
                                    backgroundColor: CustomStyles.pinki,
                                    text: "Place Order",
                                    onPressed: () async {
                                      bool isTokenNumeric(String? token) {
                                        if (token == null || token.isEmpty)
                                          return false;
                                        return int.tryParse(token) != null;
                                      }

                                      final bool isUserGuest =
                                          (apiToken == null ||
                                              apiToken!.isEmpty ||
                                              isTokenNumeric(apiToken));
                                      if (isUserGuest) {
                                        print(
                                            "Guest user trying to place order");
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen(
                                                      redirectScreen:
                                                          CheckoutScreen(
                                                        itemType:
                                                            widget.itemType,
                                                        isBuyNow:
                                                            widget.isBuyNow,
                                                        buyNowProductId: widget
                                                            .buyNowProductId,
                                                        buyNowCartItemId: widget
                                                            .buyNowCartItemId,
                                                      ),
                                                    )));
                                      } else {
                                        setState(() {
                                          ispaybtnloading = true;
                                        });

                                        await getpaymentdata();
                                      }
                                    },
                                  ),
                                ),
                          SizedBox(
                            height: 60,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          if (ispaybtnloading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showAddressFormPopup(BuildContext context, int addressId) {
    bool isLoading = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> loadData() async {
              if (addressId != 0) {
                var selectedAddress = addressApiModel!.data!
                    .firstWhere((item) => item.addressId == addressId);

                usernamecontroller.text = selectedAddress.name ?? '';
                phonecontroller.text = selectedAddress.phone ?? '';
                landmarkcontroller.clear();
                emailcontroller.text = selectedAddress.email ?? '';
                placeofbirthcontroller.text = selectedAddress.address ?? '';
                pincodecontroller.text = selectedAddress.zipcode.toString();

                stateModel = await stateApiService.fetchstatedata("101");
                statedatalist = stateModel?.data ?? [];

                try {
                  selectstate = statedatalist
                      .firstWhere((item) => item.id == selectedAddress.stateId);
                } catch (e) {
                  selectstate = null;
                }

                if (selectstate != null) {
                  cityModel = await cityApiService
                      .fetchcitydata(selectstate!.id.toString());
                  citydatalist = cityModel?.data ?? [];

                  try {
                    selectcity = citydatalist.firstWhere(
                        (item) => item.id == selectedAddress.cityId);
                  } catch (e) {
                    selectcity = null;
                  }
                }
              } else {
                usernamecontroller.clear();
                phonecontroller.clear();
                emailcontroller.clear();
                placeofbirthcontroller.clear();
                pincodecontroller.clear();
                landmarkcontroller.clear();
                selectstate = null;
                selectcity = null;

                stateModel = await stateApiService.fetchstatedata("101");
                statedatalist = stateModel?.data ?? [];
                citydatalist = [];
              }

              setState(() {
                isLoading = false;
              });
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (isLoading) loadData();
            });

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            addressId == 0
                                                ? "Add Address"
                                                : "Edit Address",
                                            style: CustomStyles.black16600)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomTextField(
                                            outlineBorderRadius: 8,
                                            starsign: "*",
                                            title: "Name",
                                            label: "Enter Name",
                                            controller: usernamecontroller,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Name is Required';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: CustomTextField(
                                            outlineBorderRadius: 8,
                                            starsign: "*",
                                            title: "Phone",
                                            label: "Enter Phone",
                                            controller: phonecontroller,
                                            maxLength: 10,
                                            textInputType: TextInputType.number,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Phone is Required';
                                              } else if (value.length != 10) {
                                                return 'Phone number should be 10 digits';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    CustomTextField(
                                      outlineBorderRadius: 8,
                                      title: "Email (Optional)",
                                      label: "Enter Email (Optional)",
                                      controller: emailcontroller,
                                      textInputType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return null;
                                        String pattern =
                                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                        RegExp regex = RegExp(pattern);
                                        if (!regex.hasMatch(value)) {
                                          return 'Enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomDropdownField<StateDatum>(
                                      outlineBorderRadius: 8,
                                      hintText: "Select State",
                                      title: "State",
                                      starsign: '*',
                                      value: selectstate,
                                      items: statedatalist
                                          .map((StateDatum values) {
                                        return DropdownMenuItem<StateDatum>(
                                          value: values,
                                          child: Text(values.name.toString()),
                                        );
                                      }).toList(),
                                      onChanged: (value) async {
                                        setState(() {
                                          selectstate = value;
                                          selectcity = null;
                                        });

                                        if (value != null) {
                                          cityModel = await cityApiService
                                              .fetchcitydata(
                                                  selectstate!.id.toString());
                                          citydatalist = cityModel?.data ?? [];

                                          setState(() {});
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select a state';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomDropdownField<CityDatum>(
                                      outlineBorderRadius: 8,
                                      hintText: "Select City",
                                      title: "City",
                                      starsign: '*',
                                      value: selectcity,
                                      items:
                                          citydatalist.map((CityDatum values) {
                                        return DropdownMenuItem<CityDatum>(
                                          value: values,
                                          child: Text(values.name.toString()),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectcity = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select city';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomTextField(
                                      outlineBorderRadius: 8,
                                      label: "Zip Code",
                                      maxLength: 6,
                                      controller: pincodecontroller,
                                      title: "Zip Code",
                                      starsign: "*",
                                      textInputType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Zip Code is Required';
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                    CustomTextField(
                                      outlineBorderRadius: 8,
                                      height: 60,
                                      label: "Address",
                                      controller: placeofbirthcontroller,
                                      title: "Address",
                                      starsign: "*",
                                      maxline: 3,
                                      textInputType:
                                          TextInputType.streetAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Address is Required';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomTextField(
                                      outlineBorderRadius: 8,
                                      label: "Landmark (Optional)",
                                      controller: landmarkcontroller,
                                      title: "Landmark (Optional)",
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomElevatedButton(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            text: "Close",
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: CustomElevatedButton(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            text: "Submit",
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                await submitaddressform(
                                                    addressId);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}
