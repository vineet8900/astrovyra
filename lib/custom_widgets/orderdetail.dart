import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:astrokavach/api/Orderresponse/orderresponse.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/AddressModel/ordermodel.dart' hide OrderItem;
import 'package:astrokavach/model/AddressModel/ordermodelscreen.dart';
import 'package:astrokavach/screen/product/product_detail_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

double _parseItemPrice(String? priceStr) {
  if (priceStr == null || priceStr.trim().isEmpty) return 0.0;
  final s = priceStr.trim();
  if (s.contains(' x ')) {
    final parts = s.split(' x ');
    if (parts.length >= 2) {
      final p = double.tryParse(parts[0].trim().replaceAll(',', '')) ?? 0.0;
      final q = double.tryParse(parts[1].trim()) ?? 1.0;
      return p * q;
    }
  }
  return double.tryParse(s.replaceAll(',', '')) ?? 0.0;
}

String _formatItemPriceDisplay(String? priceStr) {
  if (priceStr == null || priceStr.trim().isEmpty) return '₹0.00';
  final s = priceStr.trim();
  if (s.contains(' x ')) {
    final parts = s.split(' x ');
    if (parts.length >= 2) {
      final p = parts[0].trim().replaceAll(',', '');
      final q = parts[1].trim();
      return '₹$p x $q';
    }
  }
  return '₹${s.replaceAll(',', '')}';
}

