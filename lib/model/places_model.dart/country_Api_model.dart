

import 'dart:convert';

CountryModel countryModelFromJson(String str) => CountryModel.fromJson(json.decode(str));

String countryModelToJson(CountryModel data) => json.encode(data.toJson());

class CountryModel {
    bool? success;
    List<CountryDatum>? data;

    CountryModel({
        this.success,
        this.data,
    });

    factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<CountryDatum>.from(json["data"]!.map((x) => CountryDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class CountryDatum {
    dynamic id;
    dynamic name;

    CountryDatum({
        this.id,
        this.name,
    });

    factory CountryDatum.fromJson(Map<String, dynamic> json) => CountryDatum(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
