import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/youtubereview/youtubereview.dart';
import 'package:http/http.dart' as http;
// Import the model

class TextTestimonialService {
  static Future<TextTestimonialResponse> fetchTextTestimonials(
      {String? page}) async {
    try {
      final Map<String, dynamic> body = {};
      if (page != null) {
        body['page'] = page;
      }

      final response = await http.post(
        Uri.parse('${CustomStyles.apiBaseUrl}/testimonials/text'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return textTestimonialResponseFromJson(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
       
      throw Exception('Failed to fetch text testimonials: $e');
    }
  }
}
