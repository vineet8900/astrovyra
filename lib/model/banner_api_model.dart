// To parse this JSON data, do
//
//     final bannerApiModel = bannerApiModelFromJson(jsonString);

import 'dart:convert';

BannerApiModel bannerApiModelFromJson(String str) => BannerApiModel.fromJson(json.decode(str));

String bannerApiModelToJson(BannerApiModel data) => json.encode(data.toJson());

class BannerApiModel {
    String? status;
    List<BannerDatum>? data;

    BannerApiModel({
        this.status,
        this.data,
    });

    factory BannerApiModel.fromJson(Map<String, dynamic> json) => BannerApiModel(
        status: json["status"],
        data: json["data"] == null ? [] : List<BannerDatum>.from(json["data"]!.map((x) => BannerDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class BannerDatum {
    String? title;
    String? image;
    String? description;

    BannerDatum({
        this.title,
        this.image,
        this.description,
    });

    factory BannerDatum.fromJson(Map<String, dynamic> json) => BannerDatum(
        title: json["title"],
        image: json["image"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "image": image,
        "description": description,
    };
}
