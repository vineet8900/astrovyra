import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/Product_Api_Model/product_category_api_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ProductCategoryApiService {
  Future<ProductCategoryModel?> fetchproductcategory(
      {required String type}) async {
    try {
      // Headers for the request
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      Map<String, String> body = {
        'type': type
      };

      // Making the POST request with headers and body
      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}product/categories'),
        headers: headers,
        body: jsonEncode(body), // Encode the body to a JSON string
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return ProductCategoryModel.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg:
              'Failed to fetch product category. Status Code: ${response.statusCode}',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
       
    }
    return null;
  }
}
