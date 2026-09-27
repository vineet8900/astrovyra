// To parse this JSON data, do
//
//     final checkoutOrderSummaryApiModel = checkoutOrderSummaryApiModelFromJson(jsonString);

// import 'dart:convert';

// CheckoutOrderSummaryApiModel checkoutOrderSummaryApiModelFromJson(String str) => CheckoutOrderSummaryApiModel.fromJson(json.decode(str));

// String checkoutOrderSummaryApiModelToJson(CheckoutOrderSummaryApiModel data) => json.encode(data.toJson());

// class CheckoutOrderSummaryApiModel {
//     bool? success;
//     String? message;
//     Data? data;

//     CheckoutOrderSummaryApiModel({
//         this.success,
//         this.message,
//         this.data,
//     });

//     factory CheckoutOrderSummaryApiModel.fromJson(Map<String, dynamic> json) => CheckoutOrderSummaryApiModel(
//         success: json["success"],
//         message: json["message"],
//         data: json["data"] == null ? null : Data.fromJson(json["data"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "success": success,
//         "message": message,
//         "data": data?.toJson(),
//     };
// }

// class Data {
//     num? subTotal;
//     num? discount;
//     num? couponAmount;
//     num? taxes;
//     num? shippingPrice;
//     num? total;

//     Data({
//         this.subTotal,
//         this.discount,
//         this.couponAmount,
//         this.taxes,
//         this.shippingPrice,
//         this.total,
//     });

//     factory Data.fromJson(Map<String, dynamic> json) {
//         num? safeParse(dynamic value) {
//             if (value == null) return null;
//             if (value is num) return value;
//             if (value is String) return num.tryParse(value);
//             return null;
//         }

//         return Data(
//             subTotal: safeParse(json["subTotal"]),
//             discount: safeParse(json["discount"]),
//             couponAmount: safeParse(json["coupon_amount"]),
//             taxes: safeParse(json["taxes"]),
//             shippingPrice: safeParse(json["shippingPrice"]),
//             total: safeParse(json["total"]),
//         );
//     }

//     Map<String, dynamic> toJson() => {
//         "subTotal": subTotal,
//         "discount": discount,
//         "coupon_amount": couponAmount,
//         "taxes": taxes,
//         "shippingPrice": shippingPrice,
//         "total": total,
//     };
// }


// // class Data {
// //     dynamic subTotal;
// //     dynamic discount;
// //     dynamic couponAmount;
// //     dynamic taxes;
// //     dynamic shippingPrice;
// //     dynamic total;

// //     Data({
// //         this.subTotal,
// //         this.discount,
// //         this.couponAmount,
// //         this.taxes,
// //         this.shippingPrice,
// //         this.total,
// //     });

// //     factory Data.fromJson(Map<String, dynamic> json) => Data(
// //         subTotal: json["subTotal"],
// //         discount: json["discount"],
// //         couponAmount: json["coupon_amount"],
// //         taxes: json["taxes"],
// //         shippingPrice: json["shippingPrice"],
// //         total: json["total"],
// //     );

// //     Map<String, dynamic> toJson() => {
// //         "subTotal": subTotal,
// //         "discount": discount,
// //         "coupon_amount": couponAmount,
// //         "taxes": taxes,
// //         "shippingPrice": shippingPrice,
// //         "total": total,
// //     };


import 'dart:convert';

CheckoutOrderSummaryApiModel checkoutOrderSummaryApiModelFromJson(String str) => CheckoutOrderSummaryApiModel.fromJson(json.decode(str));

String checkoutOrderSummaryApiModelToJson(CheckoutOrderSummaryApiModel data) => json.encode(data.toJson());

class CheckoutOrderSummaryApiModel {
    bool? success;
    String? message;
    Data? data;

    CheckoutOrderSummaryApiModel({
        this.success,
        this.message,
        this.data,
    });

    factory CheckoutOrderSummaryApiModel.fromJson(Map<String, dynamic> json) => CheckoutOrderSummaryApiModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    num? subTotal;
    num? discount;
    num? couponAmount;
    num? taxes;
    num? shippingPrice;
    num? codCharge;
    num? total;

    Data({
        this.subTotal,
        this.discount,
        this.couponAmount,
        this.taxes,
        this.shippingPrice,
        this.codCharge,
        this.total,
    });

    factory Data.fromJson(Map<String, dynamic> json) {
        // This function now handles strings with commas
        num? safeParse(dynamic value) {
            if (value == null) return null;
            if (value is num) return value;
            if (value is String) {
                final cleanValue = value.replaceAll(',', '');
                return num.tryParse(cleanValue);
            }
            return null;
        }

        return Data(
            subTotal: safeParse(json["subTotal"]),
            discount: safeParse(json["discount"]),
            couponAmount: safeParse(json["coupon_amount"]),
            taxes: safeParse(json["taxes"]),
            shippingPrice: safeParse(json["shippingPrice"]),
            codCharge: safeParse(json["cod_charge"]),
            total: safeParse(json["total"]),
        );
    }

    Map<String, dynamic> toJson() => {
        "subTotal": subTotal,
        "discount": discount,
        "coupon_amount": couponAmount,
        "taxes": taxes,
        "shippingPrice": shippingPrice,
        "cod_charge": codCharge,
        "total": total,
    };
}
