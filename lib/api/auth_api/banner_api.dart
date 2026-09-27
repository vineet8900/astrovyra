import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/banner_api_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class BannerApiService {
  Future<BannerApiModel?> getbannerApi(String type) async {
    try {
      Map<String, dynamic> body = {
        'type': type,
      };
      final response = await http
          .post(Uri.parse('${CustomStyles.baseUrl}banners'), body: body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        return BannerApiModel.fromJson(jsonResponse);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch banner list: ${response.statusCode}',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Check Your network connection',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );

      return null;
    }
  }
}
