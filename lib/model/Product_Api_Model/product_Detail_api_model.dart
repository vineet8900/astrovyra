// // To parse this JSON data, do
// //
// //     final productDetailModel = productDetailModelFromJson(jsonString);

// import 'dart:convert';

// ProductDetailModel productDetailModelFromJson(String str) =>
//     ProductDetailModel.fromJson(json.decode(str));

// String productDetailModelToJson(ProductDetailModel data) =>
//     json.encode(data.toJson());

// class ProductDetailModel {
//   bool? success;
//   ProductDetailDatum? data;
//   String? message;

//   ProductDetailModel({
//     this.success,
//     this.data,
//     this.message,
//   });

//   factory ProductDetailModel.fromJson(Map<String, dynamic> json) =>
//       ProductDetailModel(
//         success: json["success"],
//         data: json["data"] == null
//             ? null
//             : ProductDetailDatum.fromJson(json["data"]),
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "data": data?.toJson(),
//         "message": message,
//       };
// }

// class ProductDetailDatum {
//   int? parentId;
//   dynamic id;
//   String? slug;
//   String? sku;
//   String? title;
//   String? image;
//   List<String>? galleries;
//   bool? hasVariation;
//   Attribute? attribute;
//   Attributes? attributes;
//   dynamic rating;
//   dynamic reviewsCount;
//   RatingOverview? ratingOverview;
//   dynamic basePrice;
//   dynamic salePrice;
//   dynamic affiliateMarketUrl;
//   Category? category;
//   String? type;
//   bool? canAddMore;
//   dynamic itemId;
//   dynamic itemQuantity;
//   bool? showForm;
//   Form? form;
//   dynamic avaibility;
//   String? shortDescription;
//   String? description;
//   List<Feature>? features;
//   List<Specification>? specifications;

//   ProductDetailDatum({
//     this.parentId,
//     this.id,
//     this.slug,
//     this.sku,
//     this.title,
//     this.image,
//     this.galleries,
//     this.attribute,
//     this.hasVariation,
//     this.attributes,
//     this.rating,
//     this.reviewsCount,
//     this.ratingOverview,
//     this.basePrice,
//     this.salePrice,
//     this.affiliateMarketUrl,
//     this.category,
//     this.type,
//     this.canAddMore,
//     this.itemId,
//     this.itemQuantity,
//     this.showForm,
//     this.form,
//     this.avaibility,
//     this.shortDescription,
//     this.description,
//     this.features,
//     this.specifications,
//   });

//   factory ProductDetailDatum.fromJson(Map<String, dynamic> json) =>
//       ProductDetailDatum(
//         parentId: json["parent_id"],
//         id: json["id"],
//         slug: json["slug"],
//         sku: json["sku"],
//         title: json["title"],
//         image: json["image"],
//         galleries: json["galleries"] == null
//             ? []
//             : List<String>.from(json["galleries"]!.map((x) => x)),
//         hasVariation: json["has_variation"],
//         attribute: json["attribute"] == null
//             ? null
//             : Attribute.fromJson(json["attribute"]),
//         attributes: json["attributes"] == null
//             ? null
//             : Attributes.fromJson(json["attributes"]),
//         rating: json["rating"]?.toDouble(),
//         reviewsCount: json["reviews_count"],
//         ratingOverview: json["rating_overview"] == null
//             ? null
//             : RatingOverview.fromJson(json["rating_overview"]),
//         basePrice: json["base_price"],
//         salePrice: json["sale_price"],
//         affiliateMarketUrl: json["affiliate_market_url"],
//         category: json["category"] == null
//             ? null
//             : Category.fromJson(json["category"]),
//         type: json["type"],
//         canAddMore: json["can_add_more"],
//         itemId: json["item_id"],
//         itemQuantity: json["item_quantity"],
//         showForm: json["show_form"],
//         form: json["form"] == null ? null : Form.fromJson(json["form"]),
//         avaibility: json["avaibility"],
//         shortDescription: json["short_description"],
//         description: json["description"],
//         features: json["features"] == null
//             ? []
//             : List<Feature>.from(
//                 json["features"]!.map((x) => Feature.fromJson(x))),
//         specifications: json["specifications"] == null
//             ? []
//             : List<Specification>.from(
//                 json["specifications"]!.map((x) => Specification.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "parent_id": parentId,
//         "id": id,
//         "slug": slug,
//         "sku": sku,
//         "title": title,
//         "image": image,
//         "galleries": galleries == null
//             ? []
//             : List<dynamic>.from(galleries!.map((x) => x)),
//         "has_variation": hasVariation,
//         "attribute": attribute?.toJson(),
//         "attributes": attributes?.toJson(),
//         "rating": rating,
//         "reviews_count": reviewsCount,
//         "rating_overview": ratingOverview?.toJson(),
//         "base_price": basePrice,
//         "sale_price": salePrice,
//         "affiliate_market_url": affiliateMarketUrl,
//         "category": category?.toJson(),
//         "type": type,
//         "can_add_more": canAddMore,
//         "item_id": itemId,
//         "item_quantity": itemQuantity,
//         "show_form": showForm,
//         "form": form?.toJson(),
//         "avaibility": avaibility,
//         "short_description": shortDescription,
//         "description": description,
//         "features": features == null
//             ? []
//             : List<dynamic>.from(features!.map((x) => x.toJson())),
//         "specifications": specifications == null
//             ? []
//             : List<dynamic>.from(specifications!.map((x) => x.toJson())),
//       };
// }

// class Attribute {
//   String? color;
//   String? size;
//   String? weight;
//   String? type;

//   Attribute({
//     this.color,
//     this.size,
//     this.weight,
//     this.type,
//   });

//   factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
//         color: json["Color"],
//         size: json["Size"],
//         weight: json["Weight"],
//         type: json["Type"],
//       );

//   Map<String, dynamic> toJson() => {
//         "Color": color,
//         "Size": size,
//         "Weight": weight,
//         "Type": type,
//       };
// }

// class Category {
//   String? name;
//   String? slug;
//   String? image;

//   Category({
//     this.name,
//     this.slug,
//     this.image,
//   });

//   factory Category.fromJson(Map<String, dynamic> json) => Category(
//         name: json["name"],
//         slug: json["slug"],
//         image: json["image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "slug": slug,
//         "image": image,
//       };
// }

// class Feature {
//   String? image;
//   String? heading;

//   Feature({
//     this.image,
//     this.heading,
//   });

//   factory Feature.fromJson(Map<String, dynamic> json) => Feature(
//         image: json["image"],
//         heading: json["heading"],
//       );

//   Map<String, dynamic> toJson() => {
//         "image": image,
//         "heading": heading,
//       };
// }

// class Form {
//   List<Field>? fields;

//   Form({
//     this.fields,
//   });

//   factory Form.fromJson(Map<String, dynamic> json) => Form(
//         fields: json["fields"] == null
//             ? []
//             : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "fields": fields == null
//             ? []
//             : List<dynamic>.from(fields!.map((x) => x.toJson())),
//       };
// }

// class Field {
//   String? type;
//   String? key;
//   String? label;
//   bool? required;

//   Field({
//     this.type,
//     this.key,
//     this.label,
//     this.required,
//   });

//   factory Field.fromJson(Map<String, dynamic> json) => Field(
//         type: json["type"],
//         key: json["key"],
//         label: json["label"],
//         required: json["required"],
//       );

//   Map<String, dynamic> toJson() => {
//         "type": type,
//         "key": key,
//         "label": label,
//         "required": required,
//       };
// }

