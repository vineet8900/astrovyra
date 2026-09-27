// lib/model/product_review_model.dart

import 'dart:convert';

// Helper function to parse the JSON string directly into the response model
ProductReviewResponse productReviewResponseFromJson(String str) => ProductReviewResponse.fromJson(json.decode(str));

class ProductReviewResponse {
    final bool success;
    final List<ProductReview> data;

    ProductReviewResponse({
        required this.success,
        required this.data,
    });

    factory ProductReviewResponse.fromJson(Map<String, dynamic> json) => ProductReviewResponse(
        success: json["success"] ?? false,
        data: json["data"] != null
            ? List<ProductReview>.from(json["data"].map((x) => ProductReview.fromJson(x)))
            : [],
    );
}

class ProductReview {
    final String? review;
    final double rating;
    final String? date;
    final String? userName;
    final String? userImageUrl;

    ProductReview({
        this.review,
        required this.rating,
        this.date,
        this.userName,
        this.userImageUrl,
    });

    factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
        review: json["review"],
        // Safely parse the rating as a double, defaulting to 0.0
        rating: (json["rating"] as num? ?? 0).toDouble(),
        date: json["date"],
        userName: json["user_name"],
        userImageUrl: json["user_image_url"],
    );
}