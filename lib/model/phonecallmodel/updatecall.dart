// To parse this JSON data, do
//
//     final callLogModel = callLogModelFromJson(jsonString);

import 'dart:convert';

callLogModel callLogModelFromJson(String str) => callLogModel.fromJson(json.decode(str));

String callLogModelToJson(callLogModel data) => json.encode(data.toJson());

class callLogModel {
    bool? success;
    String? message;
    String? status;
    
    ConsultationDetail? consultationDetail;


    callLogModel({
        this.success,
        this.message,
        this.status,
       
        this.consultationDetail,
    });

    factory callLogModel.fromJson(Map<String, dynamic> json) => callLogModel(
        success: json["success"],
        message: json["message"],
        status: json["status"],
     
        consultationDetail: json["consultation_detail"] == null ? null : ConsultationDetail.fromJson(json["consultation_detail"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "status": status,
    
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
