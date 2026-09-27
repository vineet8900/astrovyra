import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:astrokavach/Services/account_delete_watcher.dart';

/// AppInitializer handles all bootstrap operations before the UI is rendered.
/// This prevents [main.dart] from becoming a dumping ground for setup logic.
class AppInitializer {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Enforce App Orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // 2. Initialize Firebase
    await _initFirebase();

    // 3. Setup Background Services
    _initBackgroundServices();
  }

  static Future<void> _initFirebase() async {
    const firebaseOptions = FirebaseOptions(
      apiKey: "AIzaSyDnBPrJ3KcUEuOUcUog5_3q7AXe1w2IM2I",
      appId: "1:74328511373:android:f71ad8126d4f1dd3d363c4",
      messagingSenderId: "74328511373",
      projectId: "astrokavach-app",
    );

    if (Platform.isAndroid) {
      await Firebase.initializeApp(options: firebaseOptions);
    } else {
      await Firebase.initializeApp();
    }
  }

  static void _initBackgroundServices() {
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    
    // We can start non-context watchers here if they don't depend on UI
    // AccountDeleteWatcher.instance.start();
  }
}

/// Firebase background handler must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // It's best practice to re-initialize Firebase in the background isolate
  const firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyDnBPrJ3KcUEuOUcUog5_3q7AXe1w2IM2I",
    appId: "1:74328511373:android:f71ad8126d4f1dd3d363c4",
    messagingSenderId: "74328511373",
    projectId: "astrokavach-app",
  );
  
  if (Platform.isAndroid) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    await Firebase.initializeApp();
  }
}
