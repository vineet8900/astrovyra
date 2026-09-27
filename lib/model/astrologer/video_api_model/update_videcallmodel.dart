// To parse this JSON data, do
//
//     final videoLogModel = videoLogModelFromJson(jsonString);

import 'dart:convert';

VideoLogModel videoLogModelFromJson(String str) => VideoLogModel.fromJson(json.decode(str));

String videoLogModelToJson(VideoLogModel data) => json.encode(data.toJson());

class VideoLogModel {
    bool? success;
    String? message;
    String? status;
    
    ConsultationDetail? consultationDetail;


    VideoLogModel({
        this.success,
        this.message,
        this.status,
       
        this.consultationDetail,
    });

    factory VideoLogModel.fromJson(Map<String, dynamic> json) => VideoLogModel(
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
