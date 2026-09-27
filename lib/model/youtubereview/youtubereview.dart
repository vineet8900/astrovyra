import 'dart:convert';

// Helper function to parse the JSON string
TextTestimonialResponse textTestimonialResponseFromJson(String str) => TextTestimonialResponse.fromJson(json.decode(str));

// Main response class
class TextTestimonialResponse {
    final bool success;
    final TextTestimonialData data;

    TextTestimonialResponse({
        required this.success,
        required this.data,
    });

    factory TextTestimonialResponse.fromJson(Map<String, dynamic> json) => TextTestimonialResponse(
        success: json["success"],
        data: TextTestimonialData.fromJson(json["data"]),
    );
}

// Class for the nested "data" object
class TextTestimonialData {
    final String heading;
    final String subHeading;
    final List<TestimonialItem> data;

    TextTestimonialData({
        required this.heading,
        required this.subHeading,
        required this.data,
    });

    factory TextTestimonialData.fromJson(Map<String, dynamic> json) => TextTestimonialData(
        heading: json["heading"],
        subHeading: json["sub_heading"],
        data: List<TestimonialItem>.from(json["data"].map((x) => TestimonialItem.fromJson(x))),
    );
}

// Class for each individual testimonial item
class TestimonialItem {
    final String title;
    final String description;

    TestimonialItem({
        required this.title,
        required this.description,
    });

    factory TestimonialItem.fromJson(Map<String, dynamic> json) => TestimonialItem(
        title: json["title"],
        description: json["description"],
    );
}