// class RatingOverview {
//   dynamic one;
//   dynamic two;
//   dynamic three;
//   dynamic four;
//   dynamic five;

//   RatingOverview({
//     this.one,
//     this.two,
//     this.three,
//     this.four,
//     this.five,
//   });

//   factory RatingOverview.fromJson(Map<String, dynamic> json) => RatingOverview(
//         one: json["one"],
//         two: json["two"],
//         three: json["three"],
//         four: json["four"],
//         five: json["five"],
//       );

//   Map<String, dynamic> toJson() => {
//         "one": one,
//         "two": two,
//         "three": three,
//         "four": four,
//         "five": five,
//       };
// }

// class Specification {
//   String? heading;
//   String? text;

//   Specification({
//     this.heading,
//     this.text,
//   });

//   factory Specification.fromJson(Map<String, dynamic> json) => Specification(
//         heading: json["heading"],
//         text: json["text"],
//       );

//   Map<String, dynamic> toJson() => {
//         "heading": heading,
//         "text": text,
//       };
// }

// class Attributes {
//   List<Attributedatum>? color;
//   List<Attributedatum>? size;
//   List<Attributedatum>? type;
//   List<Attributedatum>? weight;

//   Attributes({this.color, this.size, this.type, this.weight});

//   factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
//         color: json["Color"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Color"]!.map((x) => Attributedatum.fromJson(x))),
//         size: json["Size"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Size"]!.map((x) => Attributedatum.fromJson(x))),
//         type: json["Type"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Type"]!.map((x) => Attributedatum.fromJson(x))),
//         weight: json["Weight"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Weight"]!.map((x) => Attributedatum.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "Color": color == null
//             ? []
//             : List<dynamic>.from(color!.map((x) => x.toJson())),
//         "Size": size == null
//             ? []
//             : List<dynamic>.from(size!.map((x) => x.toJson())),
//         "Weight": color == null
//             ? []
//             : List<dynamic>.from(weight!.map((x) => x.toJson())),
//         "Type": size == null
//             ? []
//             : List<dynamic>.from(type!.map((x) => x.toJson())),
//       };
// }

// class Attributedatum {
//   String? name;
//   bool? available;

//   Attributedatum({
//     this.name,
//     this.available,
//   });

//   factory Attributedatum.fromJson(Map<String, dynamic> json) => Attributedatum(
//         name: json["name"],
//         available: json["available"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "available": available,
//       };
// }

// File: product_Detail_api_model.dart

// import 'dart:convert';

// // Helper functions to convert JSON string to model and vice-versa
// ProductDetailModel productDetailModelFromJson(String str) =>
//     ProductDetailModel.fromJson(json.decode(str));

// String productDetailModelToJson(ProductDetailModel data) =>
//     json.encode(data.toJson());

// // Main Model Class
// class ProductDetailModel {
//   bool? success;
//   ProductDetailDatum? data;
//   String? message;

//   ProductDetailModel({
//     this.success,
//     this.data,
//     this.message,
//   });

//   factory ProductDetailModel.fromJson(Map<String, dynamic> json) =>
//       ProductDetailModel(
//         success: json["success"],
//         data: json["data"] == null
//             ? null
//             : ProductDetailDatum.fromJson(json["data"]),
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "data": data?.toJson(),
//         "message": message,
//       };
// }

// // Data Class containing all product details
// class ProductDetailDatum {
//   int? parentId;
//   dynamic id;
//   int? itemType; // Added
//   String? slug;
//   String? sku;
//   String? title;
//   String? image;
//   Video? video; // Added
//   List<String>? galleries;
//   bool? hasVariation;
//   Attribute? attribute;
//   Attributes? attributes;
//   dynamic rating;
//   dynamic reviewsCount;
//   RatingOverview? ratingOverview;
//   dynamic basePrice;
//   dynamic salePrice;
//   dynamic affiliateMarketUrl;
//   Category? category;
//   String? type;
//   bool? canAddMore;
//   dynamic itemId;
//   dynamic itemQuantity;
//   bool? showForm;
//   Form? form;
//   dynamic avaibility;
//   String? shortDescription;
//   String? description;
//   List<Feature>? features;
//   List<Specification>? specifications;
//   String? expireAt; // Added
//   bool? canPurchase;

//   ProductDetailDatum({
//     this.parentId,
//     this.id,
//     this.itemType, // Added
//     this.slug,
//     this.sku,
//     this.title,
//     this.image,
//     this.video, // Added
//     this.galleries,
//     this.hasVariation,
//     this.attribute,
//     this.attributes,
//     this.rating,
//     this.reviewsCount,
//     this.ratingOverview,
//     this.basePrice,
//     this.salePrice,
//     this.affiliateMarketUrl,
//     this.category,
//     this.type,
//     this.canAddMore,
//     this.itemId,
//     this.itemQuantity,
//     this.showForm,
//     this.form,
//     this.avaibility,
//     this.shortDescription,
//     this.description,
//     this.features,
//     this.specifications,
//     this.expireAt, // Added
//     this.canPurchase,
//   });

//   factory ProductDetailDatum.fromJson(Map<String, dynamic> json) =>
//       ProductDetailDatum(
//         parentId: json["parent_id"],
//         id: json["id"],
//         itemType: json["item_type"], // Added
//         slug: json["slug"],
//         sku: json["sku"],
//         title: json["title"],
//         image: json["image"],
//         video: json["video"] == null ? null : Video.fromJson(json["video"]), // Added
//         galleries: json["galleries"] == null
//             ? []
//             : List<String>.from(json["galleries"]!.map((x) => x)),
//         hasVariation: json["has_variation"],
//         attribute: json["attribute"] == null
//             ? null
//             : Attribute.fromJson(json["attribute"]),
//         attributes: json["attributes"] == null
//             ? null
//             : Attributes.fromJson(json["attributes"]),
//         rating: json["rating"],
//         reviewsCount: json["reviews_count"],
//         ratingOverview: json["rating_overview"] == null
//             ? null
//             : RatingOverview.fromJson(json["rating_overview"]),
//         basePrice: json["base_price"],
//         salePrice: json["sale_price"],
//         affiliateMarketUrl: json["affiliate_market_url"],
//         category: json["category"] == null
//             ? null
//             : Category.fromJson(json["category"]),
//         type: json["type"],
//         canAddMore: json["can_add_more"],
//         itemId: json["item_id"],
//         itemQuantity: json["item_quantity"],
//         showForm: json["show_form"],
//         form: json["form"] == null ? null : Form.fromJson(json["form"]),
//         avaibility: json["avaibility"],
//         shortDescription: json["short_description"],
//         description: json["description"],
//         features: json["features"] == null
//             ? []
//             : List<Feature>.from(
//                 json["features"]!.map((x) => Feature.fromJson(x))),
//         specifications: json["specifications"] == null
//             ? []
//             : List<Specification>.from(
//                 json["specifications"]!.map((x) => Specification.fromJson(x))),
//         expireAt: json["expire_at"],
//          // Added
//          canPurchase: json["can_purchase"],
//       );

