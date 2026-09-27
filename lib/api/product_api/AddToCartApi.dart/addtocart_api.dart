import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/addtocart_model.dart';
import 'package:http/http.dart' as http;

class AddtoCartApiService {
  /// [buyNow] 1 = add to buy-now cart (separate cart), 0 or null = normal cart
  Future<AddtoCartModel?> addToCartApi(
    String? apitoken,
    int? id,
    String? type,
    List<Map<String, String>>? formData, {
    int buyNow = 0,
  }) async {
    if (formData != null && formData.isNotEmpty) {
      for (int i = 0; i < formData.length; i++) {}
    } else {}

    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        'api_token': apitoken,
        'item_id': id,
        'type': type,
      };
      print("addto$body");
      if (buyNow == 1) {
        body['buy_now'] = 1;
      }

      if (formData != null && formData.isNotEmpty) {
        body['form_data'] = formData;
      }

      String finalJsonBody = jsonEncode(body);

      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}cart/add'),
        headers: headers,
        body: finalJsonBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (type != 'service') {
          Fluttertoast.showToast(
            msg: userFacingApiToastMessage(
              data['message'],
              isSuccessContext: true,
              successFallback: 'Added to cart successfully!',
            ),
            textColor: Colors.white,
            backgroundColor: Colors.green,
          );
        }

        return AddtoCartModel.fromJson(data);
      } else {
        print("\n❌ ADD TO CART FAILED");
        print("❌ STATUS CODE: ${response.statusCode}");
        print("❌ RESPONSE: ${response.body}");
      }
    } catch (e, stacktrace) {}

    return null;
  }
}
