import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:astrokavach/screen/auth/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:shimmer/main.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //for notification request
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
     
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      
    } else {
      Get.snackbar(
        "Notification permission denied",
        "please allow notification to receive updates",
        snackPosition: SnackPosition.BOTTOM,
      );
      Future.delayed(const Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  Future<String> getDeviceToken() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    String? token = await messaging.getToken();
   
    return token!;
  }

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitSetting =
        const AndroidInitializationSettings("@mipmap/ic_launcher");

    var iosInitSetting = const DarwinInitializationSettings();

    var initialaizationSetting = InitializationSettings(
      android: androidInitSetting,
      iOS: iosInitSetting,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initialaizationSetting,
      onDidReceiveNotificationResponse: (payload) {
        handleMessage(context, message);
      },
    );
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {
        
      }

      if (Platform.isIOS) {
        iosForgroundMessage();
      }
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        // handleMessage(context, message);
        ShowNotification(message);
      }
    });

    // Fixed the setupInteractMessage function
    setupInteractMessage(context);
  }

  //show notification
  Future<void> ShowNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: "channel Description",
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: channel.sound,
    );
    //ios
    // DarwinInitializationSettings darwinInitializationSettings = const DarwinInitializationSettings(
    //   defaultPresentAlert: true,
    //   defaultPresentBadge: true,
    //   defaultPresentSound: true,
    // );
    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
          payload: "My Data");
    });
  }

  // Fixed function - removed Future<Void> and made it proper async function
  Future<void> setupInteractMessage(BuildContext context) async {
    // Handle notification when app is in background and user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(context, message);
      // Handle the message when app is opened from notification
      if (kDebugMode) {
        
      }

      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null && message.data.isNotEmpty) {
          handleMessage(context, message);
        }
      });
      // Add your navigation logic here
      // Example: Navigate to specific screen based on message data
      // Get.to(() => SomeScreen(data: message.data));
    });

    // Handle notification when app is terminated and user taps on notification
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        
      }
      // Handle the initial message
      // Add your navigation logic here
    }
  }

  Future<void> handleMessage(
      BuildContext context, RemoteMessage message) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SplashScreen()));
  }

  Future<void> iosForgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
