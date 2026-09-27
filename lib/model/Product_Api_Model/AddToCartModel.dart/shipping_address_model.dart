// To parse this JSON data, do
//
//     final shippingAddreesModel = shippingAddreesModelFromJson(jsonString);

import 'dart:convert';

ShippingAddreesModel shippingAddreesModelFromJson(String str) => ShippingAddreesModel.fromJson(json.decode(str));

String shippingAddreesModelToJson(ShippingAddreesModel data) => json.encode(data.toJson());

class ShippingAddreesModel {
    bool? success;
    Data? data;

    ShippingAddreesModel({
        this.success,
        this.data,
    });

    factory ShippingAddreesModel.fromJson(Map<String, dynamic> json) => ShippingAddreesModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    int? country;
    int? state;
    int? city;
    int? pincode;
    String?address;

    Data({
        this.country,
        this.state,
        this.city,
        this.pincode,this.address
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        country: json["country"],
        state: json["state"],
        city: json["city"],
        pincode: json["pincode"],
        address: json["address"]
    );

    Map<String, dynamic> toJson() => {
        "country": country,
        "state": state,
        "city": city,
        "pincode": pincode,
        "address":address
    };
}
