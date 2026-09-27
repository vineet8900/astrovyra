class MahadashaModel {
  final List<dynamic> mahadasha;
  final List<dynamic> mahadashaOrder;
  final dynamic startYear;
  final dynamic dashaStartDate;
  final dynamic dashaRemainingAtBirth;

  MahadashaModel({
    required this.mahadasha,
    required this.mahadashaOrder,
    required this.startYear,
    required this.dashaStartDate,
    required this.dashaRemainingAtBirth,
  });

  factory MahadashaModel.fromJson(Map<dynamic, dynamic> json) {
    return MahadashaModel(
      mahadasha: json['mahadasha'] != null
          ? List<dynamic>.from(json['mahadasha'])
          : [],
      mahadashaOrder: json['mahadasha_order'] != null
          ? List<dynamic>.from(json['mahadasha_order'])
          : [],
      startYear: json['start_year'],
      dashaStartDate: json['dasha_start_date'],
      dashaRemainingAtBirth: json['dasha_remaining_at_birth'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'mahadasha': mahadasha,
      'mahadasha_order': mahadashaOrder,
      'start_year': startYear,
      'dasha_start_date': dashaStartDate,
      'dasha_remaining_at_birth': dashaRemainingAtBirth,
    };
  }
}
