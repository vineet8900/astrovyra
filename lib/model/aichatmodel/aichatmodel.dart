// lib/model/book_ai_consultation_model.dart

import 'dart:convert';

// Helper function to easily parse the JSON string
BookAiConsultationResponse bookAiConsultationResponseFromJson(String str) => BookAiConsultationResponse.fromJson(json.decode(str));

class BookAiConsultationResponse {
    final bool success;
    final String message;
    final int consultationId;

    BookAiConsultationResponse({
        required this.success,
        required this.message,
        required this.consultationId,
    });

    factory BookAiConsultationResponse.fromJson(Map<String, dynamic> json) => BookAiConsultationResponse(
        success: json["success"],
        message: json["message"],
        consultationId: json["consultation_id"],
    );
}