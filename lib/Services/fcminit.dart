import 'dart:io';
import 'package:flutter/material.dart';
import 'package:astrokavach/Services/Fcm_service.dart';
import 'package:astrokavach/Services/Notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class FcmInitService {
  static final NotificationService _notificationService = NotificationService();

  static void init(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () async {
        await _requestPermission();
        _notificationService.firebaseInit(context);
        _notificationService.setupInteractMessage(context);
        _notificationService.getDeviceToken().then((token) {
          print("FCM Token: $token");
        });
        FcmService.firebaseInit();
      });
    });
  }

  static Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Future.delayed(const Duration(seconds: 1));
        final result = await Permission.notification.request();
        if (result.isPermanentlyDenied) {
          openAppSettings();
        }
      }

      if (await Permission.systemAlertWindow.isDenied) {
        await Permission.systemAlertWindow.request();
      }
    }

    _notificationService.requestNotificationPermission();
  }
}
