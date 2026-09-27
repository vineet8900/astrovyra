import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/phonecallmodel/phonecall.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CanCallApiService {
  Future<CancallModel?> canvideoapidata(
      String token, int consultationid) async {
    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      final response = await http.post(
          Uri.parse('${CustomStyles.baseUrl}user/can-phone-call'),
          headers: headers,
          body: jsonEncode({"consultation_id": consultationid}));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        return CancallModel.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to call',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
     
    }
    return null;
  }
}
