import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/payment_model/checkput_order_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CheckoutOrderSummaryApi {
  Future<CheckoutOrderSummaryApiModel?> fetchchekoutorderdata(
    BuildContext context,
    String apitoken,
    dynamic action,
    dynamic itemslug,
  ) async {
    String apiUrl = '${CustomStyles.baseUrl}users/checkout';

    Map<String, String> headers = {
      'Authorization': 'Bearer $apitoken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(
            {'api_token': apitoken, 'action': action, 'item_slug': itemslug}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
         
        return CheckoutOrderSummaryApiModel.fromJson(data);
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        
        return responseData;
      } else {
         
        return null;
      }
    } catch (e) {
       
      return null;
    }
  }
}
