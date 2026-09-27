import 'dart:convert';

GiftResponse giftResponseFromJson(String str) => GiftResponse.fromJson(json.decode(str));

class GiftResponse {
    final bool success;
    final List<Gift> data;

    GiftResponse({
        required this.success,
        required this.data,
    });

    factory GiftResponse.fromJson(Map<String, dynamic> json) => GiftResponse(
        success: json["success"],
        data: List<Gift>.from(json["data"].map((x) => Gift.fromJson(x))),
    );
}

class Gift {
    final int id;
    final String icon;
    final String name;
    final String price;

    Gift({
        required this.id,
        required this.icon,
        required this.name,
        required this.price,
    });

    factory Gift.fromJson(Map<String, dynamic> json) => Gift(
        id: json["id"],
        icon: json["icon"],
        name: json["name"],
        price: json["price"],
    );
}