import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A singleton Dio client that handles global API configuration, 
/// authentication tokens, and error handling for the entire app.
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  // TODO: Move this to an Environment config file in Phase 2
  static const String baseUrl = 'https://astro.vyntrixa.in/api/';

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      // Only prints in terminal during local development. 
      // PlayStore (Release Mode) automatically blocks this for security.
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
    ]);
  }
}

/// Automatically injects the Auth token and handles 401 Unauthorized errors globally.
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  _AuthInterceptor(this.storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Inject the authentication token into every request
    final token = await storage.read(key: 'api_token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // In the future for SaaS, we will inject Tenant-ID here:
    // options.headers['x-tenant-id'] = await storage.read(key: 'tenant_id');

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Globally handle unauthorized users (e.g., Token expired)
      // TODO: Use Riverpod/GoRouter to log the user out and navigate to LoginScreen
      debugPrint('User is unauthorized. Need to log out.');
    }
    
    // Pass the error down so individual API calls can still handle specific errors (like 422 Validation)
    return handler.next(err);
  }
}
