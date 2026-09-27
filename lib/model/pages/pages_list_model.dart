import 'dart:convert';

PagesListResponse pagesListResponseFromJson(String str) =>
    PagesListResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String pagesListResponseToJson(PagesListResponse data) =>
    json.encode(data.toJson());

class PagesListResponse {
  PagesListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final List<PageItem> data;

  factory PagesListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List ? raw : const [];
    return PagesListResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: list
          .whereType<Map>()
          .map((e) => PageItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((x) => x.toJson()).toList(),
      };
}

class PageItem {
  PageItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.shortDescription,
  });

  final int id;
  final String title;
  final String slug;
  final String? shortDescription;

  factory PageItem.fromJson(Map<String, dynamic> json) => PageItem(
        id: (json['id'] is int)
            ? json['id'] as int
            : int.tryParse((json['id'] ?? '').toString()) ?? 0,
        title: (json['title'] ?? '').toString(),
        slug: (json['slug'] ?? '').toString(),
        shortDescription: json['short_description']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
        'short_description': shortDescription,
      };
}

