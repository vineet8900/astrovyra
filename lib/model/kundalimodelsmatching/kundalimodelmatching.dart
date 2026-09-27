
class KundaliMatchingResponse {
  final bool success;
  final KundaliMatchingData? data;

  KundaliMatchingResponse({required this.success, this.data});

  factory KundaliMatchingResponse.fromJson(Map<String, dynamic> json) {
    return KundaliMatchingResponse(
      success: json['suceess'] ?? false,
      data: json['data'] != null ? KundaliMatchingData.fromMap(json['data']) : null,
    );
  }
}


class KundaliMatchingData {
  final PersonDetails boy;
  final PersonDetails girl;
  final Score score;
  final dynamic botResponse; // dynamic
  
  final Map<String, GunaResult> gunas;

  KundaliMatchingData({
    required this.boy,
    required this.girl,
    required this.score,
    this.botResponse,
    required this.gunas,
  });

  factory KundaliMatchingData.fromMap(Map<String, dynamic> map) {
    final fixedKeys = ['boy', 'girl', 'score', 'bot_response'];
    final gunasMap = <String, GunaResult>{};
    
    map.forEach((key, value) {
      if (!fixedKeys.contains(key)) {
        gunasMap[key] = GunaResult.fromMap(value);
      }
    });

    return KundaliMatchingData(
      boy: PersonDetails.fromMap(map['boy']),
      girl: PersonDetails.fromMap(map['girl']),
      score: Score.fromMap(map['score']),
      botResponse: map['bot_response']['bot_response'],
      gunas: gunasMap,
    );
  }
}

class PersonDetails {
  final dynamic name;       // dynamic
  final dynamic datetime;   // dynamic
  final dynamic birthPlace; // dynamic
  final dynamic latitude;   // dynamic
  final dynamic longitude;  // dynamic
  final dynamic timezone;   // dynamic

  PersonDetails({
    this.name, 
    this.datetime, 
    this.birthPlace,
    this.latitude,
    this.longitude,
    this.timezone,
  });

  factory PersonDetails.fromMap(Map<String, dynamic> map) {
    return PersonDetails(
      name: map['name'],
      datetime: map['datetime'],
      birthPlace: map['birth_place'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timezone: map['timezone'],
    );
  }
}


class GunaResult {
  final dynamic guna;            // dynamic
  final dynamic boy;             // dynamic
  final dynamic girl;            // dynamic
  final dynamic maximumObtained; // dynamic
  final dynamic obtainedPoints;  // dynamic
  final dynamic description;     // dynamic

  GunaResult({
    this.guna,
    this.boy,
    this.girl,
    this.maximumObtained,
    this.obtainedPoints,
    this.description,
  });

  factory GunaResult.fromMap(Map<String, dynamic> map) {
    return GunaResult(
      guna: map['guna'],
      boy: map['boy'],
      girl: map['girl'],
      maximumObtained: map['maximum_obtained'],
      obtainedPoints: map['obtained_points'],
      description: map['description'],
    );
  }
}

class Score {
  final dynamic obtained; // dynamic
  final dynamic total;    // dynamic

  Score({this.obtained, this.total});

  factory Score.fromMap(Map<String, dynamic> map) {
    final scoreData = map['score'] ?? {};
    return Score(
      obtained: scoreData['obtained'],
      total: scoreData['total'],
    );
  }
}