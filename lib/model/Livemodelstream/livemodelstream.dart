import 'dart:convert';

LiveAstrologerResponse liveAstrologerResponseFromJson(String str) =>
    LiveAstrologerResponse.fromJson(json.decode(str));

class LiveAstrologerResponse {
  final bool success;
  final List<LiveAstrologer> data;

  LiveAstrologerResponse({
    required this.success,
    required this.data,
  });

  factory LiveAstrologerResponse.fromJson(Map<String, dynamic> json) {
    var astrologerList = <LiveAstrologer>[];
    if (json['data'] != null && json['data'] is List) {
      astrologerList = List<LiveAstrologer>.from(
          json["data"].map((x) => LiveAstrologer.fromJson(x)));
    }

    return LiveAstrologerResponse(
      success: json["success"] ?? false,
      data: astrologerList,
    );
  }
}

class LiveAstrologer {
  final int liveId;
  final int astrologerId;
  final String astrologerImage;
  final String name;
  final String mode;
  //final List<String> services;
  final String status;
  final String startAt;
  final String endAt;

  LiveAstrologer({
    required this.liveId,
    required this.astrologerId,
    required this.astrologerImage,
    required this.name,
    required this.mode,
    //  required this.services,
    required this.status,
    required this.startAt,
    required this.endAt,
  });

  factory LiveAstrologer.fromJson(Map<String, dynamic> json) => LiveAstrologer(
        liveId: json["live_id"] ?? 0,
        astrologerId: json["astrologer_id"] ?? 0,
        astrologerImage:
            json["astrologer_image"] ?? "",
        name: json["name"] ?? "Unknown",
        mode: json["mode"] ?? "video",

        status: json["status"] ?? "",
        startAt: json["start_at"] ?? "",
        endAt: json["end_at"] ?? "",

        //services: List<String>.from(json['services'] ?? []),
      );
}
