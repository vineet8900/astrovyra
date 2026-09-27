import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMsg {
  static void show(String message, [Color? color]) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: color ?? Colors.red,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      fontSize: 14.0,
    );
  }
}
