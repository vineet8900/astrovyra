import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/chat_model/recharge_wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class RechargeWalletApiService {
  Future<RechargeWalletModel?> fetchrechargeapidata(String token) async {
    try {
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      final response = await http.post(
          Uri.parse('${CustomStyles.baseUrl}user/recharge-plans'),
          headers: headers);
      if (response.statusCode == 200) {
        var responsedata = jsonDecode(response.body);
        return RechargeWalletModel.fromJson(responsedata);
      } else {
        // Fluttertoast.showToast(
        //   msg: 'Failed to fetch Recharge Wallet',
        //   textColor: Colors.white,
        //   backgroundColor: Colors.red,
        // );
      }
    } catch (e) {}
    return null;
  }
}
