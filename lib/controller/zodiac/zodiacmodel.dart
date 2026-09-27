// zodiac_model.dart
class ZodiacListResponse {
  final bool success;
  final List<ZodiacSign> data;

  ZodiacListResponse({
    required this.success,
    required this.data,
  });

  factory ZodiacListResponse.fromJson(Map<String, dynamic> json) {
    return ZodiacListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ZodiacSign.fromJson(item))
          .toList() ?? [],
    );
  }
}

class ZodiacSign {
  /// `zodiacId` used by `/zodiac/detail`.
  ///
  /// New `/zodiac/list` response may not include an id, so we derive it from
  /// the zodiac name when missing.
  final int id;
  final String name;
  /// Image url (API may send `image` or legacy `url`).
  final String imageUrl;

  ZodiacSign({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ZodiacSign.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString();
    return ZodiacSign(
      id: (json['id'] is int ? json['id'] as int : null) ??
          _idFromName(name) ??
          0,
      name: name,
      imageUrl: (json['image'] ?? json['url'] ?? '').toString(),
    );
  }

  /// Backward compatibility for older code using `sign.url`.
  String get url => imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': imageUrl,
      'image': imageUrl,
    };
  }

  static int? _idFromName(String rawName) {
    final n = rawName.trim().toLowerCase();
    switch (n) {
      case 'aries':
        return 1;
      case 'taurus':
        return 2;
      case 'gemini':
        return 3;
      case 'cancer':
        return 4;
      case 'leo':
        return 5;
      case 'virgo':
        return 6;
      case 'libra':
        return 7;
      case 'scorpio':
        return 8;
      case 'sagittarius':
        return 9;
      case 'capricorn':
        return 10;
      case 'aquarius':
        return 11;
      case 'pisces':
        return 12;
      default:
        return null;
    }
  }
}