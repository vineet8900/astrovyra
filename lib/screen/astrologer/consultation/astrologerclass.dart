class Astrologer{
  final String name;
  final String image;
  final double rating;
  final int originalPrice;
  final int discountedPrice;
  final bool isverified;
  Astrologer({
    required this.name,
    required this.image,
    required this.rating,
    required this.originalPrice,
    required this.discountedPrice,
    this.isverified = true,

  });

}