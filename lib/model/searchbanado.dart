// lib/model/search_model.dart


enum SearchItemType { astrologer, aiAstrologer, product, pooja, service, unknown }

class UnifiedSearchResult {
  final int id;
  final String name;
  final String? slug; 
  final SearchItemType type;
  final String? image;

  UnifiedSearchResult({
    required this.id,
    required this.name,
    this.slug,
    required this.type,
    this.image
  });


  factory UnifiedSearchResult.fromJson(Map<String, dynamic> json, SearchItemType type) {
    return UnifiedSearchResult(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      slug: json['slug'],
      image: json['image'],
      type: type,
    );
  }
}