import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/screen/auth/otp_screen.dart';
import 'package:astrokavach/screen/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

String _otpCaps(String s) =>
    s.replaceAll(RegExp(r'\botp\b', caseSensitive: false), 'OTP');

class LoginApiServices {
  void _goRegister(BuildContext context) {
    Fluttertoast.showToast(
      msg:
          'Please register first with your mobile number, then you can sign in.',
      textColor: Colors.white,
      backgroundColor: Colors.deepOrange,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final nav = Navigator.maybeOf(context) ??
          Navigator.of(context, rootNavigator: true);
      nav.pushReplacement(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    });
  }

  bool _shouldOfferRegister(int statusCode, Map<String, dynamic> data) {
    if (statusCode == 404) return true;

    final blob = jsonEncode(data).toLowerCase();
    const keys = [
      'not registered',
      'not found',
      'does not exist',
      'do not exist',
      'no user',
      'user not found',
      'account not',
      'please register',
      'register first',
      'invalid user',
      'unknown user',
      'unregistered',
      'no record',
      'not associated',
      'exist in our',
      'no account',
      'must register',
      'not exist',
      "can't find",
      'could not find',
      'cannot find',
      'credentials do not match',
      'not recognised',
      'no match',
      'not in our',
      'mobile number is not',
      'query results for model',
      'no query results',
    ];
    for (final k in keys) {
      if (blob.contains(k)) return true;
    }

    if (statusCode == 422) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final errStr = jsonEncode(errors).toLowerCase();
        if (errStr.contains('not registered') ||
            errStr.contains('not found') ||
            errStr.contains('does not exist') ||
            errStr.contains('no user') ||
            errStr.contains('please register')) {
          return true;
        }
      }
      final topMsg = (data['message'] ?? '').toString().toLowerCase();
      if (topMsg.contains('given data was invalid') &&
          errors is Map &&
          (errors.containsKey('phone') || errors.containsKey('mobile'))) {
        return true;
      }
    }

    if (statusCode >= 200 && statusCode < 300 && data['success'] == false) {
      if (data['registered'] == false ||
          data['exists'] == false ||
          data['user_exists'] == false) {
        return true;
      }
      for (final k in keys) {
        if (blob.contains(k)) return true;
      }
      final msg = (data['message'] ?? '').toString().toLowerCase();
      if (msg.contains('throttle') ||
          msg.contains('too many') ||
          msg.contains('try again later')) {
        return false;
      }
      if (msg.contains('otp') &&
          (msg.contains('sent') || msg.contains('send successfully'))) {
        return false;
      }
      return false;
    }

    final errField = data['error']?.toString().toLowerCase() ?? '';
    if (errField.contains('not_found') ||
        errField.contains('no_user') ||
        errField.contains('unregistered')) {
      return true;
    }

    return false;
  }

  Future loginUser(
      BuildContext context, String phone, Widget? redirectScreen) async {
    String apiUrl = '${CustomStyles.baseUrl}otp/user';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
        body: {'phone': phone},
      );

      final trimmed = response.body.trimLeft();
      if (trimmed.startsWith('<')) {
        _goRegister(context);
        return;
      }

      final Map<String, dynamic> responseData;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        } else if (decoded is Map) {
          responseData = Map<String, dynamic>.from(decoded);
        } else {
          Fluttertoast.showToast(
            msg: 'Something went wrong. Please try again.',
            textColor: Colors.white,
            backgroundColor: Colors.red,
          );
          return;
        }
      } on FormatException {
        _goRegister(context);
        return;
      }

      if (_shouldOfferRegister(response.statusCode, responseData)) {
        _goRegister(context);
        return;
      }

      if (response.statusCode == 200) {
        if (responseData['success'] == false) {
          Fluttertoast.showToast(
            msg: _otpCaps(responseData['message']?.toString() ??
                'Unable to send OTP. Try again.'),
            textColor: Colors.white,
            backgroundColor: Colors.red,
          );
          return;
        }
        Fluttertoast.showToast(
          msg: _otpCaps(
              responseData['message']?.toString() ?? 'OTP sent successfully'),
          textColor: Colors.white,
          backgroundColor: Colors.green,
        );

        Future.delayed(Duration(milliseconds: 100), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  boolotp: true,
                  redirectScreen: redirectScreen,
                ),
              ),
            );
          }
        });
        return;
      }

      if (response.statusCode == 422) {
        final m = responseData['message'];
        Fluttertoast.showToast(
          msg: _otpCaps((m ?? 'Request could not be completed').toString()),
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
        return;
      }

      Fluttertoast.showToast(
        msg: 'Failed to Login: ${response.statusCode}',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }
}
