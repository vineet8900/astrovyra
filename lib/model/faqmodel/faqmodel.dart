// To parse this JSON data, do
//
//     final faqResponse = faqResponseFromJson(jsonString);

import 'dart:convert';

FaqResponse faqResponseFromJson(String str) => FaqResponse.fromJson(json.decode(str));

String faqResponseToJson(FaqResponse data) => json.encode(data.toJson());

class FaqResponse {
    final bool success;
    final Data data;

    FaqResponse({
        required this.success,
        required this.data,
    });

    factory FaqResponse.fromJson(Map<String, dynamic> json) => FaqResponse(
        success: json["success"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
    };
}

class Data {
    final String heading;
    final String subHeading;
    final List<FaqItem> data;

    Data({
        required this.heading,
        required this.subHeading,
        required this.data,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        heading: json["heading"],
        subHeading: json["sub_heading"],
        data: List<FaqItem>.from(json["data"].map((x) => FaqItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "heading": heading,
        "sub_heading": subHeading,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class FaqItem {
    final String question;
    final String answer;

    FaqItem({
        required this.question,
        required this.answer,
    });

    factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        question: json["question"],
        answer: json["answer"],
    );

    Map<String, dynamic> toJson() => {
        "question": question,
        "answer": answer,
    };
}