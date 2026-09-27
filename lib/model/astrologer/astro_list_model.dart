// To parse this JSON data, do
//
//     final astrologerListModel = astrologerListModelFromJson(jsonString);

import 'dart:convert';

AstrologerListModel astrologerListModelFromJson(String str) => AstrologerListModel.fromJson(json.decode(str));

String astrologerListModelToJson(AstrologerListModel data) => json.encode(data.toJson());

class AstrologerListModel {
    bool? success;
    AstroListdatum? data;

    AstrologerListModel({
        this.success,
        this.data,
    });

    factory AstrologerListModel.fromJson(Map<String, dynamic> json) => AstrologerListModel(
        success: json["success"],
        data: json["data"] == null ? null : AstroListdatum.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class AstroListdatum {
    List<AstroDataList>? list;
    dynamic count;
    dynamic perPage;
    bool? hasMorePages;
    dynamic currentPage;
    dynamic previousPageUrl;
    dynamic nextPageUrl;
    String? lastPageUrl;

    AstroListdatum({
        this.list,
        this.count,
        this.perPage,
        this.hasMorePages,
        this.currentPage,
        this.previousPageUrl,
        this.nextPageUrl,
        this.lastPageUrl,
    });

    factory AstroListdatum.fromJson(Map<String, dynamic> json) => AstroListdatum(
        list: json["list"] == null ? [] : List<AstroDataList>.from(json["list"]!.map((x) => AstroDataList.fromJson(x))),
        count: json["count"],
        perPage: json["per_page"],
        hasMorePages: json["has_more_pages"],
        currentPage: json["current_page"],
        previousPageUrl: json["previous_page_url"],
        nextPageUrl: json["next_page_url"],
        lastPageUrl: json["last_page_url"],
    );

    Map<String, dynamic> toJson() => {
        "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
        "count": count,
        "per_page": perPage,
        "has_more_pages": hasMorePages,
        "current_page": currentPage,
        "previous_page_url": previousPageUrl,
        "next_page_url": nextPageUrl,
        "last_page_url": lastPageUrl,
    };
}

class AstroDataList {
    dynamic id;
    String? type;
    String? image;
    dynamic rating;
    String? slug;
    String? name;
    String? status;
     bool? blueTick;
    String? chatStatus;
    String? callStatus;
    String? videoStatus;
    Consultation? consultation;
    List<String>? languages;
    List<String>? services;
    dynamic experience;
    dynamic chatPrice;
    dynamic callPrice;
    dynamic videoPrice;
    dynamic chatSpecialPrice;
    dynamic callSpecialPrice;
    dynamic videoSpecialPrice;

    AstroDataList({
        this.id,
        this.type,
        this.image,
        this.rating,
        this.slug,
        this.blueTick,
        this.name,
        this.status,
        this.chatStatus,
        this.callStatus,
        this.videoStatus,
        this.consultation,
        this.languages,
        this.services,
        this.experience,
        this.chatPrice,
        this.callPrice,
        this.videoPrice,
        this.chatSpecialPrice,
        this.callSpecialPrice,
        this.videoSpecialPrice,
    });

    factory AstroDataList.fromJson(Map<String, dynamic> json) => AstroDataList(
        id: json["id"],
        type: json["type"],
        image: json["image"],
        rating: json["rating"],
        slug: json["slug"],
        name: json["name"],
        status: json["status"]?.toString(),
          blueTick: json["blue_tick"], 
        chatStatus: json["chat_status"],
        callStatus: json["call_status"],
        videoStatus: json["video_status"],
        consultation: json["consultation"] == null ? null : Consultation.fromJson(json["consultation"]),
        languages: json["languages"] == null ? [] : List<String>.from(json["languages"]!.map((x) => x)),
        services: json["services"] == null ? [] : List<String>.from(json["services"]!.map((x) => x)),
        experience: json["experience"],
        chatPrice: json["chat_price"],
        callPrice: json["call_price"],
        videoPrice: json["video_price"],
        chatSpecialPrice: json["chat_special_price"],
        callSpecialPrice: json["call_special_price"],
        videoSpecialPrice: json["video_special_price"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "image": image,
        "rating": rating,
        "slug": slug,
        "name": name,
        "status": status,
        "blue_tick": blueTick,
        "chat_status": chatStatus,
        "call_status": callStatus,
        "video_status": videoStatus,
        "consultation": consultation?.toJson(),
        "languages": languages == null ? [] : List<dynamic>.from(languages!.map((x) => x)),
        "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x)),
        "experience": experience,
        "chat_price": chatPrice,
        "call_price": callPrice,
        "video_price": videoPrice,
        "chat_special_price": chatSpecialPrice,
        "call_special_price": callSpecialPrice,
        "video_special_price": videoSpecialPrice,
    };
}

class Consultation {
    bool? now;
    bool? later;
    String? wait;

    Consultation({
        this.now,
        this.later,
        this.wait,
    });

    factory Consultation.fromJson(Map<String, dynamic> json) => Consultation(
        now: json["now"],
        later: json["later"],
        wait: json["wait"],
    );

    Map<String, dynamic> toJson() => {
        "now": now,
        "later": later,
        "wait": wait,
    };
}
