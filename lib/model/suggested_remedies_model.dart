class SuggestedRemediesResponse {
  final bool status;
  final String message;
  final List<SuggestedRemedyEntry> data;

  SuggestedRemediesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SuggestedRemediesResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'];
    return SuggestedRemediesResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: list is List
          ? list
              .map((e) =>
                  SuggestedRemedyEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : <SuggestedRemedyEntry>[],
    );
  }
}

class SuggestedRemedyEntry {
  final int id;
  final String astrologerName;
  final String createdAt;
  final List<SuggestedRemedyLineItem> products;
  final List<SuggestedRemedyLineItem> reports;
  final List<SuggestedRemedyLineItem> pujas;
  final int isUsed;

  SuggestedRemedyEntry({
    required this.id,
    required this.astrologerName,
    required this.createdAt,
    required this.products,
    required this.reports,
    required this.pujas,
    required this.isUsed,
  });

  factory SuggestedRemedyEntry.fromJson(Map<String, dynamic> json) {
    return SuggestedRemedyEntry(
      id: _parseInt(json['id']),
      astrologerName: json['astrologer_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      products: _parseItems(json['products']),
      reports: _parseItems(json['reports']),
      pujas: _parseItems(json['pujas']),
      isUsed: _parseInt(json['is_used']),
    );
  }

  static List<SuggestedRemedyLineItem> _parseItems(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((e) =>
            SuggestedRemedyLineItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  bool get hasAnyItems =>
      products.isNotEmpty || reports.isNotEmpty || pujas.isNotEmpty;
}

class SuggestedRemedyLineItem {
  final int id;
  final String title;
  final String price;

  SuggestedRemedyLineItem({
    required this.id,
    required this.title,
    required this.price,
  });

  factory SuggestedRemedyLineItem.fromJson(Map<String, dynamic> json) {
    return SuggestedRemedyLineItem(
      id: SuggestedRemedyEntry._parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
    );
  }

  String get displayPrice {
    final p = double.tryParse(price) ?? 0;
    return '₹${p.toStringAsFixed(2)}';
  }
}
