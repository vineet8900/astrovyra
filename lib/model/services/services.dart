// To parse this JSON data, do
//
//     final astrologerServicesResponse = astrologerServicesResponseFromJson(jsonString);

import 'dart:convert';

// Helper function to parse a JSON string into an AstrologerServicesResponse object
AstrologerServicesResponse astrologerServicesResponseFromJson(String str) => AstrologerServicesResponse.fromJson(json.decode(str));

// Helper function to convert an AstrologerServicesResponse object into a JSON string
String astrologerServicesResponseToJson(AstrologerServicesResponse data) => json.encode(data.toJson());

// Class representing the entire API response
class AstrologerServicesResponse {
    final bool success;
    final List<AstrologerService> data;

    AstrologerServicesResponse({
        required this.success,
        required this.data,
    });

    // Factory constructor to create an instance from a JSON map
    factory AstrologerServicesResponse.fromJson(Map<String, dynamic> json) => AstrologerServicesResponse(
        success: json["success"],
        data: List<AstrologerService>.from(json["data"].map((x) => AstrologerService.fromJson(x))),
    );

    // Method to convert the instance into a JSON map
    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

// Class representing a single astrologer service
class AstrologerService {
    final int value;
    final String icon;
    final String slug;
    final String name;

    AstrologerService({
        required this.value,
        required this.icon,
        required this.slug,
        required this.name,
    });

    // Factory constructor to create an instance from a JSON map
    factory AstrologerService.fromJson(Map<String, dynamic> json) => AstrologerService(
        value: json["value"],
        icon: json["icon"],
        slug: json["slug"],
        name: json["name"],
    );

    // Method to convert the instance into a JSON map
    Map<String, dynamic> toJson() => {
        "value": value,
        "icon": icon,
        "slug": slug,
        "name": name,
    };
}