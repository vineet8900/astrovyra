// To parse this JSON data, do
//
//     final cancallModel = cancallModelFromJson(jsonString);

import 'dart:convert';

CancallModel cancallModelFromJson(String str) =>
    CancallModel.fromJson(json.decode(str));

String cancallModelToJson(CancallModel data) =>
    json.encode(data.toJson());

class CancallModel {
  bool? success;
  String? message;
  String? status;
  AstrologerDetails? astrologerDetails;
  ConsultationDetail? consultationDetail;
  String? countdown;
  String? whenn;

  CancallModel(
      {this.success,
      this.message,
      this.status,
      this.astrologerDetails,
      this.consultationDetail,
      this.countdown,
      this.whenn});

  factory CancallModel.fromJson(Map<String, dynamic> json) =>
      CancallModel(
        success: json["success"],
        message: json["message"],
        status: json["status"],
        astrologerDetails: json["astrologer_detail"] == null
            ? null
            : AstrologerDetails.fromJson(json["astrologer_detail"]),
        consultationDetail: json["consultation_detail"] == null
            ? null
            : ConsultationDetail.fromJson(json["consultation_detail"]),
        countdown: json["count_down"],
        whenn: json["when"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "status": status,
        "astrologer_detail": astrologerDetails?.toJson(),
        "consultation_detail": consultationDetail?.toJson(),
        "count_down": countdown,
        "when": whenn
      };
}

class ConsultationDetail {
  String? startTime;
  dynamic appId;
  dynamic appSign;
  dynamic userId;
  dynamic userName;
  dynamic callId;
  int? rechargepupupcount;
  int? id;

  ConsultationDetail(
      {this.startTime,
      this.appId,
      this.appSign,
      this.userId,
      this.userName,
      this.callId,
      this.rechargepupupcount,
      this.id
      });

  factory ConsultationDetail.fromJson(Map<String, dynamic> json) =>
      ConsultationDetail(
          startTime: json["start_time"],
          appId: json["app_id"],
          appSign: json["app_sign"],
          userId: json["user_id"],
          userName: json["user_name"],
          callId: json["call_id"],
          rechargepupupcount: json["recharge_popup_count_down"],
          id: json["id"]
          );

  Map<String, dynamic> toJson() => {
        "start_time": startTime,
        "app_id": appId,
        "app_sign": appSign,
        "user_id": userId,
        "user_name": userName,
        "call_id": callId,
        "recharge_popup_count_down": rechargepupupcount,
        "id":id
      };
}

class AstrologerDetails {
  String? name;

  AstrologerDetails({
    this.name,
  });

  factory AstrologerDetails.fromJson(Map<String, dynamic> json) => AstrologerDetails(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}
