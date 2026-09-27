import 'dart:convert';

AppReferralsResponse appReferralsResponseFromJson(String str) =>
    AppReferralsResponse.fromJson(json.decode(str) as Map<String, dynamic>);

class AppReferralsResponse {
  AppReferralsResponse({
    required this.success,
    required this.data,
  });

  final bool success;
  final AppReferralsData? data;

  factory AppReferralsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return AppReferralsResponse(
      success: json['success'] == true,
      data: raw is Map
          ? AppReferralsData.fromJson(Map<String, dynamic>.from(raw))
          : null,
    );
  }
}

class AppReferralsData {
  AppReferralsData({
    required this.stats,
    required this.earnedAmount,
    required this.filters,
    required this.referrals,
    required this.pagination,
  });

  final AppReferralStats? stats;
  final num earnedAmount;
  final AppReferralFilters? filters;
  final List<Map<String, dynamic>> referrals;
  final AppReferralPagination? pagination;

  factory AppReferralsData.fromJson(Map<String, dynamic> json) {
    final refRaw = json['referrals'];
    final list = refRaw is List ? refRaw : const [];
    return AppReferralsData(
      stats: json['stats'] is Map
          ? AppReferralStats.fromJson(
              Map<String, dynamic>.from(json['stats'] as Map),
            )
          : null,
      earnedAmount: _num(json['earned_amount']),
      filters: json['filters'] is Map
          ? AppReferralFilters.fromJson(
              Map<String, dynamic>.from(json['filters'] as Map),
            )
          : null,
      referrals: list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      pagination: json['pagination'] is Map
          ? AppReferralPagination.fromJson(
              Map<String, dynamic>.from(json['pagination'] as Map),
            )
          : null,
    );
  }
}

class AppReferralStats {
  AppReferralStats({
    required this.total,
    required this.credited,
    required this.pending,
  });

  final int total;
  final int credited;
  final int pending;

  factory AppReferralStats.fromJson(Map<String, dynamic> json) =>
      AppReferralStats(
        total: _int(json['total']),
        credited: _int(json['credited']),
        pending: _int(json['pending']),
      );
}

class AppReferralFilters {
  AppReferralFilters({
    required this.status,
    required this.rewardTrigger,
  });

  final String? status;
  final String? rewardTrigger;

  factory AppReferralFilters.fromJson(Map<String, dynamic> json) =>
      AppReferralFilters(
        status: json['status']?.toString(),
        rewardTrigger: json['reward_trigger']?.toString(),
      );
}

class AppReferralPagination {
  AppReferralPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  factory AppReferralPagination.fromJson(Map<String, dynamic> json) =>
      AppReferralPagination(
        currentPage: _int(json['current_page']),
        lastPage: _int(json['last_page']),
        perPage: _int(json['per_page']),
        total: _int(json['total']),
        from: json['from'] == null ? null : _int(json['from']),
        to: json['to'] == null ? null : _int(json['to']),
      );
}

num _num(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}

int _int(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}
