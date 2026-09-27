import 'dart:convert';

import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/suggested_remedies_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SuggestedRemediesApi {
  static String get _url =>
      '${CustomStyles.apiBaseUrl}/user/suggested-remidies';

  static Future<SuggestedRemediesResponse?> fetchList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    if (token == null || token.isEmpty) {
      Fluttertoast.showToast(msg: 'Please log in to view suggested remedies.');
      return null;
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final map = json.decode(response.body) as Map<String, dynamic>;
        return SuggestedRemediesResponse.fromJson(map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
