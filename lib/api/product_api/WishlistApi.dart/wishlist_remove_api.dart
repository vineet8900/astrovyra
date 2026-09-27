import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AddtoWishlistRemoveApiService {
  Future<void> addToWishlistRemoveApi(
      String? apitoken, String wishlistid) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $apitoken',
        'Content-Type': 'application/json',
      };

      Map<String, dynamic> body = {
        'wishlist_id': wishlistid,
      };
      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/wishlist/remove'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Fluttertoast.showToast(
        //     msg: 'Successfully wishlist removes',
        //     textColor: Colors.white,
        //     backgroundColor: Colors.red,
        //   );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to Add to wishlist removed',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
       
    }
    return null;
  }
}
