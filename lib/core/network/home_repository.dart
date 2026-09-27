import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:astrokavach/core/network/dio_client.dart';
import 'package:astrokavach/model/banner_api_model.dart';
import 'package:astrokavach/model/Product_Api_Model/product_category_api_model.dart';

/// Provides the HomeRepository instance globally
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(DioClient().dio);
});

class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  /// Fetch Banners
  Future<List<BannerDatum>> fetchBanners(String type) async {
    try {
      final response = await _dio.get('banners?type=$type');
      final model = BannerApiModel.fromJson(response.data);
      return model.data ?? [];
    } catch (e) {
      throw Exception('Failed to fetch banners: $e');
    }
  }

  /// Fetch Product Categories (e.g. type = "Product" or "service")
  Future<List<ProductCategoryDatum>> fetchCategories(String type) async {
    try {
      final response = await _dio.get('product-categories/$type');
      final model = ProductCategoryModel.fromJson(response.data);
      if (model.success == true) {
        return model.data ?? [];
      } else {
        throw Exception(model.message ?? 'Failed to fetch categories');
      }
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
