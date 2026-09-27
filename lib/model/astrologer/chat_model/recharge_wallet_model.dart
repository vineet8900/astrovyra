// To parse this JSON data, do
//
//     final rechargeWalletModel = rechargeWalletModelFromJson(jsonString);

import 'dart:convert';

RechargeWalletModel rechargeWalletModelFromJson(String str) => RechargeWalletModel.fromJson(json.decode(str));

String rechargeWalletModelToJson(RechargeWalletModel data) => json.encode(data.toJson());

class RechargeWalletModel {
    bool? success;
    List<RechargeWalletList>? data;

    RechargeWalletModel({
        this.success,
        this.data,
    });

    factory RechargeWalletModel.fromJson(Map<String, dynamic> json) => RechargeWalletModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<RechargeWalletList>.from(json["data"]!.map((x) => RechargeWalletList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

// class RechargeWalletList {
//     dynamic id;
//     String? name;
//     dynamic amount;
//     dynamic extra;
//     dynamic getAmount;
//     dynamic gstPercentage;
//     dynamic gstAmount;
//     dynamic total;

//     RechargeWalletList({
//         this.id,
//         this.name,
//         this.amount,
//         this.extra,
//         this.getAmount,
//         this.gstPercentage,
//         this.gstAmount,
//         this.total,
//     });

//     factory RechargeWalletList.fromJson(Map<String, dynamic> json) => RechargeWalletList(
//         id: json["id"],
//         name: json["name"],
//         amount: json["amount"],
//         extra: json["extra"],
//         getAmount: json["get_amount"],
//         gstPercentage: json["gst_percentage"],
//         gstAmount: json["gst_amount"],
//         total: json["total"],
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "amount": amount,
//         "extra": extra,
//         "get_amount": getAmount,
//         "gst_percentage": gstPercentage,
//         "gst_amount": gstAmount,
//         "total": total,
//     };
// }

class RechargeWalletList {
    dynamic id;
    String? name;
    num? amount;
    num? extra;
    num? getAmount;
    num? gstPercentage;
    num? gstAmount;
    num? total;

    RechargeWalletList({
        this.id,
        this.name,
        this.amount,
        this.extra,
        this.getAmount,
        this.gstPercentage,
        this.gstAmount,
        this.total,
    });

    factory RechargeWalletList.fromJson(Map<String, dynamic> json) {
      num? safeParse(dynamic value) {
        if (value == null) return null;
        return num.tryParse(value.toString());
      }

      return RechargeWalletList(
        id: json["id"],
        name: json["name"],
        amount: safeParse(json["amount"]),
        extra: safeParse(json["extra"]),
        getAmount: safeParse(json["get_amount"]),
        gstPercentage: safeParse(json["gst_percentage"]),
        gstAmount: safeParse(json["gst_amount"]),
        total: safeParse(json["total"]),
      );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "amount": amount,
        "extra": extra,
        "get_amount": getAmount,
        "gst_percentage": gstPercentage,
        "gst_amount": gstAmount,
        "total": total,
    };
}
