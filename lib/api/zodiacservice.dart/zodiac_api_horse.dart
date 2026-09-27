import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/horsescode/horsce.dart';
import 'package:http/http.dart' as http;

// Import your horoscope models here
// import 'package:your_app/models/horoscope_models.dart';

class HoroscopeApiService {
  // Headers for API requests
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Fetch detailed horoscope for a specific zodiac sign and timeframe
  Future<HoroscopeResponse?> fetchHoroscopeDetail({
    required int zodiacId,
    required String timeFrame,
  }) async {
    try {
      

      // Prepare request body
      final requestBody = {
        'zodiacId': zodiacId,
        'timeFrame': timeFrame,
      };

      

      // Make POST request
      final response = await http.post(
        Uri.parse('${CustomStyles.apiBaseUrl}/zodiac/detail'),
        headers: headers,
        body: jsonEncode(requestBody),
      );
 

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final horoscopeResponse = HoroscopeResponse.fromJson(jsonResponse);
 

        return horoscopeResponse;
      } else {
         
        return HoroscopeResponse(
          success: false,
          message:
              'API Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e, stackTrace) {
       
      return HoroscopeResponse(
        success: false,
        message: 'Network Error: $e',
      );
    }
  }

  /// Alternative method with timeout
  Future<HoroscopeResponse?> fetchHoroscopeDetailWithTimeout({
    required int zodiacId,
    required String timeFrame,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${CustomStyles.apiBaseUrl}/zodiac/detail'),
            headers: headers,
            body: jsonEncode({
              'zodiacId': zodiacId,
              'timeFrame': timeFrame,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return HoroscopeResponse.fromJson(jsonResponse);
      } else {
        return HoroscopeResponse(
          success: false,
          message: 'API Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return HoroscopeResponse(
        success: false,
        message: 'Error: $e',
      );
    }
  }
}
