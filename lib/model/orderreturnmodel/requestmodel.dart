// To parse this JSON data, do
//
//     final orderRequestResponse = orderRequestResponseFromJson(jsonString);

import 'dart:convert';

// Helper function to decode the JSON string directly
OrderRequestResponse orderRequestResponseFromJson(String str) => OrderRequestResponse.fromJson(json.decode(str));

class OrderRequestResponse {
    final bool success;
    final String message;

    OrderRequestResponse({
        required this.success,
        required this.message,
    });

    factory OrderRequestResponse.fromJson(Map<String, dynamic> json) => OrderRequestResponse(
        success: json["success"] ?? false, // Default to false if null
        message: json["message"] ?? "An unknown error occurred.", // Default message
    );
}