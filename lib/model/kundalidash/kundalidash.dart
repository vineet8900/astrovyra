import 'dart:convert';

class KundaliChartResponse {
    final bool success;
    final ChartData data;

    KundaliChartResponse({
        required this.success,
        required this.data,
    });

    factory KundaliChartResponse.fromJson(Map<String, dynamic> json) => KundaliChartResponse(
        success: json["suceess"] ?? false, // Handles potential null value
        data: ChartData.fromJson(json["data"]),
    );
}

class ChartData {
    final String d1;
    final String d9;
    final List<PlanetInfo> planets;

    ChartData({
        required this.d1,
        required this.d9,
        required this.planets,
    });

    factory ChartData.fromJson(Map<String, dynamic> json) => ChartData(
        d1: json["d1"],
        d9: json["d9"],
        planets: List<PlanetInfo>.from(json["planets"].map((x) => PlanetInfo.fromJson(x))),
    );
}

class PlanetInfo {
    final String fullName;
    final String zodiac;
    final int house;

    PlanetInfo({
        required this.fullName,
        required this.zodiac,
        required this.house,
    });

    factory PlanetInfo.fromJson(Map<String, dynamic> json) => PlanetInfo(
        fullName: json["full_name"],
        zodiac: json["zodiac"],
        house: json["house"],
    );
}