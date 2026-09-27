import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/similar_product_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class SimilarproductApi {
  Future<SimilarProductModel?> getsimalarproductData(
      String? category, int? except) async {
    try {
      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}product/list'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({"category": category, "except": except}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        return SimilarProductModel.fromJson(jsonResponse);
      } else {
        // Fluttertoast.showToast(
        //   msg: 'Failed to fetch simailar product list: ${response.statusCode}',
        //   textColor: Colors.white,
        //   backgroundColor: Colors.red,
        // );
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
