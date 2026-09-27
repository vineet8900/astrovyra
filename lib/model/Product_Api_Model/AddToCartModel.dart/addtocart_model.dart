// // To parse this JSON data, do
// //
// //     final addtoCartModel = addtoCartModelFromJson(jsonString);

// import 'dart:convert';
// AddtoCartModel addtoCartModelFromJson(String str) => AddtoCartModel.fromJson(json.decode(str));

// String addtoCartModelToJson(AddtoCartModel data) => json.encode(data.toJson());

// class AddtoCartModel {
//     bool? success;
//     String? message;
//     AddtoCartDatum? addtoCartDatum;
//     String? totalQuantity;
//     int?itemid;

//     AddtoCartModel({
//         this.success,
//         this.message,
//         this.addtoCartDatum,
//         this.totalQuantity,
//         this.itemid
//     });

//     factory AddtoCartModel.fromJson(Map<String, dynamic> json) => AddtoCartModel(
//         success: json["success"],
//         message: json["message"],
//         addtoCartDatum: json["AddtoCartDatum"] == null ? null : AddtoCartDatum.fromJson(json["AddtoCartDatum"]),
//         totalQuantity: json["totalQuantity"],
//         itemid: json["item_id"]
//     );

//     Map<String, dynamic> toJson() => {
//         "success": success,
//         "message": message,
//         "AddtoCartDatum": addtoCartDatum?.toJson(),
//         "totalQuantity": totalQuantity,
//         "item_id":itemid
//     };
// }

// class AddtoCartDatum {
//     int? id;
//     String? name;
//     String? slug;
//     String? image;
//     String? basePrice;
//     String? salePrice;
//     int? discount;
//     int? quantity;
//     String? canIncrease;

//     AddtoCartDatum({
//         this.id,
//         this.name,
//         this.slug,
//         this.image,
//         this.basePrice,
//         this.salePrice,
//         this.discount,
//         this.quantity,
//         this.canIncrease,
//     });

//     factory AddtoCartDatum.fromJson(Map<String, dynamic> json) => AddtoCartDatum(
//         id: json["id"],
//         name: json["name"],
//         slug: json["slug"],
//         image: json["image"],
//         basePrice: json["base_price"],
//         salePrice: json["sale_price"],
//         discount: json["discount"],
//         quantity: json["quantity"],
//         canIncrease: json["can_increase"],
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "slug": slug,
//         "image": image,
//         "base_price": basePrice,
//         "sale_price": salePrice,
//         "discount": discount,
//         "quantity": quantity,
//         "can_increase": canIncrease,
//     };
// }



import 'dart:convert';

AddtoCartModel addtoCartModelFromJson(String str) => AddtoCartModel.fromJson(json.decode(str));

String addtoCartModelToJson(AddtoCartModel data) => json.encode(data.toJson());

class AddtoCartModel {
    bool? success;
    String? message;
    AddtoCartDatum? data;  // ✅ CHANGED FROM addtoCartDatum to data
    String? totalQuantity;
    int? itemid;

    AddtoCartModel({
        this.success,
        this.message,
        this.data,  // ✅ UPDATED
        this.totalQuantity,
        this.itemid
        
    });

    factory AddtoCartModel.fromJson(Map<String, dynamic> json) => AddtoCartModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : AddtoCartDatum.fromJson(json["data"]), // ✅ UPDATED
        totalQuantity: json["totalQuantity"],
        itemid: json["item_id"] // ✅ CHANGED TO match API response
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(), // ✅ UPDATED
        "totalQuantity": totalQuantity,
        "item_id": itemid
    };
}

class AddtoCartDatum {
    int? id;
    int? itemId;  // ✅ ADDED
    String? name;
    String? slug;
    String? image;
    String? basePrice;
    String? salePrice;
    int? discount;
    int? quantity;
    String? canIncrease;

    AddtoCartDatum({
        this.id,
        this.itemId,  // ✅ ADDED
        this.name,
        this.slug,
        this.image,
        this.basePrice,
        this.salePrice,
        this.discount,
        this.quantity,
        this.canIncrease,
    });

    factory AddtoCartDatum.fromJson(Map<String, dynamic> json) => AddtoCartDatum(
        id: json["id"],
        itemId: json["item_id"], // ✅ ADDED
        name: json["name"],
        slug: json["slug"],
        image: json["image"],
        basePrice: json["base_price"],
        salePrice: json["sale_price"],
        discount: json["discount"],
        quantity: json["quantity"],
        canIncrease: json["can_increase"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "item_id": itemId, // ✅ ADDED
        "name": name,
        "slug": slug,
        "image": image,
        "base_price": basePrice,
        "sale_price": salePrice,
        "discount": discount,
        "quantity": quantity,
        "can_increase": canIncrease,
    };
}