//   Map<String, dynamic> toJson() => {
//         "parent_id": parentId,
//         "id": id,
//         "item_type": itemType, // Added
//         "slug": slug,
//         "sku": sku,
//         "title": title,
//         "image": image,
//         "video": video?.toJson(), // Added
//         "galleries": galleries == null
//             ? []
//             : List<dynamic>.from(galleries!.map((x) => x)),
//         "has_variation": hasVariation,
//         "attribute": attribute?.toJson(),
//         "attributes": attributes?.toJson(),
//         "rating": rating,
//         "reviews_count": reviewsCount,
//         "rating_overview": ratingOverview?.toJson(),
//         "base_price": basePrice,
//         "sale_price": salePrice,
//         "affiliate_market_url": affiliateMarketUrl,
//         "category": category?.toJson(),
//         "type": type,
//         "can_add_more": canAddMore,
//         "item_id": itemId,
//         "item_quantity": itemQuantity,
//         "show_form": showForm,
//         "form": form?.toJson(),
//         "avaibility": avaibility,
//         "short_description": shortDescription,
//         "description": description,
//         "features": features == null
//             ? []
//             : List<dynamic>.from(features!.map((x) => x.toJson())),
//         "specifications": specifications == null
//             ? []
//             : List<dynamic>.from(specifications!.map((x) => x.toJson())),
//         "expire_at": expireAt, // Added
//       };
// }

// // Video Class (Newly Added)
// class Video {
//   String? type;
//   String? videoUrl;
//   String? videoId;
//   String? title;
//   String? description;
//   String? image;

//   Video({
//     this.type,
//     this.videoUrl,
//     this.videoId,
//     this.title,
//     this.description,
//     this.image,
//   });

//   factory Video.fromJson(Map<String, dynamic> json) => Video(
//         type: json["type"],
//         videoUrl: json["video_url"],
//         videoId: json["video_id"],
//         title: json["title"],
//         description: json["description"],
//         image: json["image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "type": type,
//         "video_url": videoUrl,
//         "video_id": videoId,
//         "title": title,
//         "description": description,
//         "image": image,
//       };
// }

// // Attribute Class
// class Attribute {
//   String? color;
//   String? size;
//   String? weight;
//   String? type;

//   Attribute({
//     this.color,
//     this.size,
//     this.weight,
//     this.type,
//   });

//   factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
//         color: json["Color"],
//         size: json["Size"],
//         weight: json["Weight"],
//         type: json["Type"],
//       );

//   Map<String, dynamic> toJson() => {
//         "Color": color,
//         "Size": size,
//         "Weight": weight,
//         "Type": type,
//       };
// }

// // Attributes Class
// class Attributes {
//   List<Attributedatum>? color;
//   List<Attributedatum>? size;
//   List<Attributedatum>? type;
//   List<Attributedatum>? weight;

//   Attributes({this.color, this.size, this.type, this.weight});

//   factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
//         color: json["Color"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Color"]!.map((x) => Attributedatum.fromJson(x))),
//         size: json["Size"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Size"]!.map((x) => Attributedatum.fromJson(x))),
//         type: json["Type"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Type"]!.map((x) => Attributedatum.fromJson(x))),
//         weight: json["Weight"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Weight"]!.map((x) => Attributedatum.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "Color": color == null
//             ? []
//             : List<dynamic>.from(color!.map((x) => x.toJson())),
//         "Size": size == null
//             ? []
//             : List<dynamic>.from(size!.map((x) => x.toJson())),
//         "Type": type == null
//             ? []
//             : List<dynamic>.from(type!.map((x) => x.toJson())),
//         "Weight": weight == null
//             ? []
//             : List<dynamic>.from(weight!.map((x) => x.toJson())),
//       };
// }

// // Attributedatum Class
// class Attributedatum {
//   String? name;
//   bool? available;

//   Attributedatum({
//     this.name,
//     this.available,
//   });

//   factory Attributedatum.fromJson(Map<String, dynamic> json) => Attributedatum(
//         name: json["name"],
//         available: json["available"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "available": available,
//       };
// }

// // Category Class
// class Category {
//   String? name;
//   String? slug;
//   String? image;

//   Category({
//     this.name,
//     this.slug,
//     this.image,
//   });

//   factory Category.fromJson(Map<String, dynamic> json) => Category(
//         name: json["name"],
//         slug: json["slug"],
//         image: json["image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "slug": slug,
//         "image": image,
//       };
// }

// // Feature Class
// class Feature {
//   String? image;
//   String? heading;

//   Feature({
//     this.image,
//     this.heading,
//   });

//   factory Feature.fromJson(Map<String, dynamic> json) => Feature(
//         image: json["image"],
//         heading: json["heading"],
//       );

//   Map<String, dynamic> toJson() => {
//         "image": image,
//         "heading": heading,
//       };
// }

// // Form Class
// class Form {
//   List<Field>? fields;

//   Form({
//     this.fields,
//   });

//   factory Form.fromJson(Map<String, dynamic> json) => Form(
//         fields: json["fields"] == null
//             ? []
//             : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "fields": fields == null
//             ? []
//             : List<dynamic>.from(fields!.map((x) => x.toJson())),
//       };
// }

// // Field Class
// class Field {
//   String? type;
//   String? key;
//   String? label;
//   bool? required;

//   Field({
//     this.type,
//     this.key,
//     this.label,
//     this.required,
//   });

//   factory Field.fromJson(Map<String, dynamic> json) => Field(
//         type: json["type"],
//         key: json["key"],
//         label: json["label"],
//         required: json["required"],
//       );

//   Map<String, dynamic> toJson() => {
//         "type": type,
//         "key": key,
//         "label": label,
//         "required": required,
//       };
// }

// // RatingOverview Class
// class RatingOverview {
//   dynamic one;
//   dynamic two;
//   dynamic three;
//   dynamic four;
//   dynamic five;

//   RatingOverview({
//     this.one,
//     this.two,
//     this.three,
//     this.four,
//     this.five,
//   });

//   factory RatingOverview.fromJson(Map<String, dynamic> json) => RatingOverview(
//         one: json["one"],
//         two: json["two"],
//         three: json["three"],
//         four: json["four"],
//         five: json["five"],
//       );

//   Map<String, dynamic> toJson() => {
//         "one": one,
//         "two": two,
//         "three": three,
//         "four": four,
//         "five": five,
//       };
// }

// // Specification Class
// class Specification {
//   String? heading;
//   String? text;

//   Specification({
//     this.heading,
//     this.text,
//   });

//   factory Specification.fromJson(Map<String, dynamic> json) => Specification(
//         heading: json["heading"],
//         text: json["text"],
//       );

//   Map<String, dynamic> toJson() => {
//         "heading": heading,
//         "text": text,
//       };
// }

// import 'dart:convert';

// // Helper functions to convert JSON string to model and vice-versa
// ProductDetailModel productDetailModelFromJson(String str) =>
//     ProductDetailModel.fromJson(json.decode(str));

// String productDetailModelToJson(ProductDetailModel data) =>
//     json.encode(data.toJson());

// // Main Model Class
// class ProductDetailModel {
//   bool? success;
//   ProductDetailDatum? data;
//   String? message;

//   ProductDetailModel({
//     this.success,
//     this.data,
//     this.message,
//   });

//   factory ProductDetailModel.fromJson(Map<String, dynamic> json) =>
//       ProductDetailModel(
//         success: json["success"],
//         data: json["data"] == null
//             ? null
//             : ProductDetailDatum.fromJson(json["data"]),
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "data": data?.toJson(),
//         "message": message,
//       };
// }

