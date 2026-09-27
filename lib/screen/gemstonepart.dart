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
import 'package:astrokavach/model/Gemstonemodel.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/addtocart_model.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';

class CertifiedGemstoneListScreen extends StatefulWidget {
  @override
  State<CertifiedGemstoneListScreen> createState() =>
      _CertifiedGemstoneListScreenState();
}

class _CertifiedGemstoneListScreenState
    extends State<CertifiedGemstoneListScreen> {
  List<CertifiedGemstone> gemstones = [];
  bool isLoading = true;
  String? apiToken;
  AddtoCartApiService addtoCartApiService = AddtoCartApiService();
  AddtoCartModel? addtoCartModel;
  Set<int> addingToCartSet = {};

  @override
  void initState() {
    super.initState();
    getToken();
    fetchData();
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
    final stockIdx = gemstones.indexWhere((p) => p.id == id);
    if (stockIdx >= 0 && gemstones[stockIdx].isOutOfStock) {
      return;
    }
    if (addingToCartSet.contains(id)) return;
    try {
      setState(() => addingToCartSet.add(id));
      addtoCartModel =
          await addtoCartApiService.addToCartApi(apiToken, id, "shop", null);
      if (addtoCartModel != null) {
        cartQuantityNotifier.value = addtoCartModel!.totalQuantity.toString();
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
    final data = await AstroApiService.fetchCertifiedGemstones();
    if (mounted) {
      setState(() {
        gemstones = data ?? [];
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
        title: "Certified Gemstones",
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
          ? Center(child: CircularProgressIndicator())
          : gemstones.isEmpty
              ? Center(child: Text("No Data Found"))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.56,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: gemstones.length,
                  itemBuilder: (context, index) {
                    final item = gemstones[index];
                    String imageUrl =
                        item.image ?? "https://via.placeholder.com/150";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => ProductDetailScreen(
                              itemId: item.id,
                              productname: item.name,
                              slug: item.slug,
                              type: 'gemstone',
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
                                  color: Colors.grey.shade50,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.diamond,
                                      size: 40,
                                      color: Colors.blueGrey,
                                    ),
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
                                      item.name ?? "Gemstone",
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
                                        onPressed: addingToCartSet
                                                .contains(item.id)
                                            ? null
                                            : () {
                                                if (addingToCartSet
                                                    .contains(item.id)) return;
                                                getaddtocartdata(item.id ?? 0);
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: CustomStyles.pinki,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
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
