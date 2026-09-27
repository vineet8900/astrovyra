class KundaliBasicResponse {
  final String? name;
  final String? date;
  final String? time;
  final String? place;
  final String? latitude;
  final String? longitude;
  final String? timezone;
  final Map<String, dynamic> response;

  const KundaliBasicResponse({
    required this.name,
    required this.date,
    required this.time,
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.response,
  });

  factory KundaliBasicResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload =
        (json['data'] is Map<String, dynamic>) ? json['data'] : json;

    return KundaliBasicResponse(
      name: payload['name']?.toString(),
      date: payload['date']?.toString(),
      time: payload['time']?.toString(),
      place: payload['place']?.toString(),
      latitude: payload['latitude']?.toString(),
      longitude: payload['longitude']?.toString(),
      timezone: payload['timezone']?.toString(),
      response: (payload['response'] is Map<String, dynamic>)
          ? (payload['response'] as Map<String, dynamic>)
          : <String, dynamic>{},
    );
  }
}
