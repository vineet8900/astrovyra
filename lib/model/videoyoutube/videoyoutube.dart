import 'dart:convert';

// Function to parse the JSON string into our model
VideoTestimonialResponse videoTestimonialResponseFromJson(String str) => VideoTestimonialResponse.fromJson(json.decode(str));

// Main response class
class VideoTestimonialResponse {
    final bool success;
    final Data data;

    VideoTestimonialResponse({
        required this.success,
        required this.data,
    });

    factory VideoTestimonialResponse.fromJson(Map<String, dynamic> json) => VideoTestimonialResponse(
        success: json["success"],
        data: Data.fromJson(json["data"]),
    );
}

// Class for the nested "data" object
class Data {
    final String heading;
    final String subHeading;
    final List<VideoItem> data;

    Data({
        required this.heading,
        required this.subHeading,
        required this.data,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        heading: json["heading"],
        subHeading: json["sub_heading"],
        data: List<VideoItem>.from(json["data"].map((x) => VideoItem.fromJson(x))),
    );
}

// Class for each individual video item in the list
class VideoItem {
    final String title;
    final String videoId;
    final String thumbnail;
    final String videoUrl;

    VideoItem({
        required this.title,
        required this.videoId,
        required this.thumbnail,
        required this.videoUrl,
    });

    factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
        title: json["title"],
        videoId: json["video_id"],
        thumbnail: json["thumbnail"],
        videoUrl: json["video_url"],
    );
}