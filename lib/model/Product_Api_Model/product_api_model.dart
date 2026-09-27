// To parse this JSON data, do
//
//     final productApiModel = productApiModelFromJson(jsonString);
import 'dart:convert';
ProductApiModel productApiModelFromJson(String str) => ProductApiModel.fromJson(json.decode(str));
String productApiModelToJson(ProductApiModel data) => json.encode(data.toJson());
class ProductApiModel {
    bool? success;
    List<ProductApiDatum>? data;
    String? message;

    ProductApiModel({
        this.success,
        this.data,
        this.message,
    });

    factory ProductApiModel.fromJson(Map<String, dynamic> json) => ProductApiModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<ProductApiDatum>.from(json["data"]!.map((x) => ProductApiDatum.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class ProductApiDatum {
    String? slug;
    String? name;
    String? image;

    ProductApiDatum({
        this.slug,
        this.name,
        this.image,
    });

    factory ProductApiDatum.fromJson(Map<String, dynamic> json) => ProductApiDatum(
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
