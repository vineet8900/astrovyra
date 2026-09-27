// import 'dart:convert';

// // Helper function to parse the JSON list
// List<CertifiedGemstone> certifiedGemstoneFromJson(String str) =>
//     List<CertifiedGemstone>.from(
//         json.decode(str).map((x) => CertifiedGemstone.fromJson(x)));

// String certifiedGemstoneToJson(List<CertifiedGemstone> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class CertifiedGemstone {
//   int? id;
//   int? imageId;
//   String? sku;
//   String? title;
//   String? slug;
//   String? basePrice;
//   String? salePrice;
//   String? salePriceStartDate;
//   String? salePriceEndDate;
//   dynamic affiliateMarketUrl;
//   int? categoryId;
//   dynamic brandId;
//   String? type;
//   String? status;
//   int? reviewsCount;
//   String? metaTitle;
//   String? metaKeywords;
//   String? metaDescription;
//   String? createdAt;
//   String? updatedAt;
//   int? avaibility; // Kept original spelling from API
//   int? isFeatured;
//   int? order;
//   int? isBestSeller;
//   int? hsnId;
//   String? hsnCode;
//   String? gstPercentage;
//   int? applyShipping;
//   int? shippingBasedOn;
//   String? weight;
//   String? length;
//   String? height;
//   String? breadth;
//   int? parentId;
//   int? hasVariation;
//   dynamic modelNo;
//   dynamic isbn;
//   int? minOrderQty;
//   int? maxOrderQty;
//   dynamic subType;
//   dynamic expireAt;
//   dynamic videoCallUrl;
//   int? panditId;
//   dynamic panditName;
//   dynamic place;
//   int? deliveryDateId;
//   int? minimumQuantity;
//   int? apiUrlId;
//   int? renew;
//   int? vendorId;
//   dynamic altText;

//   CertifiedGemstone({
//     this.id,
//     this.imageId,
//     this.sku,
//     this.title,
//     this.slug,
//     this.basePrice,
//     this.salePrice,
//     this.salePriceStartDate,
//     this.salePriceEndDate,
//     this.affiliateMarketUrl,
//     this.categoryId,
//     this.brandId,
//     this.type,
//     this.status,
//     this.reviewsCount,
//     this.metaTitle,
//     this.metaKeywords,
//     this.metaDescription,
//     this.createdAt,
//     this.updatedAt,
//     this.avaibility,
//     this.isFeatured,
//     this.order,
//     this.isBestSeller,
//     this.hsnId,
//     this.hsnCode,
//     this.gstPercentage,
//     this.applyShipping,
//     this.shippingBasedOn,
//     this.weight,
//     this.length,
//     this.height,
//     this.breadth,
//     this.parentId,
//     this.hasVariation,
//     this.modelNo,
//     this.isbn,
//     this.minOrderQty,
//     this.maxOrderQty,
//     this.subType,
//     this.expireAt,
//     this.videoCallUrl,
//     this.panditId,
//     this.panditName,
//     this.place,
//     this.deliveryDateId,
//     this.minimumQuantity,
//     this.apiUrlId,
//     this.renew,
//     this.vendorId,
//     this.altText,
//   });

