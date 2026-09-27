import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/schedule_later_time_slot_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ScheduleLaterTimeSlotApi {
  Future<ScheduleLaterTimeSlotApiModel?> fetchschedulelatertimeslotapi(
      int id, String date, int timeslot) async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
        'content-type': 'application/json',
      };
      final response = await http.post(
          Uri.parse('${CustomStyles.baseUrl}available-time'),
          headers: headers,
          body: jsonEncode({"id": id, "date": date, "time_slot": timeslot}));
      if (response.statusCode == 200) {
        var responsedata = jsonDecode(response.body);
        return ScheduleLaterTimeSlotApiModel.fromJson(responsedata);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch Schedule later ',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
     
    }
    return null;
  }
}
