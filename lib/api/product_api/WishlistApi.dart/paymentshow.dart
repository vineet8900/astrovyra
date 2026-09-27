// order_api_service.dart

import 'dart:convert';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/offerpayemet.dart/offerpayment.dart';
import 'package:http/http.dart' as http;

class OrderApiService {
  // Common headers
  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  /// API se payment ke options fetch karne ke liye method
  /// Yeh sirf aapke diye gaye URL par kaam karega.
  Future<List<PaymentType>> getPaymentTypes(int itemType) async {
    final url = Uri.parse('${CustomStyles.baseUrl}payment-types');

    try {
      // POST request bhejna
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(<String, int>{
          'item_type': itemType,
        }),
      );
      print("hello$itemType");

      // Check karna ki request safal hui ya nahi
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final paymentResponse = PaymentTypeResponse.fromJson(jsonResponse);

        if (paymentResponse.success) {
          return paymentResponse.data;
        } else {
          // Agar API success: false bhejta hai
          throw Exception('API request failed with success: false');
        }
      } else {
        // Agar server se error (jaise 404, 500) aata hai
        throw Exception(
            'Failed to load payment types. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Network ya parsing error ke liye
      throw Exception('Error fetching payment types: $e');
    }
  }
}
