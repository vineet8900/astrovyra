import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/astro_list_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AstrologerApiService {
  Future<AstrologerListModel?> fetchAstrologers(
      String type,
      String mode,
      String searchname,
      List<dynamic> sortby,
      List<dynamic> experiences,
      List<dynamic> prices,
      List<dynamic> rating,
      List<dynamic> expertise,
      List<dynamic> language,
      String except,
      int pageindex,
      {required String sortBy}) async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
        'content-type': 'application/json',
      };
      final response = await http.post(
          Uri.parse('${CustomStyles.baseUrl}astrologer/list?page=$pageindex'),
          headers: headers,
          body: jsonEncode({
            "type": type,
            "mode": mode,
            "city": searchname,
            "experiences": experiences,
            "sort_by": sortby,
            "prices": prices,
            "ratings": rating,
            "services": expertise,
            "languages": language,
            "except": except,
          }));
     
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return AstrologerListModel.fromJson(data);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch Astrologers: ${response.statusCode}',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      
    }
    return null;
  }
}
