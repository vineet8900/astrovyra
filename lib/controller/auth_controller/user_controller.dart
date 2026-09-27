// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jyotish_setu/api/auth_api/user_data_api.dart';
// import 'package:jyotish_setu/custom_widgets/reusable_function.dart';
// import 'package:jyotish_setu/custom_widgets/styles.dart';
// import 'package:jyotish_setu/model/user_data_model.dart';
// import 'package:jyotish_setu/screen/auth/login_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserController extends GetxController {
//   Rxn<UserDataModel> userDataModel = Rxn<UserDataModel>();
//   Rxn<Data> user = Rxn<Data>();
//     RxString name = ''.obs;
//   RxString image = ''.obs;
//    RxString email = ''.obs;

//   final ReusableFunction reusableFunction = ReusableFunction();
//  Future<void> loadUserData() async {
//     final userMap = await reusableFunction.getUserDataFromPrefs();
//     if (userMap != null) {
//       name.value = userMap['name'] ?? '';
//       image.value = userMap['image'] ?? '';
//       email.value = userMap['email'] ?? '';
//     }
//   }
//   RxBool isLoggedIn = false.obs;
//   RxString apiToken = ''.obs;

//   final userDataApi = UserDataApi();

//   @override
//   void onInit() {
//     super.onInit();
//     loadUserData();
//     _loadTokenAndUserFromPrefs();
//   }

//   Future<void> _loadTokenAndUserFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     apiToken.value = prefs.getString('api_token') ?? '';
//     isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;

//     final userDataString = prefs.getString('userdata');
//     if (userDataString != null) {
//       final userDataMap = jsonDecode(userDataString);
//       user.value = Data.fromJson(userDataMap);
//     }
//   }


//   Future<bool> fetchAndSaveUserData() async {
//     final prefs = await SharedPreferences.getInstance();

//     if (apiToken.value.isEmpty) return false;

//     final result = await userDataApi.fetchUserData(apiToken.value);

//     if (result != null && result.success == true && result.data != null) {
//       userDataModel.value = result;
//       user.value = result.data!;

//       await prefs.setString('userdata', jsonEncode(user.value!.toJson()));
//       return true;
//     }
//     return false;
//   }

//   /// 🔁 Get user data from shared preferences
//   Future<Map<String, dynamic>?> getUserDataFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userDataString = prefs.getString('userdata');

//     if (userDataString != null) {
//       return jsonDecode(userDataString);
//     }
//     return null;
//   }

//   /// 🔀 Navigate with token check
//   void navigateIfNotLoggedIn(Widget redirectScreen, {Function(Map<String, dynamic>)? onReturn}) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = apiToken.value;

//     if (!isLoggedIn.value || token.isEmpty || token.length == 12) {
//       Get.to(() => LoginScreen(redirectScreen: redirectScreen));
//     } else {
//       Get.to(() => redirectScreen)!.then((_) async {
//         if (onReturn != null) {
//           final success = await fetchAndSaveUserData();
//           if (success) {
//             onReturn(user.value!.toJson());
//           }
//         }
//       });
//     }
//   }

//   /// 🔃 Loader Widget
//   Widget loadingRow({String message = "Please wait..."}) {
//     return Center(
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(height: 30, width: 30, child: CircularProgressIndicator()),
//             SizedBox(width: 20),
//             Text(message, style: CustomStyles.black14600),
//           ],
//         ),
//       ),
//     );
//   }
// }
