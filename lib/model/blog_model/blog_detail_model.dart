// To parse this JSON data, do
//
//     final blogDetailApiModel = blogDetailApiModelFromJson(jsonString);

import 'dart:convert';

BlogDetailApiModel blogDetailApiModelFromJson(String str) => BlogDetailApiModel.fromJson(json.decode(str));

String blogDetailApiModelToJson(BlogDetailApiModel data) => json.encode(data.toJson());

class BlogDetailApiModel {
    bool? success;
    Data? data;

    BlogDetailApiModel({
        this.success,
        this.data,
    });

    factory BlogDetailApiModel.fromJson(Map<String, dynamic> json) => BlogDetailApiModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    int? id;
    String? slug;
    String? image;
    String? title;
    dynamic subTitle;
    String? description;
    String? postedOn;
    Category? category;

    Data({
        this.id,
        this.slug,
        this.image,
        this.title,
        this.subTitle,
        this.description,
        this.postedOn,
        this.category,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        slug: json["slug"],
        image: json["image"],
        title: json["title"],
        subTitle: json["subTitle"],
        description: json["description"],
        postedOn: json["postedOn"],
        category: json["category"] == null ? null : Category.fromJson(json["category"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "image": image,
        "title": title,
        "subTitle": subTitle,
        "description": description,
        "postedOn": postedOn,
        "category": category?.toJson(),
    };
}

class Category {
    int? id;
    String? slug;
    String? name;

    Category({
        this.id,
        this.slug,
        this.name,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
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
