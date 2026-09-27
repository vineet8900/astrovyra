import 'dart:convert';

import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/user_data_model.dart';
import 'package:http/http.dart' as http;

class UserDataApi {
  Future<UserDataModel> fetchUserData(String apiToken) async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $apiToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final response = await http
        .post(Uri.parse('${CustomStyles.baseUrl}user/data'), headers: headers);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
     
      return UserDataModel.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
