import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:astrokavach/core/network/auth_repository.dart';
import 'package:astrokavach/core/utils/responsive.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/core/theme/app_colors.dart';


class LoginScreen extends ConsumerStatefulWidget {
  final Widget? redirectScreen;
  const LoginScreen({super.key, this.redirectScreen});
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();

    // 1. Validation
    if (phone.isEmpty || phone.length != 10) {
      Fluttertoast.showToast(msg: "Phone number must be 10 digits");
      return;
    }
    if (int.tryParse(phone[0]) != null && int.parse(phone[0]) <= 5) {
      Fluttertoast.showToast(msg: "Please enter a valid Indian number");
      return;
    }

    // 2. Set Loading State
    setState(() => _isLoading = true);

    try {
      // 3. API Call via standard Repository
      final authRepo = ref.read(authRepositoryProvider);
      final message = await authRepo.requestLoginOtp(phone);
      
      Fluttertoast.showToast(
        msg: message, 
        backgroundColor: AppColors.success,
        textColor: AppColors.white,
      );

      // 4. Navigate to OTP Screen via GoRouter
      if (mounted) {
        context.push('/otp', extra: {
          'phone': phone, 
          'redirectScreen': widget.redirectScreen
        });
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (errorMessage.contains('NOT_REGISTERED')) {
        Fluttertoast.showToast(
          msg: "Number not registered. Please register first.",
          backgroundColor: AppColors.warning,
          textColor: AppColors.white,
        );
        if (mounted) {
          context.pushReplacement('/register');
        }
      } else {
        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
        );
      }
    } finally {
      // 5. Remove Loading State
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formWidth = Responsive.isMobile(context) 
        ? double.infinity 
        : 500.0; // Fixed width for tablet/desktop

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.pop(), // GoRouter native pop
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: formWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/astrokavach.png",
                        height: Responsive.height(context, 12).clamp(80.0, 120.0),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter mobile number to get started',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                Text('🇮🇳', style: TextStyle(fontSize: 22)),
                                SizedBox(width: 8),
                                Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: AppColors.border,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: const InputDecoration(
                                hintText: 'Mobile Number',
                                counterText: "",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Get OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
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
    );
  }
}


