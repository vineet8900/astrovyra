import 'dart:convert';

AstroDetailModel astroDetailModelFromJson(String str) => AstroDetailModel.fromJson(json.decode(str));

String astroDetailModelToJson(AstroDetailModel data) => json.encode(data.toJson());

class AstroDetailModel {
    bool? success;
    Data? data;

    AstroDetailModel({
        this.success,
        this.data,
    });

    factory AstroDetailModel.fromJson(Map<String, dynamic> json) => AstroDetailModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    AstroDetailDatum? detail;

    Data({
        this.detail,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        detail: json["detail"] == null ? null : AstroDetailDatum.fromJson(json["detail"]),
    );

    Map<String, dynamic> toJson() => {
        "detail": detail?.toJson(),
    };
}

class AstroDetailDatum {
    int? id;
    bool? blueTick;
    String? image;
    int? rating;
    int? reviewsCount;
    RatingOverview? ratingOverview;
    String? slug;
    String? name;
    String? status;
    String? chatStatus;
    String? callStatus;
    String? videoStatus;
    Consultation? consultation;
    List<String>? languages;
    List<Service>? services;
    int? experience;
    int? chatPrice;
    int? callPrice;
    int? videoPrice;
    int? chatSpecialPrice;
    int? callSpecialPrice;
    int? videoSpecialPrice;
    String? about;
    String? experienceData;
    String? education;
    String? expertiseData;

    AstroDetailDatum({
        this.id,
        this.blueTick,
        this.image,
        this.rating,
        this.reviewsCount,
        this.ratingOverview,
        this.slug,
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
        this.about,
        this.experienceData,
        this.education,
        this.expertiseData,
    });

    factory AstroDetailDatum.fromJson(Map<String, dynamic> json) => AstroDetailDatum(
        id: json["id"],
         blueTick: json["blue_tick"],
        image: json["image"],
        rating: json["rating"],
        reviewsCount: json["reviews_count"],
        ratingOverview: json["rating_overview"] == null ? null : RatingOverview.fromJson(json["rating_overview"]),
        slug: json["slug"],
        name: json["name"],
        status: json["status"]?.toString(),
        chatStatus: json["chat_status"],
        callStatus: json["call_status"],
        videoStatus: json["video_status"],
        consultation: json["consultation"] == null ? null : Consultation.fromJson(json["consultation"]),
        languages: json["languages"] == null ? [] : List<String>.from(json["languages"]!.map((x) => x)),
        services: json["services"] == null ? [] : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
        experience: json["experience"],
        chatPrice: json["chat_price"],
        callPrice: json["call_price"],
        videoPrice: json["video_price"],
        chatSpecialPrice: json["chat_special_price"],
        callSpecialPrice: json["call_special_price"],
        videoSpecialPrice: json["video_special_price"],
        about: json["about"],
        experienceData: json["experience_data"],
        education: json["education"],
        expertiseData: json["expertise_data"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "blue_tick": blueTick, 
        "image": image,
        "rating": rating,
        "reviews_count": reviewsCount,
        "rating_overview": ratingOverview?.toJson(),
        "slug": slug,
        "name": name,
        "status": status,
        "chat_status": chatStatus,
        "call_status": callStatus,
        "video_status": videoStatus,
        "consultation": consultation?.toJson(),
        "languages": languages == null ? [] : List<dynamic>.from(languages!.map((x) => x)),
        "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
        "experience": experience,
        "chat_price": chatPrice,
        "call_price": callPrice,
        "video_price": videoPrice,
        "chat_special_price": chatSpecialPrice,
        "call_special_price": callSpecialPrice,
        "video_special_price": videoSpecialPrice,
        "about": about,
        "experience_data": experienceData,
        "education": education,
        "expertise_data": expertiseData,
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

class RatingOverview {
    int? one;
    int? two;
    int? three;
    int? four;
    int? five;

    RatingOverview({
        this.one,
        this.two,
        this.three,
        this.four,
        this.five,
    });

    factory RatingOverview.fromJson(Map<String, dynamic> json) => RatingOverview(
        one: json["one"],
        two: json["two"],
        three: json["three"],
        four: json["four"],
        five: json["five"],
    );

    Map<String, dynamic> toJson() => {
        "one": one,
        "two": two,
        "three": three,
        "four": four,
        "five": five,
    };
}

class Service {
    int? value;
    String? icon;
    String? slug;
    String? name;

    Service({
        this.value,
        this.icon,
        this.slug,
        this.name,
    });

    factory Service.fromJson(Map<String, dynamic> json) => Service(
        value: json["value"],
        icon: json["icon"],
        slug: json["slug"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "value": value,
        "icon": icon,
        "slug": slug,
        "name": name,
    };
}
