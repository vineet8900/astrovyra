import 'dart:convert';

SupportMessageResponse supportMessageResponseFromJson(String str) => SupportMessageResponse.fromJson(json.decode(str));

class SupportMessageResponse {
    final bool success;
    final Data? data;

    SupportMessageResponse({
        required this.success,
        this.data,
    });

    factory SupportMessageResponse.fromJson(Map<String, dynamic> json) => SupportMessageResponse(
        success: json["success"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
    );
}

class Data {
    final TicketDetails ticket;
    final List<Message> messages;

    Data({
        required this.ticket,
        required this.messages,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        ticket: TicketDetails.fromJson(json["ticket"]),
        messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
    );
}

class Message {
    final String messageBy;
    final String message;
    final String createdAt;

    Message({
        required this.messageBy,
        required this.message,
        required this.createdAt,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        messageBy: json["message_by"],
        message: json["message"],
        createdAt: json["created_at"],
    );
}

class TicketDetails {
    final int id;
    final String status;
    final String ticketNumber;
    final String type;
    final String subject;
    final String document;
    final String createdAt;

    TicketDetails({
        required this.id,
        required this.status,
        required this.ticketNumber,
        required this.type,
        required this.subject,
        required this.document,
        required this.createdAt,
    });

    factory TicketDetails.fromJson(Map<String, dynamic> json) => TicketDetails(
        id: json["id"],
        status: json["status"],
        ticketNumber: json["ticket_number"],
        type: json["type"],
        subject: json["subject"],
        document: json["document"],
        createdAt: json["created_at"],
    );
}