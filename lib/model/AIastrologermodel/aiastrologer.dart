// lib/model/ai_astrologer_model.dart

import 'dart:convert';

AiAstrologerResponse aiAstrologerResponseFromJson(String str) => AiAstrologerResponse.fromJson(json.decode(str));

class AiAstrologerResponse {
    final bool success;
    final AiAstrologerData data;
    

    AiAstrologerResponse({
        required this.success,
        required this.data,
    });

    factory AiAstrologerResponse.fromJson(Map<String, dynamic> json) => AiAstrologerResponse(
        success: json["success"] ?? false,
        data: AiAstrologerData.fromJson(json["data"] ?? {}),
    );
}

class AiAstrologerData {
    final List<AiAstrologer> list;
    final int count;
    final bool hasMorePages;

    AiAstrologerData({
        required this.list,
        required this.count,
        required this.hasMorePages,
    });

    factory AiAstrologerData.fromJson(Map<String, dynamic> json) {
        var astrologerList = <AiAstrologer>[];
        if (json['list'] != null && json['list'] is List) {
            astrologerList = List<AiAstrologer>.from(json["list"].map((x) => AiAstrologer.fromJson(x)));
        }

        return AiAstrologerData(
            list: astrologerList,
            count: json["count"] ?? 0,
            hasMorePages: json["has_more_pages"] ?? false,
        );
    }
}

class AiAstrologer {
    final int id;
    final String type;
    final String image;
    final double rating;
    final String slug;
    final String name;
    final String status;
    final Consultation consultation;
    final List<String> languages;
    final List<String> services;
    final int experience;
    final int chatPrice;
    final int chatSpecialPrice;

    AiAstrologer({
        required this.id,
        required this.type,
        required this.image,
        required this.rating,
        required this.slug,
        required this.name,
        required this.status,
        required this.consultation,
        required this.languages,
        required this.services,
        required this.experience,
        required this.chatPrice,
        required this.chatSpecialPrice,
    });

    factory AiAstrologer.fromJson(Map<String, dynamic> json) => AiAstrologer(
        id: json["id"] ?? 0,
        type: json["type"] ?? "ai",
        image: json["image"] ?? "",
        rating: (json["rating"] ?? 0).toDouble(),
        slug: json["slug"] ?? "",
        name: json["name"] ?? "AI Astrologer",
        status: json["status"]?.toString() ?? "offline",
        consultation: Consultation.fromJson(json["consultation"] ?? {}),
        languages: json["languages"] == null ? [] : List<String>.from(json["languages"].map((x) => x)),
        services: json["services"] == null ? [] : List<String>.from(json["services"].map((x) => x)),
        experience: json["experience"] ?? 0,
        chatPrice: json["chat_price"] ?? 0,
        chatSpecialPrice: json["chat_special_price"] ?? 0,
    );
}

class Consultation {
  final int id;
    final bool now;
    final bool later;

    Consultation({
       required this.id,
        required this.now,
        required this.later,
    });

    factory Consultation.fromJson(Map<String, dynamic> json) => Consultation(
       id: json["id"],
        now: json["now"] ?? false,
        later: json["later"] ?? false,
    );
}