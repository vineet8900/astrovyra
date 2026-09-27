import 'dart:convert';

class KundaliKpResponse {
    final bool success;
    final KpData data;

    KundaliKpResponse({
        required this.success,
        required this.data,
    });

    // Fixed: Handle both String and Map input properly
    factory KundaliKpResponse.fromRawJson(String str) {
        try {
            final decoded = json.decode(str);
            return KundaliKpResponse.fromJson(decoded);
        } catch (e) {
            
            rethrow;
        }
    }

    String toRawJson() => json.encode(toJson());

    factory KundaliKpResponse.fromJson(Map<String, dynamic> json) {
        try {
            return KundaliKpResponse(
                // Handle both "success" and "suceess" (API typo)
                success: json["success"] ?? json["suceess"] ?? false,
                data: KpData.fromJson(json["data"] ?? {}),
            );
        } catch (e) {
            
            rethrow;
        }
    }

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
    };
}

class KpData {
    final String d1;
    final String chalit;
    final List<RulingPlanet> rulingPlanets;
    final String dayLord;
    final List<Planet> planets;

    KpData({
        required this.d1,
        required this.chalit,
        required this.rulingPlanets,
        required this.dayLord,
        required this.planets,
    });

    factory KpData.fromRawJson(String str) {
        try {
            final decoded = json.decode(str);
            return KpData.fromJson(decoded);
        } catch (e) {
             
            rethrow;
        }
    }

    String toRawJson() => json.encode(toJson());

    factory KpData.fromJson(Map<String, dynamic> json) {
        try {
            return KpData(
                d1: json["d1"]?.toString() ?? "",
                chalit: json["chalit"]?.toString() ?? "",
                // Handle both "rullingPlanets" (API typo) and "rulingPlanets"
                rulingPlanets: _parseRulingPlanets(json["rullingPlanets"] ?? json["rulingPlanets"] ?? []),
                dayLord: json["dayLord"]?.toString() ?? json["day_lord"]?.toString() ?? "",
                planets: _parsePlanets(json["planets"] ?? []),
            );
        } catch (e) {
             
            rethrow;
        }
    }

    static List<RulingPlanet> _parseRulingPlanets(dynamic planetsJson) {
        try {
            if (planetsJson is List) {
                return planetsJson.map((x) => RulingPlanet.fromJson(x)).toList();
            }
            return [];
        } catch (e) {
            
            return [];
        }
    }

    static List<Planet> _parsePlanets(dynamic planetsJson) {
        try {
            if (planetsJson is List) {
                return planetsJson.map((x) => Planet.fromJson(x)).toList();
            }
            return [];
        } catch (e) {
            
            return [];
        }
    }

    Map<String, dynamic> toJson() => {
        "d1": d1,
        "chalit": chalit,
        "rullingPlanets": List<dynamic>.from(rulingPlanets.map((x) => x.toJson())),
        "dayLord": dayLord,
        "planets": List<dynamic>.from(planets.map((x) => x.toJson())),
    };
}

class Planet {
    final String planet;
    final int cups;
    final String zodiac;
    final String zodiacLord;
    final String nakshatra;
    final String nakshatraLord;
    final String subLord;

    Planet({
        required this.planet,
        required this.cups,
        required this.zodiac,
        required this.zodiacLord,
        required this.nakshatra,
        required this.nakshatraLord,
        required this.subLord,
    });

    factory Planet.fromRawJson(String str) {
        try {
            final decoded = json.decode(str);
            return Planet.fromJson(decoded);
        } catch (e) {
             
            rethrow;
        }
    }

    String toRawJson() => json.encode(toJson());

    factory Planet.fromJson(Map<String, dynamic> json) {
        try {
            return Planet(
                planet: json["planet"]?.toString() ?? "",
                cups: _parseInt(json["cups"]),
                zodiac: json["zodiac"]?.toString() ?? "",
                zodiacLord: json["zodiac_lord"]?.toString() ?? json["zodiacLord"]?.toString() ?? "",
                nakshatra: json["nakshatra"]?.toString() ?? "",
                nakshatraLord: json["nakshatra_lord"]?.toString() ?? json["nakshatraLord"]?.toString() ?? "",
                subLord: json["sub_lord"]?.toString() ?? json["subLord"]?.toString() ?? "",
            );
        } catch (e) {
             
            rethrow;
        }
    }

    static int _parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        if (value is double) return value.round();
        return 0;
    }

    Map<String, dynamic> toJson() => {
        "planet": planet,
        "cups": cups,
        "zodiac": zodiac,
        "zodiac_lord": zodiacLord,
        "nakshatra": nakshatra,
        "nakshatra_lord": nakshatraLord,
        "sub_lord": subLord,
    };
}

class RulingPlanet {
    final String fullName;
    final String zodiac;
    final String zodiacLord;
    final String nakshatra;
    final String nakshatraLord;
    final double localDegree;
    final String retro;
    final String isCombust;
    final String basicAvastha;
    final int house;
    final String lordStatus;

    RulingPlanet({
        required this.fullName,
        required this.zodiac,
        required this.zodiacLord,
        required this.nakshatra,
        required this.nakshatraLord,
        required this.localDegree,
        required this.retro,
        required this.isCombust,
        required this.basicAvastha,
        required this.house,
        required this.lordStatus,
    });

    factory RulingPlanet.fromRawJson(String str) {
        try {
            final decoded = json.decode(str);
            return RulingPlanet.fromJson(decoded);
        } catch (e) {
            
            rethrow;
        }
    }

    String toRawJson() => json.encode(toJson());

    factory RulingPlanet.fromJson(Map<String, dynamic> json) {
        try {
            return RulingPlanet(
                fullName: json["full_name"]?.toString() ?? json["fullName"]?.toString() ?? "",
                zodiac: json["zodiac"]?.toString() ?? "",
                zodiacLord: json["zodiac_lord"]?.toString() ?? json["zodiacLord"]?.toString() ?? "",
                nakshatra: json["nakshatra"]?.toString() ?? "",
                nakshatraLord: json["nakshatra_lord"]?.toString() ?? json["nakshatraLord"]?.toString() ?? "",
                localDegree: _parseDouble(json["local_degree"] ?? json["localDegree"]),
                retro: json["retro"]?.toString() ?? "",
                isCombust: json["is_combust"]?.toString() ?? json["isCombust"]?.toString() ?? "",
                basicAvastha: json["basic_avastha"]?.toString() ?? json["basicAvastha"]?.toString() ?? "",
                house: _parseInt(json["house"]),
                lordStatus: json["lord_status"]?.toString() ?? json["lordStatus"]?.toString() ?? "",
            );
        } catch (e) {
             
            rethrow;
        }
    }

    static double _parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
    }

    static int _parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        if (value is double) return value.round();
        return 0;
    }

    Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "zodiac": zodiac,
        "zodiac_lord": zodiacLord,
        "nakshatra": nakshatra,
        "nakshatra_lord": nakshatraLord,
        "local_degree": localDegree,
        "retro": retro,
        "is_combust": isCombust,
        "basic_avastha": basicAvastha,
        "house": house,
        "lord_status": lordStatus,
    };
}