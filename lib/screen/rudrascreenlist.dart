import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrokavach/api/dashboard/search_delegates.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/api/product_api/AddToCartApi.dart/addtocart_api.dart';
import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/addtocart_model.dart';
import 'package:astrokavach/model/rudramodel.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';

class CertifiedRudrakshaListScreen extends StatefulWidget {
  final List<CertifiedRudraksha>? initialList;
  const CertifiedRudrakshaListScreen({super.key, this.initialList});

  @override
  State<CertifiedRudrakshaListScreen> createState() =>
      _CertifiedRudrakshaListScreenState();
}

class _CertifiedRudrakshaListScreenState
    extends State<CertifiedRudrakshaListScreen> {
  List<CertifiedRudraksha> rudrakshaList = [];
  bool isLoading = true;
  String? apiToken;
  AddtoCartApiService addtoCartApiService = AddtoCartApiService();
  AddtoCartModel? addtoCartModel;
  Set<int> addingToCartSet = {};

  @override
  void initState() {
    super.initState();
    getToken();
    if (widget.initialList != null && widget.initialList!.isNotEmpty) {
      rudrakshaList = List<CertifiedRudraksha>.from(widget.initialList!);
      isLoading = false;
    } else {
      fetchData();
    }
  }

  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');
  }

  getaddtocartdata(int id) async {
    if (apiToken == null || apiToken!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }
    final stockIdx = rudrakshaList.indexWhere((p) => p.id == id);
    if (stockIdx >= 0 && rudrakshaList[stockIdx].isOutOfStock) {
      return;
    }
    if (addingToCartSet.contains(id)) return;
    try {
      setState(() => addingToCartSet.add(id));
      addtoCartModel =
          await addtoCartApiService.addToCartApi(apiToken, id, "shop", null);
      if (addtoCartModel != null) {
        cartQuantityNotifier.value =
            addtoCartModel!.totalQuantity.toString();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item to cart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => addingToCartSet.remove(id));
    }
  }

  fetchData() async {
    final data = await AstroApiService.fetchCertifiedRudraksha();
    if (mounted) {
      setState(() {
        rudrakshaList = data ?? [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        title: "Certified Rudraksha",
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : rudrakshaList.isEmpty
              ? const Center(child: Text("No Rudraksha Found"))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.56,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: rudrakshaList.length,
                  itemBuilder: (context, index) {
                    final item = rudrakshaList[index];
                    String imageUrl = item.image ??
                        "https://via.placeholder.com/300?text=Rudraksha";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              itemId: item.id,
                              productname: item.name,
                              slug: item.slug,
                              type: 'rudraksha',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.brown.shade50,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.circle_outlined,
                                        size: 50,
                                        color: Colors.brown.shade300,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 38,
                                    child: Text(
                                      item.name ?? "Rudraksha",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                      children: [
                                        if (item.hasActiveSaleOffer) ...[
                                          TextSpan(
                                            text: "₹${item.basePrice} ",
                                            style: TextStyle(
                                              fontSize: 11,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "₹${item.salePrice}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ] else
                                          TextSpan(
                                            text: "₹${item.basePrice ?? '0'}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (item.isOutOfStock)
                                    const OutOfStockStyledButton(
                                      height: 44,
                                    )
                                  else
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed: addingToCartSet.contains(item.id)
                                            ? null
                                            : () {
                                                if (addingToCartSet.contains(item.id)) return;
                                                getaddtocartdata(item.id ?? 0);
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: CustomStyles.pinki,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          addingToCartSet.contains(item.id)
                                              ? "Adding..."
                                              : "add_to_cart".tr,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
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
    );
  }
}
