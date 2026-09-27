// lib/models/support_type_model.dart

class SupportType {
  final String name;
  final String value;

  SupportType({
    required this.name,
    required this.value,
  });

  factory SupportType.fromJson(Map<String, dynamic> json) {
    return SupportType(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }
}