import 'dart:convert';
UserConsultationModel userConsultationModelFromJson(String str) => UserConsultationModel.fromJson(json.decode(str));
String userConsultationModelToJson(UserConsultationModel data) => json.encode(data.toJson());
class UserConsultationModel {
    bool? success;
    Data? data;

    UserConsultationModel({
        this.success,
        this.data,
    });

    factory UserConsultationModel.fromJson(Map<String, dynamic> json) => UserConsultationModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    int? totalCount;
    int? videoCount;
    int? chatCount;
    int? callCount;
    List<UserConsultingList>? list;

    Data({
        this.totalCount,
        this.videoCount,
        this.chatCount,
        this.callCount,
        this.list,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalCount: json["total_count"],
        videoCount: json["video_count"],
        chatCount: json["chat_count"],
        callCount: json["call_count"],
        list: json["list"] == null ? [] : List<UserConsultingList>.from(json["list"]!.map((x) => UserConsultingList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total_count": totalCount,
        "video_count": videoCount,
        "chat_count": chatCount,
        "call_count": callCount,
        "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
    };
}

class UserConsultingList {
    int? consultationId;
    
  dynamic astrologerId; // ✅ dynamic
    String? name;
    String? date;
   dynamic charges;
   dynamic  duration;
    String? action;
    int? status;
    dynamic amount;
     bool? review;

    UserConsultingList({
        this.consultationId,
         this.astrologerId,
        this.name,
        this.date,
        this.charges,
        this.duration,
        this.action,
        this.status,
        this.amount,
        this.review,

    });

    factory UserConsultingList.fromJson(Map<String, dynamic> json) => UserConsultingList(
        consultationId: json["consultation_id"],
        name: json["name"],
        date: json["date_time"],
        charges: json["charges"],
        duration: json["duration"],
        action: json["action"],
          status: json["status"],
          amount: json["amount"],
          review: json["review"],
          astrologerId: json["astrologer_id"], // ✅ dynamic assign
    );

    Map<String, dynamic> toJson() => {
        "consultation_id": consultationId,
        "name": name,
        "date_time": date,
        "charges": charges,
        "duration": duration,
        "action": action,
        "status":status,
        "amount":amount,
         "review": review,
        "astrologer_id": astrologerId,
    };
}
