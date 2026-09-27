// import 'dart:convert';

// // Helper function to parse the raw JSON string directly
// AiConsultationListResponse aiConsultationListResponseFromJson(String str) =>
//     AiConsultationListResponse.fromJson(json.decode(str));

// // Main response class
// class AiConsultationListResponse {
//   final bool success;
//   final AiConsultationData? data;

//   AiConsultationListResponse({
//     required this.success,
//     this.data,
//   });

//   factory AiConsultationListResponse.fromJson(Map<String, dynamic> json) =>
//       AiConsultationListResponse(
//         success: json["success"] ?? false,
//         data: json["data"] != null ? AiConsultationData.fromJson(json["data"]) : null,
//       );
// }

// // Data class containing the list and total count
// class AiConsultationData {
//   final int totalCount;
//   final List<AiConsultation> list;

//   AiConsultationData({
//     required this.totalCount,
//     required this.list,
//   });

//   factory AiConsultationData.fromJson(Map<String, dynamic> json) =>
//       AiConsultationData(
//         totalCount: json["total_count"] ?? 0,
//         list: json["list"] != null
//             ? List<AiConsultation>.from(
//                 json["list"].map((x) => AiConsultation.fromJson(x)))
//             : [],
//       );
// }

// // The actual consultation object class
// class AiConsultation {
//   final int consultationId;
//   final dynamic astrologerID;
//   final String name;
//   final String dateTime;
//   final int charges;
//   final int duration;
//   final String amount;
//   final int status;
//   final String action;
//   final bool review;

//   AiConsultation({
//     required this.consultationId,
//     required this.name,
//     required this.dateTime,
//     required this.charges,
//     required this.duration,
//     required this.amount,
//     required this.status,
//     required this.action,
//     required this.review,
//     required this.astrologerID,
//   });

//   factory AiConsultation.fromJson(Map<String, dynamic> json) => AiConsultation(
//         consultationId: json["consultation_id"] ?? 0,
//         name: json["name"] ?? "N/A",
//         dateTime: json["date_time"] ?? "",
//         charges: json["charges"] ?? 0,
//         duration: json["duration"] ?? 0,
//         amount: json["amount"] ?? "0.00",
//         status: json["status"] ?? 0,
//         action: json["action"] ?? "N/A",
//         review: json["review"] ?? false,
//         astrologerID: json["astrologer_id"] ?? 0,
//       );
// }

import 'dart:convert';

// Helper function to parse the raw JSON string directly
AiConsultationListResponse aiConsultationListResponseFromJson(String str) =>
    AiConsultationListResponse.fromJson(json.decode(str));

// Main response class
class AiConsultationListResponse {
  final dynamic success;
  final AiConsultationData? data;

  AiConsultationListResponse({
    required this.success,
    this.data,
  });

  factory AiConsultationListResponse.fromJson(Map<String, dynamic> json) =>
      AiConsultationListResponse(
        success: json["success"],
        data: json["data"] != null ? AiConsultationData.fromJson(json["data"]) : null,
      );
}

// Data class containing the list and total count
class AiConsultationData {
  final dynamic totalCount;
  final List<AiConsultation> list;

  AiConsultationData({
    required this.totalCount,
    required this.list,
  });

  factory AiConsultationData.fromJson(Map<String, dynamic> json) =>
      AiConsultationData(
        totalCount: json["total_count"],
        list: json["list"] != null
            ? List<AiConsultation>.from(
                json["list"].map((x) => AiConsultation.fromJson(x)))
            : [],
      );
}

// The actual consultation object class
class AiConsultation {
  final dynamic consultationId;
  final dynamic astrologerID;
  final dynamic name;
  final dynamic dateTime;
  final dynamic charges;
  final dynamic duration;
  final dynamic amount;
  final dynamic status;
  final dynamic action;
  final dynamic review;

  AiConsultation({
    required this.consultationId,
    required this.astrologerID,
    required this.name,
    required this.dateTime,
    required this.charges,
    required this.duration,
    required this.amount,
    required this.status,
    required this.action,
    required this.review,
  });

  factory AiConsultation.fromJson(Map<String, dynamic> json) => AiConsultation(
        consultationId: json["consultation_id"],
        astrologerID: json["astrologer_id"],
        name: json["name"],
        dateTime: json["date_time"],
        charges: json["charges"],
        duration: json["duration"],
        amount: json["amount"],
        status: json["status"],
        action: json["action"],
        review: json["review"],
      );
}
