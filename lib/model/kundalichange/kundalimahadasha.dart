class YoginiModel {
  final List<dynamic> dashaList;
  final List<dynamic> endDates;
  final List<dynamic> lords;

  YoginiModel({
    required this.dashaList,
    required this.endDates,
    required this.lords,
  });

  factory YoginiModel.fromJson(Map<String, dynamic> json) {
    return YoginiModel(
      dashaList: List<dynamic>.from(json['dasha_list'] ?? const []),
      endDates: List<dynamic>.from(json['dasha_end_dates'] ?? const []),
      lords: List<dynamic>.from(json['dasha_lord_list'] ?? const []),
    );
  }
}
