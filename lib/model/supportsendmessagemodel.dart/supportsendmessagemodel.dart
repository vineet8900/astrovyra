// support_message_model.dart file ke neeche yeh code add karein

import 'dart:convert';

import 'package:astrokavach/model/supportmessagemodel/supportmessagemodel.dart';

SubmitMessageResponse submitMessageResponseFromJson(String str) =>
    SubmitMessageResponse.fromJson(json.decode(str));

class SubmitMessageResponse {
  final bool success;
  final SubmitMessageData? data;

  SubmitMessageResponse({
    required this.success,
    this.data,
  });

  factory SubmitMessageResponse.fromJson(Map<String, dynamic> json) =>
      SubmitMessageResponse(
        success: json["success"],
        data: json["data"] != null
            ? SubmitMessageData.fromJson(json["data"])
            : null,
      );
}

class SubmitMessageData {
  final Message message; // Hum purana 'Message' model hi reuse kar rahe hain

  SubmitMessageData({
    required this.message,
  });

  factory SubmitMessageData.fromJson(Map<String, dynamic> json) =>
      SubmitMessageData(
        message: Message.fromJson(json["message"]),
      );
}
