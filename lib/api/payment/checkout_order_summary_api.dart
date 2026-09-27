import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/payment_model/checkput_order_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CheckoutOrderSummaryApi {
  /// [buyNow] 1 = checkout summary for buy-now cart only
  /// [cartitemid] when buyNow=1, pass add-to-cart response data.id so backend returns correct order summary
  /// [paymentOption] 'cod' = Cash on Delivery (backend cod_charge add karke total dega), 'now' = Pay Online (cod_charge 0)
  Future<CheckoutOrderSummaryApiModel?> fetchchekoutorderdata(
    BuildContext context,
    String apitoken,
    int type, {
    int buyNow = 0,
    int? cartitemid,
    String? paymentOption,
  }) async {
    String apiUrl = '${CustomStyles.baseUrl}user/checkout';

    Map<String, String> headers = {
      'Authorization': 'Bearer $apitoken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final body = <String, dynamic>{
      'api_token': apitoken,
      'item_type': type,
    };
    print("new2$body");
    if (buyNow == 1) {
      body['buy_now'] = 1;
      if (cartitemid != null) body['cartitemid'] = cartitemid;
    }
    if (paymentOption != null && paymentOption.isNotEmpty) {
      body['payment_option'] = paymentOption;
    }
    print("checkout$body");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        return CheckoutOrderSummaryApiModel.fromJson(data);
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);

        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
