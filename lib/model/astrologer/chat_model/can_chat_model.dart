// To parse this JSON data, do
//
//     final canChatModel = canChatModelFromJson(jsonString);

import 'dart:convert';

CanChatModel canChatModelFromJson(String str) => CanChatModel.fromJson(json.decode(str));

String canChatModelToJson(CanChatModel data) => json.encode(data.toJson());

class CanChatModel {
    bool? success;
    String? message;
    String? status;
    int? chatId;
    AstrologerDetails? astrologerDetails;
    ConsultationDetail? consultationDetail;
   String? countdown;
   String? whenn;

    CanChatModel({
        this.success,
        this.message,
        this.status,
        this.chatId,
        this.astrologerDetails,
        this.consultationDetail,this.countdown,
        this.whenn
    });

    factory CanChatModel.fromJson(Map<String, dynamic> json) => CanChatModel(
        success: json["success"],
        message: json["message"],
        status: json["status"],
        chatId: json["chat_id"],
        astrologerDetails: json["astrologer_detail"] == null ? null : AstrologerDetails.fromJson(json["astrologer_detail"]),
        consultationDetail: json["consultation_detail"] == null ? null : ConsultationDetail.fromJson(json["consultation_detail"]),
         countdown: json["count_down"],
         whenn: json["when"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "status": status,
        "chat_id": chatId,
        "astrologer_detail": astrologerDetails?.toJson(),
        "consultation_detail": consultationDetail?.toJson(),
        "count_down":countdown,
        "when":whenn
    };
}

class ConsultationDetail {
    String? startTime;
    int? rechargepupupcount;
 

    ConsultationDetail({
        this.startTime,this.rechargepupupcount
   
    });

    factory ConsultationDetail.fromJson(Map<String, dynamic> json) => ConsultationDetail(
        startTime: json["start_time"],
        rechargepupupcount:json["recharge_popup_count_down"]
 
    );

    Map<String, dynamic> toJson() => {
        "start_time": startTime,
        "recharge_popup_count_down":rechargepupupcount
     
    };
}

class AstrologerDetails {
    String? name;
    dynamic id;
    dynamic slug;

    AstrologerDetails({
        this.name,this.id,this.slug
    });

    factory AstrologerDetails.fromJson(Map<String, dynamic> json) => AstrologerDetails(
        name: json["name"],
         id: json["id"],
          slug: json["slug"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "id":id,
        "slug":slug
    };
}
