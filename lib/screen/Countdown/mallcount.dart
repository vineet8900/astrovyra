import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

//import 'package.flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
// Apne project ke sahi path ke anusaar neeche di gayi lines ko badlein
import 'package:astrokavach/model/Product_Api_Model/product_list_api_model.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';

class ProductCard extends StatefulWidget {
  final ProductListsDatum product;
  final double cardWidth;
  final double screenHeight;

  const ProductCard({
    Key? key,
    required this.product,
    required this.cardWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Timer? _timer;
  Duration? _remainingTime;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeCountdown() {
    if (widget.product.expireAt == null || widget.product.expireAt!.isEmpty) {
      return;
    }
    try {
      final expireFormat = DateFormat("dd-MM-yyyy hh:mm a");
      final expireDate = expireFormat.parse(widget.product.expireAt!);
      final now = DateTime.now();
      if (expireDate.isBefore(now)) {
        if (mounted) setState(() => _isExpired = true);
      } else {
        _remainingTime = expireDate.difference(now);
        _startTimer();
      }
    } catch (e) {
     
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == null || _remainingTime!.inSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _isExpired = true);
      } else {
        if (mounted) {
          setState(() =>
              _remainingTime = _remainingTime! - const Duration(seconds: 1));
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = duration.inDays;
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$days D : $hours H : $minutes M : $seconds S";
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final bool showBookingClosed = _isExpired || product.canPurchase != true;
    final double baseVal = double.tryParse(
            product.basePrice?.toString().replaceAll(',', '') ?? '') ??
        0;
    final double saleVal = double.tryParse(
            product.salePrice?.toString().replaceAll(',', '') ?? '') ??
        0;
    final bool useSalePrice = product.hasActiveSaleOffer;

    return GestureDetector(
      onTap: () {
        if (showBookingClosed) {
          Fluttertoast.showToast(msg: "This product is currently unavailable.");
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              slug: product.slug,
              parentid: 0,
              attributevalue: [],
              itemId: product.id,
              productname: product.name,
              type: "product",
            ),
          ),
        );
      },
      child: Container(
        width: widget.cardWidth,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: widget.screenHeight * 0.18, // Height adjust ki gayi
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                    image: NetworkImage(product.image.toString()),
                    fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name ?? '',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹ ${useSalePrice ? saleVal : baseVal}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      SizedBox(width: 8),
                      if (useSalePrice)
                        Text(
                          '₹ ${product.basePrice}',
                          style: TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // --- COUNTDOWN TIMER YA UNAVAILABLE MESSAGE ---
                  if (showBookingClosed)
                    Container(
                      alignment: Alignment.center,
                      child: Text("Unavailable",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    )
                  else if (_remainingTime != null)
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        _formatDuration(_remainingTime!),
                        style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
