class RudrakshModel {
  final List<int> diseaseCure;
  final List<int> forMoney;
  final String description;
  final String botResponse;
  final String name;

  RudrakshModel({
    required this.diseaseCure,
    required this.forMoney,
    required this.description,
    required this.botResponse,
    required this.name,
  });

  factory RudrakshModel.fromJson(Map<String, dynamic> json) {
    return RudrakshModel(
      diseaseCure: List<int>.from(json['mukhi_for_disease_cure'] ?? const []),
      forMoney: List<int>.from(json['mukhi_for_money'] ?? const []),
      description: json['mukhi_description']?.toString() ?? '',
      botResponse: json['bot_response']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
