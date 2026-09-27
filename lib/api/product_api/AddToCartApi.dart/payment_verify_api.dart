import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';


class PaymentVerifyApi {
  Future fetchpaymentapidata(BuildContext context,
    String? apiToken, PaymentSuccessResponse payment_response,String callbackurl) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $apiToken',
        'Accept': 'application/json',
        'content-type': 'application/json',
      };

      Map<String, dynamic> paymentResponseMap = {
        'paymentId': payment_response.paymentId,
        'orderId': payment_response.orderId, 
        'signature': payment_response.signature,
       
      };
Map<String, dynamic> body = {
       "payment_response": paymentResponseMap,
      };

      String jsonBody = jsonEncode(body);

      final response = await http.post(
        Uri.parse('$callbackurl'),
        headers: headers,
        body: jsonBody,
      );

  
if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
      
        return data; 
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch payment verify data',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
    
    }
    return null;
  }
    void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
       
        content:Container(child: Image.asset("assets/thanks.png"),),
      
      );
    },
  );
}
}
