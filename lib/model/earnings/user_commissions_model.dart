import 'dart:convert';

UserCommissionsResponse userCommissionsResponseFromJson(String str) =>
    UserCommissionsResponse.fromJson(json.decode(str) as Map<String, dynamic>);

class UserCommissionsResponse {
  UserCommissionsResponse({
    required this.success,
    required this.data,
  });

  final bool success;
  final UserCommissionsData? data;

  factory UserCommissionsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return UserCommissionsResponse(
      success: json['success'] == true,
      data: raw is Map ? UserCommissionsData.fromJson(Map<String, dynamic>.from(raw)) : null,
    );
  }
}

class UserCommissionsData {
  UserCommissionsData({
    required this.stats,
    required this.filters,
    required this.categories,
    required this.commissions,
    required this.pagination,
  });

  final CommissionStats? stats;
  final CommissionFilters? filters;
  final List<CommissionCategory> categories;
  final List<CommissionItem> commissions;
  final CommissionPagination? pagination;

  factory UserCommissionsData.fromJson(Map<String, dynamic> json) {
    final catRaw = json['categories'];
    final comRaw = json['commissions'];
    return UserCommissionsData(
      stats: json['stats'] is Map
          ? CommissionStats.fromJson(Map<String, dynamic>.from(json['stats'] as Map))
          : null,
      filters: json['filters'] is Map
          ? CommissionFilters.fromJson(Map<String, dynamic>.from(json['filters'] as Map))
          : null,
      categories: (catRaw is List ? catRaw : const [])
          .whereType<Map>()
          .map((e) => CommissionCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      commissions: (comRaw is List ? comRaw : const [])
          .whereType<Map>()
          .map((e) => CommissionItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pagination: json['pagination'] is Map
          ? CommissionPagination.fromJson(Map<String, dynamic>.from(json['pagination'] as Map))
          : null,
    );
  }
}

class CommissionStats {
  CommissionStats({
    required this.total,
    required this.credited,
    required this.pending,
    required this.totalOrders,
  });

  final num total;
  final num credited;
  final num pending;
  final int totalOrders;

  factory CommissionStats.fromJson(Map<String, dynamic> json) => CommissionStats(
        total: _num(json['total']),
        credited: _num(json['credited']),
        pending: _num(json['pending']),
        totalOrders: _int(json['total_orders']),
      );
}

class CommissionFilters {
  CommissionFilters({
    required this.categoryId,
    required this.status,
    required this.dateFrom,
    required this.dateTo,
  });

  final int? categoryId;
  final String? status;
  final String? dateFrom;
  final String? dateTo;

  factory CommissionFilters.fromJson(Map<String, dynamic> json) => CommissionFilters(
        categoryId: json['category_id'] == null ? null : _int(json['category_id']),
        status: json['status']?.toString(),
        dateFrom: json['date_from']?.toString(),
        dateTo: json['date_to']?.toString(),
      );
}

class CommissionCategory {
  CommissionCategory({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory CommissionCategory.fromJson(Map<String, dynamic> json) => CommissionCategory(
        id: _int(json['id']),
        name: (json['name'] ?? '').toString(),
      );
}

class CommissionItem {
  CommissionItem({
    required this.id,
    required this.status,
    required this.orderId,
    required this.orderNumber,
    required this.productTitle,
    required this.categoryName,
    required this.categoryId,
    required this.orderAmount,
    required this.commissionMode,
    required this.commissionRate,
    required this.commissionRateDisplay,
    required this.commissionAmount,
    required this.createdAt,
    required this.dateDisplay,
    required this.detailUrl,
  });

  final int id;
  final String status;
  final int? orderId;
  final String? orderNumber;
  final String? productTitle;
  final String? categoryName;
  final int? categoryId;
  final num orderAmount;
  final String? commissionMode;
  final num commissionRate;
  final String? commissionRateDisplay;
  final num commissionAmount;
  final String? createdAt;
  final String? dateDisplay;
  final String? detailUrl;

  factory CommissionItem.fromJson(Map<String, dynamic> json) => CommissionItem(
        id: _int(json['id']),
        status: (json['status'] ?? '').toString(),
        orderId: json['order_id'] == null ? null : _int(json['order_id']),
        orderNumber: json['order_number']?.toString(),
        productTitle: json['product_title']?.toString(),
        categoryName: json['category_name']?.toString(),
        categoryId: json['category_id'] == null ? null : _int(json['category_id']),
        orderAmount: _num(json['order_amount']),
        commissionMode: json['commission_mode']?.toString(),
        commissionRate: _num(json['commission_rate']),
        commissionRateDisplay: json['commission_rate_display']?.toString(),
        commissionAmount: _num(json['commission_amount']),
        createdAt: json['created_at']?.toString(),
        dateDisplay: json['date_display']?.toString(),
        detailUrl: json['detail_url']?.toString(),
      );
}

class CommissionPagination {
  CommissionPagination({
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

  factory CommissionPagination.fromJson(Map<String, dynamic> json) => CommissionPagination(
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

