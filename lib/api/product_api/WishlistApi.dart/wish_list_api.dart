import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/WishlistModel.dart/wishlist_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

class UserDashboardWishListApiService {
  Future<UserDashboardWishlistModel?> getuserwishlistlistapi(
      String? apitoken) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $apitoken',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/wishlist'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
         
        return UserDashboardWishlistModel.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to Wish list',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      
    }
    return null;
  }
}
