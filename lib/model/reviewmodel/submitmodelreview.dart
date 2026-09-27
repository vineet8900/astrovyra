// lib/model/submit_review_model.dart

import 'dart:convert';

SubmitReviewResponse submitReviewResponseFromJson(String str) => SubmitReviewResponse.fromJson(json.decode(str));

String submitReviewResponseToJson(SubmitReviewResponse data) => json.encode(data.toJson());

class SubmitReviewResponse {
    final bool success;
    final String message;

    SubmitReviewResponse({
        required this.success,
        required this.message,
    });

    factory SubmitReviewResponse.fromJson(Map<String, dynamic> json) => SubmitReviewResponse(
        success: json["success"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
    };
}