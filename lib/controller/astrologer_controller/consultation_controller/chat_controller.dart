import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ChatController extends GetxController {
  var messages = <ChatMessage>[].obs;
  final TextEditingController inputController = TextEditingController();

  void sendMessage(String msg) {
    messages.add(ChatMessage(message: msg, isSender: true, time: _getTime()));
   
    Future.delayed(Duration(seconds: 1), () {
      messages.add(ChatMessage(
        message: "Namaste 🙏 As a Vedic Astrologer...",
        isSender: false,
        time: _getTime(),
      ));
    });
  }

  String _getTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    messages.add(ChatMessage(
    message: '''Hi,
Below are my details:
Date of Birth: 04/05/2000
Time of Birth: 04:05:45 PM
Place of Birth: Faridabad, Haryana
Gender: Male
Marital Status: Single
Occupation: Employee''',
    isSender: true,
    time: _getTime(),
  ));
  }
}
class ChatMessage {
  final String message;
  final bool isSender;
  final String time;

  ChatMessage({required this.message, required this.isSender, required this.time});
}