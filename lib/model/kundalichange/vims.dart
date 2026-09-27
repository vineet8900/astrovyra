class VimshottariModel {
  final DashaDetail mahadasha;
  final DashaDetail antardasha;
  final DashaDetail paryantardasha;
  final DashaDetail shookshamadasha;
  final DashaDetail pranadasha;

  VimshottariModel({
    required this.mahadasha,
    required this.antardasha,
    required this.paryantardasha,
    required this.shookshamadasha,
    required this.pranadasha,
  });

  factory VimshottariModel.fromJson(Map<String, dynamic> json) {
    return VimshottariModel(
      mahadasha: DashaDetail.fromJson(
          (json['mahadasha'] as Map?)?.cast<dynamic, dynamic>() ?? const {}),
      antardasha: DashaDetail.fromJson(
          (json['antardasha'] as Map?)?.cast<dynamic, dynamic>() ?? const {}),
      paryantardasha: DashaDetail.fromJson(
          (json['paryantardasha'] as Map?)?.cast<dynamic, dynamic>() ??
              const {}),
      shookshamadasha: DashaDetail.fromJson(
          (json['Shookshamadasha'] as Map?)?.cast<dynamic, dynamic>() ??
              const {}),
      pranadasha: DashaDetail.fromJson(
          (json['Pranadasha'] as Map?)?.cast<dynamic, dynamic>() ?? const {}),
    );
  }
}

class DashaDetail {
  final dynamic name;
  final dynamic start;
  final dynamic end;

  DashaDetail({
    required this.name,
    required this.start,
    required this.end,
  });

  factory DashaDetail.fromJson(Map<dynamic, dynamic> json) {
    return DashaDetail(
      name: json['name'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }
}