// // Data Class containing all product details
// class ProductDetailDatum {
//   int? parentId;
//   dynamic id;
//   int? itemType; // Added
//   String? slug;
//   String? sku;
//   String? title;
//   String? image;
//   Video? video; // Added
//   List<String>? galleries;
//   bool? hasVariation;
//   Attribute? attribute;
//   Attributes? attributes;
//   dynamic rating;
//   dynamic reviewsCount;
//   RatingOverview? ratingOverview;
//   dynamic basePrice;
//   dynamic salePrice;
//   dynamic affiliateMarketUrl;
//   Category? category;
//   String? type;
//   bool? canAddMore;
//   dynamic itemId;
//   dynamic itemQuantity;
//   bool? showForm;
//   Form? form;
//   dynamic avaibility;
//   String? shortDescription;
//   String? description;
//   List<Feature>? features;
//   List<Specification>? specifications;
//   String? expireAt; // Added
//   bool? canPurchase;
//   EstimatedDelivery? estimatedDelivery; // Added

//   ProductDetailDatum({
//     this.parentId,
//     this.id,
//     this.itemType, // Added
//     this.slug,
//     this.sku,
//     this.title,
//     this.image,
//     this.video, // Added
//     this.galleries,
//     this.hasVariation,
//     this.attribute,
//     this.attributes,
//     this.rating,
//     this.reviewsCount,
//     this.ratingOverview,
//     this.basePrice,
//     this.salePrice,
//     this.affiliateMarketUrl,
//     this.category,
//     this.type,
//     this.canAddMore,
//     this.itemId,
//     this.itemQuantity,
//     this.showForm,
//     this.form,
//     this.avaibility,
//     this.shortDescription,
//     this.description,
//     this.features,
//     this.specifications,
//     this.expireAt, // Added
//     this.canPurchase,
//     this.estimatedDelivery, // Added
//   });

//   factory ProductDetailDatum.fromJson(Map<String, dynamic> json) =>
//       ProductDetailDatum(
//         parentId: json["parent_id"],
//         id: json["id"],
//         itemType: json["item_type"], // Added
//         slug: json["slug"],
//         sku: json["sku"],
//         title: json["title"],
//         image: json["image"],
//         video: json["video"] == null ? null : Video.fromJson(json["video"]), // Added
//         galleries: json["galleries"] == null
//             ? []
//             : List<String>.from(json["galleries"]!.map((x) => x)),
//         hasVariation: json["has_variation"],
//         attribute: json["attribute"] == null
//             ? null
//             : Attribute.fromJson(json["attribute"]),
//         attributes: json["attributes"] == null
//             ? null
//             : Attributes.fromJson(json["attributes"]),
//         rating: json["rating"],
//         reviewsCount: json["reviews_count"],
//         ratingOverview: json["rating_overview"] == null
//             ? null
//             : RatingOverview.fromJson(json["rating_overview"]),
//         basePrice: json["base_price"],
//         salePrice: json["sale_price"],
//         affiliateMarketUrl: json["affiliate_market_url"],
//         category: json["category"] == null
//             ? null
//             : Category.fromJson(json["category"]),
//         type: json["type"],
//         canAddMore: json["can_add_more"],
//         itemId: json["item_id"],
//         itemQuantity: json["item_quantity"],
//         showForm: json["show_form"],
//         form: json["form"] == null ? null : Form.fromJson(json["form"]),
//         avaibility: json["avaibility"],
//         shortDescription: json["short_description"],
//         description: json["description"],
//         features: json["features"] == null
//             ? []
//             : List<Feature>.from(
//                 json["features"]!.map((x) => Feature.fromJson(x))),
//         specifications: json["specifications"] == null
//             ? []
//             : List<Specification>.from(
//                 json["specifications"]!.map((x) => Specification.fromJson(x))),
//         expireAt: json["expire_at"], // Added
//         canPurchase: json["can_purchase"],
//         estimatedDelivery: json["estimatedDelivery"] == null
//             ? null
//             : EstimatedDelivery.fromJson(json["estimatedDelivery"]), // Added
//       );

//   Map<String, dynamic> toJson() => {
//         "parent_id": parentId,
//         "id": id,
//         "item_type": itemType, // Added
//         "slug": slug,
//         "sku": sku,
//         "title": title,
//         "image": image,
//         "video": video?.toJson(), // Added
//         "galleries": galleries == null
//             ? []
//             : List<dynamic>.from(galleries!.map((x) => x)),
//         "has_variation": hasVariation,
//         "attribute": attribute?.toJson(),
//         "attributes": attributes?.toJson(),
//         "rating": rating,
//         "reviews_count": reviewsCount,
//         "rating_overview": ratingOverview?.toJson(),
//         "base_price": basePrice,
//         "sale_price": salePrice,
//         "affiliate_market_url": affiliateMarketUrl,
//         "category": category?.toJson(),
//         "type": type,
//         "can_add_more": canAddMore,
//         "item_id": itemId,
//         "item_quantity": itemQuantity,
//         "show_form": showForm,
//         "form": form?.toJson(),
//         "avaibility": avaibility,
//         "short_description": shortDescription,
//         "description": description,
//         "features": features == null
//             ? []
//             : List<dynamic>.from(features!.map((x) => x.toJson())),
//         "specifications": specifications == null
//             ? []
//             : List<dynamic>.from(specifications!.map((x) => x.toJson())),
//         "expire_at": expireAt, // Added
//         "can_purchase": canPurchase,
//         "estimatedDelivery": estimatedDelivery?.toJson(), // Added
//       };
// }

// // EstimatedDelivery Class (Newly Added)
// class EstimatedDelivery {
//   String? from;
//   String? to;

//   EstimatedDelivery({
//     this.from,
//     this.to,
//   });

//   factory EstimatedDelivery.fromJson(Map<String, dynamic> json) =>
//       EstimatedDelivery(
//         from: json["from"],
//         to: json["to"],
//       );

//   Map<String, dynamic> toJson() => {
//         "from": from,
//         "to": to,
//       };
// }

// // Video Class (Newly Added)
// class Video {
//   String? type;
//   String? videoUrl;
//   String? videoId;
//   String? title;
//   String? description;
//   String? image;

//   Video({
//     this.type,
//     this.videoUrl,
//     this.videoId,
//     this.title,
//     this.description,
//     this.image,
//   });

//   factory Video.fromJson(Map<String, dynamic> json) => Video(
//         type: json["type"],
//         videoUrl: json["video_url"],
//         videoId: json["video_id"],
//         title: json["title"],
//         description: json["description"],
//         image: json["image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "type": type,
//         "video_url": videoUrl,
//         "video_id": videoId,
//         "title": title,
//         "description": description,
//         "image": image,
//       };
// }

// // Attribute Class
// class Attribute {
//   String? color;
//   String? size;
//   String? weight;
//   String? type;

//   Attribute({
//     this.color,
//     this.size,
//     this.weight,
//     this.type,
//   });

//   factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
//         color: json["Color"],
//         size: json["Size"],
//         weight: json["Weight"],
//         type: json["Type"],
//       );

//   Map<String, dynamic> toJson() => {
//         "Color": color,
//         "Size": size,
//         "Weight": weight,
//         "Type": type,
//       };
// }

// // Attributes Class
// class Attributes {
//   List<Attributedatum>? color;
//   List<Attributedatum>? size;
//   List<Attributedatum>? type;
//   List<Attributedatum>? weight;

//   Attributes({this.color, this.size, this.type, this.weight});

//   factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
//         color: json["Color"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Color"]!.map((x) => Attributedatum.fromJson(x))),
//         size: json["Size"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Size"]!.map((x) => Attributedatum.fromJson(x))),
//         type: json["Type"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Type"]!.map((x) => Attributedatum.fromJson(x))),
//         weight: json["Weight"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Weight"]!.map((x) => Attributedatum.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "Color": color == null
//             ? []
//             : List<dynamic>.from(color!.map((x) => x.toJson())),
//         "Size": size == null
//             ? []
//             : List<dynamic>.from(size!.map((x) => x.toJson())),
//         "Type": type == null
//             ? []
//             : List<dynamic>.from(type!.map((x) => x.toJson())),
//         "Weight": weight == null
//             ? []
//             : List<dynamic>.from(weight!.map((x) => x.toJson())),
//       };
// }

