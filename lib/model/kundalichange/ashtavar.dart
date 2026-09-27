class AshtakvargaApiResponse {
  final List<String> ashtakvargaOrder;
  final List<List<int>> ashtakvargaPoints;
  final List<int> ashtakvargaTotal;

  const AshtakvargaApiResponse({
    required this.ashtakvargaOrder,
    required this.ashtakvargaPoints,
    required this.ashtakvargaTotal,
  });

  factory AshtakvargaApiResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload =
        (json['data'] is Map<String, dynamic>) ? json['data'] : json;

    final order = (payload['ashtakvarga_order'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    final pointsRaw = (payload['ashtakvarga_points'] as List?) ?? <dynamic>[];
    final points = pointsRaw
        .map((row) =>
            (row as List?)?.map((e) => int.tryParse('$e') ?? 0).toList() ??
            <int>[])
        .toList();

    final total = (payload['ashtakvarga_total'] as List?)
            ?.map((e) => int.tryParse('$e') ?? 0)
            .toList() ??
        <int>[];

    return AshtakvargaApiResponse(
      ashtakvargaOrder: order,
      ashtakvargaPoints: points,
      ashtakvargaTotal: total,
    );
  }
}
