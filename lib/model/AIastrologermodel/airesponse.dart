// To parse this JSON data, do
//
//     final sendMessageAiResponse = sendMessageAiResponseFromJson(jsonString);

import 'dart:convert';

SendMessageAiResponse sendMessageAiResponseFromJson(String str) => SendMessageAiResponse.fromJson(json.decode(str));

String sendMessageAiResponseToJson(SendMessageAiResponse data) => json.encode(data.toJson());

class SendMessageAiResponse {
    final bool success;
    final String message;
    final AiMessageResponse response;

    SendMessageAiResponse({
        required this.success,
        required this.message,
        required this.response,
    });

    factory SendMessageAiResponse.fromJson(Map<String, dynamic> json) => SendMessageAiResponse(
        success: json["success"],
        message: json["message"],
        response: AiMessageResponse.fromJson(json["response"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "response": response.toJson(),
    };
}

class AiMessageResponse {
    final String messageBy;
    final String message;
    final String createdAt;

    AiMessageResponse({
        required this.messageBy,
        required this.message,
        required this.createdAt,
    });

    factory AiMessageResponse.fromJson(Map<String, dynamic> json) => AiMessageResponse(
        messageBy: json["message_by"],
        message: json["message"],
        createdAt: json["created_at"],
    );

    Map<String, dynamic> toJson() => {
        "message_by": messageBy,
        "message": message,
        "created_at": createdAt,
    };
}