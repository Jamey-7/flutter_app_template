import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/language_service.dart';

part 'language_provider.g.dart';

/// Supported languages with their metadata
enum AppLanguage {
  english('en', 'English', 'English', 'assets/images/flags/US.svg'),
  spanish('es', 'Spanish', 'Español', 'assets/images/flags/ES.svg'),
  french('fr', 'French', 'Français', 'assets/images/flags/FR.svg'),
  german('de', 'German', 'Deutsch', 'assets/images/flags/DE.svg'),
  portuguese('pt', 'Portuguese', 'Português', 'assets/images/flags/PT.svg'),
  chineseSimplified('zh', 'Chinese Simplified', '简体中文', 'assets/images/flags/CN.svg'),
  japanese('ja', 'Japanese', '日本語', 'assets/images/flags/JP.svg'),
  korean('ko', 'Korean', '한국어', 'assets/images/flags/KR.svg'),
  arabic('ar', 'Arabic', 'العربية', 'assets/images/flags/SA.svg'),
  hindi('hi', 'Hindi', 'हिंदी', 'assets/images/flags/IN.svg');

  final String code;
  final String englishName;
  final String nativeName;
  final String flagPath;

  const AppLanguage(this.code, this.englishName, this.nativeName, this.flagPath);

  /// Get AppLanguage from language code
  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Language state notifier with persistence
@Riverpod(keepAlive: true)
class LanguageNotifier extends _$LanguageNotifier {
  @override
  AppLanguage build() {
    _loadSavedLanguage();
    return AppLanguage.english;
  }

  /// Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final savedCode = await LanguageService.loadLanguage();
    state = AppLanguage.fromCode(savedCode);
  }

  /// Set language and persist to SharedPreferences
  void setLanguage(AppLanguage language) {
    state = language;
    LanguageService.saveLanguage(language.code);
  }

  /// Reset to default language (English)
  void resetToDefault() {
    setLanguage(AppLanguage.english);
  }
}
