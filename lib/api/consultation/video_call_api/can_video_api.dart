import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/video_api_model/can_videocall_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CanVideoApiService {
  Future<CanVideoCallModel?> canvideoapidata(
      String token, int consultationid) async {
    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      final response = await http.post(
          Uri.parse('${CustomStyles.baseUrl}user/can-video-call'),
          headers: headers,
          body: jsonEncode({"consultation_id": consultationid}));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        return CanVideoCallModel.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to can video:',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
     
    }
    return null;
  }
}
