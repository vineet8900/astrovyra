// To parse this JSON data, do
//
//     final cartIncreaseModel = cartIncreaseModelFromJson(jsonString);

import 'dart:convert';

CartIncreaseModel cartIncreaseModelFromJson(String str) => CartIncreaseModel.fromJson(json.decode(str));

String cartIncreaseModelToJson(CartIncreaseModel data) => json.encode(data.toJson());

class CartIncreaseModel {
    bool? success;
    String? message;
    int? qunatity;
    int?totalQuantity;

    CartIncreaseModel({
        this.success,
        this.message,
        this.qunatity,this.totalQuantity
    });

    factory CartIncreaseModel.fromJson(Map<String, dynamic> json) => CartIncreaseModel(
        success: json["success"],
        message: json["message"],
        qunatity: json["qunatity"],
        totalQuantity: json["totalQuantity"]
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "qunatity": qunatity,
        "totalQuantity":totalQuantity
    };
}
