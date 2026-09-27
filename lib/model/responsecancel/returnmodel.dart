import 'dart:convert';

ReturnReasonsResponse returnReasonsResponseFromJson(String str) => ReturnReasonsResponse.fromJson(json.decode(str));

String returnReasonsResponseToJson(ReturnReasonsResponse data) => json.encode(data.toJson());

class ReturnReasonsResponse {
    final bool success;
    final List<ReturnReason> data;

    ReturnReasonsResponse({
        required this.success,
        required this.data,
    });

    factory ReturnReasonsResponse.fromJson(Map<String, dynamic> json) => ReturnReasonsResponse(
        success: json["success"],
        data: List<ReturnReason>.from(json["data"].map((x) => ReturnReason.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class ReturnReason {
    final String name;
    final dynamic value;

    ReturnReason({
        required this.name,
        required this.value,
    });

    factory ReturnReason.fromJson(Map<String, dynamic> json) => ReturnReason(
        name: json["name"],
        value: json["value"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
    };
}