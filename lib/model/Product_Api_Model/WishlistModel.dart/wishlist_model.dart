// To parse this JSON data, do
//
//     final userDashboardWishlistModel = userDashboardWishlistModelFromJson(jsonString);

import 'dart:convert';

UserDashboardWishlistModel userDashboardWishlistModelFromJson(String str) => UserDashboardWishlistModel.fromJson(json.decode(str));

String userDashboardWishlistModelToJson(UserDashboardWishlistModel data) => json.encode(data.toJson());

class UserDashboardWishlistModel {
    bool? success;
    String? message;
    Data? data;

    UserDashboardWishlistModel({
        this.success,
        this.message,
        this.data,
    });

    factory UserDashboardWishlistModel.fromJson(Map<String, dynamic> json) => UserDashboardWishlistModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    int? totalCount;
    Products? products;
    Products? services;

    Data({
        this.totalCount,
        this.products,
        this.services,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalCount: json["total_count"],
        products: json["products"] == null ? null : Products.fromJson(json["products"]),
        services: json["services"] == null ? null : Products.fromJson(json["services"]),
    );

    Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "products": products?.toJson(),
        "services": services?.toJson(),
    };
}

class Products {
    int? count;
    List<UserWishlistDatum>? list;

    Products({
        this.count,
        this.list,
    });

    factory Products.fromJson(Map<String, dynamic> json) => Products(
        count: json["count"],
        list: json["list"] == null ? [] : List<UserWishlistDatum>.from(json["list"]!.map((x) => UserWishlistDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "count": count,
        "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
    };
}

class UserWishlistDatum {
    int? wishlistId;
    String? image;
    String? name;
    String? slug;
    String? basePrice;
    String? salePrice;
    String? category;

    UserWishlistDatum({
        this.wishlistId,
        this.image,
        this.name,
        this.slug,
        this.basePrice,
        this.salePrice,
        this.category,
    });

    factory UserWishlistDatum.fromJson(Map<String, dynamic> json) => UserWishlistDatum(
        wishlistId: json["wishlist_id"],
        image: json["image"],
        name: json["name"],
        slug: json["slug"],
        basePrice: json["base_price"],
        salePrice: json["sale_price"],
        category: json["category"],
    );

    Map<String, dynamic> toJson() => {
        "wishlist_id": wishlistId,
        "image": image,
        "name": name,
        "slug": slug,
        "base_price": basePrice,
        "sale_price": salePrice,
        "category": category,
    };
}
