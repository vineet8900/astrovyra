// To parse this JSON data, do
//
//     final cartListModel = cartListModelFromJson(jsonString);

import 'dart:convert';

CartListModel cartListModelFromJson(String str) => CartListModel.fromJson(json.decode(str));

String cartListModelToJson(CartListModel data) => json.encode(data.toJson());

class CartListModel {
    bool? success;
    String? message;
    List<CartListingDatum>? data;
    int? total;
    int? discount;
    int? tax;
    int? subTotal;
    int? shipping;
    String? totalQuantity;


    CartListModel({
        this.success,
        this.message,
        this.data,
        this.total,
        this.discount,
        this.tax,
        this.subTotal,
        this.shipping,
        this.totalQuantity,
    });

    factory CartListModel.fromJson(Map<String, dynamic> json) => CartListModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? [] : List<CartListingDatum>.from(json["data"]!.map((x) => CartListingDatum.fromJson(x))),
        total: json["total"],
        discount: json["discount"],
        tax: json["tax"],
        subTotal: json["subTotal"],
        shipping: json["shipping"],
        totalQuantity: json["totalQuantity"],
      
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "total": total,
        "discount": discount,
        "tax": tax,
        "subTotal": subTotal,
        "shipping": shipping,
        "totalQuantity": totalQuantity,
      
    };
}

// Your existing CartListModel class up here remains the same...

class CartListingDatum {
    int? itemid;
    int? id;
    String? name;
    String? slug;
    String? image;
    dynamic basePrice;
    dynamic salePrice;
    int? discount;
    int? quantity;
    String? canIncrease;
    String? stamp;
    
    // --- 1. YEH LINE ADD KI HAI ---
    final List<dynamic>? formData;

    CartListingDatum({
      this.itemid,
        this.id,
        this.name,
        this.slug,
        this.image,
        this.basePrice,
        this.salePrice,
        this.discount,
        this.quantity,
        this.canIncrease,
        this.stamp,

        // --- 2. YEH LINE CONSTRUCTOR MEIN ADD KI HAI ---
        this.formData,
    });

    factory CartListingDatum.fromJson(Map<String, dynamic> json) => CartListingDatum(
       itemid: json["item_id"],
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        image: json["image"],
        basePrice: json["base_price"],
        salePrice: json["sale_price"],
        discount: json["discount"],
        quantity: json["quantity"],
        canIncrease: json["can_increase"],
        stamp: json["stamp"],

        // --- 3. YEH LINE API SE DATA PARSE KARNE KE LIYE ADD KI HAI ---
        formData: json["form_data"] == null ? [] : List<dynamic>.from(json["form_data"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
      "item_id":itemid,
        "id": id,
        "name": name,
        "slug": slug,
        "image": image,
        "base_price": basePrice,
        "sale_price": salePrice,
        "discount": discount,
        "quantity": quantity,
        "can_increase": canIncrease,
        "stamp":stamp,
        
        // --- 4. (Optional but good practice) YEH LINE BHI ADD KAR DI HAI ---
        "form_data": formData == null ? [] : List<dynamic>.from(formData!.map((x) => x)),
    };
}