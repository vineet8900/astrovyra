// To parse this JSON data, do
//
//     final productCategoryModel = productCategoryModelFromJson(jsonString);

import 'dart:convert';

ProductCategoryModel productCategoryModelFromJson(String str) => ProductCategoryModel.fromJson(json.decode(str));

String productCategoryModelToJson(ProductCategoryModel data) => json.encode(data.toJson());

class ProductCategoryModel {
    bool? success;
    List<ProductCategoryDatum>? data;
    String? message;

    ProductCategoryModel({
        this.success,
        this.data,
        this.message,
    });

    factory ProductCategoryModel.fromJson(Map<String, dynamic> json) => ProductCategoryModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<ProductCategoryDatum>.from(json["data"]!.map((x) => ProductCategoryDatum.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class ProductCategoryDatum {
    int? id;
    String? slug;
    String? name;
    String? image;

    ProductCategoryDatum({
       this.id,
        this.slug,
        this.name,
        this.image,
    });

    factory ProductCategoryDatum.fromJson(Map<String, dynamic> json) => ProductCategoryDatum(
        id:json["id"],
        slug: json["slug"],
        name: json["name"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "slug": slug,
        "name": name,
        "image": image,
    };
}
