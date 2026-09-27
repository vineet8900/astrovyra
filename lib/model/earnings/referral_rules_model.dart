import 'dart:convert';

ReferralRulesResponse referralRulesResponseFromJson(String str) =>
    ReferralRulesResponse.fromJson(json.decode(str) as Map<String, dynamic>);

class ReferralRulesResponse {
  ReferralRulesResponse({
    required this.status,
    required this.data,
  });

  final bool status;
  final ReferralRulesData? data;

  factory ReferralRulesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return ReferralRulesResponse(
      status: json['status'] == true,
      data: raw is Map ? ReferralRulesData.fromJson(Map<String, dynamic>.from(raw)) : null,
    );
  }
}

class ReferralRulesData {
  ReferralRulesData({
    required this.appReferral,
    required this.productCommission,
    required this.wallet,
    required this.faq,
  });

  final List<String> appReferral;
  final List<String> productCommission;
  final List<String> wallet;
  final List<ReferralFaqItem> faq;

  factory ReferralRulesData.fromJson(Map<String, dynamic> json) {
    final ar = json['app_referral'];
    final pc = json['product_commission'];
    final w = json['wallet'];
    final fq = json['faq'];
    return ReferralRulesData(
      appReferral: (ar is List ? ar : const [])
          .map((e) => e?.toString() ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      productCommission: (pc is List ? pc : const [])
          .map((e) => e?.toString() ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      wallet: (w is List ? w : const [])
          .map((e) => e?.toString() ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      faq: (fq is List ? fq : const [])
          .whereType<Map>()
          .map((e) => ReferralFaqItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class ReferralFaqItem {
  ReferralFaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  factory ReferralFaqItem.fromJson(Map<String, dynamic> json) => ReferralFaqItem(
        question: (json['question'] ?? '').toString(),
        answer: (json['answer'] ?? '').toString(),
      );
}

