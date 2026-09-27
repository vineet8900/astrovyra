// To parse this JSON data, do
//
//     final reviewModel = reviewModelFromJson(jsonString);

import 'dart:convert';

ReviewModel reviewModelFromJson(String str) => ReviewModel.fromJson(json.decode(str));

String reviewModelToJson(ReviewModel data) => json.encode(data.toJson());

class ReviewModel {
    bool? success;
    List<ReviewDatum>? data;

    ReviewModel({
        this.success,
        this.data,
    });

    factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<ReviewDatum>.from(json["data"]!.map((x) => ReviewDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class ReviewDatum {
    String? userName;
    String? userImageUrl;
    String? date;
    String? review;

    ReviewDatum({
        this.userName,
        this.userImageUrl,
        this.date,
        this.review,
    });

    factory ReviewDatum.fromJson(Map<String, dynamic> json) => ReviewDatum(
        userName: json["user_name"],
        userImageUrl: json["user_image_url"],
        date: json["date"],
        review: json["review"],
    );

    Map<String, dynamic> toJson() => {
        "user_name": userName,
        "user_image_url": userImageUrl,
        "date": date,
        "review": review,
    };
}
