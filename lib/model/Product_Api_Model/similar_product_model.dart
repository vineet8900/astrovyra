// To parse this JSON data, do
//
//     final similarProductModel = similarProductModelFromJson(jsonString);

import 'dart:convert';

SimilarProductModel similarProductModelFromJson(String str) => SimilarProductModel.fromJson(json.decode(str));

String similarProductModelToJson(SimilarProductModel data) => json.encode(data.toJson());

class SimilarProductModel {
    bool? success;
    Data? data;
    String? message;

    SimilarProductModel({
        this.success,
        this.data,
        this.message,
    });

    factory SimilarProductModel.fromJson(Map<String, dynamic> json) => SimilarProductModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

class Data {
    String? category;
   dynamic minPrice;
  dynamic maxPrice;
    int? currentPage;
    int? total;
    String? firstPageUrl;
    String? lastPageUrl;
    dynamic prevPageUrl;
    String? nextPageUrl;
    int? perPage;
    List<SimilarProduct>? products;

    Data({
        this.category,
        this.minPrice,
        this.maxPrice,
        this.currentPage,
        this.total,
        this.firstPageUrl,
        this.lastPageUrl,
        this.prevPageUrl,
        this.nextPageUrl,
        this.perPage,
        this.products,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        category: json["category"],
        minPrice: json["minPrice"],
        maxPrice: json["maxPrice"],
        currentPage: json["current_page"],
        total: json["total"],
        firstPageUrl: json["first_page_url"],
        lastPageUrl: json["last_page_url"],
        prevPageUrl: json["prev_page_url"],
        nextPageUrl: json["next_page_url"],
        perPage: json["per_page"],
        products: json["products"] == null ? [] : List<SimilarProduct>.from(json["products"]!.map((x) => SimilarProduct.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "category": category,
        "minPrice": minPrice,
        "maxPrice": maxPrice,
        "current_page": currentPage,
        "total": total,
        "first_page_url": firstPageUrl,
        "last_page_url": lastPageUrl,
        "prev_page_url": prevPageUrl,
        "next_page_url": nextPageUrl,
        "per_page": perPage,
        "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    };
}

class SimilarProduct {
  int ?id;
    String? slug;
    String? name;
    String? image;
    String? type;
    dynamic avaibility;
    dynamic basePrice;
    dynamic salePrice;
    dynamic offerEnd;
    String? salePriceEndDate;

    SimilarProduct({
      this.id,
        this.slug,
        this.name,
        this.image,
        this.type,
        this.avaibility,
        this.basePrice,
        this.salePrice,
        this.offerEnd,
        this.salePriceEndDate,
    });

    factory SimilarProduct.fromJson(Map<String, dynamic> json) => SimilarProduct(
      id:json["id"],
        slug: json["slug"],
        name: json["name"],
        image: json["image"],
        type: json["type"]?.toString(),
        avaibility: json["avaibility"],
        basePrice: json["base_price"],
        salePrice: json["sale_price"],
        offerEnd: json["offer_end"],
        salePriceEndDate: json["sale_price_end_date"],
    );

    Map<String, dynamic> toJson() => {
      "id":id,
        "slug": slug,
        "name": name,
        "image": image,
        "type": type,
        "avaibility": avaibility,
        "base_price": basePrice,
        "sale_price": salePrice,
        "offer_end": offerEnd,
        "sale_price_end_date": salePriceEndDate,
    };

    bool get hasActiveSaleOffer {
      if (_isOfferEnded()) return false;
      final sp = double.tryParse(
              salePrice?.toString().replaceAll(',', '') ?? '') ??
          0;
      if (sp <= 0) return false;
      if (_isSaleEndDateExpired()) return false;
      final bp = double.tryParse(
              basePrice?.toString().replaceAll(',', '') ?? '') ??
          0;
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

    bool get isOutOfStock {
      if (avaibility == null) return false;
      final n = int.tryParse(avaibility.toString().trim()) ?? -1;
      return n <= 0;
    }
}