// // Attributedatum Class
// class Attributedatum {
//   String? name;
//   bool? available;

//   Attributedatum({
//     this.name,
//     this.available,
//   });

//   factory Attributedatum.fromJson(Map<String, dynamic> json) => Attributedatum(
//         name: json["name"],
//         available: json["available"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "available": available,
//       };
// }

// // Category Class
// class Category {
//   String? name;
//   String? slug;
//   String? image;

//   Category({
//     this.name,
//     this.slug,
//     this.image,
//   });

//   factory Category.fromJson(Map<String, dynamic> json) => Category(
//         name: json["name"],
//         slug: json["slug"],
//         image: json["image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "slug": slug,
//         "image": image,
//       };
// }

// // Feature Class
// class Feature {
//   String? image;
//   String? heading;

//   Feature({
//     this.image,
//     this.heading,
//   });

//   factory Feature.fromJson(Map<String, dynamic> json) => Feature(
//         image: json["image"],
//         heading: json["heading"],
//       );

//   Map<String, dynamic> toJson() => {
//         "image": image,
//         "heading": heading,
//       };
// }

// // Form Class
// class Form {
//   List<Field>? fields;

//   Form({
//     this.fields,
//   });

//   factory Form.fromJson(Map<String, dynamic> json) => Form(
//         fields: json["fields"] == null
//             ? []
//             : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "fields": fields == null
//             ? []
//             : List<dynamic>.from(fields!.map((x) => x.toJson())),
//       };
// }

// // Field Class
// class Field {
//   String? type;
//   String? key;
//   String? label;
//   bool? required;

//   Field({
//     this.type,
//     this.key,
//     this.label,
//     this.required,
//   });

//   factory Field.fromJson(Map<String, dynamic> json) => Field(
//         type: json["type"],
//         key: json["key"],
//         label: json["label"],
//         required: json["required"],
//       );

//   Map<String, dynamic> toJson() => {
//         "type": type,
//         "key": key,
//         "label": label,
//         "required": required,
//       };
// }

// // RatingOverview Class
// class RatingOverview {
//   dynamic one;
//   dynamic two;
//   dynamic three;
//   dynamic four;
//   dynamic five;

//   RatingOverview({
//     this.one,
//     this.two,
//     this.three,
//     this.four,
//     this.five,
//   });

//   factory RatingOverview.fromJson(Map<String, dynamic> json) => RatingOverview(
//         one: json["one"],
//         two: json["two"],
//         three: json["three"],
//         four: json["four"],
//         five: json["five"],
//       );

//   Map<String, dynamic> toJson() => {
//         "one": one,
//         "two": two,
//         "three": three,
//         "four": four,
//         "five": five,
//       };
// }

// // Specification Class
// class Specification {
//   String? heading;
//   String? text;

//   Specification({
//     this.heading,
//     this.text,
//   });

//   factory Specification.fromJson(Map<String, dynamic> json) => Specification(
//         heading: json["heading"],
//         text: json["text"],
//       );

//   Map<String, dynamic> toJson() => {
//         "heading": heading,
//         "text": text,
//       };
// }

// import 'dart:convert';

// // Helper functions to convert JSON string to model and vice-versa
// ProductDetailModel productDetailModelFromJson(String str) =>
//     ProductDetailModel.fromJson(json.decode(str));

// String productDetailModelToJson(ProductDetailModel data) =>
//     json.encode(data.toJson());

// // Main Model Class
// class ProductDetailModel {
//   bool? success;
//   ProductDetailDatum? data;
//   String? message;

//   ProductDetailModel({
//     this.success,
//     this.data,
//     this.message,
//   });

//   factory ProductDetailModel.fromJson(Map<String, dynamic> json) =>
//       ProductDetailModel(
//         success: json["success"],
//         data: json["data"] == null
//             ? null
//             : ProductDetailDatum.fromJson(json["data"]),
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "data": data?.toJson(),
//         "message": message,
//       };
// }

// // Data Class containing all product details
// class ProductDetailDatum {
//   int? parentId;
//   dynamic id;
//   int? itemType;
//   String? slug;
//   String? sku;
//   String? title;
//   String? image;
//   Video? video;
//   List<String>? galleries;
//   bool? hasVariation;
//   Attribute? attribute;
//   Attributes? attributes;
//   dynamic rating;
//   dynamic reviewsCount;
//   RatingOverview? ratingOverview;
//   dynamic basePrice;
//   dynamic salePrice;
//   String? salePriceStartDate; // Added
//   String? salePriceEndDate; // Added
//   dynamic affiliateMarketUrl;
//   Category? category;
//   String? type;
//   bool? canAddMore;
//   dynamic itemId;
//   dynamic itemQuantity;
//   bool? showForm;
//   Form? form;
//   dynamic avaibility;
//   String? shortDescription;
//   String? description;
//   List<Feature>? features;
//   List<Specification>? specifications;
//   String? expireAt;
//   Panditji? panditji; // Added
//   String? place; // Added
//   bool? canPurchase;
//   EstimatedDelivery? estimatedDelivery;

//   ProductDetailDatum({
//     this.parentId,
//     this.id,
//     this.itemType,
//     this.slug,
//     this.sku,
//     this.title,
//     this.image,
//     this.video,
//     this.galleries,
//     this.hasVariation,
//     this.attribute,
//     this.attributes,
//     this.rating,
//     this.reviewsCount,
//     this.ratingOverview,
//     this.basePrice,
//     this.salePrice,
//     this.salePriceStartDate, // Added
//     this.salePriceEndDate, // Added
//     this.affiliateMarketUrl,
//     this.category,
//     this.type,
//     this.canAddMore,
//     this.itemId,
//     this.itemQuantity,
//     this.showForm,
//     this.form,
//     this.avaibility,
//     this.shortDescription,
//     this.description,
//     this.features,
//     this.specifications,
//     this.expireAt,
//     this.panditji, // Added
//     this.place, // Added
//     this.canPurchase,
//     this.estimatedDelivery,
//   });

