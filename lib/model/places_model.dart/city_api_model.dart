

import 'dart:convert';

CityModel citymodelFromJson(String str) => CityModel.fromJson(json.decode(str));

String citymodelToJson(CityModel data) => json.encode(data.toJson());

class CityModel {
    bool? success;
    List<CityDatum>? data;

    CityModel({
        this.success,
        this.data,
    });

    factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<CityDatum>.from(json["data"]!.map((x) => CityDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class CityDatum {
    dynamic id;
    dynamic name;

    CityDatum({
        this.id,
        this.name,
    });

    factory CityDatum.fromJson(Map<String, dynamic> json) => CityDatum(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
