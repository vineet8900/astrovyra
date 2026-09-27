import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/chat_model/rechargepaynow_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class RechargePaynowApiService {
  Future<RechargePayNowModel?> fetchrechargepaynowapidata(
      String token, int planid, String coupcode) async {
    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      Map<String, dynamic> body = {
        "plan_id": planid,
        "coupon_code": coupcode,
      };
      
      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/recharge'),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        var responsedata = jsonDecode(response.body);
        return RechargePayNowModel.fromJson(responsedata);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to Recharge Payment Now',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
     
    }
    return null;
  }
}
