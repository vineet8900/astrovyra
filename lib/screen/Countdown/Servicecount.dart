import 'dart:async';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:astrokavach/model/Product_Api_Model/product_list_api_model.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';

class AstroServiceCard extends StatefulWidget {
  final ProductListsDatum service;
  final double cardWidth;
  final double screenHeight;

  const AstroServiceCard({
    Key? key,
    required this.service,
    required this.cardWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  State<AstroServiceCard> createState() => _AstroServiceCardState();
}

class _AstroServiceCardState extends State<AstroServiceCard> {
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
    if (widget.service.expireAt == null || widget.service.expireAt!.isEmpty) {
      return;
    }
    try {
      final expireFormat = DateFormat("dd-MM-yyyy hh:mm a");
      final expireDate = expireFormat.parse(widget.service.expireAt!);
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
    final service = widget.service;
    final bool showBookingClosed = service.canPurchase != true;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              slug: service.slug,
              parentid: 0,
              attributevalue: [],
              itemId: service.id,
              productname: service.name,
              type: "service",
            ),
          ),
        );
      },
      child: SizedBox(
        width: widget.cardWidth,
        child: Container(
          margin: EdgeInsets.only(right: 12, bottom: 8, top: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: Colors.white,
                  child: Image.network(
                    service.image.toString(),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 36,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
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
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          service.name ?? 'Service',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.032,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        if (showBookingClosed)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: isSmallScreen ? 5 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Closed",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (_remainingTime != null)
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _formatDuration(_remainingTime!),
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (service.salePrice != 0 &&
                                      service.salePrice != null)
                                    Text(
                                      '₹${(double.tryParse(service.basePrice?.toString() ?? '0') ?? 0).round()}',
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.028,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor:
                                            Colors.white.withOpacity(0.85),
                                        color: Colors.white.withOpacity(0.85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Text(
                                    '₹${(double.tryParse((service.salePrice == 0 || service.salePrice == null ? service.basePrice : service.salePrice)?.toString() ?? '0') ?? 0).round()}',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (!showBookingClosed) ...[
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: CustomStyles.detailsOrange,
                                      width: 1.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Detail",
                                  style: TextStyle(
                                    color: CustomStyles.detailsOrange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
