import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:astrokavach/Routes/app_pages.dart';
import 'package:astrokavach/Routes/app_routes.dart';
import 'package:astrokavach/translationscrenn/app_translation.dart';
import 'package:astrokavach/Services/fcminit.dart';
import 'package:astrokavach/Services/account_delete_watcher.dart';

import 'package:astrokavach/core/init/app_initializer.dart';
import 'package:astrokavach/core/routes/app_router.dart';

void main() async {
  // 1. Initialize all core services (Firebase, Orientation, Background Handlers)
  await AppInitializer.init();

  // 2. Initialize legacy GetX translations manually to support old files without GetMaterialApp
  Get.addTranslations(AppTranslations().keys);
  Get.updateLocale(const Locale('en', 'US'));

  // 3. Run the App within Riverpod's ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Context-dependent initializations remain in the UI layer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FcmInitService.init(context);
      AccountDeleteWatcher.instance.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the GoRouter provider from our new routing system
    final router = ref.watch(goRouterProvider);

    // Using standard MaterialApp with GoRouter.
    // We are manually injecting translations below so that legacy .tr works without GetMaterialApp.
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Astrokavach app',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E4677),
          brightness: Brightness.light,
        ).copyWith(
          surface: Colors.white,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: Colors.white,
          surfaceContainer: const Color(0xFFF5F5F5),
          surfaceContainerHigh: const Color(0xFFEEEEEE),
          surfaceContainerHighest: const Color(0xFFE0E0E0),
        ),
        useMaterial3: true,
      ),
      // Using Riverpod + GoRouter handles navigation automatically
      routerConfig: router,
    );
  }
}
