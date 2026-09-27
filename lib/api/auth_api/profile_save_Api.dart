import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class UserDataSaveApiServices {
  Future<void> saveuserdata(
    BuildContext context,
    String apiToken,
    String name,
    dynamic gender,
    dynamic country,
    dynamic state,
    dynamic city,
    String image,
    String address,
    dynamic pincode,
    String birthDate,
    String birthTime,
    String birthPlace,

  ) async {
    final String apiUrl = '${CustomStyles.baseUrl}user/data/save';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $apiToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      'name': name,
      'gender_id': gender,
      'country_id': country,
      'state_id': state,
      'city_id': city,
      'image': image.isNotEmpty ? image : "",
      'address': address.trim(),
      'pincode': pincode.trim(),
       'birth_date': birthDate,
      'birth_time': birthTime,
      'birth_place': birthPlace,
    };

    

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

     

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        if (responseData.containsKey('data') && responseData['data'] != null) {
          String userDataJson = jsonEncode(responseData['data']);
          await prefs.setString('userdata', userDataJson);
        }

        Fluttertoast.showToast(
          msg: responseData['message'] ?? 'Data saved successfully',
          textColor: Colors.white,
          backgroundColor: Colors.green,
        );
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'] ?? 'Something went wrong',
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
  }
}
