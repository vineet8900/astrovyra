import 'dart:convert';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cart_decrease_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CartListDecreaseApiService {
  Future<CartDecreaseModel?> getCartDecreaseapi(
      String? apitoken, int itemid) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {"item_id": itemid};

      String jsonBody = jsonEncode(body);
      final response = await http.post(
          Uri.parse('${CustomStyles.baseUrl}cart/decrease'),
          headers: headers,
          body: jsonBody);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String message = (data['message'] ?? '').toString();
        if (message.isNotEmpty) {
          Fluttertoast.showToast(
            msg: userFacingApiToastMessage(
              message,
              isSuccessContext: true,
              successFallback: 'Updated successfully.',
            ),
            textColor: Colors.white,
            backgroundColor: Colors.green,
          );
        }
        return CartDecreaseModel.fromJson(data);
      } else if (response.statusCode == 402) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        String message = data['message'];
         

        return null;
      }
    } catch (e) {
      
    }
    return null;
  }
}
