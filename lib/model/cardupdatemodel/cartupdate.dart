import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class FormDataItem {
  final String key;
  final String label;
  final String value;

  FormDataItem({
    required this.key,
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'value': value,
    };
  }
}

class CartUpdateResponse {
  final bool success;
  final String message;

  CartUpdateResponse({
    required this.success,
    required this.message,
  });

  factory CartUpdateResponse.fromJson(Map<String, dynamic> json) {
    return CartUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class CartItemDetails {
  final int itemId;
  final String itemName;
  final String itemImage;
  final List<FormDataItem> formData;

  CartItemDetails({
    required this.itemId,
    required this.itemName,
    required this.itemImage,
    required this.formData,
  });

  factory CartItemDetails.fromJson(Map<String, dynamic> json) {
    List<FormDataItem> formDataList = [];
    if (json['form_data'] != null) {
      for (var item in json['form_data']) {
        formDataList.add(FormDataItem(
          key: item['key'] ?? '',
          label: item['label'] ?? '',
          value: item['value'] ?? '',
        ));
      }
    }

    return CartItemDetails(
      itemId: json['item_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      itemImage: json['item_image'] ?? '',
      formData: formDataList,
    );
  }
}