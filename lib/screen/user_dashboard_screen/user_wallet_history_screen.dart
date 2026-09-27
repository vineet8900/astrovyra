import 'package:flutter/material.dart';
import 'package:astrokavach/api/dashboard/user_wallet_history_api.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/user_dashboard_model/user_wallet_history_model.dart';
import 'package:astrokavach/screen/astrologer/home_screen.dart';
import 'package:astrokavach/screen/wallet/wallet_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletHistoryScreen extends StatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen>
    with WidgetsBindingObserver {
  bool isloading = false;
  String? apiToken;
  int currentPage = 1;
  bool isMoreDataAvailable = true;
  ReusableFunction reusableFunction = ReusableFunction();
  WalletHistoryApiService walletHistoryApiService = WalletHistoryApiService();
  WalletHistoryModel? walletHistoryModel;
  List<WalletHistoryList> wallethistorylist = [];
  Map<String, dynamic>? user;
  dynamic walletamount;

  fetchUserData() async {
    final userData = await reusableFunction.getUserDataFromPrefs();
    if (mounted) {
      setState(() {
        user = userData;
        walletamount = userData?["wallet"];
      });
    }
  }

  // Reset all data when user logs out
  void resetData() {
    if (mounted) {
      setState(() {
        user = null;
        walletamount = null;
        apiToken = null;
        wallethistorylist.clear();
        walletHistoryModel = null;
        currentPage = 1;
        isMoreDataAvailable = true;
        isloading = false;
      });
    }
  }

  getwallethistorydata() async {
    if (!isloading && isMoreDataAvailable) {
      setState(() {
        isloading = true;
      });

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        apiToken = prefs.getString("api_token");

        // If no token, reset everything
        if (apiToken == null || apiToken!.isEmpty || apiToken!.length == 12) {
          resetData();
          return;
        }

        walletHistoryModel =
            await walletHistoryApiService.fetchwallethistryapidata(
          context,
          apiToken.toString(),
          currentPage,
        );

        final newList = walletHistoryModel?.data?.list ?? [];

        if (newList.isNotEmpty) {
          if (mounted) {
            setState(() {
              wallethistorylist.addAll(newList);
            });
          }

          if (wallethistorylist.length >=
              (walletHistoryModel?.data?.count ?? 0)) {
            isMoreDataAvailable = false;
          } else {
            currentPage++;
          }
        } else {
          isMoreDataAvailable = false;
        }
      } catch (e, stacktrace) {
        isMoreDataAvailable = false;
      } finally {
        if (mounted) {
          setState(() {
            isloading = false;
          });
        }
      }
    }
  }

  ScrollController scrollController = ScrollController();

  onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 30 &&
        !isloading &&
        isMoreDataAvailable) {
      getwallethistorydata();
    }
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchUserData();
    scrollController = ScrollController();
    scrollController.addListener(onScroll);
    getwallethistorydata();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh user data when app comes back to foreground
      fetchUserData();
    }
  }

  // Add this method to handle route changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if user data has changed when returning to this screen
    fetchUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          backgroundColor: CustomStyles.whiteColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          automaticallyImplyLeading: false,
          title: 'walletHistory'.tr,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 5),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: CustomStyles.pinki),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Wallet Balance", style: CustomStyles.white),
                          // Only show wallet amount if user is logged in
                          (user == null || walletamount == null)
                              ? Text("₹0", style: CustomStyles.white)
                              : Row(
                                  children: [
                                    Icon(Icons.currency_rupee_outlined,
                                        color: Colors.white, size: 20),
                                    Text(walletamount.toString(),
                                        style: CustomStyles.white),
                                  ],
                                ),
                        ],
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalletScreen()),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text('addMoney'.tr,
                              style: CustomStyles.black14600),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Show different content based on user login status
                (user == null ||
                        apiToken == null ||
                        apiToken!.isEmpty ||
                        apiToken!.length == 12)
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_outlined,
                                  size: 80, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                "Please login to view wallet history",
                                style: CustomStyles.black14500,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : isloading && wallethistorylist.isEmpty
                        ? Center(child: reusableFunction.loadingRow())
                        : wallethistorylist.isEmpty
                            ? Center(
                                child: Text(
                                  "No Data Found!",
                                  style: CustomStyles.black14500,
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  controller: scrollController,
                                  scrollDirection: Axis.vertical,
                                  itemCount: wallethistorylist.length +
                                      (isMoreDataAvailable ? 1 : 0),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    if (index < wallethistorylist.length) {
                                      return InkWell(
                                        child: Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Mode',
                                                        style: CustomStyles
                                                            .black12400),
                                                    Text(
                                                        wallethistorylist[index]
                                                                .mode ??
                                                            "",
                                                        style: TextStyle(
                                                            color: Colors.blue,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Recharge ID',
                                                        style: CustomStyles
                                                            .black12400),
                                                    Text(
                                                        wallethistorylist[index]
                                                                .rechargeId ??
                                                            "",
                                                        style: CustomStyles
                                                            .black12400),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Package',
                                                        style: CustomStyles
                                                            .black12400),
                                                    Text(
                                                        wallethistorylist[index]
                                                                .package ??
                                                            "",
                                                        style: CustomStyles
                                                            .black12400),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Credit',
                                                        style: CustomStyles
                                                            .black12400),
                                                    Text(
                                                        (wallethistorylist[
                                                                        index]
                                                                    .credit ??
                                                                0)
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Debit',
                                                        style: CustomStyles
                                                            .black12400),
                                                    Text(
                                                        (wallethistorylist[
                                                                        index]
                                                                    .debit ??
                                                                0)
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Date & Time',
                                                        style: CustomStyles
                                                            .black12400),
                                                    Text(
                                                        wallethistorylist[index]
                                                                .dateTime ??
                                                            "",
                                                        style: CustomStyles
                                                            .black12400),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              SizedBox(height: 10),
                                              wallethistorylist[index]
                                                          .invoice!
                                                          .has ==
                                                      false
                                                  ? SizedBox(
                                                      height: 0, width: 0)
                                                  : GestureDetector(
                                                      onTap: () async {
                                                        setState(() {
                                                          launchURL(
                                                              wallethistorylist[
                                                                          index]
                                                                      .invoice!
                                                                      .url ??
                                                                  "");
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 12,
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10)),
                                                          color: Colors
                                                              .grey.shade200,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                "Download Invoice",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            Icon(Icons.download,
                                                                size: 16,
                                                                color:
                                                                    CustomStyles
                                                                        .bgcolor),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Center(
                                          child: SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 1.7),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
              ],
            ),
          ),
        ),
    );
  }
}
