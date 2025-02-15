// utils/language_utils.dart
enum AppLanguage { english, hindi }

class LanguageUtils {
  static String getLanguageName(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.hindi:
        return 'हिंदी';
    }
  }
}
