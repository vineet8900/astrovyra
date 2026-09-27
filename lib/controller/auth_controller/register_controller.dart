// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jyotish_setu/api/auth_api/register_api.dart';

// class RegisterController extends GetxController {
//   RegisterApiServices registerApiServices = RegisterApiServices();

//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   final formKey = GlobalKey<FormState>();

//   void submitForm()async {
//     if (formKey.currentState!.validate()) {
//       final name = nameController.text.trim();
//       final email = emailController.text.trim();
//       final phone = phoneController.text.trim();

//    await   registerApiServices.registerUser(name, email, phone);

//       // Optional toast or snackbar
//       // ToastMsg.show("Registration Success");
//     }
//   }

//   @override
//   void onClose() {
//     nameController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.onClose();
//   }
// }
