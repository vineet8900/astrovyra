// lib/app/localization/app_translations.dart

import 'package:astrokavach/translationscrenn/en_tr.dart';
import 'package:astrokavach/translationscrenn/hi_tr.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': EnUs.translations, // English (US)
        'hi_IN': HiIn.translations, // Hindi (India)
      };
}
