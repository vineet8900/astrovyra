// To parse this JSON data, do
//
//     final chatLogModel = chatLogModelFromJson(jsonString);

import 'dart:convert';

ChatLogModel chatLogModelFromJson(String str) => ChatLogModel.fromJson(json.decode(str));

String chatLogModelToJson(ChatLogModel data) => json.encode(data.toJson());

class ChatLogModel {
    bool? success;
    String? message;
    String? status;
    List<ChatListDatum>? data;
     int? chatLogsCount;
    ConsultationDetail? consultationDetail;


    ChatLogModel({
        this.success,
        this.message,
        this.status,
        this.data,
          this.chatLogsCount,
        this.consultationDetail,
    });

    factory ChatLogModel.fromJson(Map<String, dynamic> json) => ChatLogModel(
        success: json["success"],
        message: json["message"],
        status: json["status"],
        data: json["data"] == null ? [] : List<ChatListDatum>.from(json["data"]!.map((x) => ChatListDatum.fromJson(x))),
     chatLogsCount: json["chatLogsCount"],
        consultationDetail: json["consultation_detail"] == null ? null : ConsultationDetail.fromJson(json["consultation_detail"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
"chatLogsCount": chatLogsCount,
        "consultation_detail": consultationDetail?.toJson(),
    };
}
class ConsultationDetail {
    bool? showLeadPopup;

    ConsultationDetail({
        this.showLeadPopup,
    });

    factory ConsultationDetail.fromJson(Map<String, dynamic> json) => ConsultationDetail(
        showLeadPopup: json["show_lead_popup"],
    );

    Map<String, dynamic> toJson() => {
        "show_lead_popup": showLeadPopup,
    };
}
class ChatListDatum {
    String? messageBy;
    String? message;
    String? createdAt;

    ChatListDatum({
        this.messageBy,
        this.message,
        this.createdAt,
    });

    factory ChatListDatum.fromJson(Map<String, dynamic> json) => ChatListDatum(
        messageBy: json["message_by"],
        message: json["message"],
        createdAt: json["created_at"],
    );

    Map<String, dynamic> toJson() => {
        "message_by": messageBy,
        "message": message,
        "created_at": createdAt,
    };
}
