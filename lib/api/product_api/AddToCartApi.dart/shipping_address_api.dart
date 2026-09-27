import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/payment_model/shipping_address_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ShippingAddressApi {
  Future<ShippingAddreesModel?> getstshippingaddressdata(
    BuildContext context,
    String apitoken,
  ) async {
    String apiUrl = '${CustomStyles.baseUrl}users/shipping-address';

    Map<String, String> headers = {
      'Authorization': 'Bearer $apitoken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({
          'api_token': apitoken,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
         
        return ShippingAddreesModel.fromJson(data);
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
         

        return responseData;
      } else {
        final responseData = jsonDecode(response.body);
        String errorMsg = responseData['message'] ?? '';

        Fluttertoast.showToast(
          msg: errorMsg,
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred: $e',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
       
      return null;
    }
    return null;
  }
}
