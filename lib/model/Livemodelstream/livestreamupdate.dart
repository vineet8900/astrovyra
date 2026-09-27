// lib/model/update_live_status_model.dart

import 'dart:convert';

UpdateLiveStatusResponse updateLiveStatusResponseFromJson(String str) => UpdateLiveStatusResponse.fromJson(json.decode(str));

class UpdateLiveStatusResponse {
    final bool success;
    final String message;

    UpdateLiveStatusResponse({
        required this.success,
        required this.message,
    });

    factory UpdateLiveStatusResponse.fromJson(Map<String, dynamic> json) => UpdateLiveStatusResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
    );
}