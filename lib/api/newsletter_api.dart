import 'dart:convert';

import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/newsletter_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsletterApi {
  static String get _url => '${CustomStyles.apiBaseUrl}/user/newsletter';

  static Future<NewsletterResponse?> postEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    if (token == null || token.isEmpty) return null;

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: headers,
        body: jsonEncode({'email': email.trim()}),
      );

      final code = response.statusCode;
      if (code >= 200 && code < 300) {
        final raw = response.body.trim();
        if (raw.isEmpty) return null;
        final decoded = json.decode(raw);
        if (decoded is! Map<String, dynamic>) return null;
        return NewsletterResponse.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
