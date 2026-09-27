// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jyotish_setu/api/auth_api/otp_verify_api.dart';
// import 'package:jyotish_setu/custom_widgets/flutter_toast.dart';

// class OtpController extends GetxController {
//   final otpController = TextEditingController();
//   final phoneNumber = ''.obs;
//   final timerSeconds = 120.obs;
//   final isLoading = false.obs;

//   final OTPVerifyService otpService = OTPVerifyService();
//   Timer? _timer;

//   @override
//   void onInit() {
//     super.onInit();
//     getSavedUserData();
//     startTimer();
//   }

//   void getSavedUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     phoneNumber.value = prefs.getString('phone') ?? '';
//   }

//   void startTimer() {
//     _timer?.cancel();
//     timerSeconds.value = 120;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (timerSeconds.value > 0) {
//         timerSeconds.value--;
//       } else {
//         _timer?.cancel();
//       }
//     });
//   }

//   void resendOtp() {
//     startTimer();
//     ToastMsg.show("OTP has been resent to ${phoneNumber.value}");
//   }

//   void verifyOtp({Widget? redirectScreen}) async {
//     final otp = otpController.text.trim();

//     if (otp.isEmpty) {
//       ToastMsg.show("Please enter the OTP");
//       return;
//     }

//     if (otp.length != 6) {
//       ToastMsg.show("OTP must be 6 digits");
//       return;
//     }

//     isLoading.value = true;

//     final result = await otpService.otpVerify(
//       otp,
//       phoneNumber.value,
//       redirectScreen: redirectScreen,
//     );

//     isLoading.value = false;

//     if (result != null) {
   
//     }
//   }

//   @override
//   void onClose() {
//     _timer?.cancel();
//     otpController.dispose();
//     super.onClose();
//   }
// }
