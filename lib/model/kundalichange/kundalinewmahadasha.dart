class AntarDashaTableModel {
  final List<List<String>> antardashas;
  final List<List<String>> antardashaOrder;
  final String birthYear;

  AntarDashaTableModel({
    required this.antardashas,
    required this.antardashaOrder,
    required this.birthYear,
  });

  factory AntarDashaTableModel.fromJson(Map<String, dynamic> json) {
    List<List<String>> parseNestedList(dynamic value) {
      if (value is List) {
        return value
            .map<List<String>>(
              (row) => (row as List).map((e) => e.toString()).toList(),
            )
            .toList();
      }
      return <List<String>>[];
    }

    return AntarDashaTableModel(
      antardashas: parseNestedList(json['antardashas']),
      antardashaOrder: parseNestedList(json['antardasha_order']),
      birthYear: json['birth_year']?.toString() ?? '',
    );
  }
}
