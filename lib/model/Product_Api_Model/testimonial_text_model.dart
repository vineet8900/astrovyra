// To parse this JSON data, do
//
//     final testimonialTextModel = testimonialTextModelFromJson(jsonString);

import 'dart:convert';

TestimonialTextModel testimonialTextModelFromJson(String str) => TestimonialTextModel.fromJson(json.decode(str));

String testimonialTextModelToJson(TestimonialTextModel data) => json.encode(data.toJson());

class TestimonialTextModel {
    bool? success;
    Data? data;

    TestimonialTextModel({
        this.success,
        this.data,
    });

    factory TestimonialTextModel.fromJson(Map<String, dynamic> json) => TestimonialTextModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    String? heading;
    String? subHeading;
    List<TextmonialTectDatum>? data;

    Data({
        this.heading,
        this.subHeading,
        this.data,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        heading: json["heading"],
        subHeading: json["sub_heading"],
        data: json["data"] == null ? [] : List<TextmonialTectDatum>.from(json["data"]!.map((x) => TextmonialTectDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "heading": heading,
        "sub_heading": subHeading,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class TextmonialTectDatum {
    String? title;
    String? city;
    int? rating;
    String? imageUrl;
    String? description;

    TextmonialTectDatum({
        this.title,
        this.city,
        this.rating,
        this.imageUrl,
        this.description,
    });

    factory TextmonialTectDatum.fromJson(Map<String, dynamic> json) => TextmonialTectDatum(
        title: json["title"],
        city: json["city"],
        rating: json["rating"],
        imageUrl: json["image_url"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "city": city,
        "rating": rating,
        "image_url": imageUrl,
        "description": description,
    };
}
