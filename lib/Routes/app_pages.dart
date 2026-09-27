import 'package:astrokavach/controller/auth_controller/spalsh_controller.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/screen/auth/intro_screen.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/auth/register_screen.dart';
import 'package:astrokavach/screen/auth/splash_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

//import 'package:jyotish_setu/controllers/splash_controller.dart'; // Example
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        // Example of a simple binding
        Get.lazyPut<SplashController>(() => SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.intro,
      page: () => const IntroScreen(),
    ),
    GetPage(
      name: AppRoutes.bottom,
      page: () => BottomAppBarScreen(),
      binding: BindingsBuilder(() {
        // Example of a simple binding
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),

    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
    ),

    // GetPage(
    //   name: AppRoutes.horsescope,
    //   page: () => const Horsescopedetails(zodiacId: null,, timeframe: '',), // Dekha? Koi arguments nahi.
    // ),
    // Add more pages as needed
  ];
}

