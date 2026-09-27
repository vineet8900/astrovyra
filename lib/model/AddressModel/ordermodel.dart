


import 'dart:convert';

// Helper function to parse the raw JSON string
UserOrdersResponse userOrdersResponseFromJson(String str) => 
    UserOrdersResponse.fromJson(json.decode(str));

// Main response class that holds the list of orders
class UserOrdersResponse {
  final bool success;
  final List<UserOrder> data;

  UserOrdersResponse({
    required this.success,
    required this.data,
  });

  factory UserOrdersResponse.fromJson(Map<String, dynamic> json) => 
      UserOrdersResponse(
        success: json["success"] ?? false,
        data: json["data"] != null 
            ? List<UserOrder>.from(json["data"].map((x) => UserOrder.fromJson(x))) 
            : [],
      );
}

// Class representing a single order
class UserOrder {
  final int orderId;
  final String orderNumber;
  final String date;
  final String totalPrice;
  final String status;
  final bool showShippingAddress;
  final OrderItem? item; // Nullable because some orders have empty item array

  UserOrder({
    required this.orderId,
    required this.orderNumber,
    required this.date,
    required this.totalPrice,
    required this.status,
    required this.showShippingAddress,
    this.item,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    // Handle both Map and empty List for item field
    OrderItem? orderItem;
    final itemData = json["item"];
    
    if (itemData != null && itemData is Map<String, dynamic>) {
      orderItem = OrderItem.fromJson(itemData);
    }
    // If itemData is List (empty array), orderItem remains null

    return UserOrder(
      orderId: json["order_id"] ?? 0,
      orderNumber: json["order_number"] ?? "N/A",
      date: json["date"] ?? "N/A",
      totalPrice: json["total_price"] ?? "0.00",
      status: json["status"] ?? "N/A",
      showShippingAddress: json["show_shipping_address"] ?? false,
      item: orderItem,
    );
  }

  // Helper getter to check if order has item
  bool get hasItem => item != null;
}

// Class for the nested 'item' object within an order
class OrderItem {
  final int parentId;
  final int itemId;
  final String slug;
  final String image;
  final String name;
  final String price;
  /// Variations from API (e.g. size, carat, color, weight). Used for display in order list/detail.
  final Map<String, String> variations;
  final String size;
  final String carat;
  final String color;
  final String weight;

  OrderItem({
    required this.parentId,
    required this.itemId,
    required this.slug,
    required this.image,
    required this.name,
    required this.price,
    Map<String, String>? variations,
    String? size,
    String? carat,
    String? color,
    String? weight,
  })  : variations = variations ?? {},
        size = size ?? '',
        carat = carat ?? '',
        color = color ?? '',
        weight = weight ?? '';

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Only use what API sends inside "variations" – no merging of direct fields (so attar doesn't show carat etc.)
    final rawVariations = json["variations"];
    Map<String, String> variationsMap = {};
    if (rawVariations != null && rawVariations is Map) {
      for (final e in (rawVariations as Map).entries) {
        if (e.value != null) variationsMap["${e.key}"] = "${e.value}";
      }
    }
    final size = (json["size"]?.toString().trim() ?? "").isNotEmpty
        ? json["size"].toString().trim()
        : variationsMap["size"] ?? "";
    final carat = (json["carat"]?.toString().trim() ?? "").isNotEmpty
        ? json["carat"].toString().trim()
        : variationsMap["carat"] ?? "";
    final color = (json["color"]?.toString().trim() ?? "").isNotEmpty
        ? json["color"].toString().trim()
        : variationsMap["color"] ?? "";
    final weight = (json["weight"]?.toString().trim() ?? "").isNotEmpty
        ? json["weight"].toString().trim()
        : variationsMap["weight"] ?? "";

    return OrderItem(
      parentId: json["parent_id"] ?? 0,
      itemId: json["item_id"] ?? 0,
      slug: json["slug"] ?? "",
      image: json["image"] ?? "",
      name: json["name"] ?? "N/A",
      price: json["price"] ?? "0.00",
      variations: variationsMap,
      size: size,
      carat: carat,
      color: color,
      weight: weight,
    );
  }

  /// Returns display-friendly list of variation labels (e.g. "Size: 6 ML", "Carat: 08-09").
  List<String> get variationLabels {
    final list = <String>[];
    for (final e in variations.entries) {
      if (e.key.trim().isEmpty || e.value.trim().isEmpty) continue;
      final label = e.key.length == 1
          ? e.key.toUpperCase()
          : "${e.key[0].toUpperCase()}${e.key.substring(1)}";
      list.add("$label: ${e.value}");
    }
    return list;
  }

  /// Name with variation shown only once – if name already contains the variation text, returns name only.
  String get displayTitle {
    if (variationLabels.isEmpty) return name;
    final suffix = variationLabels.join(", ");
    if (name.contains(suffix)) return name;
    return "$name ($suffix)";
  }
}