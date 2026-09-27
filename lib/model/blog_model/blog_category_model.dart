// To parse this JSON data, do
//
//     final blogCategoryModel = blogCategoryModelFromJson(jsonString);

import 'dart:convert';

BlogCategoryModel blogCategoryModelFromJson(String str) => BlogCategoryModel.fromJson(json.decode(str));

String blogCategoryModelToJson(BlogCategoryModel data) => json.encode(data.toJson());

class BlogCategoryModel {
    bool? success;
    List<Datum>? data;

    BlogCategoryModel({
        this.success,
        this.data,
    });

    factory BlogCategoryModel.fromJson(Map<String, dynamic> json) => BlogCategoryModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    int? id;
    String? slug;
    String? name;

    Datum({
        this.id,
        this.slug,
        this.name,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        slug: json["slug"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "name": name,
    };
}
