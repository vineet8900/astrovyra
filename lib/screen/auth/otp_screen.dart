import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';

import 'package:astrokavach/core/network/auth_repository.dart';
import 'package:astrokavach/core/providers/auth_provider.dart';
import 'package:astrokavach/core/utils/responsive.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/core/theme/app_colors.dart';
import 'package:astrokavach/Services/Notification_service.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String phone;
  final Widget? redirectScreen;

  const OTPScreen({
    super.key,
    required this.phone,
    this.redirectScreen,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  
  int _remainingSeconds = 120;
  Timer? _timer;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;
    
    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final message = await authRepo.requestLoginOtp(widget.phone);
      Fluttertoast.showToast(msg: message, backgroundColor: AppColors.success);
      _startTimer();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      Fluttertoast.showToast(msg: 'Please enter the complete 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      
      // Get FCM Token
      final fcmToken = await NotificationService().getDeviceToken() ?? "no_token";
      
      // Verify OTP and get API Token
      final token = await authRepo.verifyOtp(
        phone: widget.phone,
        otp: otp,
        fcmToken: fcmToken,
      );
      
      // Fetch user data for the old legacy homescreen
      await authRepo.fetchAndSaveUserData(token);

      // Log the user in globally using Riverpod
      // This will instantly redirect to /home thanks to GoRouter's redirect logic!
      await ref.read(authStateProvider.notifier).login(token);

      Fluttertoast.showToast(msg: "Login Successfully", backgroundColor: AppColors.success);

    } catch (e) {
      final error = e.toString().replaceAll('Exception: ', '');
      Fluttertoast.showToast(msg: error, backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    "assets/astrokavach.png",
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 60),
                const Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We have Sent You OTP to verify the Mobile Number ${widget.phone} via SMS',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 30),
                
                // Using Pinput package makes OTP handling professional and bug-free
                Center(
                  child: Pinput(
                    length: 6,
                    controller: _otpController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                    ),
                    onCompleted: (pin) => _verifyOTP(),
                  ),
                ),
                
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24, width: 24, 
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          children: [
                            const TextSpan(text: "Didn't get the OTP? "),
                            if (_remainingSeconds > 0)
                              TextSpan(
                                text: 'Resend in ${_formatTime(_remainingSeconds)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_canResend)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: GestureDetector(
                            onTap: _resendOTP,
                            child: const Text(
                              "Resend OTP",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: AppColors.primary,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


