// To parse this JSON data, do
//
//     final addressApiModel = addressApiModelFromJson(jsonString);

import 'dart:convert';

AddressApiModel addressApiModelFromJson(String str) => AddressApiModel.fromJson(json.decode(str));

String addressApiModelToJson(AddressApiModel data) => json.encode(data.toJson());

class AddressApiModel {
    bool? success;
    String? message;
    List<AddressDatum>? data;

    AddressApiModel({
        this.success,
        this.message,
        this.data,
    });

    factory AddressApiModel.fromJson(Map<String, dynamic> json) => AddressApiModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? [] : List<AddressDatum>.from(json["data"]!.map((x) => AddressDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class AddressDatum {
    int? addressId;
    String? name;
    String? email;
   dynamic phone;
    dynamic country;
    dynamic countryId;
    dynamic state;
    dynamic stateId;
    dynamic city;
    dynamic cityId;
    dynamic zipcode;
   dynamic address;

    AddressDatum({
        this.addressId,
        this.name,
        this.email,
        this.phone,
        this.country,
        this.countryId,
        this.state,
        this.stateId,
        this.city,
        this.cityId,
        this.zipcode,
        this.address,
    });

    factory AddressDatum.fromJson(Map<String, dynamic> json) => AddressDatum(
        addressId: json["address_id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        country: json["country"],
        countryId: json["country_id"],
        state: json["state"],
        stateId: json["state_id"],
        city: json["city"],
        cityId: json["city_id"],
        zipcode: json["zipcode"],
        address: json["address"],
    );

    Map<String, dynamic> toJson() => {
        "address_id": addressId,
        "name": name,
        "email": email,
        "phone": phone,
        "country": country,
        "country_id": countryId,
        "state": state,
        "state_id": stateId,
        "city": city,
        "city_id": cityId,
        "zipcode": zipcode,
        "address": address,
    };
}
