
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:astrokavach/api/auth_api/user_data_api.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/astro_detail_model.dart' hide Data;
import 'package:astrokavach/model/user_data_model.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/walletupdate.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hides raw URLs, HTML error pages, and common server dumps from API `message`
/// values before showing them in toasts or dialogs.
String userFacingApiToastMessage(
  dynamic rawMessage, {
  required bool isSuccessContext,
  String successFallback = 'Operation completed successfully.',
  String errorFallback = 'Something went wrong. Please try again.',
}) {
  final s = (rawMessage ?? '').toString().trim();
  if (s.isEmpty) {
    return isSuccessContext ? successFallback : errorFallback;
  }
  if (_apiMessageLooksUnsafeForUser(s)) {
    return isSuccessContext ? successFallback : errorFallback;
  }
  return s;
}

bool _apiMessageLooksUnsafeForUser(String s) {
  final lower = s.toLowerCase();
  if (lower.contains('http://') || lower.contains('https://')) return true;
  if (lower.contains('<!doctype') || lower.contains('<html')) return true;
  if (lower.contains('sqlstate') ||
      lower.contains('stack trace') ||
      lower.contains('fatal error') ||
      lower.contains('exception in')) {
    return true;
  }
  return false;
}

/// Ensures a guest cart token exists (12-digit) so add-to-cart and cart list work without login.
/// Returns the token to use for cart APIs.
Future<String?> ensureGuestToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('api_token');
  if (token == null || token.isEmpty) {
    const digits = '0123456789';
    final random = Random();
    token = List.generate(12, (_) => digits[random.nextInt(digits.length)]).join();
    await prefs.setString('api_token', token);
  }
  return token;
}

/// Returns true if user is not logged in or is guest (12-digit token).
Future<bool> isGuestUser() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  if (!isLoggedIn) return true;
  final token = prefs.getString('api_token');
  if (token == null || token.isEmpty) return true;
  if (token.length == 12 && int.tryParse(token) != null) return true;
  return false;
}

/// Notifier to refresh Home (user name, cart count) when user logs in. Increment after login success.
final ValueNotifier<int> refreshHomeAfterLoginNotifier = ValueNotifier<int>(0);

class ReusableFunction {
  UserDataModel? userDataModel;
  UserDataApi userDataApi = UserDataApi();

  Future<Map<String, dynamic>?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiToken = prefs.getString('api_token');

    if (apiToken != null) {
      userDataModel = await userDataApi.fetchUserData(apiToken);

      if (userDataModel != null && userDataModel!.success == true) {
        // ✅ Ab directly access kar sakte ho without type casting
        Data? userMap = userDataModel!.data;

        if (userMap != null) {
          Map<String, dynamic> converted = userMap.toJson();
          await saveUserDataToPrefs(converted);
          return converted;
        }
      }
    }
    return null;
  }


  Future<void> refreshUserDataFromServer(String apiToken) async {
    try {
      userDataModel = await userDataApi.fetchUserData(apiToken);

      if (userDataModel != null && userDataModel!.success == true) {
        // ✅ Directly access without casting
        Data? userMap = userDataModel!.data;

        if (userMap != null) {
          Map<String, dynamic> converted = userMap.toJson();
          await saveUserDataToPrefs(converted);

          WalletEventBus().updateWallet(converted);

          print(
              "✅ User data refreshed from server and broadcasted via EventBus!");
        }
      }
    } catch (e) {
      print("❌ Error refreshing user data from server: $e");
    }
  }

  
  Future<void> saveUserDataToPrefs(Map<String, dynamic>? userData) async {
    if (userData == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userDataString = jsonEncode(userData);

    await prefs.setString('userdata', userDataString);
    print("✅ New user data saved to SharedPreferences!");
  }


  Future<Map<String, dynamic>?> getUserDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userdata');

    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        Map<String, dynamic> userDataMap = jsonDecode(userDataString);
        return userDataMap;
      } catch (e) {
        print("Error decoding user data from prefs: $e");
        return null;
      }
    }
    return null;
  }

  void navigateIfNotLoggedIn(
      BuildContext context, Widget redirectScreen, String? apiToken,
      [Function(Map<String, dynamic>)? onReturnCallback]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenFromPrefs = prefs.getString('api_token');
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    String? finalToken = apiToken ?? tokenFromPrefs;

    print("Final API Token: $finalToken");

    if (!isLoggedIn ||
        finalToken == null ||
        finalToken.isEmpty ||
        finalToken.length == 12) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(redirectScreen: redirectScreen),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => redirectScreen,
        ),
      ).then((_) async {
        if (onReturnCallback != null) {
          var updatedUser = await getUserData();
          if (updatedUser != null) {
            onReturnCallback(updatedUser);
          }
        }
      });
    }
  }

  Widget loadingRow({String message = "Please wait..."}) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
            SizedBox(width: 20),
            Text(
              message,
              style: CustomStyles.black14600,
            ),
          ],
        ),
      ),
    );
  }
}
