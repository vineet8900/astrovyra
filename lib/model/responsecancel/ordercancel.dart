import 'dart:convert';

CancelReasonsResponse cancelReasonsResponseFromJson(String str) => CancelReasonsResponse.fromJson(json.decode(str));

String cancelReasonsResponseToJson(CancelReasonsResponse data) => json.encode(data.toJson());

class CancelReasonsResponse {
    final bool success;
    final List<CancelReason> data;

    CancelReasonsResponse({
        required this.success,
        required this.data,
    });

    factory CancelReasonsResponse.fromJson(Map<String, dynamic> json) => CancelReasonsResponse(
        success: json["success"],
        data: List<CancelReason>.from(json["data"].map((x) => CancelReason.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class CancelReason {
    final String name;
    final dynamic value;

    CancelReason({
        required this.name,
        required this.value,
    });

    factory CancelReason.fromJson(Map<String, dynamic> json) => CancelReason(
        name: json["name"],
        value: json["value"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
    };
}