// To parse this JSON data, do
//
//     final walletHistoryResponse = walletHistoryResponseFromJson(jsonString);

import 'dart:convert';

WalletHistoryResponse walletHistoryResponseFromJson(String str) => WalletHistoryResponse.fromJson(json.decode(str));

String walletHistoryResponseToJson(WalletHistoryResponse data) => json.encode(data.toJson());

class WalletHistoryResponse {
    final bool success;
    final Data? data;

    WalletHistoryResponse({
        required this.success,
        this.data,
    });

    factory WalletHistoryResponse.fromJson(Map<String, dynamic> json) => WalletHistoryResponse(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    final List<WalletTransaction> list;
    final int count;
    final int perPage;
    final bool hasMorePages;
    final int currentPage;
    final String? previousPageUrl;
    final String? nextPageUrl;
    final String? lastPageUrl;

    Data({
        required this.list,
        required this.count,
        required this.perPage,
        required this.hasMorePages,
        required this.currentPage,
        this.previousPageUrl,
        this.nextPageUrl,
        this.lastPageUrl,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        list: List<WalletTransaction>.from(json["list"].map((x) => WalletTransaction.fromJson(x))),
        count: json["count"],
        perPage: json["per_page"],
        hasMorePages: json["has_more_pages"],
        currentPage: json["current_page"],
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

class WalletTransaction {
    final int transitionId;
    final String remark;
    final num amount; // Use num to handle both int and double
    final String action;
    final String status;
    final String dateTime;
    final String invoice;

    WalletTransaction({
        required this.transitionId,
        required this.remark,
        required this.amount,
        required this.action,
        required this.status,
        required this.dateTime,
        required this.invoice,
    });

    factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
        transitionId: json["transition_id"],
        remark: json["remark"],
        amount: json["amount"],
        action: json["action"],
        status: json["status"],
        dateTime: json["date_time"],
        invoice: json["invoice"],
    );

    Map<String, dynamic> toJson() => {
        "transition_id": transitionId,
        "remark": remark,
        "amount": amount,
        "action": action,
        "status": status,
        "date_time": dateTime,
        "invoice": invoice,
    };
}