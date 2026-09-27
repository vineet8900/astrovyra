import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class DeleteAddressApiService {
  Future<Map<String, dynamic>?> deleteaddressapi({
    required String token,
    required int addressId,
  }) async {
    try {
      Map<String, String> headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      Map<String, dynamic> body = {
        "id": addressId,
      };

      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/addresses-delete'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        String message = data['message'];
        message.isEmpty
            ? ''
            : Fluttertoast.showToast(
                msg: message,
                textColor: Colors.white,
                backgroundColor: Colors.green,
              );
        return data;
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);
        String message = data['message'];
        message.isEmpty
            ? ''
            : Fluttertoast.showToast(
                msg: message,
                textColor: Colors.white,
                backgroundColor: Colors.red,
              );
        return data;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }
}
