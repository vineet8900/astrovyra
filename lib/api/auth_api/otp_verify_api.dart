import 'dart:convert';
import 'package:astrokavach/Services/Notification_service.dart';
import 'package:astrokavach/api/auth_api/user_data_api.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/otp_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

String _otpCaps(String s) =>
    s.replaceAll(RegExp(r'\botp\b', caseSensitive: false), 'OTP');

class LoginOTPService {
  UserDataApi userDataApi = UserDataApi();
  NotificationService notificationService = NotificationService();

  Future<OtpModel?> otpverify(BuildContext context, String otp, String phone,
      {Widget? redirectScreen}) async {
    String apiUrl = '${CustomStyles.apiBaseUrl}/otp/user/verify';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? guesttoken = prefs.getString('api_token');
      String? fcmToken = await notificationService.getDeviceToken();

      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      print("fcmtoken:$fcmToken");

      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'phone': phone,
          'otp': otp,
          if (guesttoken != null) 'api_token': guesttoken,
          'fcm_token': fcmToken,
        }),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        String? newToken = jsonResponse['data']?['token'];
        if (newToken != null) {
          await prefs.setString('api_token', newToken);
          await prefs.setBool('isLoggedIn', true);
          print('✅ API Token saved: $newToken');
        }

        final userDataResponse =
            await userDataApi.fetchUserData(newToken ?? '');
        if (userDataResponse != null && userDataResponse.success == true) {
          final userMap = userDataResponse.data?.toJson();
          if (userMap != null) {
            await prefs.setString('userdata', jsonEncode(userMap));
          }
        }
        Fluttertoast.showToast(
          msg: "Login Successfully",
          textColor: Colors.white,
          backgroundColor: Colors.green,
        );

        refreshHomeAfterLoginNotifier.value++;

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => redirectScreen ?? BottomAppBarScreen(),
            ),
          );
        }

        return OtpModel.fromJson(jsonResponse);
      } else {
        final responseData = jsonDecode(response.body);
        final dynamic m = responseData is Map
            ? responseData['message']
            : null;
        Fluttertoast.showToast(
          msg: _otpCaps(
              (m ?? 'OTP not matched. Please try again.').toString()),
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("catch ky h $e");
      Fluttertoast.showToast(
        msg: _otpCaps('$e'),
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    }

    return null;
  }
}
