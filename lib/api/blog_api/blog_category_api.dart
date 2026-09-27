import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/blog_model/blog_category_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class BlogCategoryApi {
  Future<BlogCategoryModel?> fetchBlogApi() async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
        'content-type': 'application/json',
      };
      final response = await http.post(
          Uri.parse('${CustomStyles.baseUrl}blog/categories'),
          headers: headers);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return BlogCategoryModel.fromJson(data);
      } else {
// Fluttertoast.showToast(
//           msg: 'Failed to fetch Blog category: ${response.statusCode}',
//           textColor: Colors.white,
//           backgroundColor: Colors.red,
//         );
      }
    } catch (e) {
      
    }
    return null;
  }
}
