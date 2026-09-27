// To parse this JSON data, do
//
//     final checkoutOrderSummaryApiModel = checkoutOrderSummaryApiModelFromJson(jsonString);

import 'dart:convert';

CheckoutOrderSummaryApiModel checkoutOrderSummaryApiModelFromJson(String str) => CheckoutOrderSummaryApiModel.fromJson(json.decode(str));

String checkoutOrderSummaryApiModelToJson(CheckoutOrderSummaryApiModel data) => json.encode(data.toJson());

class CheckoutOrderSummaryApiModel {
    bool? success;
    String? message;
    Data? data;

    CheckoutOrderSummaryApiModel({
        this.success,
        this.message,
        this.data,
    });

    factory CheckoutOrderSummaryApiModel.fromJson(Map<String, dynamic> json) => CheckoutOrderSummaryApiModel(
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
    dynamic subTotal;
    dynamic discount;
    dynamic couponAmount;
    dynamic taxes;
    dynamic shippingPrice;
    dynamic total;

    Data({
        this.subTotal,
        this.discount,
        this.couponAmount,
        this.taxes,
        this.shippingPrice,
        this.total,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        subTotal: json["subTotal"],
        discount: json["discount"],
        couponAmount: json["coupon_amount"],
        taxes: json["taxes"],
        shippingPrice: json["shippingPrice"],
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "subTotal": subTotal,
        "discount": discount,
        "coupon_amount": couponAmount,
        "taxes": taxes,
        "shippingPrice": shippingPrice,
        "total": total,
    };
}
