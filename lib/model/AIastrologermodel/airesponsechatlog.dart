// lib/model/ai_chat_model.dart

import 'dart:convert';

// Helper function to parse the main response
AiChatResponse aiChatResponseFromJson(String str) => AiChatResponse.fromJson(json.decode(str));

class AiChatResponse {
    final bool success;
    final List<ChatMessage> data;
    final String status;

    AiChatResponse({
        required this.success,
        required this.data,
        required this.status,
    });

    factory AiChatResponse.fromJson(Map<String, dynamic> json) => AiChatResponse(
        success: json["success"] ?? false,
        data: json["data"] != null 
            ? List<ChatMessage>.from(json["data"].map((x) => ChatMessage.fromJson(x))) 
            : [],
        status: json["status"] ?? "end", // Default to 'end' if status is missing
    );
}

class ChatMessage {
    final String messageBy;
    final String message;
    final String createdAt;

    ChatMessage({
        required this.messageBy,
        required this.message,
        required this.createdAt,
    });

    factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        messageBy: json["message_by"] ?? "astrologer",
        message: json["message"] ?? "",
        createdAt: json["created_at"] ?? "",
    );
}