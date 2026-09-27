
import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/payment_model/place_order_api_model.dart';
import 'package:http/http.dart' as http;

class PlaceOrderApi {
  /// [buyNow] 1 = place order for buy-now cart only (backend clears buy-now cart after)
  /// [cartitemid] when set (e.g. Buy Now), backend uses only this cart item for order amount
  Future<PlacerOrderApiModel?> fetchplaceorderdata({
    required String apiToken,
    required int? addressid,
    required String couponcode,
    required int itemType,
    required String paymentOption, // "now" or "cod"
    required String billingAddress, // "shipping" or "different"
    int buyNow = 0,
    int? cartitemid,
    String? billingFullName,
    String? billingEmail,
    String? billingPhone,
    String? billingAddr,
    String? billingPinCode,
    int? billingCityId,
    int? billingStateId,
    String? billingAddressLandmark,
  }) async {
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $apiToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      Map<String, dynamic> body = {
        "item_type": itemType,
        "coupon_code": couponcode,
        "payment_option": paymentOption,
        "billing_address": billingAddress,
      };
      if (buyNow == 1) {
        body["buy_now"] = 1;
      }
      if (cartitemid != null) {
        body["cartitemid"] = cartitemid;
      }

     
      if (itemType == 0) {
        body["address_id"] = addressid;
      }

      
      if (billingAddress == 'different' && itemType == 0) {
        body.addAll({
          "billing_address_full_name": billingFullName,
          "billing_address_email": billingEmail,
          "billing_address_phone": billingPhone,
          "billing_address_address": billingAddr,
          "billing_address_pincode": billingPinCode,
          "billing_address_city": billingCityId,
          "billing_address_state": billingStateId,
          "billing_address_country": 101, // Default Country ID
        });
        if (billingAddressLandmark != null &&
            billingAddressLandmark.trim().isNotEmpty) {
          body["billing_address_landmark"] = billingAddressLandmark.trim();
        }
      }

      final response = await http.post(
        Uri.parse('${CustomStyles.baseUrl}user/place-order'),
        headers: headers,
        body: jsonEncode(body),
      );

      print("Place Order Request Body: ${jsonEncode(body)}");
      print("Place Order Response Status Code: ${response.statusCode}");
      print("Place Order Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return PlacerOrderApiModel.fromJson(data);
      } else {
        var errorData = jsonDecode(response.body);
        // Fluttertoast.showToast(msg: errorData['message'] ?? 'Order placement failed');
        return null;
      }
    } catch (e) {
      print('PlaceOrderApi Error: $e');
      return null;
    }
  }
}
