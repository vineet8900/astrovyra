import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/chat_model/can_chat_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CanChatApiService {
  Future<CanChatModel?> canchatapidata(String token, int consultationid) async {
    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      final response = await http.post(
          Uri.parse('${CustomStyles.baseUrl}user/can-chat'),
          headers: headers,
          body: jsonEncode({"consultation_id": consultationid}));
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        return CanChatModel.fromJson(data);
      } 
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Check Your network connection',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
      
    }
    return null;
  }
}
