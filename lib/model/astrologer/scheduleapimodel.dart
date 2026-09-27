// To parse this JSON data, do
//
//     final scheduleLaterApiModel = scheduleLaterApiModelFromJson(jsonString);

import 'dart:convert';

ScheduleLaterApiModel scheduleLaterApiModelFromJson(String str) => ScheduleLaterApiModel.fromJson(json.decode(str));

String scheduleLaterApiModelToJson(ScheduleLaterApiModel data) => json.encode(data.toJson());

class ScheduleLaterApiModel {
    bool? success;
    List<DateTime>? data;

    ScheduleLaterApiModel({
        this.success,
        this.data,
    });

    factory ScheduleLaterApiModel.fromJson(Map<String, dynamic> json) => ScheduleLaterApiModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<DateTime>.from(json["data"]!.map((x) => DateTime.parse(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
    };
}
