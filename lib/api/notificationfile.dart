import 'dart:convert';
//import 'package:astrokavach/model/notificationmodel/notificationmodel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:astrokavach/Services/notifationmodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrokavach/custom_widgets/styles.dart';


class NotificationApiService {
  static const String notificationsEndpoint =
      '${CustomStyles.apiBaseUrl}/user/notifications';

  
  static Future<NotificationResponse?> fetchNotifications(
      {int page = 1}) async {
  
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(
          msg: "Authentication token not found. Please log in.");
      return null;
    }

    // 2. Prepare Headers
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

  
    final Uri uri = Uri.parse(notificationsEndpoint).replace(queryParameters: {
      'page': page.toString(),
    });

    try {
  
      final response = await http.post(
        uri,
        headers: headers,
      );

      

      // 5. Process the Response
      if (response.statusCode == 200) {
        final notificationResponse =
            notificationResponseFromJson(response.body);

        if (notificationResponse.success) {
          return notificationResponse;
        } else {
          // API success false case
          // Fluttertoast.showToast(msg: notificationResponse.message);
          return null;
        }
      } else {
        // HTTP Error Handling
        // Fluttertoast.showToast(
        //     msg: 'Error fetching notifications: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Exception Handling
     
      return null;
    }
  }
}
