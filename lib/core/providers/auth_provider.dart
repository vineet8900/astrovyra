import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astrokavach/core/cache/cache_manager.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Represents the authentication state of the application.
/// Null means loading/checking, true means logged in, false means logged out.
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _checkAuthStatus();
  }

  /// Check initial auth status on app launch
  Future<void> _checkAuthStatus() async {
    try {
      // Future.wait ensures we check the cache AND give the Splash Screen 
      // exactly 2.5 seconds to show its beautiful animation before redirecting.
      final results = await Future.wait([
        CacheManager.isLoggedIn(),
        Future.delayed(const Duration(milliseconds: 2500)),
      ]);
      
      final isLoggedIn = results[0] as bool;
      state = AsyncValue.data(isLoggedIn);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Login user and update state
  Future<void> login(String token) async {
    await CacheManager.saveToken(token);
    state = const AsyncValue.data(true);
  }

  /// Logout user and update state
  Future<void> logout() async {
    await CacheManager.clearAll();
    state = const AsyncValue.data(false);
  }
}
