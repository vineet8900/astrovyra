// To parse this JSON data, do
//
//     final placerOrderApiModel = placerOrderApiModelFromJson(jsonString);

import 'dart:convert';

PlacerOrderApiModel placerOrderApiModelFromJson(String str) => PlacerOrderApiModel.fromJson(json.decode(str));

String placerOrderApiModelToJson(PlacerOrderApiModel data) => json.encode(data.toJson());

class PlacerOrderApiModel {
    bool? success;
    String? message;
    String? status;
    Order? order;
    Data? data;

    PlacerOrderApiModel({
        this.success,
        this.message,
        this.status,
        this.order,
        this.data,
    });

    factory PlacerOrderApiModel.fromJson(Map<String, dynamic> json) => PlacerOrderApiModel(
        success: json["success"],
        message: json["message"],
        status: json["status"],
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "status": status,
        "order": order?.toJson(),
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

class Order {
    int? orderId;

    Order({
        this.orderId,
    });

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json["order_id"],
    );

    Map<String, dynamic> toJson() => {
        "order_id": orderId,
    };
}
