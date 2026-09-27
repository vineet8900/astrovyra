import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Cache Manager
/// Replaces direct SharedPreferences calls with a secure, testable interface.
class CacheManager {
  static const _storage = FlutterSecureStorage();
  
  static const String _tokenKey = 'api_token';

  /// Save Auth Token (Syncs with SharedPreferences for legacy API compatibility)
  static Future<void> saveToken(String token) async {
    // Save securely for our new Dio client
    await _storage.write(key: _tokenKey, value: token);
    
    // TEMPORARY: Save to SharedPreferences so the old HTTP APIs still work
    // until we migrate the Home Screen.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get Auth Token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all data (Logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
