// lib/model/can_review_model.dart

import 'dart:convert';

CanReviewResponse canReviewResponseFromJson(String str) => CanReviewResponse.fromJson(json.decode(str));

String canReviewResponseToJson(CanReviewResponse data) => json.encode(data.toJson());

class CanReviewResponse {
    final bool success;
    final String message;

    CanReviewResponse({
        required this.success,
        required this.message,
    });

    factory CanReviewResponse.fromJson(Map<String, dynamic> json) => CanReviewResponse(
        success: json["success"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
    };
}