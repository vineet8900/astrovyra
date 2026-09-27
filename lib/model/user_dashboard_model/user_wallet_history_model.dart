// To parse this JSON data, do
//
//     final walletHistoryModel = walletHistoryModelFromJson(jsonString);

import 'dart:convert';

WalletHistoryModel walletHistoryModelFromJson(String str) => WalletHistoryModel.fromJson(json.decode(str));

String walletHistoryModelToJson(WalletHistoryModel data) => json.encode(data.toJson());

class WalletHistoryModel {
    bool? success;
    Data? data;

    WalletHistoryModel({
        this.success,
        this.data,
    });

    factory WalletHistoryModel.fromJson(Map<String, dynamic> json) => WalletHistoryModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    List<WalletHistoryList>? list;
    int? count;
    int? perPage;
    bool? hasMorePages;
    dynamic currentPage;
    dynamic previousPageUrl;
   dynamic nextPageUrl;
    dynamic lastPageUrl;

    Data({
        this.list,
        this.count,
        this.perPage,
        this.hasMorePages,
        this.currentPage,
        this.previousPageUrl,
        this.nextPageUrl,
        this.lastPageUrl,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        list: json["list"] == null ? [] : List<WalletHistoryList>.from(json["list"]!.map((x) => WalletHistoryList.fromJson(x))),
        count: json["count"],
        perPage: json["per_page"],
        hasMorePages: json["has_more_pages"],
        currentPage: json["current_page"],
        previousPageUrl: json["previous_page_url"],
        nextPageUrl: json["next_page_url"],
        lastPageUrl: json["last_page_url"],
    );

    Map<String, dynamic> toJson() => {
        "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
        "count": count,
        "per_page": perPage,
        "has_more_pages": hasMorePages,
        "current_page": currentPage,
        "previous_page_url": previousPageUrl,
        "next_page_url": nextPageUrl,
        "last_page_url": lastPageUrl,
    };
}

class WalletHistoryList {
    int? id;
    String? rechargeId;
    String? dateTime;
    String? package;
    String? mode;
    double? debit;
    int? credit;
    Invoice? invoice;

    WalletHistoryList({
        this.id,
        this.rechargeId,
        this.dateTime,
        this.package,
        this.mode,
        this.debit,
        this.credit,
        this.invoice,
    });

    factory WalletHistoryList.fromJson(Map<String, dynamic> json) => WalletHistoryList(
        id: json["id"],
        rechargeId: json["recharge_id"],
        dateTime: json["date_time"],
        package: json["package"],
        mode: json["mode"],
        debit: json["debit"]?.toDouble(),
        credit: json["credit"],
        invoice: json["invoice"] == null ? null : Invoice.fromJson(json["invoice"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "recharge_id": rechargeId,
        "date_time": dateTime,
        "package": package,
        "mode": mode,
        "debit": debit,
        "credit": credit,
        "invoice": invoice?.toJson(),
    };
}

class Invoice {
    bool? has;
    int? id;
    dynamic page;
    String? url;

    Invoice({
        this.has,
        this.id,
        this.page,
        this.url,
    });

    factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        has: json["has"],
        id: json["id"],
        page: json["page"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "has": has,
        "id": id,
        "page": page,
        "url": url,
    };
}

