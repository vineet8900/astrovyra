import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/AddressModel/address_api_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;


class AddressApiService {
  Future<AddressApiModel?> getaddressapidata(
    String token,
  ) async {
    try {
      Map<String, String> headers = {
        "Authorization": "Bearer $token",
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/addresses'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        return AddressApiModel.fromJson(jsonData);
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
