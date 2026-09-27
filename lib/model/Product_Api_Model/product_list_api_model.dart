import 'dart:convert';

ProductListApiModel productListApiModelFromJson(String str) => ProductListApiModel.fromJson(json.decode(str));

String productListApiModelToJson(ProductListApiModel data) => json.encode(data.toJson());

class ProductListApiModel {
    bool? success;
    ProductDatumList? data;
    String? message;

    ProductListApiModel({
        this.success,
        this.data,
        this.message,
    });

    factory ProductListApiModel.fromJson(Map<String, dynamic> json) => ProductListApiModel(
        success: json["success"],
        data: json["data"] == null ? null : ProductDatumList.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
    };
}

class ProductDatumList {

    num? category;
    dynamic minPrice;
    dynamic maxPrice;
    int? currentPage;
    int? total;
    String? firstPageUrl;
    String? lastPageUrl;
    dynamic prevPageUrl;
    String? nextPageUrl;
    int? perPage;
    List<ProductListsDatum>? products;
    

    ProductDatumList({
   
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

    factory ProductDatumList.fromJson(Map<String, dynamic> json) => ProductDatumList(
   
        category: json["category_id"],
     minPrice: json["minPrice"] is String ? json["minPrice"] : json["minPrice"].toString(),
        maxPrice: json["maxPrice"] is String ? json["maxPrice"] : json["maxPrice"].toString(),
        currentPage: json["current_page"],
        total: json["total"],
        firstPageUrl: json["first_page_url"],
        lastPageUrl: json["last_page_url"],
        prevPageUrl: json["prev_page_url"],
        nextPageUrl: json["next_page_url"],
        perPage: json["per_page"],
        products: json["products"] == null ? [] : List<ProductListsDatum>.from(json["products"]!.map((x) => ProductListsDatum.fromJson(x))),
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

class ProductListsDatum {
     int? id;
    String? slug;
    String? name;
    String? image;
    dynamic basePrice;
    dynamic salePrice;
    dynamic offerEnd;
    String? salePriceEndDate;
    bool? canaddtocart;
    String?expertat;
     bool? canPurchase;
    String? expireAt;
    dynamic place;
    dynamic avaibility;


    ProductListsDatum({
         this.id,
        this.slug,
        this.name,
        this.image,
        this.basePrice,
        this.salePrice,
        this.offerEnd,
        this.salePriceEndDate,
        this.canaddtocart,
        this.expertat,
        this.canPurchase,
        this.expireAt,
        this.place,
        this.avaibility,

    });

    factory ProductListsDatum.fromJson(Map<String, dynamic> json) => ProductListsDatum(
      expertat:json["expire_at"],
         id:json["id"],
        slug: json["slug"],
        name: json["name"],
        image: json["image"],
        basePrice: json["base_price"],
        salePrice: json["sale_price"],
        offerEnd: json["offer_end"],
        salePriceEndDate: json["sale_price_end_date"],
        canaddtocart:json["can_add_to_cart"],
         canPurchase: json["can_purchase"],
        expireAt: json["expire_at"],
        place: json["place"],
        avaibility: json["avaibility"],
    );

    Map<String, dynamic> toJson() => {
      "expire_at":expertat,
        "id":id,
        "slug": slug,
        "name": name,
        "image": image,
        "base_price": basePrice,
        "sale_price": salePrice,
        "offer_end": offerEnd,
        "sale_price_end_date": salePriceEndDate,
        "can_add_to_cart":canaddtocart,
        "can_purchase": canPurchase,
        "expire_at": expireAt,
        "place": place,
        "avaibility": avaibility,

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
}

extension ProductListsDatumStock on ProductListsDatum {
  bool get isOutOfStock {
    if (avaibility == null) return false;
    final n = int.tryParse(avaibility.toString().trim()) ?? -1;
    return n <= 0;
  }
}
