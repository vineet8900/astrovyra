// payment_type_model.dart

class PaymentTypeResponse {
  final bool success;
  final List<PaymentType> data;

  PaymentTypeResponse({required this.success, required this.data});

  factory PaymentTypeResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<PaymentType> dataList = list.map((i) => PaymentType.fromJson(i)).toList();
    return PaymentTypeResponse(success: json['success'], data: dataList);
  }
}

class PaymentType {
  final String name;
  final String value;

  PaymentType({required this.name, required this.value});

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(name: json['name'], value: json['value']);
  }
}