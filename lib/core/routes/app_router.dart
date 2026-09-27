import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:astrokavach/core/providers/auth_provider.dart';
import 'package:astrokavach/screen/auth/splash_screen.dart';
import 'package:astrokavach/screen/auth/intro_screen.dart';
// Note: Replace with your actual Bottom/Home screen import
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart'; 

import 'package:astrokavach/screen/auth/otp_screen.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/auth/register_screen.dart';

/// Centralized Router using GoRouter and Riverpod
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    // Redirect logic acts as our global navigation guard
    redirect: (context, state) {
      // If auth state is loading, stay on splash screen (/)
      if (authState.isLoading) return '/';

      // Once loaded, if on splash screen, route based on auth status
      final bool isLoggedIn = authState.value ?? false;
      final bool isGoingToSplash = state.matchedLocation == '/';
      if (isGoingToSplash) {
        return isLoggedIn ? '/home' : '/intro';
      }

      // Allow access to auth screens if not logged in
      final isAuthRoute = state.matchedLocation == '/intro' || 
                          state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register' ||
                          state.matchedLocation == '/otp';

      // If user is not logged in and trying to access protected routes, send to intro
      if (!isLoggedIn && !isAuthRoute) {
        return '/intro';
      }

      // No redirection needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/intro',
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OTPScreen(
            phone: extra?['phone'] as String? ?? '', // Pass the phone securely from the route
            redirectScreen: extra?['redirectScreen'] as Widget?,
          );
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => BottomAppBarScreen(),
      ),
    ],
  );
});
