import 'dart:convert';

// Function to parse the main response
SortByResponse sortByResponseFromJson(String str) => SortByResponse.fromJson(json.decode(str));

class SortByResponse {
    final bool success;
    final List<SortByOption> data;

    SortByResponse({
        required this.success,
        required this.data,
    });

    factory SortByResponse.fromJson(Map<String, dynamic> json) => SortByResponse(
        success: json["success"],
        data: List<SortByOption>.from(json["data"].map((x) => SortByOption.fromJson(x))),
    );
}

// Class for each individual sort option
class SortByOption {
    final String label;
    final String value;

    SortByOption({
        required this.label,
        required this.value,
    });

    factory SortByOption.fromJson(Map<String, dynamic> json) => SortByOption(
        label: json["label"],
        value: json["value"],
    );
}