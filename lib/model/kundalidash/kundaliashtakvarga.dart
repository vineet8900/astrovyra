import 'dart:convert';

class AshtakvargaResponse {
    final bool success;
    final AshtakvargaData data;

    AshtakvargaResponse({
        required this.success,
        required this.data,
    });

    // Fixed: Handle both String and Map input
    factory AshtakvargaResponse.fromRawJson(String str) {
        try {
            final decoded = json.decode(str);
            return AshtakvargaResponse.fromJson(decoded);
        } catch (e) {
            
            rethrow;
        }
    }

    factory AshtakvargaResponse.fromJson(Map<String, dynamic> json) {
        try {
            return AshtakvargaResponse(
                // Handle both "success" and "suceess" (API typo)
                success: json["success"] ?? json["suceess"] ?? false,
                data: AshtakvargaData.fromJson(json["data"] ?? {}),
            );
        } catch (e) {
           
            rethrow;
        }
    }
}

class AshtakvargaData {
    final String sun;
    final String moon;
    final String mercury;
    final String venus;
    final String mars;
    final String jupiter;
    final String saturn;
    final String rahu;
    final String ketu;

    AshtakvargaData({
        required this.sun,
        required this.moon,
        required this.mercury,
        required this.venus,
        required this.mars,
        required this.jupiter,
        required this.saturn,
        required this.rahu,
        required this.ketu,
    });

    factory AshtakvargaData.fromJson(Map<String, dynamic> json) {
        try {
            return AshtakvargaData(
                sun: json["sun"]?.toString() ?? "",
                moon: json["moon"]?.toString() ?? "",
                mercury: json["mercury"]?.toString() ?? "",
                venus: json["venus"]?.toString() ?? "",
                mars: json["mars"]?.toString() ?? "",
                jupiter: json["jupiter"]?.toString() ?? "",
                saturn: json["saturn"]?.toString() ?? "",
                rahu: json["rahu"]?.toString() ?? "",
                ketu: json["ketu"]?.toString() ?? "",
            );
        } catch (e) {
             
            rethrow;
        }
    }

    // Helper to get charts as a map, filtering out empty ones
    Map<String, String> get charts {
        final map = {
            'Sun': sun,
            'Moon': moon,
            'Mars': mars,
            'Mercury': mercury,
            'Jupiter': jupiter,
            'Venus': venus,
            'Saturn': saturn,
            // Include Rahu and Ketu if they have data
            if (rahu.isNotEmpty) 'Rahu': rahu,
            if (ketu.isNotEmpty) 'Ketu': ketu,
        };
        
        // Remove entries where the SVG string is empty
        map.removeWhere((key, value) => value.isEmpty);
        return map;
    }
}