//   factory ProductDetailDatum.fromJson(Map<String, dynamic> json) =>
//       ProductDetailDatum(
//         parentId: json["parent_id"],
//         id: json["id"],
//         itemType: json["item_type"],
//         slug: json["slug"],
//         sku: json["sku"],
//         title: json["title"],
//         image: json["image"],
//         video: json["video"] == null ? null : Video.fromJson(json["video"]),
//         galleries: json["galleries"] == null
//             ? []
//             : List<String>.from(json["galleries"]!.map((x) => x)),
//         hasVariation: json["has_variation"],
//         attribute: json["attribute"] == null
//             ? null
//             : Attribute.fromJson(json["attribute"]),
//         attributes: json["attributes"] == null
//             ? null
//             : Attributes.fromJson(json["attributes"]),
//         rating: json["rating"],
//         reviewsCount: json["reviews_count"],
//         ratingOverview: json["rating_overview"] == null
//             ? null
//             : RatingOverview.fromJson(json["rating_overview"]),
//         basePrice: json["base_price"],
//         salePrice: json["sale_price"],
//         salePriceStartDate: json["sale_price_start_date"], // Added
//         salePriceEndDate: json["sale_price_end_date"], // Added
//         affiliateMarketUrl: json["affiliate_market_url"],
//         category: json["category"] == null
//             ? null
//             : Category.fromJson(json["category"]),
//         type: json["type"],
//         canAddMore: json["can_add_more"],
//         itemId: json["item_id"],
//         itemQuantity: json["item_quantity"],
//         showForm: json["show_form"],
//         form: json["form"] == null ? null : Form.fromJson(json["form"]),
//         avaibility: json["avaibility"],
//         shortDescription: json["short_description"],
//         description: json["description"],
//         features: json["features"] == null
//             ? []
//             : List<Feature>.from(
//                 json["features"]!.map((x) => Feature.fromJson(x))),
//         specifications: json["specifications"] == null
//             ? []
//             : List<Specification>.from(
//                 json["specifications"]!.map((x) => Specification.fromJson(x))),
//         expireAt: json["expire_at"],
//         panditji: json["panditji"] == null
//             ? null
//             : Panditji.fromJson(json["panditji"]), // Added
//         place: json["place"], // Added
//         canPurchase: json["can_purchase"],
//         estimatedDelivery: json["estimatedDelivery"] == null
//             ? null
//             : EstimatedDelivery.fromJson(json["estimatedDelivery"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "parent_id": parentId,
//         "id": id,
//         "item_type": itemType,
//         "slug": slug,
//         "sku": sku,
//         "title": title,
//         "image": image,
//         "video": video?.toJson(),
//         "galleries": galleries == null
//             ? []
//             : List<dynamic>.from(galleries!.map((x) => x)),
//         "has_variation": hasVariation,
//         "attribute": attribute?.toJson(),
//         "attributes": attributes?.toJson(),
//         "rating": rating,
//         "reviews_count": reviewsCount,
//         "rating_overview": ratingOverview?.toJson(),
//         "base_price": basePrice,
//         "sale_price": salePrice,
//         "sale_price_start_date": salePriceStartDate, // Added
//         "sale_price_end_date": salePriceEndDate, // Added
//         "affiliate_market_url": affiliateMarketUrl,
//         "category": category?.toJson(),
//         "type": type,
//         "can_add_more": canAddMore,
//         "item_id": itemId,
//         "item_quantity": itemQuantity,
//         "show_form": showForm,
//         "form": form?.toJson(),
//         "avaibility": avaibility,
//         "short_description": shortDescription,
//         "description": description,
//         "features": features == null
//             ? []
//             : List<dynamic>.from(features!.map((x) => x.toJson())),
//         "specifications": specifications == null
//             ? []
//             : List<dynamic>.from(specifications!.map((x) => x.toJson())),
//         "expire_at": expireAt,
//         "panditji": panditji?.toJson(), // Added
//         "place": place, // Added
//         "can_purchase": canPurchase,
//         "estimatedDelivery": estimatedDelivery?.toJson(),
//       };
// }

// // Panditji Class (Newly Added)
// class Panditji {
//   int? id;
//   String? name;
//   String? image;

//   Panditji({
//     this.id,
//     this.name,
//     this.image,
//   });

//   factory Panditji.fromJson(Map<String, dynamic> json) => Panditji(
//         id: json["id"],
//         name: json["name"],
//         image: json["image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "image": image,
//       };
// }

// // EstimatedDelivery Class
// class EstimatedDelivery {
//   String? from;
//   String? to;

//   EstimatedDelivery({
//     this.from,
//     this.to,
//   });

//   factory EstimatedDelivery.fromJson(Map<String, dynamic> json) =>
//       EstimatedDelivery(
//         from: json["from"],
//         to: json["to"],
//       );

//   Map<String, dynamic> toJson() => {
//         "from": from,
//         "to": to,
//       };
// }

// // Video Class
// class Video {
//   String? type;
//   String? videoUrl;
//   String? videoId;
//   String? title;
//   String? description;
//   String? image;

//   Video({
//     this.type,
//     this.videoUrl,
//     this.videoId,
//     this.title,
//     this.description,
//     this.image,
//   });

//   factory Video.fromJson(Map<String, dynamic> json) => Video(
//         type: json["type"],
//         videoUrl: json["video_url"],
//         videoId: json["video_id"],
//         title: json["title"],
//         description: json["description"],
//         image: json["image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "type": type,
//         "video_url": videoUrl,
//         "video_id": videoId,
//         "title": title,
//         "description": description,
//         "image": image,
//       };
// }

// // Attribute Class
// class Attribute {
//   String? color;
//   String? size;
//   String? weight;
//   String? type;

//   Attribute({
//     this.color,
//     this.size,
//     this.weight,
//     this.type,
//   });

//   factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
//         color: json["Color"],
//         size: json["Size"],
//         weight: json["Weight"],
//         type: json["Type"],
//       );

//   Map<String, dynamic> toJson() => {
//         "Color": color,
//         "Size": size,
//         "Weight": weight,
//         "Type": type,
//       };
// }

// // Attributes Class
// class Attributes {
//   List<Attributedatum>? color;
//   List<Attributedatum>? size;
//   List<Attributedatum>? type;
//   List<Attributedatum>? weight;

//   Attributes({this.color, this.size, this.type, this.weight});

//   factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
//         color: json["Color"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Color"]!.map((x) => Attributedatum.fromJson(x))),
//         size: json["Size"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Size"]!.map((x) => Attributedatum.fromJson(x))),
//         type: json["Type"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Type"]!.map((x) => Attributedatum.fromJson(x))),
//         weight: json["Weight"] == null
//             ? []
//             : List<Attributedatum>.from(
//                 json["Weight"]!.map((x) => Attributedatum.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "Color": color == null
//             ? []
//             : List<dynamic>.from(color!.map((x) => x.toJson())),
//         "Size": size == null
//             ? []
//             : List<dynamic>.from(size!.map((x) => x.toJson())),
//         "Type": type == null
//             ? []
//             : List<dynamic>.from(type!.map((x) => x.toJson())),
//         "Weight": weight == null
//             ? []
//             : List<dynamic>.from(weight!.map((x) => x.toJson())),
//       };
// }

// // Attributedatum Class
// class Attributedatum {
//   String? name;
//   bool? available;

//   Attributedatum({
//     this.name,
//     this.available,
//   });

//   factory Attributedatum.fromJson(Map<String, dynamic> json) => Attributedatum(
//         name: json["name"],
//         available: json["available"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "available": available,
//       };
// }

// // Category Class
// class Category {
//   String? name;
//   String? slug;
//   String? image;

//   Category({
//     this.name,
//     this.slug,
//     this.image,
//   });

//   factory Category.fromJson(Map<String, dynamic> json) => Category(
//         name: json["name"],
//         slug: json["slug"],
//         image: json["image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "slug": slug,
//         "image": image,
//       };
// }

// // Feature Class
// class Feature {
//   String? image;
//   String? heading;

//   Feature({
//     this.image,
//     this.heading,
//   });

//   factory Feature.fromJson(Map<String, dynamic> json) => Feature(
//         image: json["image"],
//         heading: json["heading"],
//       );

//   Map<String, dynamic> toJson() => {
//         "image": image,
//         "heading": heading,
//       };
// }

// // Form Class
// class Form {
//   List<Field>? fields;

//   Form({
//     this.fields,
//   });

//   factory Form.fromJson(Map<String, dynamic> json) => Form(
//         fields: json["fields"] == null
//             ? []
//             : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "fields": fields == null
//             ? []
//             : List<dynamic>.from(fields!.map((x) => x.toJson())),
//       };
// }

