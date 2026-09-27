import 'dart:convert';

import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/privacy_policy_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class PrivacyPolicyApiService {
  Future<PrivacyPolicyResponse?> fetchPrivacyPolicy() async {
    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'content-type': 'application/json',
      };
      final uri = Uri.parse('${CustomStyles.baseUrl}astrologer/privacy-policy');
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(<String, dynamic>{}),
      );
      if (response.statusCode == 200) {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        return PrivacyPolicyResponse.fromJson(map);
      }
      Fluttertoast.showToast(
        msg: 'Failed: ${response.statusCode}',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
      return null;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Network issue',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
      return null;
    }
  }
}
