// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jyotish_setu/api/auth_api/login_api.dart';
// import 'package:jyotish_setu/custom_widgets/flutter_toast.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginController extends GetxController {
//   final phoneController = TextEditingController();
//   final isSelected = false.obs;
//   final isLoading = false.obs;

//   LoginApiServices loginApi = LoginApiServices();

//   void toggleCheckbox(bool? value) {
//     isSelected.value = value ?? false;
//   }

//   void getOtp({Widget? redirectScreen}) async{
//     final phone = phoneController.text.trim();

//     if (phone.isEmpty) {
//       ToastMsg.show("Please enter phone number");
//       return;
//     }

//     if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
//       ToastMsg.show("Please enter a valid 10-digit number");
//       return;
//     }

//     if (!isSelected.value) {
//       ToastMsg.show("Please agree to terms & conditions");
//       return;
//     }


//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setString('phone', phone);

//   isLoading.value = true;
//     loginApi.loginUser(phone, redirectScreen: redirectScreen).whenComplete(() {
//       isLoading.value = false;
//     });
//   }

//   @override
//   void onClose() {
//     phoneController.dispose();
//     super.onClose();
//   }
//   @override
//   void dispose() {
//     super.dispose();
//     phoneController.dispose();
//   }
// }
