// To parse this JSON data, do
//
//     final supportTicketListResponse = supportTicketListResponseFromJson(jsonString);

import 'dart:convert';

SupportTicketListResponse supportTicketListResponseFromJson(String str) => SupportTicketListResponse.fromJson(json.decode(str));

class SupportTicketListResponse {
    final bool success;
    final Data? data;

    SupportTicketListResponse({
        required this.success,
        this.data,
    });

    factory SupportTicketListResponse.fromJson(Map<String, dynamic> json) => SupportTicketListResponse(
        success: json["success"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
    );
}

class Data {
    final List<SupportTicket> list;

    Data({
        required this.list,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        list: List<SupportTicket>.from(json["list"].map((x) => SupportTicket.fromJson(x))),
    );
}

class SupportTicket {
    final int id;
    final String status;
    final String ticketNumber;
    final String type;
    final String subject;
    final String message;
    final String document;
    final String createdAt;

    SupportTicket({
        required this.id,
        required this.status,
        required this.ticketNumber,
        required this.type,
        required this.subject,
        required this.message,
        required this.document,
        required this.createdAt,
    });

    factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
        id: json["id"],
        status: json["status"],
        ticketNumber: json["ticket_number"],
        type: json["type"],
        subject: json["subject"],
        message: json["message"],
        document: json["document"],
        createdAt: json["created_at"],
    );
}