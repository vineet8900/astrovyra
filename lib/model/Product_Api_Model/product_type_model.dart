// To parse this JSON data, do
//
//     final productTypeApiModel = productTypeApiModelFromJson(jsonString);

import 'dart:convert';

ProductTypeApiModel productTypeApiModelFromJson(String str) => ProductTypeApiModel.fromJson(json.decode(str));

String productTypeApiModelToJson(ProductTypeApiModel data) => json.encode(data.toJson());

class ProductTypeApiModel {
    bool? success;
    List<ProductTypeDatumn>? data;
    String? message;

    ProductTypeApiModel({
        this.success,
        this.data,
        this.message,
    });

    factory ProductTypeApiModel.fromJson(Map<String, dynamic> json) => ProductTypeApiModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<ProductTypeDatumn>.from(json["data"]!.map((x) => ProductTypeDatumn.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class ProductTypeDatumn {
    String? slug;
    String? name;

    ProductTypeDatumn({
        this.slug,
        this.name,
    });

    factory ProductTypeDatumn.fromJson(Map<String, dynamic> json) => ProductTypeDatumn(
        slug: json["slug"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "slug": slug,
        "name": name,
    };
}