//   factory CertifiedGemstone.fromJson(Map<String, dynamic> json) =>
//       CertifiedGemstone(
//         id: json["id"],
//         imageId: json["image_id"],
//         sku: json["sku"],
//         title: json["title"],
//         slug: json["slug"],
//         basePrice: json["base_price"],
//         salePrice: json["sale_price"],
//         salePriceStartDate: json["sale_price_start_date"],
//         salePriceEndDate: json["sale_price_end_date"],
//         affiliateMarketUrl: json["affiliate_market_url"],
//         categoryId: json["category_id"],
//         brandId: json["brand_id"],
//         type: json["type"],
//         status: json["status"],
//         reviewsCount: json["reviews_count"],
//         metaTitle: json["meta_title"],
//         metaKeywords: json["meta_keywords"],
//         metaDescription: json["meta_description"],
//         createdAt: json["created_at"],
//         updatedAt: json["updated_at"],
//         avaibility: json["avaibility"],
//         isFeatured: json["is_featured"],
//         order: json["order"],
//         isBestSeller: json["is_best_seller"],
//         hsnId: json["hsn_id"],
//         hsnCode: json["hsn_code"],
//         gstPercentage: json["gst_percentage"],
//         applyShipping: json["apply_shipping"],
//         shippingBasedOn: json["shipping_based_on"],
//         weight: json["weight"],
//         length: json["length"],
//         height: json["height"],
//         breadth: json["breadth"],
//         parentId: json["parent_id"],
//         hasVariation: json["has_variation"],
//         modelNo: json["model_no"],
//         isbn: json["isbn"],
//         minOrderQty: json["min_order_qty"],
//         maxOrderQty: json["max_order_qty"],
//         subType: json["sub_type"],
//         expireAt: json["expire_at"],
//         videoCallUrl: json["video_call_url"],
//         panditId: json["pandit_id"],
//         panditName: json["pandit_name"],
//         place: json["place"],
//         deliveryDateId: json["delivery_date_id"],
//         minimumQuantity: json["minimum_quantity"],
//         apiUrlId: json["api_url_id"],
//         renew: json["renew"],
//         vendorId: json["vendor_id"],
//         altText: json["alt_text"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "image_id": imageId,
//         "sku": sku,
//         "title": title,
//         "slug": slug,
//         "base_price": basePrice,
//         "sale_price": salePrice,
//         "sale_price_start_date": salePriceStartDate,
//         "sale_price_end_date": salePriceEndDate,
//         "affiliate_market_url": affiliateMarketUrl,
//         "category_id": categoryId,
//         "brand_id": brandId,
//         "type": type,
//         "status": status,
//         "reviews_count": reviewsCount,
//         "meta_title": metaTitle,
//         "meta_keywords": metaKeywords,
//         "meta_description": metaDescription,
//         "created_at": createdAt,
//         "updated_at": updatedAt,
//         "avaibility": avaibility,
//         "is_featured": isFeatured,
//         "order": order,
//         "is_best_seller": isBestSeller,
//         "hsn_id": hsnId,
//         "hsn_code": hsnCode,
//         "gst_percentage": gstPercentage,
//         "apply_shipping": applyShipping,
//         "shipping_based_on": shippingBasedOn,
//         "weight": weight,
//         "length": length,
//         "height": height,
//         "breadth": breadth,
//         "parent_id": parentId,
//         "has_variation": hasVariation,
//         "model_no": modelNo,
//         "isbn": isbn,
//         "min_order_qty": minOrderQty,
//         "max_order_qty": maxOrderQty,
//         "sub_type": subType,
//         "expire_at": expireAt,
//         "video_call_url": videoCallUrl,
//         "pandit_id": panditId,
//         "pandit_name": panditName,
//         "place": place,
//         "delivery_date_id": deliveryDateId,
//         "minimum_quantity": minimumQuantity,
//         "api_url_id": apiUrlId,
//         "renew": renew,
//         "vendor_id": vendorId,
//         "alt_text": altText,
//       };
// }

import 'dart:convert';

// Helper functions
List<CertifiedGemstone> certifiedGemstoneFromJson(String str) =>
    List<CertifiedGemstone>.from(
        json.decode(str).map((x) => CertifiedGemstone.fromJson(x)));

String certifiedGemstoneToJson(List<CertifiedGemstone> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CertifiedGemstone {
  int? id;
  String? name; // "title" ki jagah ab "name" hai
  String? slug;
  String? image; // "image_id" ki jagah ab direct URL "image" hai
  String? basePrice;
  String? salePrice;
  String? salePriceEndDate;
  dynamic offerEnd;
  int? review;
  dynamic avaibility;

  CertifiedGemstone({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.basePrice,
    this.salePrice,
    this.salePriceEndDate,
    this.offerEnd,
    this.review,
    this.avaibility,
  });

  factory CertifiedGemstone.fromJson(Map<String, dynamic> json) =>
      CertifiedGemstone(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        image: json["image"],
        basePrice: json["base_price"],
        salePrice: json["sale_price"],
        salePriceEndDate: json["sale_price_end_date"],
        offerEnd: json["offer_end"],
        review: json["review"], // ✅ MAP HERE
        avaibility: json["avaibility"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "image": image,
        "base_price": basePrice,
        "sale_price": salePrice,
        "sale_price_end_date": salePriceEndDate,
        "offer_end": offerEnd,
        "review": review, // ✅ ADD HERE
        "avaibility": avaibility,
      };

  bool get isOutOfStock {
    if (avaibility == null) return false;
    final n = int.tryParse(avaibility.toString().trim()) ?? -1;
    return n <= 0;
  }

  bool get hasActiveSaleOffer {
    if (_isOfferEnded()) return false;
    final sp = double.tryParse(salePrice?.replaceAll(',', '') ?? '') ?? 0;
    if (sp <= 0) return false;
    if (_isSaleEndDateExpired()) return false;
    final bp = double.tryParse(basePrice?.replaceAll(',', '') ?? '') ?? 0;
    return bp <= 0 || sp < bp;
  }

  bool _isOfferEnded() {
    final raw = offerEnd?.toString().trim();
    return raw == '1';
  }

  bool _isSaleEndDateExpired() {
    final raw = salePriceEndDate?.trim();
    if (raw == null || raw.isEmpty || raw == '0000-00-00') return false;
    try {
      final date = DateTime.parse(raw);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      return DateTime.now().isAfter(endOfDay);
    } catch (_) {
      return false;
    }
  }
}
