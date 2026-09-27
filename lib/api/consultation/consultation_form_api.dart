import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/screen/astrologer/astrologer_list_screen.dart';
import 'package:astrokavach/screen/astrologer/consultation/chat_screen.dart';
import 'package:astrokavach/screen/astrologer/consultation/phonecalling.dart';
import 'package:astrokavach/screen/astrologer/consultation/video_screen.dart';
import 'package:astrokavach/screen/thankyou_screen.dart';
import 'package:astrokavach/screen/wallet/wallet_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ConsultationApiService {
  callapidata(
      {required BuildContext context,
      String? token,
      int? id,
      String? mode,
      String? when,
      int? timeSlot,
      String? name,
      String? email,
      int? mobile,
      String? scheduledDate,
      String? scheduledTimeSlot,
      int? gender,
      String? occupation,
      String? maritalstatus,
      //new filled add here
      String? birthDate,
      String? birthTime,
      String? birthPlace}) async {
    try {
      final url = Uri.parse("${CustomStyles.baseUrl}user/book-consultaion");

      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final body = {
        "id": id,
        "mode": mode,
        "when": when,

        "name": name,
        // "email": email,
        //"mobile": mobile,
        if (when == 'later') ...{
          "scheduled_date": scheduledDate,
          "scheduled_time_slot": scheduledTimeSlot,
          "time_slot": timeSlot,
        },
        "gender": gender,
        "occupation": occupation,
        "maritial_status": maritalstatus,
        //new filled
        "birth_date": birthDate,
        "birth_time": birthTime,
        "birth_place": birthPlace,
      };
    
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      
      final responseData = jsonDecode(response.body);
      
      String msg = responseData["message"];
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ThankyouScreen(
                      msg: msg,
                    )));

        var consultationId = responseData['consultation_id'];
       
        if (when == "now") {
          if (mode == "chat") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        consultationid: consultationId,
                      )),
            );
            return null;
          } else if (mode == "video") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? apiToken = prefs.getString('api_token');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => VideoWebviewScreen(
                        consultationid: consultationId,
                      )),
            );
            return null;
          } else if (mode == "call") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? apiToken = prefs.getString('api_token');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => PhoneCallScreen(
                        consultationid: consultationId,
                      )),
            );
            return null;
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ThankyouScreen(
                          msg: msg,
                        )));
            return null;
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'],
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AstrologerListScreen(
                  // bottambarindex: 2,
                  // leadingbtn: false,
                  )),
          // (Route<dynamic> route) => false,
        );
        if (responseData["status"] == "recharge") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WalletScreen()),
          );
        }
        return null;
      }
    } catch (e) {
     
    }
  }
}
