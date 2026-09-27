import 'dart:convert';
import 'package:astrokavach/controller/panchang/panchang.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:http/http.dart' as http;

class PanchangService {
  static Future<PanchangResponse> fetchPanchang(String date) async {
    try {
      final response = await http.post(
        Uri.parse('${CustomStyles.apiBaseUrl}/panchang/detail'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'date': date}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PanchangResponse.fromJson(jsonData);
      } else {
        throw Exception('Server error panchn: ${response.statusCode}');
      }
    } catch (e) {
      
      throw Exception('Failed to fetch panchang data: $e');
    }
  }
}
