class KundaliCreateResponse {
  final bool success;
  final String? message;
  final int? kundaliId;
  final String? redirectTo;

  KundaliCreateResponse({
    required this.success,
    required this.message,
    required this.kundaliId,
    required this.redirectTo,
  });

  factory KundaliCreateResponse.failure(String message, {int? httpStatus}) {
    return KundaliCreateResponse(
      success: false,
      message: httpStatus != null ? '$message (HTTP $httpStatus)' : message,
      kundaliId: null,
      redirectTo: null,
    );
  }

  static String? extractErrorMessage(Map<String, dynamic> json) {
    final m = json['message'];
    if (m is String && m.trim().isNotEmpty) return m.trim();
    final errors = json['errors'];
    if (errors is Map) {
      final parts = <String>[];
      errors.forEach((k, v) {
        if (v is List && v.isNotEmpty) {
          parts.add('$k: ${v.first}');
        } else if (v is String) {
          parts.add('$k: $v');
        }
      });
      if (parts.isNotEmpty) return parts.join('\n');
    }
    if (json['error'] != null) return json['error'].toString();
    return null;
  }

  factory KundaliCreateResponse.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    int? idFromData;
    if (data is int) {
      idFromData = data;
    } else if (data is Map<String, dynamic>) {
      final raw = data['kundali_id'] ?? data['id'] ?? data['kundaliId'];
      idFromData = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
    }

    final dynamic rawId = json['kundali_id'] ?? json['kundaliId'] ?? idFromData;
    final int? parsedId =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final dynamic rawSuccess = json['success'] ?? json['suceess'];

    return KundaliCreateResponse(
      success: rawSuccess == null ? (parsedId != null) : rawSuccess == true,
      message: (json['message'] ?? json['msg'])?.toString(),
      kundaliId: parsedId,
      redirectTo: (json['redirectTo'] ?? json['redirect_to'])?.toString(),
    );
  }
}
