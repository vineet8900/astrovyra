// To parse this JSON data, do
//
//     final sendLiveChatResponse = sendLiveChatResponseFromJson(jsonString);

import 'dart:convert';

// Helper function to parse a raw JSON string into the model
SendLiveChatResponse sendLiveChatResponseFromJson(String str) => SendLiveChatResponse.fromJson(json.decode(str));

// Helper function to convert the model into a JSON string
String sendLiveChatResponseToJson(SendLiveChatResponse data) => json.encode(data.toJson());

class SendLiveChatResponse {
    final bool success;
    final String message;

    SendLiveChatResponse({
        required this.success,
        required this.message,
    });

    factory SendLiveChatResponse.fromJson(Map<String, dynamic> json) => SendLiveChatResponse(
        success: json["success"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
    };
}