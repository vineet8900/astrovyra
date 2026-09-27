import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConsultationFormController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final tobController = TextEditingController();

  final genderList = ['Male', 'Female', 'Other'];
  final maritalStatusList = ['Single', 'Married', 'Divorced', 'Widowed'];
  final occupationList = ['Student', 'Working', 'Self-Employed', 'Housewife', 'Other'];

  var selectedGender = ''.obs;
  var selectedMaritalStatus = ''.obs;
  var selectedOccupation = ''.obs;

  var dateOfBirth = DateTime.now().obs;
  var timeOfBirth = TimeOfDay.now().obs;

  void clearAll() {
    nameController.clear();
    phoneController.clear();
    dobController.clear();     
    tobController.clear();

    selectedGender.value = '';
    selectedMaritalStatus.value = '';
    selectedOccupation.value = '';

    dateOfBirth.value = DateTime.now();
    timeOfBirth.value = TimeOfDay.now();
  }

  void submit() {

    Get.back(); 
    clearAll();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    tobController.dispose();  
    super.onClose();
  }
}
