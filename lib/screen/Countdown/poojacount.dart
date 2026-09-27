import 'dart:async';
import 'dart:ui';

import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/product_list_api_model.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PoojaCard extends StatefulWidget {
  final ProductListsDatum pooja;
  final double cardWidth;
  final double screenHeight;

  const PoojaCard({
    Key? key,
    required this.pooja,
    required this.cardWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  State<PoojaCard> createState() => _PoojaCardState();
}

class _PoojaCardState extends State<PoojaCard> {
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
    if (widget.pooja.expireAt == null || widget.pooja.expireAt!.isEmpty) {
      return;
    }
    try {
      final expireFormat = DateFormat("dd-MM-yyyy hh:mm a");
      final expireDate = expireFormat.parse(widget.pooja.expireAt!);
      final now = DateTime.now();
      if (expireDate.isBefore(now)) {
        if (mounted) setState(() => _isExpired = true);
      } else {
        _remainingTime = expireDate.difference(now);
        _startTimer();
      }
    } catch (e) {}
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

  Widget _buildTimeUnit(
    String value,
    String label,
    Color bgColor,
    double screenWidth,
  ) {
    final isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pooja = widget.pooja;
    final bool showBookingClosed = _isExpired || pooja.canPurchase != true;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    final nameFontSize = isSmallScreen
        ? 14.0
        : isMediumScreen
            ? 15.0
            : 16.0;
    final priceFontSize = isSmallScreen
        ? 12.0
        : isMediumScreen
            ? 13.0
            : 14.0;
    final oldPriceFontSize = isSmallScreen ? 11.0 : 12.0;
    final buttonFontSize = isSmallScreen ? 11.0 : 12.0;
    final messageFontSize = isSmallScreen ? 9.0 : 10.0;
    final iconSize = isSmallScreen ? 10.0 : 12.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              slug: pooja.slug,
              parentid: 0,
              attributevalue: [],
              itemId: pooja.id,
              productname: pooja.name,
              type: "pooja",
            ),
          ),
        );
      },
      child: SizedBox(
        width: widget.cardWidth,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400, width: 1),
            boxShadow: isSmallScreen
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
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
                    pooja.image.toString(),
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
                          color: Colors.grey,
                          size: isSmallScreen ? 30 : 40,
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
                          pooja.name ?? '',
                          style: TextStyle(
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: isSmallScreen ? 1 : 2,
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
                              "Booking Closed",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (_remainingTime != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: iconSize, color: Colors.white),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      "Puja Booking Will be Close In :",
                                      style: TextStyle(
                                          fontSize: messageFontSize,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 4 : 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _buildTimeUnit(
                                      _remainingTime!.inDays.toString(),
                                      "Days",
                                      CustomStyles.offerCountdownDaysBg,
                                      screenWidth,
                                    ),
                                    SizedBox(width: isSmallScreen ? 4 : 6),
                                    _buildTimeUnit(
                                      (_remainingTime!.inHours.remainder(24))
                                          .toString(),
                                      "Hrs",
                                      CustomStyles.offerCountdownHoursBg,
                                      screenWidth,
                                    ),
                                    SizedBox(width: isSmallScreen ? 4 : 6),
                                    _buildTimeUnit(
                                      (_remainingTime!.inMinutes.remainder(60))
                                          .toString(),
                                      "Min",
                                      CustomStyles.offerCountdownMinutesBg,
                                      screenWidth,
                                    ),
                                    SizedBox(width: isSmallScreen ? 4 : 6),
                                    _buildTimeUnit(
                                      (_remainingTime!.inSeconds.remainder(60))
                                          .toString(),
                                      "Sec",
                                      CustomStyles.offerCountdownSecondsBg,
                                      screenWidth,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (pooja.salePrice != 0 &&
                                      pooja.salePrice != null)
                                    Text(
                                      '₹${pooja.basePrice}',
                                      style: TextStyle(
                                        fontSize: oldPriceFontSize,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor:
                                            Colors.white.withOpacity(0.85),
                                        color: Colors.white.withOpacity(0.85),
                                        height: 1.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Text(
                                    '₹${pooja.salePrice == 0 || pooja.salePrice == null ? pooja.basePrice : pooja.salePrice}',
                                    style: TextStyle(
                                      fontSize: priceFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      height: 1.0,
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
                                  "Details",
                                  style: TextStyle(
                                    color: CustomStyles.detailsOrange,
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.w600,
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
