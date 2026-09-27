  // To parse this JSON data, do
  //
  //     final productReviewsResponse = productReviewsResponseFromJson(jsonString);

  import 'dart:convert';

  // Helper function to easily parse the JSON string into your model
  ProductReviewsResponse productReviewsResponseFromJson(String str) => ProductReviewsResponse.fromJson(json.decode(str));

  // Main class representing the entire API response
  class ProductReviewsResponse {
      final bool success;
      final List<ReviewData> data;

      ProductReviewsResponse({
          required this.success,
          required this.data,
      });

      factory ProductReviewsResponse.fromJson(Map<String, dynamic> json) => ProductReviewsResponse(
          success: json["success"],
          // Safely parse the list of reviews
          data: List<ReviewData>.from(json["data"].map((x) => ReviewData.fromJson(x))),
      );
  }

  // Class representing a single review object from the "data" list
  class ReviewData {
      final String review;
      final int rating;
      final String date;
      final String userName;
      final String userImageUrl;

      ReviewData({
          required this.review,
          required this.rating,
          required this.date,
          required this.userName,
          required this.userImageUrl,
      });

      factory ReviewData.fromJson(Map<String, dynamic> json) => ReviewData(
          review: json["review"],
          rating: json["rating"],
          date: json["date"],
          // Maps the JSON key "user_name" to the Dart variable "userName"
          userName: json["user_name"],
          // Maps the JSON key "user_image_url" to the Dart variable "userImageUrl"
          userImageUrl: json["user_image_url"],
      );
  }