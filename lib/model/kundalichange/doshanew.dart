class DoshaResponse {
  final bool isPresent;
  final String botResponse;
  final List<String> remedies;
  final String? description;
  final List<String> factors;
  final List<String> aspects;
  final int score;
  final bool? isAnshik;
  final List<String> cancellationReasons;

  DoshaResponse({
    required this.isPresent,
    required this.botResponse,
    required this.remedies,
    required this.description,
    required this.factors,
    required this.aspects,
    required this.score,
    required this.isAnshik,
    required this.cancellationReasons,
  });

  factory DoshaResponse.fromJson(Map<String, dynamic> json) {
    final cancellation = json['cancellation'];
    final cancellationReasons =
        (cancellation is Map && cancellation['cancellationReason'] is List)
            ? List<String>.from(
                (cancellation['cancellationReason'] as List).map((e) => '$e'))
            : <String>[];

    return DoshaResponse(
      isPresent: (json['is_dosha_present'] ??
              json['manglik_by_mars'] ??
              json['shani_period_type'] ??
              json['is_dosha_present_mars_from_lagna'] ??
              false) ==
          true,
      botResponse: (json['bot_response'] ?? '').toString(),
      remedies: json['remedies'] is List
          ? List<String>.from((json['remedies'] as List).map((e) => '$e'))
          : <String>[],
      description: json['description']?.toString(),
      factors: json['factors'] is List
          ? List<String>.from((json['factors'] as List).map((e) => '$e'))
          : <String>[],
      aspects: json['aspects'] is List
          ? List<String>.from((json['aspects'] as List).map((e) => '$e'))
          : <String>[],
      score: int.tryParse('${json['score'] ?? 0}') ?? 0,
      isAnshik: json['is_anshik'] is bool ? json['is_anshik'] as bool : null,
      cancellationReasons: cancellationReasons,
    );
  }
}

class MangalAnalysisResponse {
  final Map<String, dynamic> factors;
  final bool isDoshaPresentMarsFromLagna;
  final bool isDoshaPresentMarsFromMoon;
  final bool isAnshik;
  final bool isDoshaPresent;
  final String botResponse;
  final int score;
  final CancellationData? cancellation;

  MangalAnalysisResponse({
    required this.factors,
    required this.isDoshaPresentMarsFromLagna,
    required this.isDoshaPresentMarsFromMoon,
    required this.isAnshik,
    required this.isDoshaPresent,
    required this.botResponse,
    required this.score,
    required this.cancellation,
  });

  factory MangalAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return MangalAnalysisResponse(
      factors: json['factors'] is Map
          ? Map<String, dynamic>.from(json['factors'] as Map)
          : <String, dynamic>{},
      isDoshaPresentMarsFromLagna:
          (json['is_dosha_present_mars_from_lagna'] ?? false) == true,
      isDoshaPresentMarsFromMoon:
          (json['is_dosha_present_mars_from_moon'] ?? false) == true,
      isAnshik: (json['is_anshik'] ?? false) == true,
      isDoshaPresent: (json['is_dosha_present'] ?? false) == true,
      botResponse: (json['bot_response'] ?? '').toString(),
      score: int.tryParse('${json['score'] ?? 0}') ?? 0,
      cancellation: json['cancellation'] is Map
          ? CancellationData.fromJson(
              Map<String, dynamic>.from(json['cancellation'] as Map),
            )
          : null,
    );
  }
}

class CancellationData {
  final double cancellationScore;
  final List<String> cancellationReason;

  CancellationData({
    required this.cancellationScore,
    required this.cancellationReason,
  });

  factory CancellationData.fromJson(Map<String, dynamic> json) {
    return CancellationData(
      cancellationScore: (json['cancellationScore'] as num?)?.toDouble() ?? 0,
      cancellationReason: json['cancellationReason'] is List
          ? List<String>.from(
              (json['cancellationReason'] as List).map((e) => '$e'),
            )
          : <String>[],
    );
  }
}