// // Field Class
// class Field {
//   String? type;
//   String? key;
//   String? label;
//   bool? required;

//   Field({
//     this.type,
//     this.key,
//     this.label,
//     this.required,
//   });

//   factory Field.fromJson(Map<String, dynamic> json) => Field(
//         type: json["type"],
//         key: json["key"],
//         label: json["label"],
//         required: json["required"],
//       );

//   Map<String, dynamic> toJson() => {
//         "type": type,
//         "key": key,
//         "label": label,
//         "required": required,
//       };
// }

// // RatingOverview Class
// class RatingOverview {
//   dynamic one;
//   dynamic two;
//   dynamic three;
//   dynamic four;
//   dynamic five;

//   RatingOverview({
//     this.one,
//     this.two,
//     this.three,
//     this.four,
//     this.five,
//   });

//   factory RatingOverview.fromJson(Map<String, dynamic> json) => RatingOverview(
//         one: json["one"],
//         two: json["two"],
//         three: json["three"],
//         four: json["four"],
//         five: json["five"],
//       );

//   Map<String, dynamic> toJson() => {
//         "one": one,
//         "two": two,
//         "three": three,
//         "four": four,
//         "five": five,
//       };
// }

// // Specification Class
// class Specification {
//   String? heading;
//   String? text;

//   Specification({
//     this.heading,
//     this.text,
//   });

//   factory Specification.fromJson(Map<String, dynamic> json) => Specification(
//         heading: json["heading"],
//         text: json["text"],
//       );

//   Map<String, dynamic> toJson() => {
//         "heading": heading,
//         "text": text,
//       };
// }

import 'dart:convert';

// Helper functions to convert JSON string to model and vice-versa
ProductDetailModel productDetailModelFromJson(String str) =>
    ProductDetailModel.fromJson(json.decode(str));

String productDetailModelToJson(ProductDetailModel data) =>
    json.encode(data.toJson());

// Main Model Class
class ProductDetailModel {
  bool? success;
  ProductDetailDatum? data;
  String? message;

