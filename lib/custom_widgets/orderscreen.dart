import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/orderdetail.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/AddressModel/ordermodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Orderscreen extends StatefulWidget {
  const Orderscreen({super.key});

  @override
  State<Orderscreen> createState() => _OrderscreenState();
}

class _OrderscreenState extends State<Orderscreen> {
  late Future<List<UserOrder>?> _ordersFuture;

  Color _statusColor(String raw) {
    final s = raw.toLowerCase().trim();
    if (s == 'ordered') return Colors.red;
    if (s == 'completed') return Colors.green;
    if (s == 'process' || s == 'processing') return Colors.blue;
    return Colors.orange;
  }

  @override
  void initState() {
    super.initState();
    _ordersFuture = AstroApiService.fetchUserOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = AstroApiService.fetchUserOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          backgroundColor: CustomStyles.whiteColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: 'orderHistory'.tr,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
          actions: [],
        ),
        body: SafeArea(
          top: true,
          bottom: true,
          child: FutureBuilder<List<UserOrder>?>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text("An error occurred: ${snapshot.error}"),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "You haven't placed any orders yet.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final orders = snapshot.data!;
              return RefreshIndicator(
                onRefresh: _refreshOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return InkWell(
                        onTap: () {
                          // Null check for item
                          if (order.item != null) {
                            

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderDetailScreen(
                                          orderId: order.orderId,
                                          itemId: order.item!.itemId,
                                          parentId: order.item!.parentId,
                                          shipping: order.showShippingAddress,
                                        )));
                          } else {
                            //Handle case when item is null
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order details not available'),
                              ),
                            );
                          }
                        },
                        child: _buildOrderCard(order));
                  },
                ),
              );
            },
          ),
        ),
    );
  }

  Widget _buildOrderCard(UserOrder order) {
    // Check if item exists
    final hasItem = order.item != null;

    return Card(
      elevation: 4,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: hasItem && order.item!.image.isNotEmpty
                  ? Image.network(
                      order.item!.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.shopping_bag_outlined,
                              color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasItem ? order.item!.displayTitle : "Order Item",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Order: ${order.orderNumber}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Date: ${order.date}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),

                  // Price and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${order.totalPrice}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal,
                        ),
                      ),
                      Text(
                        order.status,
                        style: TextStyle(
                          color: _statusColor(order.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
    );
  }
}
