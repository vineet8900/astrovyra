import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/user_dashboard_model/user_consultation_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class UserConsultingApiService {
  Future<UserConsultationModel?> getuserconsultingapidata(
      String token, String type) async {
    try {
      Map<String, String> headers = {
        "Authorization": "Bearer $token",
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/consultations'),
        headers: headers,
        body: jsonEncode({"type": type}),
      );
     

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        return UserConsultationModel.fromJson(jsonData);
      } else {
       
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error in API call: ${e.toString()}',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    }
    return null;
  }
}
