import 'package:astrokavach/screen/thankyou_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:astrokavach/api/consultation/chat_api/recharge_paynow_api.dart';
import 'package:astrokavach/api/consultation/chat_api/recharge_wallet_api.dart';
import 'package:astrokavach/api/payment/checkout_couponcode_api.dart';
import 'package:astrokavach/api/payment/checkout_order_summary_api.dart';
import 'package:astrokavach/api/payment/payment_verify_api.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/payment_confirming_overlay.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/cutsom_textfield.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/chat_model/recharge_wallet_model.dart';
import 'package:astrokavach/model/astrologer/chat_model/rechargepaynow_model.dart';
import 'package:astrokavach/model/payment_model/checkput_order_summary_model.dart';
import 'package:astrokavach/screen/astrologer/home_screen.dart';
import 'package:astrokavach/screen/auth/profile_screen.dart';
import 'package:astrokavach/screen/user_dashboard_screen/user_wallet_history_screen.dart';
import 'package:astrokavach/screen/walletupdate.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();
  final GlobalKey billSummaryKey = GlobalKey();

  final ReusableFunction reusableFunction = ReusableFunction();
  final RechargeWalletApiService rechargeWalletApiService =
      RechargeWalletApiService();
  final RechargePaynowApiService rechargePaynowApiService =
      RechargePaynowApiService();
  final PaymentVerifyApi paymentVerifyApi = PaymentVerifyApi();
  final CheckoutOrderSummaryApi checkoutOrderSummaryApi =
      CheckoutOrderSummaryApi();
  final CheckoutCouponcodeApi checkoutCouponcodeApi = CheckoutCouponcodeApi();
  final TextEditingController couponcodecontroller = TextEditingController();
  final Razorpay razorpay = Razorpay();

  Map<String, dynamic>? user;
  RechargeWalletModel? rechargeWalletModel;
  RechargePayNowModel? rechargePayNowModel;
  CheckoutOrderSummaryApiModel? checkoutOrderSummaryApiModel;

  List<RechargeWalletList> rechargewalletlist = [];
  bool isloading = false;
  bool ispaybtnloading = false;
  String? apiToken;
  String? callbackurl;
  String? billsummary = '';
  dynamic rechargeamount;
  dynamic gstpercent;
  dynamic getamount;
  dynamic gstAmount;
  dynamic totalamount;
  dynamic id;
  int selectedIndex = 0;
  dynamic couponamount;
  dynamic walletamount;
  dynamic options;

  // Responsive helper methods - IMPROVED
  int getCrossAxisCount(BuildContext context) {
    return 3; // Fixed 3 columns
  }

  // UPDATED - Better aspect ratio for all screen sizes
  double getChildAspectRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 0.95; // Tablets - taller cards
    if (width >= 600) return 1.0; // Large phones - taller cards
    return 1.05; // Small phones - taller cards
  }

  double getHorizontalPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 24;
    if (width >= 600) return 16;
    return 12; // Increased from 10
  }

  // NEW - Card padding helper
  double getCardPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 4.0;
    if (width >= 600) return 3.0;
    return 2.5;
  }

  // NEW - Green container height
  double getGreenContainerHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 32;
    if (width >= 600) return 28;
    return 26; // Increased
  }

  // NEW - Pink container height
  double getPinkContainerHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 32;
    if (width >= 600) return 28;
    return 26; // Increased significantly
  }

  void scrollToBillSummary() {
    final context = billSummaryKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  fetchUserData() async {
    final userData = await reusableFunction.getUserDataFromPrefs();
    if (userData != null) {
      setState(() {
        user = userData;
        walletamount = userData["wallet"];
      });
    }
  }

  bool couponapply = false;
  getRechargeData() async {
    setState(() {
      isloading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    var result = await rechargeWalletApiService
        .fetchrechargeapidata(apiToken.toString());

    if (result != null && result.data != null && result.data!.isNotEmpty) {
      setState(() {
        rechargeWalletModel = result;
        rechargewalletlist = result.data!;
        selectedIndex = 0;

        final firstPlan = result.data!.first;
        updateBillSummary(firstPlan);
      });
    } else {
      setState(() {
        rechargewalletlist = [];
      });
      
    }

    setState(() {
      isloading = false;
    });
  }

  void updateBillSummary(RechargeWalletList plan) {
    setState(() {
      id = plan.id;
      rechargeamount = plan.amount ?? 0;
      gstpercent =
          double.tryParse(plan.gstPercentage?.toString() ?? '0') ?? 0.0;
      billsummary = plan.name ?? '';
      getamount = plan.getAmount ?? 0;
      gstAmount = plan.gstAmount ?? 0.0;
      totalamount = plan.total ?? 0.0;
      couponamount = null;
      couponcodecontroller.clear();
      couponapply = false;
    });
  }

  Future<void> getpaymentdata(int planid, String couponcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');
    if (apiToken == null || apiToken!.isEmpty) return;

    Map<String, dynamic>? userData =
        await reusableFunction.getUserDataFromPrefs();
    if (userData == null || userData["country"] == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ProfileScreen()));
      return;
    }

    rechargePayNowModel = await rechargePaynowApiService
        .fetchrechargepaynowapidata(apiToken!, planid, couponcode);
    if (rechargePayNowModel?.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment data could not be fetched")));
      return;
    }

    final data = rechargePayNowModel!.data!;
    callbackurl = data.callbackUrl;

    if (data.amount != null && data.amount! > 0) {
      options = {
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
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ThankyouScreen(msg: rechargePayNowModel!.message)));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    final dynamic result = await PaymentConfirmingOverlay.run(context, () async {
      return paymentVerifyApi.fetchpaymentapidata(
          context, apiToken, response, callbackurl.toString());
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

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ThankyouScreen(msg: result['message'])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment verification failed")));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {}

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("External Wallet: ${response.walletName}")));
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    getRechargeData();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final horizontalPadding = getHorizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        title: 'addMoneyToWallet'.tr,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      body: isloading
          ? reusableFunction.loadingRow()
          : SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isTablet ? 16 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                        thickness: isTablet ? 3 : 5,
                        color: const Color(0xffE8E8E8)),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 5),
                      child: Row(
                        children: [
                          Text(
                            "Wallet Amount",
                            style: isTablet
                                ? CustomStyles.black16600.copyWith(
                                    fontSize: 18, fontWeight: FontWeight.bold)
                                : CustomStyles.black16600
                                    .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Image.asset(
                            "assets/rupee.png",
                            color: Colors.black,
                            scale: isTablet ? 3.5 : 4,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            walletamount.toString(),
                            style: isTablet
                                ? CustomStyles.black14400.copyWith(
                                    fontSize: 17, fontWeight: FontWeight.w500)
                                : CustomStyles.black14400.copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                        thickness: isTablet ? 3 : 5,
                        color: const Color(0xffE8E8E8)),
                    if (rechargewalletlist.isNotEmpty)
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add Money to Wallet",
                                    style: isTablet
                                        ? CustomStyles.black16600
                                            .copyWith(fontSize: 18)
                                        : CustomStyles.black16600,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Select from the available recharge packs given below",
                                    style: isTablet
                                        ? CustomStyles.grey12400
                                            .copyWith(fontSize: 15)
                                        : CustomStyles.grey12400
                                            .copyWith(fontSize: 13),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WalletHistoryScreen()),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: CustomStyles.pinki,
                                    borderRadius: BorderRadius.circular(5)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 16 : 10,
                                    vertical: isTablet ? 12 : 10),
                                child: Text(
                                  'history'.tr,
                                  style: isTablet
                                      ? CustomStyles.white.copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)
                                      : CustomStyles.white.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                    SizedBox(height: isTablet ? 24 : 20),

                    // IMPROVED Grid - Better sized cards
                    !isloading
                        ? rechargewalletlist.isEmpty
                            ? Center(
                                child: Text(
                                  "No Recharge Plans Available",
                                  style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      color: Colors.grey),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: isTablet ? 16 : 10,
                                  mainAxisSpacing: isTablet ? 16 : 10,
                                  childAspectRatio:
                                      getChildAspectRatio(context),
                                ),
                                itemCount: rechargewalletlist.length,
                                itemBuilder: (context, index) {
                                  final plan = rechargewalletlist[index];
                                  final bool isSelected =
                                      selectedIndex == index;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                        updateBillSummary(plan);
                                        scrollToBillSummary();
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? CustomStyles.pinki
                                              : Colors.grey.shade400,
                                          width: isSelected ? 2.0 : 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade400,
                                            spreadRadius: 1,
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(6.5),
                                        child: Column(
                                          children: [
                                            // Green container - IMPROVED
                                            Padding(
                                              padding: EdgeInsets.all(
                                                  getCardPadding(context)),
                                              child: Container(
                                                height: getGreenContainerHeight(
                                                    context),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: CustomStyles.green,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4,
                                                        vertical: 2),
                                                    child: Text(
                                                      plan.name ?? "",
                                                      style: TextStyle(
                                                        fontSize:
                                                            isTablet ? 13 : 10,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.2,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Amount section - IMPROVED
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                color: Colors.white,
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4),
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        '₹${plan.amount}',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: isTablet
                                                              ? 20
                                                              : 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Pink container - SIGNIFICANTLY IMPROVED
                                            Container(
                                              height: getPinkContainerHeight(
                                                  context),
                                              width: double.infinity,
                                              color: CustomStyles.pinki,
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 4),
                                              child: (plan.extra != null &&
                                                      plan.extra! > 0)
                                                  ? FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        '${plan.extra!.toStringAsFixed(2)}% Extra',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.85),
                                                          fontSize: isTablet
                                                              ? 14
                                                              : 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          height: 1.1,
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                        : const Center(child: CircularProgressIndicator()),

                    SizedBox(height: isTablet ? 30 : 20),

                    // Bill Summary Section
                    Container(
                      key: billSummaryKey,
                      padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 10,
                          vertical: isTablet ? 12 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 12 : 8, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 1.5),
                            ),
                            child: CustomTextField(
                              title: '',
                              label: 'enterCouponCode'.tr,
                              controller: couponcodecontroller,
                              readOnly: couponapply,
                              suffixIcon: GestureDetector(
                                onTap: () async {
                                  if (couponapply) {
                                    // --- REMOVE COUPON LOGIC ---
                                    setState(() {
                                      couponcodecontroller.clear();
                                      couponapply = false;
                                      final currentPlan =
                                          rechargewalletlist[selectedIndex];
                                      updateBillSummary(currentPlan);
                                    });
                                    Fluttertoast.showToast(
                                        msg: "Coupon Removed");
                                  } else {
                                    // --- APPLY COUPON LOGIC ---
                                    if (couponcodecontroller.text.isNotEmpty) {
                                      checkoutOrderSummaryApiModel =
                                          await checkoutCouponcodeApi
                                              .fetchvheckoutCouponcodeApi(
                                                  context,
                                                  apiToken.toString(),
                                                  'recharge',
                                                  couponcodecontroller.text,
                                                  id ?? 0,
                                                  0,
                                                  0);

                                      if (checkoutOrderSummaryApiModel !=
                                          null) {
                                        if (checkoutOrderSummaryApiModel!
                                                .success ==
                                            true) {
                                          Fluttertoast.showToast(
                                            msg: checkoutOrderSummaryApiModel!
                                                    .message ??
                                                '',
                                            backgroundColor: Colors.green,
                                          );
                                          setState(() {
                                            couponapply =
                                                true; // please set true
                                            totalamount =
                                                checkoutOrderSummaryApiModel!
                                                    .data!.total;
                                            gstAmount =
                                                checkoutOrderSummaryApiModel!
                                                    .data!.taxes;
                                            couponamount =
                                                checkoutOrderSummaryApiModel!
                                                    .data!.couponAmount;
                                          });
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: checkoutOrderSummaryApiModel!
                                                .message
                                                .toString(),
                                            backgroundColor: Colors.red,
                                          );
                                        }
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Please enter coupon code");
                                    }
                                  }
                                },
                                child: Container(
                                  width: isTablet ? 100 : 80,
                                  height: 40,
                                  margin: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(3),
                                        bottomRight: Radius.circular(3)),
                                    color: couponapply
                                        ? Colors.red.shade400
                                        : CustomStyles.pinki,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    couponapply
                                        ? 'Remove'
                                        : 'apply'.tr,
                                    style: isTablet
                                        ? CustomStyles.black13600.copyWith(
                                            fontSize: 15,
                                            color: couponapply
                                                ? Colors.white
                                                : Colors.white)
                                        : CustomStyles.black13600.copyWith(
                                            color: couponapply
                                                ? Colors.white
                                                : Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            // child: CustomTextField(
                            //   title: '',
                            //   label: 'enterCouponCode'.tr,
                            //   controller: couponcodecontroller,
                            //   suffixIcon: GestureDetector(
                            //     onTap: () async {
                            //       if (couponcodecontroller.text.isNotEmpty) {
                            //         checkoutOrderSummaryApiModel =
                            //             await checkoutCouponcodeApi
                            //                 .fetchvheckoutCouponcodeApi(
                            //                     context,
                            //                     apiToken.toString(),
                            //                     'recharge',
                            //                     couponcodecontroller.text,
                            //                     id ?? 0,
                            //                     0,
                            //                     0);
                            //         couponapply = true;
                            //         if (checkoutOrderSummaryApiModel != null) {
                            //           if (checkoutOrderSummaryApiModel!
                            //                   .success ==
                            //               true) {
                            //             Fluttertoast.showToast(
                            //               msg: checkoutOrderSummaryApiModel!
                            //                       .message ??
                            //                   '',
                            //               toastLength: Toast.LENGTH_SHORT,
                            //               gravity: ToastGravity.BOTTOM,
                            //               backgroundColor: Colors.green,
                            //               textColor: Colors.white,
                            //               fontSize: 14.0,
                            //             );
                            //             setState(() {
                            //               totalamount =
                            //                   checkoutOrderSummaryApiModel!
                            //                       .data!.total;
                            //               gstAmount =
                            //                   checkoutOrderSummaryApiModel!
                            //                       .data!.taxes;
                            //               couponamount =
                            //                   checkoutOrderSummaryApiModel!
                            //                       .data!.couponAmount;
                            //             });
                            //           } else {
                            //             Fluttertoast.showToast(
                            //               msg: checkoutOrderSummaryApiModel!
                            //                   .message
                            //                   .toString(),
                            //               toastLength: Toast.LENGTH_SHORT,
                            //               gravity: ToastGravity.BOTTOM,
                            //               backgroundColor: Colors.red,
                            //               textColor: Colors.white,
                            //               fontSize: 14.0,
                            //             );
                            //           }
                            //         }
                            //       } else {
                            //         setState(() {
                            //           couponapply = false;
                            //         });
                            //         Fluttertoast.showToast(
                            //           msg: "Please enter coupon code",
                            //           toastLength: Toast.LENGTH_SHORT,
                            //           gravity: ToastGravity.BOTTOM,
                            //           backgroundColor: Colors.red,
                            //           textColor: Colors.white,
                            //           fontSize: 14.0,
                            //         );
                            //       }
                            //     },
                            //     child: Container(
                            //       width: isTablet ? 100 : 80,
                            //       height: 40,
                            //       margin: const EdgeInsets.all(1),
                            //       decoration: BoxDecoration(
                            //         borderRadius: const BorderRadius.only(
                            //             topRight: Radius.circular(3),
                            //             bottomRight: Radius.circular(3)),
                            //         color: CustomStyles.pinki,
                            //       ),
                            //       alignment: Alignment.center,
                            //       child: Text(
                            //         'apply'.tr,
                            //         style: isTablet
                            //             ? CustomStyles.white
                            //                 .copyWith(fontSize: 15)
                            //             : CustomStyles.white,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ),
                          SizedBox(height: isTablet ? 16 : 10),
                          if (billsummary != null && billsummary!.isNotEmpty)
                            Row(
                              children: [
                                Text(
                                  "Bill Summary",
                                  style: isTablet
                                      ? CustomStyles.black16600
                                          .copyWith(fontSize: 19)
                                      : CustomStyles.black16600
                                          .copyWith(fontSize: 17),
                                ),
                                const Spacer(),
                                Text(
                                  billsummary ?? '',
                                  style: isTablet
                                      ? CustomStyles.black16600
                                          .copyWith(fontSize: 18)
                                      : CustomStyles.black16600,
                                ),
                              ],
                            ),
                          Divider(
                              thickness: isTablet ? 1 : 2,
                              color: const Color(0xffE8E8E8)),
                          if (rechargeamount != null)
                            buildAmountRow(
                                "Recharge Amount", rechargeamount, isTablet),
                          if (couponamount != null)
                            buildAmountRow(
                                "Coupon Applied", couponamount, isTablet),
                          Divider(
                              thickness: isTablet ? 3 : 2,
                              color: const Color(0xffE8E8E8)),
                          if (gstAmount != null && gstpercent != null)
                            buildAmountRow("GST charges (${gstpercent}%)",
                                gstAmount, isTablet),
                          Divider(
                              thickness: isTablet ? 3 : 2,
                              color: const Color(0xffE8E8E8)),
                          if (totalamount != null)
                            buildAmountRow("To Pay", totalamount, isTablet),
                          Divider(
                              thickness: isTablet ? 3 : 2,
                              color: const Color(0xffE8E8E8)),
                          if (getamount != null)
                            buildAmountRow("Get", getamount, isTablet),
                          Divider(
                              thickness: isTablet ? 3 : 2,
                              color: const Color(0xffE8E8E8)),
                        ],
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: isTablet ? 40 : 30),
                        child: ispaybtnloading
                            ? const CircularProgressIndicator()
                            : CustomOutlinedButton(
                                backgroundColor: CustomStyles.pinki,
                                width: isTablet ? 250 : 200,
                                text: 'payNow'.tr,
                                onPressed: () async {
                                  if (id == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Invalid plan. Please try again.")),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    ispaybtnloading = true;
                                  });
                                  await getpaymentdata(
                                      id!, couponcodecontroller.text);
                                  setState(() {
                                    ispaybtnloading = false;
                                  });
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSecureTransactionFooter(isTablet), // Widget Call
                    const SizedBox(height: 20), // Bottom padding
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSecureTransactionFooter(bool isTablet) {
    return Column(
      children: [
        // --- Part 1: Cashback Banner (Green Box) ---
        Container(
          margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "₹${getamount ?? 0} cashback in wallet after recharge",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- Part 2: 100% Secure Payment Text ---
        Text(
          "100% Secure Payment",
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 12),

        // --- Part 3: Razorpay Footer Image ---
        Image.asset(
          'assets/razi.jpg',
          height: isTablet ? 50 : 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              children: [
                const Text("Secured by Razorpay",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.payment, color: Colors.blue),
                    SizedBox(width: 5),
                    Icon(Icons.lock, color: Colors.grey),
                    SizedBox(width: 5),
                    Icon(Icons.credit_card, color: Colors.orange),
                  ],
                )
              ],
            );
          },
        ),

        // Bottom spacing
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildAmountRow(String label, num? amount, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTablet
                ? CustomStyles.black14400.copyWith(fontSize: 16)
                : CustomStyles.black14400.copyWith(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/rupee.png",
                  color: Colors.black,
                  scale: isTablet ? 3.5 : 4,
                ),
                const SizedBox(width: 8),
                Text(
                  amount?.toString() ?? '0',
                  style: isTablet
                      ? CustomStyles.black14500
                          .copyWith(fontSize: 17, fontWeight: FontWeight.bold)
                      : CustomStyles.black14500
                          .copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
