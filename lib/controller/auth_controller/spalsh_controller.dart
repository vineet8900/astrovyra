import 'package:astrokavach/screen/astrologer/home_screen.dart';
import 'package:astrokavach/screen/auth/intro_screen.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    isLoggedIn();
  }

  void isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiToken = prefs.getString('api_token');

    await Future.delayed(Duration(seconds: 2));

    if (apiToken != null && apiToken.isNotEmpty) {
      Get.offAll(() => HomeScreen());
    } else {
      Get.offAll(() => IntroScreen());
    }
  }
}
