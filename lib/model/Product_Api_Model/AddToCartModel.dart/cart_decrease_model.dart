// To parse this JSON data, do
//
//     final cartDecreaseModel = cartDecreaseModelFromJson(jsonString);

import 'dart:convert';

CartDecreaseModel cartDecreaseModelFromJson(String str) => CartDecreaseModel.fromJson(json.decode(str));

String cartDecreaseModelToJson(CartDecreaseModel data) => json.encode(data.toJson());

class CartDecreaseModel {
    bool? success;
    String? message;
    int? qunatity;
   int? totalQuantity;

    CartDecreaseModel({
        this.success,
        this.message,
        this.qunatity,this.totalQuantity
    });

    factory CartDecreaseModel.fromJson(Map<String, dynamic> json) => CartDecreaseModel(
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