bool _isPoojaLikeOrder(OrderData order) {
  final t = order.productType.toLowerCase().trim();
  if (t.contains('pooja') || t.contains('puja')) return true;
  if (order.formData != null) return true;
  return false;
}

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final int itemId;
  final int parentId;
  final bool shipping;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.itemId,
    required this.parentId,
    required this.shipping,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<OrderDetailResponse?> _orderDetailFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailFuture = AstroApiService.fetchOrderDetail(widget.orderId);
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not open the invoice link: $urlString')),
        );
      }
    }
  }

  void _showReviewDialog(OrderData order) {
    final _reviewController = TextEditingController();
    final _reviewFormKey = GlobalKey<FormState>();
    double _currentRating = 0.0;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _reviewFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.rate_review,
                            size: 40,
                            color: Colors.black26,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Rate Your Experience",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "How was your order?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              RatingBar.builder(
                                initialRating: 0,
                                minRating: 1,
                                direction: Axis.horizontal,
                                itemCount: 5,
                                itemSize: 40,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  setDialogState(() {
                                    _currentRating = rating;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              if (_currentRating > 0)
                                Text(
                                  _currentRating == 1
                                      ? "Poor"
                                      : _currentRating == 2
                                          ? "Fair"
                                          : _currentRating == 3
                                              ? "Good"
                                              : _currentRating == 4
                                                  ? "Very Good"
                                                  : "Excellent",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _reviewController,
                          decoration: InputDecoration(
                            hintText: "Share your experience...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade800, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your review.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        final isFormValid = _reviewFormKey
                                            .currentState!
                                            .validate();
                                        if (_currentRating == 0.0) {
                                          Fluttertoast.showToast(
                                            msg:
                                                "Please provide a star rating.",
                                            backgroundColor: Colors.red,
                                          );
                                          return;
                                        }
                                        if (!isFormValid) return;

                                        setDialogState(
                                            () => isSubmitting = true);

                                        final response =
                                            await AstroApiService.submitReview(
                                          page: 'shop',
                                          id: widget.itemId,
                                          rating: _currentRating.toInt(),
                                          review: _reviewController.text,
                                          orderId: widget.orderId,
                                        );

                                        setDialogState(
                                            () => isSubmitting = false);

                                        if (response != null &&
                                            response.success) {
                                          Navigator.pop(context);
                                          setState(() {
                                            _orderDetailFuture = AstroApiService
                                                .fetchOrderDetail(
                                                    widget.orderId);
                                          });
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomStyles.pinki,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Submit",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
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

  void _showTrackingStatusDialog(List<Track> trackingData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text("Order Tracking"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(trackingData.length, (index) {
              final track = trackingData[index];
              return _buildTrackingStep(
                title: track.status,
                date: track.createdAt,
                isFirst: index == 0,
                isLast: index == trackingData.length - 1,
                isActive: true,
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep({
    required String title,
    required String date,
    required bool isFirst,
    required bool isLast,
    required bool isActive,
  }) {
    const double connectorHeight = 22.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 2,
                height: connectorHeight,
                color: isFirst
                    ? Colors.transparent
                    : (isActive ? Colors.green : Colors.grey.shade300),
              ),
              Container(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : (isActive ? Colors.green : Colors.grey.shade300),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: FutureBuilder<OrderDetailResponse?>(
          future: _orderDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const Center(
                  child:
                      Text("Could not load order details. Please try again."));
            }

            final orderData = snapshot.data!.data;

            return Scaffold(
              appBar: CustomAppBar(
                backgroundColor: CustomStyles.whiteColor,
                title: 'orderDetails'.tr,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(1.0),
                  child: Container(
                    color: Colors.grey.shade300,
                    height: 1.0,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  if (orderData.productType.toLowerCase() != 'service' &&
                      !_isPoojaLikeOrder(orderData))
                    TextButton.icon(
                      onPressed: () {
                        _showTrackingStatusDialog(orderData.track);
                      },
                      icon: const Icon(Icons.local_shipping_outlined,
                          color: Colors.black),
                      label: Text(
                        'checkStatus'.tr,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderStatusSection(orderData),
                    const SizedBox(height: 10),
                    if (orderData.items.isNotEmpty &&
                        orderData.items.first.userData.isNotEmpty) ...[
                      _buildUserDataSection(orderData.items.first.userData),
                      const SizedBox(height: 10),
                    ],
                    _buildAddressSection(
                      title: "Billing Address",
                      address: orderData.billingAddress,
                      isBilling: true,
                    ),
                    const SizedBox(height: 10),
                    if (widget.shipping)
                      _buildAddressSection(
                        title: "Shipping Address",
                        address: orderData.shippingAddress,
                        isBilling: false,
                      ),
                    if (orderData.formData != null) ...[
                      _buildFormDataSection(
                          orderData.formData!, orderData.date),
                      const SizedBox(height: 10),
                    ],
                    _buildOrderSummarySection(orderData),
                    const SizedBox(height: 10),
                    Column(
                        children: orderData.items.map((OrderItem) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildOrderItemSection(OrderItem),
                      );
                    }).toList()),
                    const SizedBox(height: 10),
                    _buildActionButtons(orderData),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderStatusSection(OrderData order) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              "Order Status",
              order.status,
              status: order.status,
              labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
              valueStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              "Order Date",
              order.date,
              labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
              valueStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              "Order Number",
              order.orderNumber,
              labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
              valueStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    String? status,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    Color statusColor = Colors.black87;

    if (status != null) {
      switch (status.toLowerCase()) {
        case 'completed':
          statusColor = Colors.green.shade700;
          break;
        case 'pending':
          statusColor = Colors.orange.shade700;
          break;
        case 'cancelled':
          statusColor = Colors.red.shade700;
          break;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
        ),
        Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: status != null ? statusColor : Colors.black87,
              ),
        ),
      ],
    );
  }

  Widget _buildAddressSection({
    required String title,
    required Address address,
    bool isBilling = false,
  }) {
    final String landmark =
        isBilling ? address.billingLandmark : address.landmark;
    final String phone =
        isBilling ? address.billingPhoneNumber : address.phoneNumber;
    final String email = isBilling ? address.billingEmail : address.email;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 0),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (address.name.isNotEmpty)
              Text(address.name,
                  style: const TextStyle(fontSize: 12, height: 1.5)),
            if (address.address.isNotEmpty ||
                address.city.isNotEmpty ||
                address.zipcode.isNotEmpty)
              Text('${address.address}, ${address.city} - ${address.zipcode}',
                  style: const TextStyle(fontSize: 12, height: 1.5)),
            if (address.state.isNotEmpty || address.country.isNotEmpty)
              Text('${address.state} (${address.country})',
                  style: const TextStyle(fontSize: 12, height: 1.5)),
            if (landmark.isNotEmpty)
              Text('Landmark: $landmark',
                  style: const TextStyle(fontSize: 12, height: 1.5)),
            if (phone.isNotEmpty)
              Text('Phone: $phone',
                  style: const TextStyle(fontSize: 12, height: 1.5)),
            if (email.isNotEmpty)
              Text('Email: $email',
                  style: const TextStyle(fontSize: 12, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummarySection(OrderData order) {
    final shippingCost = double.tryParse(order.shippingPrice) ?? 0.0;
    final discountcost = double.tryParse(order.discount) ?? 0.0;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(
              "Payment Method",
              order.paymentMethod.toUpperCase(),
              labelStyle: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              valueStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(height: 24, thickness: 1),
            const Text("Order Summary",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
            const SizedBox(height: 8),
            _buildSummaryRow(
              "Price:",
              "₹${order.items.isEmpty ? '0' : order.items.fold<double>(0.0, (sum, o) => sum + _parseItemPrice(o.item.price)).toStringAsFixed(2)}",
              labelStyle: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
              valueStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),

            if (discountcost > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow("Discount:", "₹${order.discount}",
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  valueStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  isDiscount: true),
            ],
            // const SizedBox(height: 8),
            const SizedBox(height: 8),

            if ((double.tryParse(order.codCharge) ?? 0.0) > 0) ...[
              _buildSummaryRow(
                "COD Charge:",
                "₹${order.codCharge}",
                labelStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.normal),
                valueStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
            ],
            _buildSummaryRow(
              "Item(s) Subtotal:",
              "₹${order.totalPrice} ",
              labelStyle: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
              valueStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            const Divider(height: 24, thickness: 1),
            _buildSummaryRow("Total:", "₹${order.totalPrice}",
                labelStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                valueStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    final defaultValueStyle = TextStyle(
      fontSize: 16,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color:
          isDiscount ? Colors.red : (isTotal ? Colors.black : Colors.black87),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              labelStyle ?? const TextStyle(fontSize: 14, color: Colors.black),
        ),
        Text(
          value,
          style: valueStyle ?? defaultValueStyle,
        ),
      ],
    );
  }

  Widget _buildOrderItemSection(OrderItem orderItem) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        side: const BorderSide(color: Colors.black, width: 0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                orderItem.item.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 80),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderItem.item.displayTitle,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Price: ${_formatItemPriceDisplay(orderItem.item.price)}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderData order) {
    final productSlug =
        order.items.isNotEmpty ? order.items.first.item.slug : null;
    final firstItem = order.items.isNotEmpty ? order.items.first.item : null;
    final reorderItemId = firstItem?.itemId ?? widget.itemId;
    final reorderParentId = firstItem?.parentId ?? widget.parentId;

    String? reorderType =
        order.productType.isNotEmpty ? order.productType.toLowerCase() : null;
    if (reorderType == 'shop') reorderType = 'product';
    final itemIds =
        order.items.map((orderItem) => orderItem.item.itemId).toList();
    final isPoojaOrder = _isPoojaLikeOrder(order);

    Widget buildStatusChip(String label, String status) {
      Color chipColor = CustomStyles.pinki;
      String statusText = status.toUpperCase();

      switch (status.toLowerCase()) {
        case 'approved':
          chipColor = CustomStyles.pinki;
          break;
        case 'rejected':
          chipColor = CustomStyles.pinki;
          break;
        case 'requested':
        case 'pending':
          chipColor = CustomStyles.pinki;
          statusText = "PENDING";
          break;
      }
      return Chip(
        label:
            Text('$label: $statusText', style: TextStyle(color: Colors.white)),
        backgroundColor: chipColor,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    }

    return Column(
      children: [
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (productSlug != null && reorderItemId != 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        slug: productSlug,
                        itemId: reorderItemId,
                        parentid: reorderParentId,
                        type: reorderType,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300),
              child:
                  const Text("Reorder", style: TextStyle(color: Colors.black)),
            ),

            // Review Button
            if (order.canReview &&
                    order.status.toLowerCase() == 'delivered' &&
                    order.items.isNotEmpty &&
                    order.items.first.item.review ||
                order.status.toLowerCase() == 'completed')
              ElevatedButton(
                onPressed: () => _showReviewDialog(order),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300),
                child:
                    const Text("Review", style: TextStyle(color: Colors.black)),
              ),

            // --- LOGIC: HIDE CANCEL/RETURN IF SERVICE ---
            if (order.productType != 'Service') ...[
              // --- CANCEL LOGIC ---
              if (order.cancel.request)
                buildStatusChip('Cancel Request', order.cancel.status)
              else if (order.cancel.can)
                ElevatedButton(
                  onPressed: () async {
                    final bool? success =
                        await OrderActionDialogs.showCancelDialog(
                      context,
                      orderId: order.orderId,
                    );
                    if (success == true && mounted) {
                      setState(() {
                        _orderDetailFuture =
                            AstroApiService.fetchOrderDetail(widget.orderId);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.black)),
                ),

              if (!isPoojaOrder) ...[
                if (order.returnData.request)
                  buildStatusChip('Return Request', order.returnData.status)
                else if (order.returnData.can)
                  ElevatedButton(
                    onPressed: () async {
                      final bool? success =
                          await OrderActionDialogs.showReturnDialog(
                        context,
                        orderId: order.orderId,
                        itemIds: itemIds,
                      );
                      if (success == true && mounted) {
                        setState(() {
                          _orderDetailFuture =
                              AstroApiService.fetchOrderDetail(widget.orderId);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300),
                    child: const Text("Return",
                        style: TextStyle(color: Colors.black)),
                  ),
              ],
            ],
          ],
        ),
        const SizedBox(height: 16),

        if (order.pdfUrl.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Download Report",
                      style: TextStyle(fontSize: 16)),
                  onPressed: () => _launchURL(order.pdfUrl),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade800,
                    side: BorderSide(color: Colors.red.shade800),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share_outlined,
                      color: Colors.deepOrange),
                  label: const Text("Share", style: TextStyle(fontSize: 16)),
                  onPressed: () => Share.share(order.pdfUrl),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade800,
                    side: BorderSide(color: Colors.red.shade800),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // --- INVOICE BUTTON ---
        if (order.invoice.has)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.download_rounded),
              label: const Text("Download Invoice",
                  style: TextStyle(fontSize: 16)),
              onPressed: () => _launchURL(order.invoice.url),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade800,
                side: BorderSide(color: Colors.blue.shade800),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormDataSection(OrderFormData formData, String orderDate) {
    DateTime? purchaseTime = DateTime.tryParse(orderDate);
    if (purchaseTime == null && orderDate.contains('-')) {
      try {
        List<String> parts = orderDate.split(' ')[0].split('-');
        String timeStr =
            orderDate.contains(' ') ? orderDate.split(' ')[1] : "00:00:00";
        purchaseTime =
            DateTime.tryParse("${parts[2]}-${parts[1]}-${parts[0]} $timeStr");
      } catch (_) {}
    }

    bool isWithin15Min = false;
    if (purchaseTime != null) {
      final diff = DateTime.now().difference(purchaseTime).inMinutes;
      if (diff >= 0 && diff < 15) {
        isWithin15Min = true;
      }
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pooja / Event Details",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            if (formData.place.isNotEmpty) ...[
              _buildDetailRow(
                "Place",
                formData.place,
                labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
                valueStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
            ],
            if (formData.startAt.isNotEmpty) ...[
              _buildDetailRow(
                "Date & Time",
                formData.startAt,
                labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
                valueStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
            ],
            ...formData.formItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildDetailRow(
                  item.label,
                  item.value,
                  labelStyle:
                      const TextStyle(fontSize: 12, color: Colors.black),
                  valueStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
            if (formData.videoCallUrl.isNotEmpty && isWithin15Min) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL(formData.videoCallUrl),
                  icon: const Icon(Icons.video_call, color: Colors.white),
                  label: const Text("Join Video Call",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserDataSection(List<UserDataField> userData) {
    if (userData.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "User Details",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...userData.map((field) {
              if (field.label.isEmpty && field.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        field.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        field.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
