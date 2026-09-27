// To parse this JSON data, do
//
//     final supportTicketResponse = supportTicketResponseFromJson(jsonString);

import 'dart:convert';

// Helper function to convert JSON string to model object
SupportTicketResponse supportTicketResponseFromJson(String str) => SupportTicketResponse.fromJson(json.decode(str));

// Helper function to convert model object to JSON string
String supportTicketResponseToJson(SupportTicketResponse data) => json.encode(data.toJson());

class SupportTicketResponse {
    final bool success;
    final String message;
    final TicketData? data; // Data ko nullable banaya gaya hai taaki error response handle ho sake

    SupportTicketResponse({
        required this.success,
        required this.message,
        this.data,
    });

    factory SupportTicketResponse.fromJson(Map<String, dynamic> json) => SupportTicketResponse(
        success: json["success"],
        message: json["message"],
        // Check karein ki data null hai ya nahi
        data: json["data"] != null ? TicketData.fromJson(json["data"]) : null,
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class TicketData {
    final String ticketNumber;

    TicketData({
        required this.ticketNumber,
    });

    factory TicketData.fromJson(Map<String, dynamic> json) => TicketData(
        ticketNumber: json["ticket_number"],
    );

    Map<String, dynamic> toJson() => {
        "ticket_number": ticketNumber,
    };
}