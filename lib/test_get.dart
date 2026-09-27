import 'package:get/get.dart';
import 'package:astrokavach/translationscrenn/app_translation.dart';
import 'package:flutter/material.dart';

void main() {
  Get.addTranslations(AppTranslations().keys);
  Get.updateLocale(const Locale('en', 'US'));
}
