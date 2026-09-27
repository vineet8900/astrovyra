class PrivacyPolicyResponse {
  PrivacyPolicyResponse({
    this.status,
    this.data,
  });

  final bool? status;
  final List<PrivacyPolicyItem>? data;

  factory PrivacyPolicyResponse.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyResponse(
      status: json['status'] as bool?,
      data: json['data'] == null
          ? null
          : (json['data'] as List<dynamic>)
              .map((e) =>
                  PrivacyPolicyItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data?.map((e) => e.toJson()).toList(),
      };
}

class PrivacyPolicyItem {
  PrivacyPolicyItem({
    this.id,
    this.name,
    this.slug,
    this.content,
    this.status,
    this.metaTitle,
    this.metaKeywords,
    this.metaDescription,
    this.template,
    this.imageId,
    this.createdAt,
    this.updatedAt,
    this.shortDescription,
    this.parentPageId,
    this.hideFromList,
    this.showInNavigation,
    this.bannerImageId,
    this.displayInUserApp,
    this.displayInCustomerApp,
  });

  final int? id;
  final String? name;
  final String? slug;
  final String? content;
  final int? status;
  final String? metaTitle;
  final String? metaKeywords;
  final String? metaDescription;
  final String? template;
  final int? imageId;
  final String? createdAt;
  final String? updatedAt;
  final String? shortDescription;
  final int? parentPageId;
  final int? hideFromList;
  final int? showInNavigation;
  final int? bannerImageId;
  final int? displayInUserApp;
  final int? displayInCustomerApp;

  factory PrivacyPolicyItem.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyItem(
      id: json['id'] as int?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      content: json['content'] as String?,
      status: json['status'] is int ? json['status'] as int? : null,
      metaTitle: json['meta_title'] as String?,
      metaKeywords: json['meta_keywords'] as String?,
      metaDescription: json['meta_description'] as String?,
      template: json['template'] as String?,
      imageId: json['image_id'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      shortDescription: json['short_description'] as String?,
      parentPageId: json['parent_page_id'] as int?,
      hideFromList: json['hide_from_list'] as int?,
      showInNavigation: json['show_in_navigation'] as int?,
      bannerImageId: json['banner_image_id'] as int?,
      displayInUserApp: json['display_in_user_app'] as int?,
      displayInCustomerApp: json['display_in_customer_app'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'content': content,
        'status': status,
        'meta_title': metaTitle,
        'meta_keywords': metaKeywords,
        'meta_description': metaDescription,
        'template': template,
        'image_id': imageId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'short_description': shortDescription,
        'parent_page_id': parentPageId,
        'hide_from_list': hideFromList,
        'show_in_navigation': showInNavigation,
        'banner_image_id': bannerImageId,
        'display_in_user_app': displayInUserApp,
        'display_in_customer_app': displayInCustomerApp,
      };
}
