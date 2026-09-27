// controllers/notification_controller.dart
import 'package:get/get.dart';

class NotificationController extends GetxController {
 
  RxList<String> notificationList = <String>[
    'Special transit alert: Find out how planetary movements might affect you today.',
    'New message from your astrologer.',
    'Reminder: Your consultation is scheduled for tomorrow.',
    'Special discount on readings this week.',
    'Astrology seminar invitation.',
    'Weekly horoscope is now available.',
    'Your feedback is appreciated!',
    'Monthly subscription renewal reminder.',
    'Special transit alert: Find out how planetary movements might affect you today.',
    'New message from your astrologer.',
    'Reminder: Your consultation is scheduled for tomorrow.',
    'Special discount on readings this week.',
    'Astrology seminar invitation.',
    'Weekly horoscope is now available.',
    'Your feedback is appreciated!',
    'Monthly subscription renewal reminder.'
  ].obs;

  void deleteNotification(int index) {
    notificationList.removeAt(index);
  }

  void clearAll() {
    notificationList.clear();
  }
}
