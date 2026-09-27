import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/payment_model/checkput_order_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CheckoutCouponcodeApi {
  /// [buyNow] 1 = coupon apply on buy-now cart
  /// [cartitemid] when buyNow=1, pass add-to-cart response data.id so backend applies coupon on correct item
  /// [paymentOption] 'cod' / 'now' — order page pe backend iske hisaab se cod_charge add karke total deta hai
  Future<CheckoutOrderSummaryApiModel?> fetchvheckoutCouponcodeApi(
    BuildContext context,
    String apitoken,
    dynamic page,
    dynamic couponcode,
    int id,
    int itemType,
    int? addressId, {
    int buyNow = 0,
    int? cartitemid,
    String? paymentOption,
  }) async {
    String apiUrl = '${CustomStyles.baseUrl}user/coupon';

    Map<String, String> headers = {
      'Authorization': 'Bearer $apitoken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> requestBody = {
      'api_token': apitoken,
      'page': page,
      'coupon_code': couponcode,
      'plan_id': id,
      'item_type': itemType,
    };
    // Buy Now: coupon sirf usi cart item pe lage, poore add-to-cart total pe nahi — isliye cartitemid bhejo
    if (buyNow == 1) {
      requestBody['buy_now'] = 1;
      if (cartitemid != null) requestBody['cartitemid'] = cartitemid.toString();
    }

    if (page == 'order' && addressId != null) {
      requestBody['address_id'] = addressId;
    }
    if (page == 'order' && paymentOption != null && paymentOption.isNotEmpty) {
      requestBody['payment_option'] = paymentOption;
    }

    print("========== COUPON API REQUEST ==========");
    print("coupon requestBody: $requestBody");
    print("cartitemid (buyNow=$buyNow): $cartitemid");
    print("==========================================");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody), // <-- 3. USE THE NEW REQUEST BODY
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        return CheckoutOrderSummaryApiModel.fromJson(data);
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);

        return responseData;
      } else {
        final responseData = jsonDecode(response.body);

        String errorMsg = responseData['message'] ?? '';
        Fluttertoast.showToast(
          msg: errorMsg,
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      return null;
    }
    return null; // Added to handle all code paths
  }
}
