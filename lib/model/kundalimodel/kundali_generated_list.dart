class KundaliGeneratedItem {
  final int kundaliId;
  final String name;
  final String gender;
  final String birthDate;
  final String birthTime;
  final String birthPlace;
  final String language;

  KundaliGeneratedItem({
    required this.kundaliId,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.language,
  });

  factory KundaliGeneratedItem.fromJson(Map<String, dynamic> json) {
    final id = json['kundali_id'];
    final kid = id is int
        ? id
        : id is num
            ? id.toInt()
            : int.tryParse(id?.toString() ?? '') ?? 0;
    return KundaliGeneratedItem(
      kundaliId: kid,
      name: json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      birthDate: json['birth_date']?.toString() ?? '',
      birthTime: json['birth_time']?.toString() ?? '',
      birthPlace: json['birth_place']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
    );
  }
}

class KundaliGeneratedListResult {
  final List<KundaliGeneratedItem> items;
  final int currentPage;
  final int lastPage;

  KundaliGeneratedListResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  factory KundaliGeneratedListResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return KundaliGeneratedListResult(items: [], currentPage: 1, lastPage: 1);
    }
    final rawItems = data['items'];
    final list = <KundaliGeneratedItem>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map<String, dynamic>) {
          final item = KundaliGeneratedItem.fromJson(e);
          if (item.kundaliId > 0) list.add(item);
        }
      }
    }
    final pag = data['pagination'];
    int cur = 1;
    int last = 1;
    if (pag is Map<String, dynamic>) {
      final cp = pag['current_page'];
      final lp = pag['last_page'];
      if (cp is int) {
        cur = cp;
      } else if (cp is num) {
        cur = cp.toInt();
      }
      if (lp is int) {
        last = lp;
      } else if (lp is num) {
        last = lp.toInt();
      }
    }
    return KundaliGeneratedListResult(
      items: list,
      currentPage: cur,
      lastPage: last,
    );
  }
}
