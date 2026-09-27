

import 'dart:convert';

StateModel statemodelFromJson(String str) => StateModel.fromJson(json.decode(str));

String statemodelToJson(StateModel data) => json.encode(data.toJson());

class StateModel {
    bool? success;
    List<StateDatum>? data;

    StateModel({
        this.success,
        this.data,
    });

    factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<StateDatum>.from(json["data"]!.map((x) => StateDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class StateDatum {
    dynamic id;
    dynamic name;

    StateDatum({
        this.id,
        this.name,
    });

    factory StateDatum.fromJson(Map<String, dynamic> json) => StateDatum(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
