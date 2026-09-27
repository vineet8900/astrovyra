
import 'dart:convert';

UserDataModel userDataModelFromJson(String str) => UserDataModel.fromJson(json.decode(str));

String userDataModelToJson(UserDataModel data) => json.encode(data.toJson());

class UserDataModel {
    bool? success;
    Data? data;

    UserDataModel({
        this.success,
        this.data,
    });

    factory UserDataModel.fromJson(Map<String, dynamic> json) => UserDataModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    int? id;
    String? name;
    String? email;
    String? phone;
    int? countryId;
    String? country;
    int? stateId;
    String? state;
    int? cityId;
    String? city;
    String? pincode;
    String? address;
    int? genderId;
    String? gender;
    String? image;
    int? wallet;
    String? lastLogined;
    String? birthDate;
    String? birthTime;
    String? birthPlace;

    Data({
        this.id,
        this.name,
        this.email,
        this.phone,
        this.countryId,
        this.country,
        this.stateId,
        this.state,
        this.cityId,
        this.city,
        this.pincode,
        this.address,
        this.genderId,
        this.gender,
        this.image,
        this.wallet,
        this.lastLogined,
        this.birthDate,
        this.birthTime,
        this.birthPlace,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        countryId: json["country_id"],
        country: json["country"],
        stateId: json["state_id"],
        state: json["state"],
        cityId: json["city_id"],
        city: json["city"],
        pincode: json["pincode"],
        address: json["address"],
        genderId: json["gender_id"],
        gender: json["gender"],
        image: json["image"],
        wallet: json["wallet"],
        lastLogined: json["last_logined"],
        birthDate: json["birth_date"],
        birthTime: json["birth_time"],
        birthPlace: json["birth_place"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "country_id": countryId,
        "country": country,
        "state_id": stateId,
        "state": state,
        "city_id": cityId,
        "city": city,
        "pincode": pincode,
        "address": address,
        "gender_id": genderId,
        "gender": gender,
        "image": image,
        "wallet": wallet,
        "last_logined": lastLogined,
        "birth_date": birthDate,
        "birth_time": birthTime,
        "birth_place": birthPlace,
    };
}
