import 'dart:convert';

class AllChartsResponse {
    final bool success;
    final AllChartsData data;

    AllChartsResponse({
        required this.success,
        required this.data,
    });

    factory AllChartsResponse.fromRawJson(String str) => AllChartsResponse.fromJson(json.decode(str));

    factory AllChartsResponse.fromJson(Map<String, dynamic> json) => AllChartsResponse(
        // Handles the "suceess" typo from the API
        success: json["suceess"] ?? false,
        data: AllChartsData.fromJson(json["data"]),
    );
}

class AllChartsData {
    final String description;
    final Map<String, String> charts;

    AllChartsData({
        required this.description,
        required this.charts,
    });

    factory AllChartsData.fromJson(Map<String, dynamic> json) {
        final String description = json['description'] ?? 'No description available.';
        final Map<String, String> chartsMap = {};

        // A map to give user-friendly names to the chart keys
        const chartNameMapping = {
            'd1': 'D1 - Lagna',
            'chalit': 'Chalit',
            'moon': 'Moon Chart',
            'sun': 'Sun Chart',
            'd3': 'D3 - Drekkana',
            'd7': 'D7 - Saptamsa',
            'd9': 'D9 - Navamsa',
            'd10': 'D10 - Dasamsa',
            'd12': 'D12 - Dwadashamsa',
            'd16': 'D16 - Shodashamsa',
            'd20': 'D20 - Vimshamsa',
            'd24': 'D24 - Chaturvimshamsa',
            'd30': 'D30 - Trimshamsa',
            'd40': 'D40 - Khavedamsa',
            'd45': 'D45 - Akshavedamsa',
            'd60': 'D60 - Shashtyamsa',
        };

        // Iterate through the JSON and add any non-description keys to the map
        json.forEach((key, value) {
            if (key != 'description' && value is String && value.isNotEmpty) {
                // Use the friendly name if available, otherwise use the key itself
                chartsMap[chartNameMapping[key] ?? key.toUpperCase()] = value;
            }
        });

        return AllChartsData(
            description: description,
            charts: chartsMap,
        );
    }
}