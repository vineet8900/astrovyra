import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/chat_model/chat_log_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ChatLogApiSevice {
  Future<ChatLogModel?> fetchatloapidata(
      String token, int consultationid, int chatid, String status) async {
    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      Map<String, dynamic> body = {
        "consultation_id": consultationid,
        "chat_id": chatid,
        "status": status
      };
      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/chat-logs'),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        var responsedata = jsonDecode(response.body);

        return ChatLogModel.fromJson(responsedata);
      } 
    } catch (e) {
      
    }
    return null;
  }
}
