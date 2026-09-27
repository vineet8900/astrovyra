

// import 'dart:convert';

// BlogListModel blogListModelFromJson(String str) => BlogListModel.fromJson(json.decode(str));

// String blogListModelToJson(BlogListModel data) => json.encode(data.toJson());

// class BlogListModel {
//     bool? success;
//     Data? data;

//     BlogListModel({
//         this.success,
//         this.data,
//     });

//     factory BlogListModel.fromJson(Map<String, dynamic> json) => BlogListModel(
//         success: json["success"],
//         data: json["data"] == null ? null : Data.fromJson(json["data"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "success": success,
//         "data": data?.toJson(),
//     };
// }

// class Data {
//     int? categoryId;
//     int? currentPage;
//     int? total;
//     String? firstPageUrl;
//     String? lastPageUrl;
//     dynamic prevPageUrl;
//     dynamic nextPageUrl;
//     int? perPage;
//     List<BlogList>? list;

//     Data({
//         this.categoryId,
//         this.currentPage,
//         this.total,
//         this.firstPageUrl,
//         this.lastPageUrl,
//         this.prevPageUrl,
//         this.nextPageUrl,
//         this.perPage,
//         this.list,
//     });

//     factory Data.fromJson(Map<String, dynamic> json) => Data(
//         categoryId: json["categoryId"],
//         currentPage: json["current_page"],
//         total: json["total"],
//         firstPageUrl: json["first_page_url"],
//         lastPageUrl: json["last_page_url"],
//         prevPageUrl: json["prev_page_url"],
//         nextPageUrl: json["next_page_url"],
//         perPage: json["per_page"],
//         list: json["list"] == null ? [] : List<BlogList>.from(json["list"]!.map((x) => BlogList.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "categoryId": categoryId,
//         "current_page": currentPage,
//         "total": total,
//         "first_page_url": firstPageUrl,
//         "last_page_url": lastPageUrl,
//         "prev_page_url": prevPageUrl,
//         "next_page_url": nextPageUrl,
//         "per_page": perPage,
//         "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
//     };
// }

// class BlogList {
//     int? id;
//     String? slug;
//     String? title;
//     dynamic subTitle;
//     String? image;
//     String? postedOn;

//     BlogList({
//         this.id,
//         this.slug,
//         this.title,
//         this.subTitle,
//         this.image,
//         this.postedOn,
//     });

//     factory BlogList.fromJson(Map<String, dynamic> json) => BlogList(
//         id: json["id"],
//         slug: json["slug"],
//         title: json["title"],
//         subTitle: json["subTitle"],
//         image: json["image"],
//         postedOn: json["postedOn"],
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "slug": slug,
//         "title": title,
//         "subTitle": subTitle,
//         "image": image,
//         "postedOn": postedOn,
//     };
// }


import 'dart:convert';

BlogListModel blogListModelFromJson(String str) => BlogListModel.fromJson(json.decode(str));

String blogListModelToJson(BlogListModel data) => json.encode(data.toJson());

class BlogListModel {
    bool? success;
    Data? data;

    BlogListModel({
        this.success,
        this.data,
    });

    factory BlogListModel.fromJson(Map<String, dynamic> json) => BlogListModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    int? categoryId;
    int? currentPage;
    int? total;
    String? firstPageUrl;
    String? lastPageUrl;
    dynamic prevPageUrl;
    dynamic nextPageUrl;
    int? perPage;
    List<BlogList>? list;

    Data({
        this.categoryId,
        this.currentPage,
        this.total,
        this.firstPageUrl,
        this.lastPageUrl,
        this.prevPageUrl,
        this.nextPageUrl,
        this.perPage,
        this.list,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        categoryId: json["categoryId"],
        currentPage: json["current_page"],
        total: json["total"],
        firstPageUrl: json["first_page_url"],
        lastPageUrl: json["last_page_url"],
        prevPageUrl: json["prev_page_url"],
        nextPageUrl: json["next_page_url"],
        perPage: json["per_page"],
        list: json["list"] == null ? [] : List<BlogList>.from(json["list"]!.map((x) => BlogList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "categoryId": categoryId,
        "current_page": currentPage,
        "total": total,
        "first_page_url": firstPageUrl,
        "last_page_url": lastPageUrl,
        "prev_page_url": prevPageUrl,
        "next_page_url": nextPageUrl,
        "per_page": perPage,
        "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
    };
}

class BlogList {
    int? id;
    String? slug;
    String? title;
    String? category;
    dynamic subTitle;
    String? image;
    String? postedOn;

    BlogList({
        this.id,
        this.slug,
        this.title,
        this.category,
        this.subTitle,
        this.image,
        this.postedOn,
    });

    factory BlogList.fromJson(Map<String, dynamic> json) => BlogList(
        id: json["id"],
        slug: json["slug"],
        title: json["title"],
        category: json["category"],
        subTitle: json["subTitle"],
        image: json["image"],
        postedOn: json["postedOn"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "title": title,
        "category": category,
        "subTitle": subTitle,
        "image": image,
        "postedOn": postedOn,
    };
}