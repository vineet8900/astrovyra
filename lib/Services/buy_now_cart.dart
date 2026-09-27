class BuyNowCart {
  static bool _isActive = false;

  static bool get isActive => _isActive;

  static void activate() {
    _isActive = true;
  }

  static void clear() {
    _isActive = false;
  }
}
