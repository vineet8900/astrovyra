import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/scheduleapimodel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ConsultationScheduleLaterApi {
  Future<ScheduleLaterApiModel?> fetchschedulelaterapi(int id) async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
        'content-type': 'application/json',
      };
      final response = await http.post(
          Uri.parse('${CustomStyles.baseUrl}available-date'),
          headers: headers,
          body: jsonEncode({"id": id}));
      if (response.statusCode == 200) {
        var responsedata = jsonDecode(response.body);
        return ScheduleLaterApiModel.fromJson(responsedata);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch Schedule later api: ${response.statusCode}',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
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
