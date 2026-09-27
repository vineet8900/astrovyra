
import 'dart:convert';
OtpModel otpModelFromJson(String str) => OtpModel.fromJson(json.decode(str));
String otpModelToJson(OtpModel data) => json.encode(data.toJson());

class OtpModel {
    String? message;
    int? status;
    String? apiToken;
     UserData? data;

    OtpModel({
        this.message,
        this.status,
        this.apiToken,this.data
    });

    factory OtpModel.fromJson(Map<String, dynamic> json) => OtpModel(
        message: json["message"],
        status: json["status"],
        apiToken: json["api_token"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "api_token": apiToken,
    };
}
  class UserData {
    String? name;
    String? email;
    String? phone;
    dynamic? state;
    dynamic? city;
    dynamic? gender;
    String? image;

    UserData({
        this.name,
        this.email,
        this.phone,
        this.state,
        this.city,
        this.gender,
        this.image,
    });

    factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        state: json["state"],
        city: json["city"],
        gender: json["gender"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "phone": phone,
        "state": state,
        "city": city,
        "gender": gender,
        "image": image,
    };
}
