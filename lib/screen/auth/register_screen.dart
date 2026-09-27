import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:astrokavach/core/network/auth_repository.dart';
import 'package:astrokavach/core/utils/responsive.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/cutsom_textfield.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/core/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _firstnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _firstnameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    setState(() => _isLoading = true);

    try {
      // 1. Temporarily save to SharedPreferences (for legacy support if needed)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("name", name);
      await prefs.setString("email", email);
      await prefs.setString("phone", phone);

      // 2. Call the new API Layer
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.registerUser(name: name, email: email, phone: phone);

      Fluttertoast.showToast(msg: "Registered Successfully", backgroundColor: AppColors.success);

      // 3. Navigate back to login using GoRouter
      if (mounted) {
        context.pushReplacement('/login');
      }
    } catch (e) {
      final error = e.toString().replaceAll('Exception: ', '');
      Fluttertoast.showToast(msg: error, backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent physical back button from bypassing routing rules
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.pushReplacement('/login');
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
            onPressed: () => context.pushReplacement('/login'),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: SizedBox(
                // Use Responsive width to keep forms clean on tablets
                width: Responsive.isMobile(context) ? double.infinity : 500,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Image.asset(
                          "assets/astrokavach.png",
                          height: Responsive.height(context, 12).clamp(80.0, 120.0),
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),
                        CustomTextField(
                          starsign: "*",
                          label: 'Enter name',
                          controller: _firstnameController,
                          title: "Name",
                          prefixIcon: Icon(Icons.person, color: AppColors.textSecondary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Name is Required';
                            return null;
                          },
                        ),
                        CustomTextField(
                          starsign: "*",
                          textInputType: TextInputType.phone,
                          maxLength: 10,
                          title: "Phone",
                          label: "Enter Phone",
                          controller: _phoneController,
                          prefixIcon: Icon(Icons.phone_android_sharp, color: AppColors.textSecondary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Phone is Required';
                            if (value.length != 10) return 'Phone number should be 10 digits';
                            return null;
                          },
                        ),
                        CustomTextField(
                          starsign: "*",
                          title: "Email",
                          label: "Enter Email",
                          controller: _emailController,
                          textInputType: TextInputType.emailAddress,
                          prefixIcon: Icon(Icons.email, color: AppColors.textSecondary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Email is Required';
                            final pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                            if (!RegExp(pattern).hasMatch(value)) return 'Enter a valid email address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _isLoading
                              ? const Center(
                                  child: SizedBox(
                                    height: 24, width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : CustomElevatedButton(
                                  backgroundColor: AppColors.primary,
                                  text: "Register",
                                  onPressed: _handleRegister,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(fontSize: 14, color: AppColors.black87),
                            ),
                            GestureDetector(
                              onTap: () => context.pushReplacement('/login'),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


