// To parse this JSON data, do
//
//     final addtoWishlistModel = addtoWishlistModelFromJson(jsonString);

import 'dart:convert';

AddtoWishlistModel addtoWishlistModelFromJson(String str) => AddtoWishlistModel.fromJson(json.decode(str));

String addtoWishlistModelToJson(AddtoWishlistModel data) => json.encode(data.toJson());

class AddtoWishlistModel {
    bool? success;
    String? message;
    AddWishlistDatum? data;
    int? totalItem;

    AddtoWishlistModel({
        this.success,
        this.message,
        this.data,
        this.totalItem,
    });

    factory AddtoWishlistModel.fromJson(Map<String, dynamic> json) => AddtoWishlistModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : AddWishlistDatum.fromJson(json["data"]),
        totalItem: json["totalItem"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
        "totalItem": totalItem,
    };
}

class AddWishlistDatum {
    int? id;

    AddWishlistDatum({
        this.id,
    });

    factory AddWishlistDatum.fromJson(Map<String, dynamic> json) => AddWishlistDatum(
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
    };
}
