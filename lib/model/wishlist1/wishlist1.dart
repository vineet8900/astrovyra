// To parse this JSON data, do
//
//     final wishlistResponse = wishlistResponseFromJson(jsonString);

import 'dart:convert';

// Helper function to parse the JSON string into a WishlistResponse object
WishlistResponse wishlistResponseFromJson(String str) => WishlistResponse.fromJson(json.decode(str));

// Main response class
class WishlistResponse {
    final bool success;
    final String message;
    final WishlistData? data;

    WishlistResponse({
        required this.success,
        required this.message,
        this.data,
    });

    factory WishlistResponse.fromJson(Map<String, dynamic> json) => WishlistResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : WishlistData.fromJson(json["data"]),
    );
}

// Class for the "data" object
class WishlistData {
    final int totalCount;
    final WishlistCategory products;
    final WishlistCategory services;

    WishlistData({
        required this.totalCount,
        required this.products,
        required this.services,
    });

    factory WishlistData.fromJson(Map<String, dynamic> json) => WishlistData(
        totalCount: json["total_count"],
        products: WishlistCategory.fromJson(json["products"]),
        services: WishlistCategory.fromJson(json["services"]),
    );
}

// Class for "products" and "services" which share the same structure
class WishlistCategory {
    final int count;
    final List<WishlistItem> list;

    WishlistCategory({
        required this.count,
        required this.list,
    });

    factory WishlistCategory.fromJson(Map<String, dynamic> json) => WishlistCategory(
        count: json["count"],
        list: List<WishlistItem>.from(json["list"].map((x) => WishlistItem.fromJson(x))),
    );
}

// Class for individual items in the "list" array
class WishlistItem {
    final int wishlistId;
    final int itemId;
    final String image;
    final String name;
    final String slug;
    final String basePrice;
    final String salePrice;
    final String category;

    WishlistItem({
        required this.wishlistId,
        required this.image,
        required this.name,
        required this.slug,
        required this.basePrice,
        required this.salePrice,
        required this.category,
        required this.itemId,
    });

    factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        wishlistId: json["wishlist_id"],
        image: json["image"],
        name: json["name"],
        slug: json["slug"],
        basePrice: json["base_price"],
        salePrice: json["sale_price"],
        category: json["category"],
        itemId: json["item_id"],
    );
}