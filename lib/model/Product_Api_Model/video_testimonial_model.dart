// To parse this JSON data, do
//
//     final videoTestimonialModel = videoTestimonialModelFromJson(jsonString);

import 'dart:convert';

VideoTestimonialModel videoTestimonialModelFromJson(String str) => VideoTestimonialModel.fromJson(json.decode(str));

String videoTestimonialModelToJson(VideoTestimonialModel data) => json.encode(data.toJson());

class VideoTestimonialModel {
    bool? success;
    Data? data;

    VideoTestimonialModel({
        this.success,
        this.data,
    });

    factory VideoTestimonialModel.fromJson(Map<String, dynamic> json) => VideoTestimonialModel(
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

    List<VideoTestimonialDatum>? data;

    Data({
        this.heading,
        this.subHeading,
        this.data,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        heading: json["heading"],
        subHeading: json["sub_heading"],
        data: json["data"] == null ? [] : List<VideoTestimonialDatum>.from(json["data"]!.map((x) => VideoTestimonialDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "heading": heading,
        "sub_heading": subHeading,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class VideoTestimonialDatum {
    String? title;
    String? city;
    int? rating;
    String? videoId;
    String? videoUrl;
    String? description;
     String? thumbnail;

    VideoTestimonialDatum({
        this.title,
        this.city,
        this.rating,
        this.videoId,
        this.videoUrl,
        this.description,
        this.thumbnail
    });

    factory VideoTestimonialDatum.fromJson(Map<String, dynamic> json) => VideoTestimonialDatum(
        title: json["title"],
        city: json["city"],
        rating: json["rating"],
        videoId: json["video_id"],
        videoUrl: json["video_url"],
        description: json["description"],
         thumbnail: json["thumbnail"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "city": city,
        "rating": rating,
        "video_id": videoId,
        "video_url": videoUrl,
        "description": description,
         "thumbnail": thumbnail,
    };
}
