import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/astro_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AstrologerDetailApiService {
  Future<AstroDetailModel?> fetchAstroDetails(
    String? slug,
  ) async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
        'content-type': 'application/json',
      };
      final response =
          await http.post(Uri.parse('${CustomStyles.baseUrl}astrologer/detail'),
              headers: headers,
              body: jsonEncode({
                "slug": slug,
                // "type":type
              }));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
       
        return AstroDetailModel.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch astrologer details: ${response.statusCode}',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
        return null;
      }
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
