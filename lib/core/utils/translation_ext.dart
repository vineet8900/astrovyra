import 'package:astrokavach/translationscrenn/en_tr.dart';
// import 'package:astrokavach/translationscrenn/hi_tr.dart';

/// A lightweight replacement for GetX's .tr extension.
/// This allows us to completely remove GetX without breaking thousands of lines of code.
extension TranslationExtension on String {
  String get tr {
    // Currently hardcoded to English to remove GetX dependency.
    // Later we can connect this to Riverpod to support dynamic language switching.
    return EnUs.translations[this] ?? this;
  }
}
