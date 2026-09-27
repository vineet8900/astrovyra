import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astrokavach/core/utils/responsive.dart';
import 'package:astrokavach/core/cache/cache_manager.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/styles.dart';

/// A completely clean, responsive, and stateless Intro Screen.
class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Responsive(
          // For mobile, we build a standard column layout
          mobile: _buildContent(context),
          // For tablets, we could build a side-by-side layout, 
          // but for now, we just constrain the width to make it look premium.
          tablet: Center(
            child: SizedBox(
              width: 500, // Constrain width on tablets
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Spacer(flex: 2),
        Image.asset(
          "assets/astrokavach.png",
          // Use responsive width: 60% of screen width, max 300px
          width: Responsive.width(context, 60).clamp(150.0, 300.0),
          fit: BoxFit.contain,
        ),
        SizedBox(height: Responsive.height(context, 3)), // Responsive gap
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "Talk with your Favorite Astrologer Today. Chat, Call & Video Call with astrologer by AstroConcern",
            // You can use Responsive.fontSize here if you make styles dynamic later
            style: CustomStyles.black14500, 
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(flex: 1),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 44),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomElevatedButton(
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: CustomStyles.pinki,
                    blurRadius: 0,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
                backgroundColor: CustomStyles.ctaColor,
                textStyle: CustomStyles.white13600,
                text: "Login",
                onPressed: () {
                  // Replaced GetX with GoRouter
                  context.push('/login'); 
                },
              ),
              const SizedBox(height: 28),
              CustomElevatedButton(
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: CustomStyles.pinki,
                    blurRadius: 0,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
                backgroundColor: CustomStyles.ctaColor,
                textStyle: CustomStyles.white13600,
                text: "Register",
                onPressed: () {
                  // Replaced GetX with GoRouter
                  context.push('/register');
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 100,
                height: 40,
                child: CustomElevatedButton(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 0,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  backgroundColor: Colors.white,
                  textStyle: CustomStyles.black13600,
                  text: "Skip",
                  onPressed: () async {
                    // Centralized cache wipe instead of direct SharedPreferences call
                    await CacheManager.clearAll();
                    if (context.mounted) {
                      context.go('/home'); // Routing handled centrally
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
