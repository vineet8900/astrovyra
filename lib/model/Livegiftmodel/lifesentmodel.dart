import 'dart:convert';

// Function to parse the JSON string into a SendGiftResponse object
SendGiftResponse sendGiftResponseFromJson(String str) => SendGiftResponse.fromJson(json.decode(str));

// Function to convert a SendGiftResponse object into a JSON string
String sendGiftResponseToJson(SendGiftResponse data) => json.encode(data.toJson());

class SendGiftResponse {
    final bool success;
    final String message;
    final int wallet;

    SendGiftResponse({
        required this.success,
        required this.message,
        required this.wallet,
    });

    factory SendGiftResponse.fromJson(Map<String, dynamic> json) => SendGiftResponse(
        success: json["success"],
        message: json["message"],
        wallet: json["wallet"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "wallet": wallet,
    };
}