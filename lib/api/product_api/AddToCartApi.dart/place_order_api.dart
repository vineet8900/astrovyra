import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/payment_model/place_order_api_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PlaceOrderApi {
  Future<PlacerOrderApiModel?> fetchplaceorderdata(
      {required String apiToken,
      required int addressid,
      required String couponcode}) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $apiToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      Map<String, dynamic> body = {
        "address_id": addressid,
        "coupon_code": couponcode
      };

      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}users/place-order'),
        headers: headers,
        body: jsonEncode(body),
      );

      

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('success')) {
          return PlacerOrderApiModel.fromJson(data);
        } else {
           
          return null;
        }
      } else {
       
        return null;
      }
    } catch (e) {
    
    }
    return null;
  }
}
