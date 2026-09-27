import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/user_dashboard_model/user_wallet_history_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class WalletHistoryApiService {
  Future<WalletHistoryModel?> fetchwallethistryapidata(
      BuildContext? context, String apiToken, dynamic pageindex) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $apiToken',
        'Accept': 'application/json',
        'content-type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(
            '${CustomStyles.baseUrl}user/recharge-histories?page=$pageindex'),
        headers: headers,
      );

     

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return WalletHistoryModel.fromJson(data);
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);
        String message = data['message'];
        message.isEmpty
            ? ''
            : Fluttertoast.showToast(
                msg: message,
                textColor: Colors.white,
                backgroundColor: Colors.green,
              );
      }
    } catch (e) {
    
    }
    return null;
  }
}
