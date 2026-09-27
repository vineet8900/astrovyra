import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AddtoCartRemoveApiService {
  Future<void> addToCartRemoveApi(String itemid) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };

      Map<String, dynamic> body = {
        // 'user_token':apitoken,
        'item_id': itemid,
      };
      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}cart/remove'),
        headers: headers,
        body: json.encode(body),
      );
       
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        Fluttertoast.showToast(
          msg: data['message'],
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);

        
      }
    } catch (e) {
      
    }
    return null;
  }
}
