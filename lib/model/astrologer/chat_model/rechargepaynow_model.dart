// To parse this JSON data, do
//
//     final rechargePayNowModel = rechargePayNowModelFromJson(jsonString);

import 'dart:convert';

RechargePayNowModel rechargePayNowModelFromJson(String str) => RechargePayNowModel.fromJson(json.decode(str));

String rechargePayNowModelToJson(RechargePayNowModel data) => json.encode(data.toJson());

class RechargePayNowModel {
    bool? success;
    String? message;
    String? status;
    Data? data;

    RechargePayNowModel({
        this.success,
        this.message,
        this.status,
        this.data,
    });

    factory RechargePayNowModel.fromJson(Map<String, dynamic> json) => RechargePayNowModel(
        success: json["success"],
        message: json["message"],
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "status": status,
        "data": data?.toJson(),
    };
}

class Data {
    String? key;
    int? amount;
    String? currency;
    String? name;
    String? libraryName;
    String? image;
    String? description;
    String? orderId;
    String? callbackUrl;
    Prefill? prefill;
    Theme? theme;

    Data({
        this.key,
        this.amount,
        this.currency,
        this.name,
        this.libraryName,
        this.image,
        this.description,
        this.orderId,
        this.callbackUrl,
        this.prefill,
        this.theme,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        key: json["key"],
        amount: json["amount"],
        currency: json["currency"],
        name: json["name"],
        libraryName: json["library_name"],
        image: json["image"],
        description: json["description"],
        orderId: json["order_id"],
        callbackUrl: json["callback_url"],
        prefill: json["prefill"] == null ? null : Prefill.fromJson(json["prefill"]),
        theme: json["theme"] == null ? null : Theme.fromJson(json["theme"]),
    );

    Map<String, dynamic> toJson() => {
        "key": key,
        "amount": amount,
        "currency": currency,
        "name": name,
        "library_name": libraryName,
        "image": image,
        "description": description,
        "order_id": orderId,
        "callback_url": callbackUrl,
        "prefill": prefill?.toJson(),
        "theme": theme?.toJson(),
    };
}

class Prefill {
    String? name;
    String? email;
    String? contact;

    Prefill({
        this.name,
        this.email,
        this.contact,
    });

    factory Prefill.fromJson(Map<String, dynamic> json) => Prefill(
        name: json["name"],
        email: json["email"],
        contact: json["contact"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "contact": contact,
    };
}

class Theme {
    String? color;

    Theme({
        this.color,
    });

    factory Theme.fromJson(Map<String, dynamic> json) => Theme(
        color: json["color"],
    );

    Map<String, dynamic> toJson() => {
        "color": color,
    };
}
