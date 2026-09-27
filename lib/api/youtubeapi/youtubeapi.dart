import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/videoyoutube/videoyoutube.dart';
import 'package:http/http.dart' as http;
// Import the model we just created

class VideoTestimonialService {
  static Future<VideoTestimonialResponse> fetchVideoTestimonials(
      {String? page}) async {
    try {
   
      final Map<String, dynamic> body = {};
      if (page != null) {
        body['page'] = page;
      }

      final response = await http.post(
        Uri.parse('${CustomStyles.apiBaseUrl}/testimonials/video'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Encode the body to JSON
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        return videoTestimonialResponseFromJson(response.body);
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any other errors (e.g., network issues)
       
      throw Exception('Failed to fetch video testimonials: $e');
    }
  }
}
