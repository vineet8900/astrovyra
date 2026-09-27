import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrokavach/core/network/dio_client.dart';

/// Provides the AuthRepository instance globally
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(DioClient().dio);
});

/// Handles all Authentication API calls (Login, Register, OTP Verification)
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Requests an OTP for the given phone number.
  /// Returns a success message if the OTP is sent.
  /// Throws an Exception if the user is not registered or API fails.
  Future<String> requestLoginOtp(String phone) async {
    try {
      final response = await _dio.post(
        'otp/user',
        data: {'phone': phone},
      );

      // In Dio, any 2xx status code comes here.
      // The backend might return success: false even for a 200 OK.
      final data = response.data;

      if (data is Map && data['success'] == false) {
        throw Exception(data['message'] ?? 'Unable to send OTP');
      }

      return data['message'] ?? 'OTP sent successfully';
    } on DioException catch (e) {
      _handleDioError(e);
      // This return will never be reached because _handleDioError always throws,
      // but Dart needs it to satisfy the return type.
      throw Exception('Unexpected error');
    }
  }

  /// Helper to convert Dio HTTP errors into clean, user-friendly messages
  void _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      
      // If the backend returns HTML instead of JSON (like a 404/500 Laravel page)
      if (data is String && data.trimLeft().startsWith('<')) {
        throw Exception('Server error. Please try again later.');
      }

      // Handle specific HTTP Status Codes
      if (statusCode == 404) {
        throw Exception('NOT_REGISTERED');
      } else if (statusCode == 422) {
        // Validation Errors
        if (data is Map && data['errors'] != null) {
          throw Exception('NOT_REGISTERED'); // Simplify to "Please register"
        }
        final message = data is Map ? data['message'] : 'Invalid details';
        throw Exception(message);
      } else {
        throw Exception(data is Map ? data['message'] : 'Something went wrong ($statusCode)');
      }
    } else {
      throw Exception('Network error. Please check your internet connection.');
    }
  }

  /// Verifies OTP. Returns the API Token on success.
  Future<String> verifyOtp({
    required String phone, 
    required String otp, 
    required String fcmToken,
    String? guestToken,
  }) async {
    try {
      final response = await _dio.post(
        'otp/user/verify',
        data: {
          'phone': phone,
          'otp': otp,
          'fcm_token': fcmToken,
          if (guestToken != null) 'api_token': guestToken,
        },
      );

      final data = response.data;
      
      if (data is Map && data['success'] == false) {
        throw Exception(data['message'] ?? 'OTP Verification Failed');
      }

      final String? token = data['data']?['token'];
      if (token == null) {
        throw Exception('Server did not return an auth token.');
      }

      return token;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        final msg = e.response?.data['message'] ?? 'Invalid OTP';
        throw Exception(msg);
      }
      _handleDioError(e);
      throw Exception('Unexpected error');
    }
  }

  /// Temporarily fetches user data to support the old Home Screen codebase
  Future<void> fetchAndSaveUserData(String token) async {
    try {
      // Create a temporary dio instance to pass the token directly
      // since the global DioClient might not have processed the token yet
      final tempDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        }
      ));
      
      final response = await tempDio.post('user/data');
      if (response.data['success'] == true && response.data['data'] != null) {
        // Save to SharedPreferences for legacy compatibility
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userdata', jsonEncode(response.data['data']));
      }
    } catch (e) {
      print('Warning: Failed to fetch user data after login: $e');
    }
  }

  /// Registers a new user. Throws an exception if registration fails.
  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        'register/user',
        data: {
          "name": name,
          "email": email,
          "phone": phone,
        },
      );

      final data = response.data;
      if (data is Map && data['success'] == false) {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        if (data is Map) {
          final message = data['message'] ?? 'Validation Error';
          throw Exception(message);
        }
        throw Exception('Validation Error');
      }
      _handleDioError(e);
      throw Exception('Unexpected error');
    }
  }
}