  ProductDetailModel({
    this.success,
    this.data,
    this.message,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) =>
      ProductDetailModel(
        success: json["success"],
        data: json["data"] == null
            ? null
            : ProductDetailDatum.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

// Data Class containing all product details
class ProductDetailDatum {
  int? parentId;
  dynamic id;
  int? itemType;
  String? slug;
  String? sku;
  String? title;
  String? image;
  Video? video;
  List<String>? galleries;
  bool? hasVariation;
  Attribute? attribute;
  Attributes? attributes;
  dynamic rating;
  dynamic reviewsCount;
  RatingOverview? ratingOverview;
  dynamic basePrice;
  dynamic salePrice;
  dynamic percentOff;
  dynamic offerEnd;
  String? salePriceStartDate;
  String? salePriceEndDate;
  dynamic affiliateMarketUrl;
  Category? category;
  String? type;
  bool? canAddMore;
  dynamic itemId;
  dynamic itemQuantity;
  bool? showForm;
  Form? form;
  dynamic avaibility;
  String? shortDescription;
  String? description;
  List<Feature>? features;
  List<Specification>? specifications;
  String? expireAt;
  Panditji? panditji;
  String? place;
  bool? canPurchase;
  EstimatedDelivery? estimatedDelivery;

  ProductDetailDatum({
    this.parentId,
    this.id,
    this.itemType,
    this.slug,
    this.sku,
    this.title,
    this.image,
    this.video,
    this.galleries,
    this.hasVariation,
    this.attribute,
    this.attributes,
    this.rating,
    this.reviewsCount,
    this.ratingOverview,
    this.basePrice,
    this.salePrice,
    this.percentOff,
    this.offerEnd,
    this.salePriceStartDate,
    this.salePriceEndDate,
    this.affiliateMarketUrl,
    this.category,
    this.type,
    this.canAddMore,
    this.itemId,
    this.itemQuantity,
    this.showForm,
    this.form,
    this.avaibility,
    this.shortDescription,
    this.description,
    this.features,
    this.specifications,
    this.expireAt,
    this.panditji,
    this.place,
    this.canPurchase,
    this.estimatedDelivery,
  });

  factory ProductDetailDatum.fromJson(Map<String, dynamic> json) =>
      ProductDetailDatum(
        parentId: json["parent_id"],
        id: json["id"],
        itemType: json["item_type"],
        slug: json["slug"],
        sku: json["sku"],
        title: json["title"],
        image: json["image"],
        video: json["video"] == null ? null : Video.fromJson(json["video"]),
        galleries: json["galleries"] == null
            ? []
            : List<String>.from(json["galleries"]!.map((x) => x)),
        hasVariation: json["has_variation"],
        attribute: json["attribute"] == null
            ? null
            : Attribute.fromJson(json["attribute"]),
        attributes: json["attributes"] == null
            ? null
            : Attributes.fromJson(json["attributes"]),
        rating: json["rating"],
        reviewsCount: json["reviews_count"],
        ratingOverview: json["rating_overview"] == null
            ? null
            : RatingOverview.fromJson(json["rating_overview"]),
        basePrice: json["base_price"],
        salePrice: json["sale_price"],
        percentOff: json["percent_off"],
        offerEnd: json["offer_end"],
        salePriceStartDate: json["sale_price_start_date"],
        salePriceEndDate: json["sale_price_end_date"],
        affiliateMarketUrl: json["affiliate_market_url"],
        category: json["category"] == null
            ? null
            : Category.fromJson(json["category"]),
        type: json["type"],
        canAddMore: json["can_add_more"],
        itemId: json["item_id"],
        itemQuantity: json["item_quantity"],
        showForm: json["show_form"],
        form: json["form"] == null ? null : Form.fromJson(json["form"]),
        avaibility: json["avaibility"],
        shortDescription: json["short_description"],
        description: json["description"],
        features: json["features"] == null
            ? []
            : List<Feature>.from(
                json["features"]!.map((x) => Feature.fromJson(x))),
        specifications: json["specifications"] == null
            ? []
            : List<Specification>.from(
                json["specifications"]!.map((x) => Specification.fromJson(x))),
        expireAt: json["expire_at"],
        panditji: json["panditji"] == null
            ? null
            : Panditji.fromJson(json["panditji"]),
        place: json["place"],
        canPurchase: json["can_purchase"],
        estimatedDelivery: json["estimatedDelivery"] == null
            ? null
            : EstimatedDelivery.fromJson(json["estimatedDelivery"]),
      );

  Map<String, dynamic> toJson() => {
        "parent_id": parentId,
        "id": id,
        "item_type": itemType,
        "slug": slug,
        "sku": sku,
        "title": title,
        "image": image,
        "video": video?.toJson(),
        "galleries": galleries == null
            ? []
            : List<dynamic>.from(galleries!.map((x) => x)),
        "has_variation": hasVariation,
        "attribute": attribute?.toJson(),
        "attributes": attributes?.toJson(),
        "rating": rating,
        "reviews_count": reviewsCount,
        "rating_overview": ratingOverview?.toJson(),
        "base_price": basePrice,
        "sale_price": salePrice,
        "percent_off": percentOff,
        "offer_end": offerEnd,
        "sale_price_start_date": salePriceStartDate,
        "sale_price_end_date": salePriceEndDate,
        "affiliate_market_url": affiliateMarketUrl,
        "category": category?.toJson(),
        "type": type,
        "can_add_more": canAddMore,
        "item_id": itemId,
        "item_quantity": itemQuantity,
        "show_form": showForm,
        "form": form?.toJson(),
        "avaibility": avaibility,
        "short_description": shortDescription,
        "description": description,
        "features": features == null
            ? []
            : List<dynamic>.from(features!.map((x) => x.toJson())),
        "specifications": specifications == null
            ? []
            : List<dynamic>.from(specifications!.map((x) => x.toJson())),
        "expire_at": expireAt,
        "panditji": panditji?.toJson(),
        "place": place,
        "can_purchase": canPurchase,
        "estimatedDelivery": estimatedDelivery?.toJson(),
      };
}

// Panditji Class
class Panditji {
  int? id;
  String? name;
  String? image;

  Panditji({
    this.id,
    this.name,
    this.image,
  });

  factory Panditji.fromJson(Map<String, dynamic> json) => Panditji(
        id: json["id"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
      };
}

// EstimatedDelivery Class
class EstimatedDelivery {
  String? from;
  String? to;

  EstimatedDelivery({
    this.from,
    this.to,
  });

  factory EstimatedDelivery.fromJson(Map<String, dynamic> json) =>
      EstimatedDelivery(
        from: json["from"],
        to: json["to"],
      );

  Map<String, dynamic> toJson() => {
        "from": from,
        "to": to,
      };
}

// Video Class
class Video {
  String? type;
  String? videoUrl;
  String? videoId;
  String? title;
  String? description;
  String? image;

  Video({
    this.type,
    this.videoUrl,
    this.videoId,
    this.title,
    this.description,
    this.image,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        type: json["type"],
        videoUrl: json["video_url"],
        videoId: json["video_id"],
        title: json["title"],
        description: json["description"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "video_url": videoUrl,
        "video_id": videoId,
        "title": title,
        "description": description,
        "image": image,
      };
}

// ---------------------------------------------------------------------------
// UPDATED ATTRIBUTE CLASS (Single Selection)
// ---------------------------------------------------------------------------
class Attribute {
  String? color;
  String? size;
  String? weight;
  String? type;
  String? carat; // Added
  String? origin; // Added
  String? style;

  Attribute({
    this.color,
    this.size,
    this.weight,
    this.type,
    this.carat, // Added
    this.origin, // Added
    this.style, // <--- NEW ADDITION
  });

  factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
        color: json["Color"],
        size: json["Size"],
        weight: json["Weight"],
        type: json["Type"],
        carat: json["carat"], // Maps to lowercase 'carat' in JSON
        origin: json["ORIGIN"], // Maps to uppercase 'ORIGIN' in JSON
        style: json["Style"], // <--- MAP JSON KEY
      );

  Map<String, dynamic> toJson() => {
        "Color": color,
        "Size": size,
        "Weight": weight,
        "Type": type,
        "carat": carat, // Added
        "ORIGIN": origin, // Added
      };
}

// ---------------------------------------------------------------------------
// UPDATED ATTRIBUTES CLASS (List of Variations)
// ---------------------------------------------------------------------------
class Attributes {
  List<Attributedatum>? color;
  List<Attributedatum>? size;
  List<Attributedatum>? type;
  List<Attributedatum>? weight;
  List<Attributedatum>? carat; // Added
  List<Attributedatum>? origin; // Added
  List<Attributedatum>? style; // <--- NEW ADDITION

  Attributes(
      {this.color,
      this.size,
      this.type,
      this.weight,
      this.carat, // Added
      this.origin, // Added
      this.style // <--- NEW ADDITION
      });

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        color: json["Color"] == null
            ? []
            : List<Attributedatum>.from(
                json["Color"]!.map((x) => Attributedatum.fromJson(x))),
        size: json["Size"] == null
            ? []
            : List<Attributedatum>.from(
                json["Size"]!.map((x) => Attributedatum.fromJson(x))),
        type: json["Type"] == null
            ? []
            : List<Attributedatum>.from(
                json["Type"]!.map((x) => Attributedatum.fromJson(x))),
        weight: json["Weight"] == null
            ? []
            : List<Attributedatum>.from(
                json["Weight"]!.map((x) => Attributedatum.fromJson(x))),
        // New Fields Mapping
        carat: json["carat"] == null
            ? []
            : List<Attributedatum>.from(
                json["carat"]!.map((x) => Attributedatum.fromJson(x))),
        origin: json["ORIGIN"] == null
            ? []
            : List<Attributedatum>.from(
                json["ORIGIN"]!.map((x) => Attributedatum.fromJson(x))),
        style: json["Style"] == null
            ? []
            : List<Attributedatum>.from(
                json["Style"]!.map((x) => Attributedatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Color": color == null
            ? []
            : List<dynamic>.from(color!.map((x) => x.toJson())),
        "Size": size == null
            ? []
            : List<dynamic>.from(size!.map((x) => x.toJson())),
        "Type": type == null
            ? []
            : List<dynamic>.from(type!.map((x) => x.toJson())),
        "Weight": weight == null
            ? []
            : List<dynamic>.from(weight!.map((x) => x.toJson())),
        // New Fields to Json
        "carat": carat == null
            ? []
            : List<dynamic>.from(carat!.map((x) => x.toJson())),
        "ORIGIN": origin == null
            ? []
            : List<dynamic>.from(origin!.map((x) => x.toJson())),
      };
}

// Attributedatum Class
class Attributedatum {
  String? name;
  int? itemId;
  bool? available;

  Attributedatum({
    this.name,
    this.itemId,
    this.available,
  });

  factory Attributedatum.fromJson(Map<String, dynamic> json) => Attributedatum(
        name: json["name"],
        itemId: json["item_id"],
        available: json["available"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "item_id": itemId,
        "available": available,
      };
}

// Category Class
class Category {
  String? name;
  String? slug;
  String? image;

  Category({
    this.name,
    this.slug,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
        slug: json["slug"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "slug": slug,
        "image": image,
      };
}

// Feature Class
class Feature {
  String? image;
  String? heading;

  Feature({
    this.image,
    this.heading,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        image: json["image"],
        heading: json["heading"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "heading": heading,
      };
}

// Form Class
class Form {
  List<Field>? fields;

  Form({
    this.fields,
  });

  factory Form.fromJson(Map<String, dynamic> json) => Form(
        fields: json["fields"] == null
            ? []
            : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "fields": fields == null
            ? []
            : List<dynamic>.from(fields!.map((x) => x.toJson())),
      };
}

// Field Class
class Field {
  String? type;
  String? key;
  String? label;
  bool? required;

  Field({
    this.type,
    this.key,
    this.label,
    this.required,
  });

  factory Field.fromJson(Map<String, dynamic> json) => Field(
        type: json["type"],
        key: json["key"],
        label: json["label"],
        required: json["required"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "key": key,
        "label": label,
        "required": required,
      };
}

// RatingOverview Class
class RatingOverview {
  dynamic one;
  dynamic two;
  dynamic three;
  dynamic four;
  dynamic five;

  RatingOverview({
    this.one,
    this.two,
    this.three,
    this.four,
    this.five,
  });

  factory RatingOverview.fromJson(Map<String, dynamic> json) => RatingOverview(
        one: json["one"],
        two: json["two"],
        three: json["three"],
        four: json["four"],
        five: json["five"],
      );

  Map<String, dynamic> toJson() => {
        "one": one,
        "two": two,
        "three": three,
        "four": four,
        "five": five,
      };
}

// Specification Class
class Specification {
  String? heading;
  String? text;

  Specification({
    this.heading,
    this.text,
  });

  factory Specification.fromJson(Map<String, dynamic> json) => Specification(
        heading: json["heading"],
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "heading": heading,
        "text": text,
      };
}
