import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class SubmitAddressApiService {
  Future<Map<String, dynamic>?> submitAddress({
    required String token,
    required dynamic addressId,
    required String fullName,
    required String email,
    required String phone,
    required dynamic countryId,
    required dynamic stateId,
    required dynamic cityId,
    required dynamic zipcode,
    required String address,
    String? landmark,
  }) async {
    try {
      Map<String, String> headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      Map<String, dynamic> body = {
        "id": addressId,
        "name": fullName,
        "email": email,
        "phone": phone,
        "country_id": countryId,
        "state_id": stateId,
        "city_id": cityId,
        "zipcode": zipcode,
        "address": address,
      };
      if (landmark != null && landmark.trim().isNotEmpty) {
        body["landmark"] = landmark.trim();
      }
      print("user1$body");

      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/addresses-submit'),
        headers: headers,
        body: jsonEncode(body),
      );
      print(response.body);

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
      debugPrint("Exception: $e");
    }
  }
}
