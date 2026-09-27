
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cartlistmodel.dart';
import 'package:http/http.dart' as http;

class CartListApiService {
  /// [buyNow] 1 = fetch buy-now cart only (separate cart), 0 or null = normal cart
  Future<CartListModel?> getCartlistapi(String? apitoken, int itemType,
      {bool showErrorToast = true, int buyNow = 0}) async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      Map<String, dynamic> body = {
        'api_token': apitoken,
        'item_type': itemType,
      };
      if (buyNow == 1) {
        body['buy_now'] = 1;
      }
      String jsonBody = jsonEncode(body);

      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}cart/list'),
        headers: headers,
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print("CartList Response for item_type: $itemType -> ${response.body}");
        return CartListModel.fromJson(data);
      } else {
        print(
            "Failed to fetch cart list: Status ${response.statusCode}, Response: ${response.body}");
        if (showErrorToast) {
          Fluttertoast.showToast(
            msg: 'Failed to fetch cart',
            textColor: Colors.white,
            backgroundColor: Colors.red,
          );
        }
        return null;
      }
    } catch (e) {
      // print("Error fetching cart list: $e");
      // Fluttertoast.showToast(
      //   msg: 'An error occurred: $e',
      //   textColor: Colors.white,
      //   backgroundColor: Colors.red,
      // );
      return null;
    }
  }

  /// Buy-now cart clear karta hai jab user checkout se back aata hai bina order place kiye.
  Future<void> clearBuyNowCart(String? apitoken) async {
    if (apitoken == null || apitoken.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}cart/clear'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'api_token': apitoken, 'buy_now': 1}),
      );
      if (response.statusCode == 200) {
        print('Buy-now cart cleared');
      }
    } catch (e) {
      print('clearBuyNowCart error: $e');
    }
  }
}

// import 'dart:convert';
// import 'package:astrokavach/custom_widgets/styles.dart';
// import 'package:astrokavach/model/Product_Api_Model/AddToCartModel.dart/cartlistmodel.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;

// class CartListApiService {
//   Future<CartListModel?> getCartlistapi(String? apitoken, int itemType) async {
//     try {
//       Map<String, String> headers = {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//       };
//       Map<String, dynamic> body = {
//         'api_token': apitoken,
//         'item_type': itemType,
//       };
//       String jsonBody = jsonEncode(body);

//       final response = await http.post(
//         Uri.parse('${CustomStyles.baseUrl}cart/list'),
//         headers: headers,
//         body: jsonBody,
//       );

//       if (response.statusCode == 200) {
//         Map<String, dynamic> data = jsonDecode(response.body);
        
//         return CartListModel.fromJson(data);
//       } else {
        
//         Fluttertoast.showToast(
//           msg: 'Failed to fetch cart',
//           textColor: Colors.white,
//           backgroundColor: Colors.red,
//         );
//         return null;
//       }
//     } catch (e) {
       
//       return null;
//     }
//   }
// }
