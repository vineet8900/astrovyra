import 'dart:convert';

// Helper functions to parse JSON
List<CertifiedRudraksha> certifiedRudrakshaFromJson(String str) =>
    List<CertifiedRudraksha>.from(
        json.decode(str).map((x) => CertifiedRudraksha.fromJson(x)));

String certifiedRudrakshaToJson(List<CertifiedRudraksha> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CertifiedRudraksha {
  int? id;
  String? name; // Changed from 'title'
  String? slug;
  String? image; // Changed from 'image_id' (Direct URL)
  String? basePrice;
  String? salePrice;
  String? salePriceEndDate;
  dynamic offerEnd;
  int? review;
  dynamic avaibility;

  CertifiedRudraksha({
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

  factory CertifiedRudraksha.fromJson(Map<String, dynamic> json) =>
      CertifiedRudraksha(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        image: json["image"],
        basePrice: json["base_price"],
        salePrice: json["sale_price"],
        salePriceEndDate: json["sale_price_end_date"],
        offerEnd: json["offer_end"],
        review: json["review"],
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
        "review": review,
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
