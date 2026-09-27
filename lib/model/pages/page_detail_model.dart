import 'dart:convert';

PageDetailResponse pageDetailResponseFromJson(String str) =>
    PageDetailResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String pageDetailResponseToJson(PageDetailResponse data) =>
    json.encode(data.toJson());

class PageDetailResponse {
  PageDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final PageDetailData? data;

  factory PageDetailResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return PageDetailResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: raw is Map ? PageDetailData.fromJson(Map<String, dynamic>.from(raw)) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}

class PageDetailData {
  PageDetailData({
    required this.id,
    required this.title,
    required this.slug,
    required this.body,
    required this.content,
    required this.shortDescription,
    required this.metaTitle,
    required this.metaDescription,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String slug;
  final String? body;
  final String? content;
  final String? shortDescription;
  final String? metaTitle;
  final String? metaDescription;
  final String? updatedAt;

  factory PageDetailData.fromJson(Map<String, dynamic> json) => PageDetailData(
        id: (json['id'] is int)
            ? json['id'] as int
            : int.tryParse((json['id'] ?? '').toString()) ?? 0,
        title: (json['title'] ?? '').toString(),
        slug: (json['slug'] ?? '').toString(),
        body: json['body']?.toString(),
        content: json['content']?.toString(),
        shortDescription: json['short_description']?.toString(),
        metaTitle: json['meta_title']?.toString(),
        metaDescription: json['meta_description']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
        'body': body,
        'content': content,
        'short_description': shortDescription,
        'meta_title': metaTitle,
        'meta_description': metaDescription,
        'updated_at': updatedAt,
      };
}

