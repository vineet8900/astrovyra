import 'dart:convert';

UserEarningsResponse userEarningsResponseFromJson(String str) =>
    UserEarningsResponse.fromJson(json.decode(str) as Map<String, dynamic>);

class UserEarningsResponse {
  UserEarningsResponse({
    required this.success,
    required this.data,
  });

  final bool success;
  final UserEarningsData? data;

  factory UserEarningsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return UserEarningsResponse(
      success: json['success'] == true,
      data: raw is Map ? UserEarningsData.fromJson(Map<String, dynamic>.from(raw)) : null,
    );
  }
}

class UserEarningsData {
  UserEarningsData({
    required this.summary,
    required this.stats,
    required this.filters,
    required this.transactions,
    required this.pagination,
  });

  final EarningsSummary? summary;
  final EarningsStats? stats;
  final EarningsFilters? filters;
  final List<EarningsTransaction> transactions;
  final EarningsPagination? pagination;

  factory UserEarningsData.fromJson(Map<String, dynamic> json) {
    final txRaw = json['transactions'];
    final txList = txRaw is List ? txRaw : const [];
    return UserEarningsData(
      summary: json['summary'] is Map
          ? EarningsSummary.fromJson(Map<String, dynamic>.from(json['summary'] as Map))
          : null,
      stats: json['stats'] is Map
          ? EarningsStats.fromJson(Map<String, dynamic>.from(json['stats'] as Map))
          : null,
      filters: json['filters'] is Map
          ? EarningsFilters.fromJson(Map<String, dynamic>.from(json['filters'] as Map))
          : null,
      transactions: txList
          .whereType<Map>()
          .map((e) => EarningsTransaction.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pagination: json['pagination'] is Map
          ? EarningsPagination.fromJson(
              Map<String, dynamic>.from(json['pagination'] as Map),
            )
          : null,
    );
  }
}

class EarningsSummary {
  EarningsSummary({
    required this.totalEarnings,
    required this.referralWallet,
    required this.commissionWallet,
  });

  final num totalEarnings;
  final EarningsWallet? referralWallet;
  final EarningsWallet? commissionWallet;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) => EarningsSummary(
        totalEarnings: _num(json['total_earnings']),
        referralWallet: json['referral_wallet'] is Map
            ? EarningsWallet.fromJson(
                Map<String, dynamic>.from(json['referral_wallet'] as Map),
              )
            : null,
        commissionWallet: json['commission_wallet'] is Map
            ? EarningsWallet.fromJson(
                Map<String, dynamic>.from(json['commission_wallet'] as Map),
              )
            : null,
      );
}

class EarningsWallet {
  EarningsWallet({
    required this.balance,
    required this.lifetime,
  });

  final num balance;
  final num lifetime;

  factory EarningsWallet.fromJson(Map<String, dynamic> json) => EarningsWallet(
        balance: _num(json['balance']),
        lifetime: _num(json['lifetime']),
      );
}

class EarningsStats {
  EarningsStats({
    required this.totalReferrals,
    required this.activeReferrals,
    required this.commissionOrders,
  });

  final int totalReferrals;
  final int activeReferrals;
  final int commissionOrders;

  factory EarningsStats.fromJson(Map<String, dynamic> json) => EarningsStats(
        totalReferrals: _int(json['total_referrals']),
        activeReferrals: _int(json['active_referrals']),
        commissionOrders: _int(json['commission_orders']),
      );
}

class EarningsFilters {
  EarningsFilters({
    required this.walletType,
    required this.transactionType,
    required this.dateFrom,
    required this.dateTo,
  });

  final String? walletType;
  final String? transactionType;
  final String? dateFrom;
  final String? dateTo;

  factory EarningsFilters.fromJson(Map<String, dynamic> json) => EarningsFilters(
        walletType: json['wallet_type']?.toString(),
        transactionType: json['transaction_type']?.toString(),
        dateFrom: json['date_from']?.toString(),
        dateTo: json['date_to']?.toString(),
      );
}

class EarningsPagination {
  EarningsPagination({
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

  factory EarningsPagination.fromJson(Map<String, dynamic> json) => EarningsPagination(
        currentPage: _int(json['current_page']),
        lastPage: _int(json['last_page']),
        perPage: _int(json['per_page']),
        total: _int(json['total']),
        from: json['from'] == null ? null : _int(json['from']),
        to: json['to'] == null ? null : _int(json['to']),
      );
}

class EarningsTransaction {
  EarningsTransaction({
    required this.raw,
    required this.id,
    required this.amount,
    required this.amountSigned,
    required this.balanceAfter,
    required this.walletType,
    required this.walletLabel,
    required this.transactionType,
    required this.typeLabel,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dateDisplay,
    required this.referenceLine,
    required this.viewUrl,
  });

  final Map<String, dynamic> raw;
  final int? id;
  final num? amount;
  final num? amountSigned;
  final num? balanceAfter;
  final String? walletType;
  final String? walletLabel;
  final String? transactionType;
  final String? typeLabel;
  final String? title;
  final String? description;
  final String? createdAt;
  final String? dateDisplay;
  final String? referenceLine;
  final String? viewUrl;

  factory EarningsTransaction.fromJson(Map<String, dynamic> json) => EarningsTransaction(
        raw: json,
        id: json['id'] == null ? null : _int(json['id']),
        amount: json['amount'] == null ? null : _num(json['amount']),
        amountSigned: json['amount_signed'] == null ? null : _num(json['amount_signed']),
        balanceAfter: json['balance_after'] == null ? null : _num(json['balance_after']),
        walletType: json['wallet_type']?.toString(),
        walletLabel: (json['wallet_label'] ?? json['wallet'])?.toString(),
        transactionType: json['transaction_type']?.toString(),
        typeLabel: (json['type_label'] ?? json['type'])?.toString(),
        title: (json['title'] ?? json['name'] ?? json['remark'])?.toString(),
        description: (json['description'] ?? json['details'] ?? json['message'])?.toString(),
        createdAt: (json['created_at'] ?? json['date'] ?? json['updated_at'])?.toString(),
        dateDisplay: (json['date_display'] ?? json['dateDisplay'])?.toString(),
        referenceLine: (json['reference_line'] ?? json['referenceLine'])?.toString(),
        viewUrl: (json['view_url'] ?? json['viewUrl'])?.toString(),
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

