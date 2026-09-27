import 'dart:convert';

class DashaResponse {
    final bool success;
    final DashaData data;

    DashaResponse({
        required this.success,
        required this.data,
    });

    factory DashaResponse.fromRawJson(String str) => DashaResponse.fromJson(json.decode(str));

    factory DashaResponse.fromJson(Map<String, dynamic> json) => DashaResponse(
        success: json["suceess"] ?? false,
        data: DashaData.fromJson(json["data"]),
    );
}

class DashaData {
    final List<VimshottariDasha> vimshottari;
    final YoginiDasha yogini;

    DashaData({
        required this.vimshottari,
        required this.yogini,
    });

    factory DashaData.fromJson(Map<String, dynamic> json) => DashaData(
        vimshottari: List<VimshottariDasha>.from(json["vimshottari"].map((x) => VimshottariDasha.fromJson(x))),
        yogini: YoginiDasha.fromJson(json["yogini"]),
    );
}

class VimshottariDasha {
    final String fullName;
    final String startEnd;
    final String prediction;
    final String planetInZodiac;

    VimshottariDasha({
        required this.fullName,
        required this.startEnd,
        required this.prediction,
        required this.planetInZodiac,
    });

    factory VimshottariDasha.fromJson(Map<String, dynamic> json) => VimshottariDasha(
        fullName: json["full_name"] ?? "N/A",
        startEnd: json["start_end"] ?? "N/A",
        prediction: json["prediction"] ?? "No prediction available.",
        planetInZodiac: json["planet_in_zodiac"] ?? "No details available.",
    );
}

class YoginiDasha {
    final String description;
    final List<YoginiPlanet> planets;

    YoginiDasha({
        required this.description,
        required this.planets,
    });

    factory YoginiDasha.fromJson(Map<String, dynamic> json) => YoginiDasha(
        description: json["description"] ?? "",
        planets: List<YoginiPlanet>.from(json["planets"].map((x) => YoginiPlanet.fromJson(x))),
    );
}

class YoginiPlanet {
    final String planet;
    final String start;
    final String end;

    YoginiPlanet({
        required this.planet,
        required this.start,
        required this.end,
    });

    factory YoginiPlanet.fromJson(Map<String, dynamic> json) => YoginiPlanet(
        planet: json["planet"] ?? "N/A",
        start: json["start"] ?? "N/A",
        end: json["end"] ?? "N/A",
    );
}