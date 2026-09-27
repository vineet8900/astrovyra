// To parse this JSON data, do
//
//     final wishlistAddRemoveResponse = wishlistAddRemoveResponseFromJson(jsonString);

import 'dart:convert';

WishlistAddRemoveResponse wishlistAddRemoveResponseFromJson(String str) => WishlistAddRemoveResponse.fromJson(json.decode(str));

String wishlistAddRemoveResponseToJson(WishlistAddRemoveResponse data) => json.encode(data.toJson());

class WishlistAddRemoveResponse {
    final bool success;
    final String message;
    final Data? data;
    final int totalItem;

    WishlistAddRemoveResponse({
        required this.success,
        required this.message,
        this.data,
        required this.totalItem,
    });

    factory WishlistAddRemoveResponse.fromJson(Map<String, dynamic> json) => WishlistAddRemoveResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
        totalItem: json["totalItem"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "totalItem": totalItem,
    };
}

class Data {
    final int wishlistId;

    Data({
        required this.wishlistId,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        wishlistId: json["wishlist_id"],
    );

    Map<String, dynamic> toJson() => {
        "wishlist_id": wishlistId,
    };
}