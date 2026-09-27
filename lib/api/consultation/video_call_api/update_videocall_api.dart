import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/video_api_model/update_videcallmodel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class UpdateVideoApiService {
  Future<VideoLogModel?> updatevideoapidata(
      String token, int consultationid, String status) async {
    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      Map<String, dynamic> body = {
        "consultation_id": consultationid,
        "status": status
      };
      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/update-video-call-status'),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        var responsedata = jsonDecode(response.body);
        
        return VideoLogModel.fromJson(responsedata);
      } else {
        var responsedata = jsonDecode(response.body);
        
        Fluttertoast.showToast(
          msg: 'Failed to update video',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
     
    }
    return null;
  }
}
