import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ===================================================================================
// == Models Section ===============================================================
// ===================================================================================

/// Model for the reasons fetched from the API (e.g., "Item not needed anymore")
class Reason {
  final String name;
  final dynamic value;

  Reason({required this.name, required this.value});

  factory Reason.fromJson(Map<String, dynamic> json) => Reason(
        name: json["name"],
        value: json["value"],
      );
}

/// Model for the response received after submitting a cancel/return request
class OrderRequestResponse {
  final bool success;
  final String message;

  OrderRequestResponse({
    required this.success,
    required this.message,
  });

  factory OrderRequestResponse.fromJson(Map<String, dynamic> json) =>
      OrderRequestResponse(
        success: json["success"],
        message: json["message"],
      );
}

// ===================================================================================
// == API Service Section ==========================================================
// ===================================================================================

class OrderApiService {
  static String get _baseUrl => CustomStyles.baseUrl;
  static String get _orderRequestEndpoint =>
      '${CustomStyles.baseUrl}user/order-request';

  /// Fetches the predefined reasons for cancelling an order.
  static Future<List<Reason>?> fetchCancelReasons() async {
    final url = Uri.parse('${_baseUrl}order-cancel-reasons');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<Reason> reasons = (data['data'] as List)
              .map((item) => Reason.fromJson(item))
              .where((reason) => reason.value != "")
              .toList();
          return reasons.isNotEmpty ? reasons : null;
        }
      }
      Fluttertoast.showToast(msg: "Server returned an error.");
      return null;
    } catch (e) {
       
      Fluttertoast.showToast(msg: "Could not load reasons. Check internet.");
      return null;
    }
  }

  /// Fetches the predefined reasons for returning an order.
  static Future<List<Reason>?> fetchReturnReasons() async {
    final url = Uri.parse('${_baseUrl}order-return-reasons');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<Reason> reasons = (data['data'] as List)
              .map((item) => Reason.fromJson(item))
              .where((reason) => reason.value != "")
              .toList();
          return reasons.isNotEmpty ? reasons : null;
        }
      }
      Fluttertoast.showToast(msg: "Server returned an error.");
      return null;
    } catch (e) {
      
      Fluttertoast.showToast(msg: "Could not load reasons. Check internet.");
      return null;
    }
  }

  /// [NEW] Submits a request to cancel or return an order.
  static Future<OrderRequestResponse?> orderRequest({
    required String requestType,
    required int orderId,
    required String reason,
    String? message, // For 'Other' reason
    List<int>? itemIds, // For return requests
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(
          msg: "Authentication token not found. Please log in.");
      return null;
    }

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> body = {
      'request_type': requestType,
      'order_id': orderId,
      'reason': reason,
    };

    if (message != null && message.isNotEmpty) {
      body['message'] = message;
    }
    if (requestType == 'return' && itemIds != null) {
      body['item_ids'] = itemIds;
    }

    try {
      final response = await http.post(
        Uri.parse(_orderRequestEndpoint),
        headers: headers,
        body: jsonEncode(body),
      );

       

      final responseData =
          OrderRequestResponse.fromJson(json.decode(response.body));

      Fluttertoast.showToast(
        msg: responseData.message,
        backgroundColor: responseData.success ? Colors.green : Colors.red,
      );

      return responseData;
    } catch (e) {
       
      Fluttertoast.showToast(
          msg: 'An unexpected error occurred. Check your connection.');
      return null;
    }
  }
}

// ===================================================================================
// == Dialogs ki Asli Class yahan hai (UPDATED) =======================================
// ===================================================================================

