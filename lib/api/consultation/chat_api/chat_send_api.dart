import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ChatSendApiService {
  Future fetchsendapidata(String token, String msg, int consultation_id) async {
    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      Map<String, dynamic> body = {
        "message": msg,
        "consultation_id": consultation_id,
      };
      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/send-message'),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        var responsedata = jsonDecode(response.body);
        return responsedata;
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to Chat send',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      
    }
    return null;
  }
}
