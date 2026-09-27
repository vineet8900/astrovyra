import 'dart:convert';

RecentViewsModel recentViewsModelFromJson(String str) =>
    RecentViewsModel.fromJson(json.decode(str));

String recentViewsModelToJson(RecentViewsModel data) =>
    json.encode(data.toJson());

class RecentViewsModel {
  bool? status;
  List<RecentViewDatum>? data;

  RecentViewsModel({
    this.status,
    this.data,
  });

  factory RecentViewsModel.fromJson(Map<String, dynamic> json) =>
      RecentViewsModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<RecentViewDatum>.from(
                json["data"].map((x) => RecentViewDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class RecentViewDatum {
  int? id;
  String? title;
  String? image;
  String? slug;
  String? type;

  RecentViewDatum({
    this.id,
    this.title,
    this.image,
    this.slug,
    this.type,
  });

  factory RecentViewDatum.fromJson(Map<String, dynamic> json) =>
      RecentViewDatum(
        id: json["id"],
        title: json["title"],
        image: json["image"],
        slug: json["slug"],
        type: (json["type"] ??
                json["product_type"] ??
                json["item_type"] ??
                json["kind"])
            ?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "slug": slug,
        "type": type,
      };
}