class OrderActionDialogs {
  /// CANCEL DIALOG
  static Future<bool?> showCancelDialog(BuildContext context,
      {required int orderId}) async {
    final reasons = await OrderApiService.fetchCancelReasons();
    if (!context.mounted) return false;
    if (reasons == null || reasons.isEmpty) return false;

    String? selectedValue;
    final otherReasonController = TextEditingController();
    bool showOtherField = false;
    bool isSubmitting = false;

    // The dialog now returns a boolean value (true for success, false/null for close/failure)
    return showDialog<bool>(
      context: context,
      barrierDismissible: !isSubmitting, // Prevent closing while loading
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Cancel Order"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Reason For Cancellation",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedValue,
                    isExpanded: true,
                    hint: Text("Select"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    onChanged: (newValue) {
                      setDialogState(() {
                        selectedValue = newValue;
                        final selectedReason = reasons
                            .firstWhere((r) => r.value.toString() == newValue);
                        showOtherField =
                            selectedReason.name.toLowerCase() == 'other';
                      });
                    },
                    items: reasons
                        .map((reason) => DropdownMenuItem(
                              value: reason.value.toString(),
                              child: Text(reason.name),
                            ))
                        .toList(),
                  ),
                  if (showOtherField)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextFormField(
                        controller: otherReasonController,
                        decoration: InputDecoration(
                          hintText: "Please specify your reason",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Close")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomStyles.pinki,
                  foregroundColor: Colors.black,
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (selectedValue == null) {
                          Fluttertoast.showToast(
                              msg: "Please select a reason.");
                          return;
                        }
                        if (showOtherField &&
                            otherReasonController.text.trim().isEmpty) {
                          Fluttertoast.showToast(
                              msg:
                                  "Please specify your reason in the text box.");
                          return;
                        }

                        setDialogState(() => isSubmitting = true);

                        final response = await OrderApiService.orderRequest(
                          requestType: 'cancel',
                          orderId: orderId,
                          reason: selectedValue!,
                          message: showOtherField
                              ? otherReasonController.text
                              : null,
                        );

                        setDialogState(() => isSubmitting = false);

                        if (response != null && response.success) {
                          Navigator.pop(
                              context, true); // Return true on success
                        }
                      },
                child: isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : Text(
                        "Send",
                        style: TextStyle(color: Colors.white),
                      ),
              )
            ],
          );
        });
      },
    );
  }

  /// RETURN DIALOG
  static Future<bool?> showReturnDialog(BuildContext context,
      {required int orderId, required List<int> itemIds}) async {
    final reasons = await OrderApiService.fetchReturnReasons();
    if (!context.mounted) return false;
    if (reasons == null || reasons.isEmpty) return false;

    String? selectedValue;
    final otherReasonController = TextEditingController();
    bool showOtherField = false;
    bool isSubmitting = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: !isSubmitting, // Prevent closing while loading
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text("Return Request"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Reason For Return",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedValue,
                    isExpanded: true,
                    hint: Text("Select"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    onChanged: (newValue) {
                      setDialogState(() {
                        selectedValue = newValue;
                        final selectedReason = reasons
                            .firstWhere((r) => r.value.toString() == newValue);
                        showOtherField =
                            selectedReason.name.toLowerCase() == 'other';
                      });
                    },
                    items: reasons
                        .map((reason) => DropdownMenuItem(
                              value: reason.value.toString(),
                              child: Text(reason.name),
                            ))
                        .toList(),
                  ),
                  if (showOtherField)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextFormField(
                        controller: otherReasonController,
                        decoration: InputDecoration(
                          hintText: "Please specify your reason",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Close")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomStyles.pinki,
                  foregroundColor: Colors.black,
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (selectedValue == null) {
                          Fluttertoast.showToast(
                              msg: "Please select a reason.");
                          return;
                        }
                        if (showOtherField &&
                            otherReasonController.text.trim().isEmpty) {
                          Fluttertoast.showToast(
                              msg:
                                  "Please specify your reason in the text box.");
                          return;
                        }

                        setDialogState(() => isSubmitting = true);

                        final response = await OrderApiService.orderRequest(
                            requestType: 'return',
                            orderId: orderId,
                            reason: selectedValue!,
                            message: showOtherField
                                ? otherReasonController.text
                                : null,
                            itemIds: itemIds);

                        setDialogState(() => isSubmitting = false);

                        if (response != null && response.success) {
                          Navigator.pop(
                              context, true); // Return true on success
                        }
                      },
                child: isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        "Send",
                        style: TextStyle(color: Colors.white),
                      ),
              )
            ],
          );
        });
      },
    );
  }
}
