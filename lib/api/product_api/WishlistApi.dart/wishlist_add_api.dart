import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/WishlistModel.dart/addtowishlist_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AddtoWishlistApiService {
  Future<AddtoWishlistModel?> addToWishlistApi(
    String? apitoken,
    String? slug,
    String? action,
  ) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $apitoken',
        'Content-Type': 'application/json',
      };
      Map<String, dynamic> body = {
        'slug': slug,
        'action': action,
      };
       
      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/wishlist/add'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: data['message'],
          textColor: Colors.white,
          backgroundColor: Colors.green,
        );
        return AddtoWishlistModel.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to Add to Wishlist Item',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      
    }
    return null;
  }
}
