import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:astrokavach/core/network/home_repository.dart';
import 'package:astrokavach/model/banner_api_model.dart';
import 'package:astrokavach/model/Product_Api_Model/product_category_api_model.dart';

/// Provider for Home Banners. 
/// Using `keepAlive: true` allows Stale-While-Revalidate caching.
final bannerProvider = FutureProvider.family<List<BannerDatum>, String>((ref, type) async {
  // Keep the data alive even if the user leaves the home screen
  ref.keepAlive();
  
  final repo = ref.read(homeRepositoryProvider);
  return repo.fetchBanners(type);
});

/// Provider for Product/Service Categories.
final categoryProvider = FutureProvider.family<List<ProductCategoryDatum>, String>((ref, type) async {
  // Keep the data alive in memory
  ref.keepAlive();
  
  final repo = ref.read(homeRepositoryProvider);
  return repo.fetchCategories(type);
});
