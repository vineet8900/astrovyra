class LocationSearchRequest {
  final String searchPlace;

  LocationSearchRequest({required this.searchPlace});

  Map<String, dynamic> toJson() {
    return {
      'searchPlace': searchPlace,
    };
  }
}

class LocationSearchResponse {
  final bool success;
  final List<LocationData> data;

  LocationSearchResponse({
    required this.success,
    required this.data,
  });

  factory LocationSearchResponse.fromJson(Map<String, dynamic> json) {
    return LocationSearchResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => LocationData.fromJson(item))
          .toList() ?? [],
    );
  }
}

class LocationData {
  final String name;
  final String fullName;

  LocationData({
    required this.name,
    required this.fullName,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'full_name': fullName,
    };
  }
}