class ActiveReferrals {
  final int creditedCount;
  final int pendingCount;
  final num earnedAmount;
  final int total;

  ActiveReferrals({
    required this.creditedCount,
    required this.pendingCount,
    required this.earnedAmount,
    required this.total,
  });

  factory ActiveReferrals.fromJson(Map<String, dynamic> json) {
    return ActiveReferrals(
      creditedCount: _int(json['credited_count']),
      pendingCount: _int(json['pending_count']),
      earnedAmount: _num(json['earned_amount']) ?? 0,
      total: _int(json['total']),
    );
  }
}

class ProductCommission {
  final num creditedAmount;
  final num pendingAmount;
  final int orders;
  final int creditedCount;
  final int pendingCount;
  final int totalCount;

  ProductCommission({
    required this.creditedAmount,
    required this.pendingAmount,
    required this.orders,
    required this.creditedCount,
    required this.pendingCount,
    required this.totalCount,
  });

  factory ProductCommission.fromJson(Map<String, dynamic> json) {
    return ProductCommission(
      creditedAmount: _num(json['credited_amount']) ?? 0,
      pendingAmount: _num(json['pending_amount']) ?? 0,
      orders: _int(json['orders']),
      creditedCount: _int(json['credited_count']),
      pendingCount: _int(json['pending_count']),
      totalCount: _int(json['total_count']),
    );
  }
}

class ReferEarnData {
  final String referCode;
  final String referralLink;
  final num earnings;
  final num referralWallet;
  final num referralWalletLifetime;
  final num commissionWallet;
  final num commissionWalletLifetime;
  final ActiveReferrals activeReferrals;
  final ProductCommission productCommission;

  ReferEarnData({
    required this.referCode,
    required this.referralLink,
    required this.earnings,
    required this.referralWallet,
    required this.referralWalletLifetime,
    required this.commissionWallet,
    required this.commissionWalletLifetime,
    required this.activeReferrals,
    required this.productCommission,
  });

  factory ReferEarnData.fromJson(Map<String, dynamic> json) {
    final code = (json['refer_code'] ?? json['refercode'])?.toString() ?? '';
    final link = json['referral_link']?.toString() ?? '';
    final ar = json['active_referrals'];
    final pc = json['product_commission'];
    return ReferEarnData(
      referCode: code,
      referralLink: link,
      earnings: _num(json['earnings']) ?? 0,
      referralWallet: _num(json['referral_wallet']) ?? 0,
      referralWalletLifetime: _num(json['referral_wallet_lifetime']) ?? 0,
      commissionWallet: _num(json['commission_wallet']) ?? 0,
      commissionWalletLifetime: _num(json['commission_wallet_lifetime']) ?? 0,
      activeReferrals: ar is Map<String, dynamic>
          ? ActiveReferrals.fromJson(ar)
          : ActiveReferrals(
              creditedCount: 0,
              pendingCount: 0,
              earnedAmount: 0,
              total: 0,
            ),
      productCommission: pc is Map<String, dynamic>
          ? ProductCommission.fromJson(pc)
          : ProductCommission(
              creditedAmount: 0,
              pendingAmount: 0,
              orders: 0,
              creditedCount: 0,
              pendingCount: 0,
              totalCount: 0,
            ),
    );
  }
}

class ReferEarnResponse {
  final bool success;
  final ReferEarnData? data;

  ReferEarnResponse({required this.success, this.data});

  factory ReferEarnResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'];
    return ReferEarnResponse(
      success: json['success'] == true,
      data: d is Map<String, dynamic> ? ReferEarnData.fromJson(d) : null,
    );
  }
}

int _int(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.round();
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

num? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}
