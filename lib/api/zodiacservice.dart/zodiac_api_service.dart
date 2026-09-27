// zodiac_api_service.dart
import 'dart:convert';
import 'package:astrokavach/controller/zodiac/zodiacmodel.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

// Import your zodiac model here
// import 'zodiac_model.dart';

class ZodiacApiService {
  Future<ZodiacListResponse?> fetchZodiacSigns(
      {String timeframe = "today"}) async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('${CustomStyles.apiBaseUrl}/zodiac/list'),
        headers: headers,
        body: jsonEncode({
          "timeframe": timeframe, // today, weekly, yearly
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        return ZodiacListResponse.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch zodiac signs',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
