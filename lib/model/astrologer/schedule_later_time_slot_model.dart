// To parse this JSON data, do
//
//     final scheduleLaterTimeSlotApiModel = scheduleLaterTimeSlotApiModelFromJson(jsonString);

import 'dart:convert';

ScheduleLaterTimeSlotApiModel scheduleLaterTimeSlotApiModelFromJson(String str) => ScheduleLaterTimeSlotApiModel.fromJson(json.decode(str));

String scheduleLaterTimeSlotApiModelToJson(ScheduleLaterTimeSlotApiModel data) => json.encode(data.toJson());

class ScheduleLaterTimeSlotApiModel {
    bool? success;
    List<String>? timeIntervals;

    ScheduleLaterTimeSlotApiModel({
        this.success,
        this.timeIntervals,
    });

    factory ScheduleLaterTimeSlotApiModel.fromJson(Map<String, dynamic> json) => ScheduleLaterTimeSlotApiModel(
        success: json["success"],
        timeIntervals: json["timeIntervals"] == null ? [] : List<String>.from(json["timeIntervals"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "timeIntervals": timeIntervals == null ? [] : List<dynamic>.from(timeIntervals!.map((x) => x)),
    };
}
