class GemModel {
  final String name;
  final String gem;
  final String otherName;
  final String planet;
  final String description;
  final List<String> goodResults;
  final List<String> diseasesCure;
  final String finger;
  final String weight;
  final String day;
  final String metal;
  final List<String> substitute;
  final List<String> notToWearWith;
  final String timeToWearShort;
  final String timeToWear;
  final String methods;
  final String mantra;
  final String lifeStone;
  final String luckyStone;
  final String fortuneStone;
  final List<FlawResult> flawResults;

  GemModel({
    required this.name,
    required this.gem,
    required this.otherName,
    required this.planet,
    required this.description,
    required this.goodResults,
    required this.diseasesCure,
    required this.finger,
    required this.weight,
    required this.day,
    required this.metal,
    required this.substitute,
    required this.notToWearWith,
    required this.timeToWearShort,
    required this.timeToWear,
    required this.methods,
    required this.mantra,
    required this.lifeStone,
    required this.luckyStone,
    required this.fortuneStone,
    required this.flawResults,
  });

  factory GemModel.fromJson(Map<String, dynamic> json) {
    final extendedRaw = json['extended'];
    Map<String, dynamic>? extended;

    if (extendedRaw is List &&
        extendedRaw.isNotEmpty &&
        extendedRaw.first is Map) {
      extended = Map<String, dynamic>.from(extendedRaw.first as Map);
    } else if (extendedRaw is Map) {
      extended = Map<String, dynamic>.from(extendedRaw as Map);
    }

    return GemModel(
      name: json['name']?.toString() ?? '',
      gem: json['gem']?.toString() ?? '',
      otherName: json['other_name']?.toString() ?? '',
      planet: json['planet']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      goodResults:
          (json['good_results'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      diseasesCure:
          (json['diseases_cure'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      substitute:
          (json['substitute'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      notToWearWith: (json['not_to_wear_with'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      finger: json['finger']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      metal: json['metal']?.toString() ?? '',
      timeToWearShort: json['time_to_wear_short']?.toString() ?? '',
      timeToWear: json['time_to_wear']?.toString() ?? '',
      methods: json['methods']?.toString() ?? '',
      mantra: json['mantra']?.toString() ?? '',
      lifeStone:
          (extended?['life_stone'] ?? extended?['lifeStone'])?.toString() ??
              'N/A',
      luckyStone:
          (extended?['lucky_stone'] ?? extended?['luckyStone'])?.toString() ??
              'N/A',
      fortuneStone: (extended?['fortune_stone'] ?? extended?['fortuneStone'])
              ?.toString() ??
          'N/A',
      flawResults: (json['flaw_results'] as List?)
              ?.whereType<Map>()
              .map((e) => FlawResult.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }
}

class FlawResult {
  final String flawType;
  final String flawEffects;

  FlawResult({required this.flawType, required this.flawEffects});

  factory FlawResult.fromJson(Map<String, dynamic> json) {
    return FlawResult(
      flawType: json['flaw_type']?.toString() ?? '',
      flawEffects: json['flaw_effects']?.toString() ?? '',
    );
  }
}
