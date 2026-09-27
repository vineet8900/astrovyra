import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// +++ START: NotifyUserResponse MODEL +++
// This is the new model for the notify user API response.

NotifyUserResponse notifyUserResponseFromJson(String str) => NotifyUserResponse.fromJson(json.decode(str));

String notifyUserResponseToJson(NotifyUserResponse data) => json.encode(data.toJson());

class NotifyUserResponse {
    final bool success;
    final String message;

    NotifyUserResponse({
        required this.success,
        required this.message,
    });

    factory NotifyUserResponse.fromJson(Map<String, dynamic> json) => NotifyUserResponse(
        success: json["success"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
    };
}