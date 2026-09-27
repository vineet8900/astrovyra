// To parse this JSON data, do
//
//     final faqModel = faqModelFromJson(jsonString);

import 'dart:convert';

FaqModel faqModelFromJson(String str) => FaqModel.fromJson(json.decode(str));

String faqModelToJson(FaqModel data) => json.encode(data.toJson());

class FaqModel {
    bool? success;
    Data? data;

    FaqModel({
        this.success,
        this.data,
    });

    factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
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
    List<FAQDatum>? data;

    Data({
        this.heading,
        this.subHeading,
        this.data,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        heading: json["heading"],
        subHeading: json["sub_heading"],
        data: json["data"] == null ? [] : List<FAQDatum>.from(json["data"]!.map((x) => FAQDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "heading": heading,
        "sub_heading": subHeading,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class FAQDatum {
    String? question;
    String? answer;

    FAQDatum({
        this.question,
        this.answer,
    });

    factory FAQDatum.fromJson(Map<String, dynamic> json) => FAQDatum(
        question: json["question"],
        answer: json["answer"],
    );

    Map<String, dynamic> toJson() => {
        "question": question,
        "answer": answer,
    };
}
