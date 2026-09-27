import 'dart:convert';

OrderDetailResponse orderDetailResponseFromJson(String str) =>
    OrderDetailResponse.fromJson(json.decode(str));

class OrderDetailResponse {
  final bool success;
  final OrderData data;

  OrderDetailResponse({
    required this.success,
    required this.data,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      OrderDetailResponse(
        success: json["success"] ?? false,
        data: OrderData.fromJson(json["data"]),
      );
}

class OrderFormData {
  final List<OrderFormItem> formItems;
  final String videoCallUrl;
  final String place;
  final String startAt;

  OrderFormData({
    required this.formItems,
    required this.videoCallUrl,
    required this.place,
    required this.startAt,
  });

  factory OrderFormData.fromJson(Map<dynamic, dynamic> json) {
    var list = json['formdata'] as List? ?? [];
    List<OrderFormItem> itemsList =
        list.map((i) => OrderFormItem.fromJson(i)).toList();

    return OrderFormData(
      formItems: itemsList,
      videoCallUrl: json['video_call_url'] ?? "",
      place: json['place'] ?? "",
      startAt: json['start_at'] ?? "",
    );
  }
}

class OrderFormItem {
  final String name;
  final String label;
  final String value;

  OrderFormItem({
    required this.name,
    required this.label,
    required this.value,
  });

  factory OrderFormItem.fromJson(Map<String, dynamic> json) {
    return OrderFormItem(
      name: json['name'] ?? "",
      label: json['label'] ?? "",
      value: json['value'] ?? "",
    );
  }
}

class OrderData {
  final int orderId;
  final String date;
  final String orderNumber;
  final String status;
  final String pdfUrl;
  final String paymentMethod;
  final Cancel cancel;
  final ReturnData returnData;
  final Address billingAddress;
  final Address shippingAddress;
  final String productType;
  final String subTotal;
  final String discount;
  final String gstTaxes;
  final String shippingPrice;
  final String totalPrice;
  final bool canReview;
  final Invoice invoice;
  final List<Track> track;
  final List<OrderItem> items;
  final OrderFormData? formData;
  final String codCharge;

  OrderData({
    required this.orderId,
    required this.date,
    required this.orderNumber,
    required this.status,
    required this.pdfUrl,
    required this.paymentMethod,
    required this.cancel,
    required this.returnData,
    required this.productType,
    required this.billingAddress,
    required this.shippingAddress,
    required this.subTotal,
    required this.discount,
    required this.gstTaxes,
    required this.shippingPrice,
    required this.totalPrice,
    required this.canReview,
    required this.invoice,
    required this.track,
    required this.items,
    this.formData,
    required this.codCharge,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
        orderId: json["order_id"] ?? 0,
        date: json["date"] ?? "",
        orderNumber: json["order_number"] ?? "",
        status: json["status"] ?? "",
        pdfUrl: json["pdf_url"] ?? "",
        paymentMethod: json["payment_method"] ?? "",
        productType: json["product_type"] ?? "",
        cancel: Cancel.fromJson(json["cancel"] ?? {}),
        returnData: ReturnData.fromJson(json["return"] ?? {}),
        billingAddress: Address.fromJson(json["billing_address"] ?? {}),
        shippingAddress: Address.fromJson(json["shipping_address"] ?? {}),
        subTotal: json["sub_total"] ?? "",
        discount: json["discount"] ?? "",
        gstTaxes: json["gst_taxes"] ?? "",
        shippingPrice: json["shipping_price"] ?? "",
        totalPrice: json["total_price"] ?? "",
        canReview: json["can_review"] ?? false,
        codCharge: json["cod_charge"] ?? "",
        invoice: Invoice.fromJson(json["invoice"] ?? {}),
        track: json["track"] != null
            ? List<Track>.from(json["track"].map((x) => Track.fromJson(x)))
            : [],
        formData: json['formdata'] != null && json['formdata'] is Map
            ? OrderFormData.fromJson(json['formdata'])
            : null,
        items: json["items"] != null
            ? List<OrderItem>.from(
                json["items"].map((x) => OrderItem.fromJson(x)))
            : [],
      );
}

class Address {
  final String name;
  final String address;
  final String country;
  final String state;
  final String city;
  final String zipcode;
  final String landmark;
  final String phoneNumber;
  final String billingLandmark;
  final String billingPhoneNumber;
  final String email;
  final String billingEmail;

  Address({
    required this.name,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.zipcode,
    required this.landmark,
    required this.phoneNumber,
    required this.billingLandmark,
    required this.billingPhoneNumber,
    required this.email,
    required this.billingEmail,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        name: json["name"] ?? "",
        address: json["address"] ?? "",
        country: json["country"] ?? "",
        state: json["state"] ?? "",
        city: json["city"] ?? "",
        zipcode: json["zipcode"] ?? "",
        landmark: json["landmark"] ?? "",
        phoneNumber: json["phone_number"] ?? "",
        billingLandmark: json["billing_landmark"] ?? "",
        billingPhoneNumber: json["billing_phone_number"] ?? "",
        email: json["email"] ?? "",
        billingEmail: json["billing_email"] ?? "",
      );
}

class Cancel {
  final bool can;
  final bool request;
  final String reason;
  final String message;
  final String status;

  Cancel({
    required this.can,
    required this.request,
    required this.reason,
    required this.message,
    required this.status,
  });

  factory Cancel.fromJson(Map<String, dynamic> json) => Cancel(
        can: json["can"] ?? false,
        request: json["request"] ?? false,
        reason: json["reason"] ?? "",
        message: json["message"] ?? "",
        status: json["status"] ?? "",
      );
}

class ReturnData {
  final bool can;
  final bool request;
  final String reason;
  final String message;
  final String status;

  ReturnData({
    required this.can,
    required this.request,
    required this.reason,
    required this.message,
    required this.status,
  });

  factory ReturnData.fromJson(Map<String, dynamic> json) => ReturnData(
        can: json["can"] ?? false,
        request: json["request"] ?? false,
        reason: json["reason"] ?? "",
        message: json["message"] ?? "",
        status: json["status"] ?? "",
      );
}

class Invoice {
  final bool has;
  final int id;
  final String page;
  final String url;

  Invoice({
    required this.has,
    required this.id,
    required this.page,
    required this.url,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        has: json["has"] ?? false,
        id: json["id"] ?? 0,
        page: json["page"] ?? "",
        url: json["url"] ?? "",
      );
}

class OrderItem {
  final Item item;
  final List<UserDataField> userData;

  OrderItem({
    required this.item,
    required this.userData,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        item: Item.fromJson(json["item"] ?? {}),
        userData: json["user_data"] != null
            ? List<UserDataField>.from(
                (json["user_data"] as List)
                    .map((x) => UserDataField.fromJson(x)))
            : <UserDataField>[],
      );
}

class Item {
  final int parentId;
  final int itemId;
  final String slug;
  final String image;
  final String name;
  final String price;
  final bool review;
  final String carat;
  final String size;
  final String color;
  final String weight;
  /// Variations from API (e.g. size, carat, color, weight). Used for display in order detail.
  final Map<String, String> variations;

  Item({
    required this.parentId,
    required this.itemId,
    required this.slug,
    required this.image,
    required this.name,
    required this.price,
    required this.review,
    required this.carat,
    String? size,
    String? color,
    String? weight,
    Map<String, String>? variations,
  })  : size = size ?? '',
        color = color ?? '',
        weight = weight ?? '',
        variations = variations ?? {};

  factory Item.fromJson(Map<String, dynamic> json) {
    // Only use what API sends inside "variations" – no merging of direct fields (so attar doesn't show carat etc.)
    final rawVariations = json["variations"];
    Map<String, String> variationsMap = {};
    if (rawVariations != null && rawVariations is Map) {
      for (final e in (rawVariations as Map).entries) {
        if (e.value != null) variationsMap["${e.key}"] = "${e.value}";
      }
    }
    final size = (json["size"]?.toString().trim() ?? "").isNotEmpty
        ? json["size"].toString().trim()
        : variationsMap["size"] ?? "";
    final carat = (json["carat"]?.toString().trim() ?? "").isNotEmpty
        ? json["carat"].toString().trim()
        : variationsMap["carat"] ?? "";
    final color = (json["color"]?.toString().trim() ?? "").isNotEmpty
        ? json["color"].toString().trim()
        : variationsMap["color"] ?? "";
    final weight = (json["weight"]?.toString().trim() ?? "").isNotEmpty
        ? json["weight"].toString().trim()
        : variationsMap["weight"] ?? "";

    return Item(
      parentId: json["parent_id"] ?? 0,
      itemId: json["item_id"] ?? 0,
      slug: json["slug"] ?? "",
      image: json["image"] ?? "",
      name: json["name"] ?? "",
      price: json["price"] ?? "",
      review: json["review"] ?? false,
      carat: carat,
      size: size,
      color: color,
      weight: weight,
      variations: variationsMap,
    );
  }

  /// Returns display-friendly list of variation labels (e.g. "Size: 6 ML", "Carat: 08-09").
  List<String> get variationLabels {
    final list = <String>[];
    for (final e in variations.entries) {
      if (e.key.trim().isEmpty || e.value.trim().isEmpty) continue;
      final label = e.key.length == 1
          ? e.key.toUpperCase()
          : "${e.key[0].toUpperCase()}${e.key.substring(1)}";
      list.add("$label: ${e.value}");
    }
    return list;
  }

  /// Name with variation shown only once – if name already contains the variation text, returns name only.
  String get displayTitle {
    if (variationLabels.isEmpty) return name;
    final suffix = variationLabels.join(", ");
    if (name.contains(suffix)) return name;
    return "$name ($suffix)";
  }
}

class UserDataField {
  final String label;
  final String value;

  UserDataField({
    required this.label,
    required this.value,
  });

  factory UserDataField.fromJson(Map<String, dynamic> json) => UserDataField(
        label: json["label"] ?? "",
        value: json["value"] ?? "",
      );
}

class Track {
  final String status;
  final String createdAt;

  Track({
    required this.status,
    required this.createdAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        status: json["status"] ?? "",
        createdAt: json["created_at"] ?? "",
      );
}
