// To parse this JSON data, do
//
//     final productSortByApiModel = productSortByApiModelFromJson(jsonString);

import 'dart:convert';

ProductSortByApiModel productSortByApiModelFromJson(String str) => ProductSortByApiModel.fromJson(json.decode(str));

String productSortByApiModelToJson(ProductSortByApiModel data) => json.encode(data.toJson());

class ProductSortByApiModel {
    bool? success;
    List<ProductSortbyDatum>? data;
    String? message;

    ProductSortByApiModel({
        this.success,
        this.data,
        this.message,
    });

    factory ProductSortByApiModel.fromJson(Map<String, dynamic> json) => ProductSortByApiModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<ProductSortbyDatum>.from(json["data"]!.map((x) => ProductSortbyDatum.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class ProductSortbyDatum {
    String? slug;
    String? name;

    ProductSortbyDatum({
        this.slug,
        this.name,
    });

    factory ProductSortbyDatum.fromJson(Map<String, dynamic> json) => ProductSortbyDatum(
        slug: json["slug"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "slug": slug,
        "name": name,
    };
}
