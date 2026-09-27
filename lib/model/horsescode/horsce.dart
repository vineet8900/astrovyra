class HoroscopeResponse {
  final bool success;
  final HoroscopeData? data;
  final String? message;

  HoroscopeResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory HoroscopeResponse.fromJson(Map<String, dynamic> json) {
    return HoroscopeResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? HoroscopeData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }

  @override
  String toString() {
    return 'HoroscopeResponse(success: $success, data: $data, message: $message)';
  }
}

class HoroscopeData {
  final String date;
  final String timeFrame;
  final HoroscopePrediction prediction;
  final String comment;

  HoroscopeData({
    required this.date,
    required this.timeFrame,
    required this.prediction,
    required this.comment,
  });

  factory HoroscopeData.fromJson(Map<String, dynamic> json) {
    return HoroscopeData(
      date: json['date'] ?? '',
      timeFrame: json['timeFrame'] ?? '',
      prediction: HoroscopePrediction.fromJson(json['prediction'] ?? {}),
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'timeFrame': timeFrame,
      'prediction': prediction.toJson(),
      'comment': comment,
    };
  }

  @override
  String toString() {
    return 'HoroscopeData(date: $date, timeFrame: $timeFrame, prediction: $prediction, comment: $comment)';
  }
}

class HoroscopePrediction {
  final HoroscopeSection loveAndRelationships;
  final HoroscopeSection healthAndWellness;
  final HoroscopeSection careerAndEducation;
  final HoroscopeSection moneyAndFinances;
  final HoroscopeSection familyAndFriends;
  final HoroscopeSection totalScore;

  HoroscopePrediction({
    required this.loveAndRelationships,
    required this.healthAndWellness,
    required this.careerAndEducation,
    required this.moneyAndFinances,
    required this.familyAndFriends,
    required this.totalScore,
  });

  factory HoroscopePrediction.fromJson(Map<String, dynamic> json) {
    return HoroscopePrediction(
      loveAndRelationships: HoroscopeSection.fromJson(json['love_and_relationships'] ?? {}),
      healthAndWellness: HoroscopeSection.fromJson(json['health_and_wellness'] ?? {}),
      careerAndEducation: HoroscopeSection.fromJson(json['career_and_education'] ?? {}),
      moneyAndFinances: HoroscopeSection.fromJson(json['money_and_finances'] ?? {}),
      familyAndFriends: HoroscopeSection.fromJson(json['family_and_friends'] ?? {}),
      totalScore: HoroscopeSection.fromJson(json['total_score'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'love_and_relationships': loveAndRelationships.toJson(),
      'health_and_wellness': healthAndWellness.toJson(),
      'career_and_education': careerAndEducation.toJson(),
      'money_and_finances': moneyAndFinances.toJson(),
      'family_and_friends': familyAndFriends.toJson(),
      'total_score': totalScore.toJson(),
    };
  }

  // Helper method to get all sections as a list
  List<HoroscopeSection> getAllSections() {
    return [
      loveAndRelationships,
      healthAndWellness,
      careerAndEducation,
      moneyAndFinances,
      familyAndFriends,
      totalScore,
    ];
  }

  @override
  String toString() {
    return 'HoroscopePrediction(loveAndRelationships: $loveAndRelationships, healthAndWellness: $healthAndWellness, careerAndEducation: $careerAndEducation, moneyAndFinances: $moneyAndFinances, familyAndFriends: $familyAndFriends, totalScore: $totalScore)';
  }
}

class HoroscopeSection {
  final String name;
  final List<String> value;

  HoroscopeSection({
    required this.name,
    required this.value,
  });

  factory HoroscopeSection.fromJson(Map<String, dynamic> json) {
    return HoroscopeSection(
      name: json['name'] ?? '',
      value: json['value'] != null 
          ? List<String>.from(json['value'].map((x) => x.toString()))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }

  // Helper method to get combined text
  String getCombinedText() {
    return value.join(' ');
  }

  @override
  String toString() {
    return 'HoroscopeSection(name: $name, value: $value)';
  }
}