import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/payment_model/checkput_order_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CheckoutCouponcodeApi {
  Future<CheckoutOrderSummaryApiModel?> fetchvheckoutCouponcodeApi(
      BuildContext context,
      String apitoken,
      dynamic page,
      dynamic couponcode,
      int id) async {
    String apiUrl = '${CustomStyles.baseUrl}users/coupon';

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
          'page': page,
          'coupon_code': couponcode,
          'plan_id': id,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        return CheckoutOrderSummaryApiModel.fromJson(data);
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
   
      return null;
    }
  }
}
