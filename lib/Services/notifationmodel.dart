import 'dart:convert';

NotificationResponse notificationResponseFromJson(String str) =>
    NotificationResponse.fromJson(json.decode(str));

String notificationResponseToJson(NotificationResponse data) =>
    json.encode(data.toJson());

class NotificationResponse {
  bool success;
  String message;
  NotificationData? data;

  NotificationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? NotificationData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class NotificationData {
  List<NotificationItem> list;
  int count;
  int perPage;
  bool hasMorePages;
  int currentPage;
  String? previousPageUrl;
  String? nextPageUrl;
  String? lastPageUrl;

  NotificationData({
    required this.list,
    required this.count,
    required this.perPage,
    required this.hasMorePages,
    required this.currentPage,
    this.previousPageUrl,
    this.nextPageUrl,
    this.lastPageUrl,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        list: json["list"] != null
            ? List<NotificationItem>.from(
                json["list"].map((x) => NotificationItem.fromJson(x)))
            : [],
        count: json["count"] ?? 0,
        perPage: json["per_page"] ?? 10,
        hasMorePages: json["has_more_pages"] ?? false,
        currentPage: json["current_page"] ?? 1,
        previousPageUrl: json["previous_page_url"],
        nextPageUrl: json["next_page_url"],
        lastPageUrl: json["last_page_url"],
      );

  Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
        "count": count,
        "per_page": perPage,
        "has_more_pages": hasMorePages,
        "current_page": currentPage,
        "previous_page_url": previousPageUrl,
        "next_page_url": nextPageUrl,
        "last_page_url": lastPageUrl,
      };
}

class NotificationItem {
  int? id;
  String message;
  DateTime? createdAt;
  String? forType;
  String? appLink;
  String? link;

  NotificationItem({
    this.id,
    required this.message,
    this.createdAt,
    this.forType,
    this.appLink,
    this.link,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json["id"] is int ? json["id"] as int : int.tryParse('${json["id"]}'),
        message: json["message"] ?? "",
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        forType: json["for"]?.toString(),
        appLink: json["app_link"]?.toString(),
        link: json["link"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
        "created_at": createdAt?.toIso8601String(),
        "for": forType,
        "app_link": appLink,
        "link": link,
      };
}
