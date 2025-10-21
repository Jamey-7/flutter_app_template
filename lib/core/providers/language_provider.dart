import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/language_service.dart';

part 'language_provider.g.dart';

/// Supported languages with their metadata
enum AppLanguage {
  english('en', 'English', 'English', '🇺🇸'),
  spanish('es', 'Spanish', 'Español', '🇪🇸'),
  french('fr', 'French', 'Français', '🇫🇷'),
  german('de', 'German', 'Deutsch', '🇩🇪'),
  portuguese('pt', 'Portuguese', 'Português', '🇵🇹'),
  chineseSimplified('zh', 'Chinese Simplified', '简体中文', '🇨🇳'),
  japanese('ja', 'Japanese', '日本語', '🇯🇵'),
  korean('ko', 'Korean', '한국어', '🇰🇷'),
  arabic('ar', 'Arabic', 'العربية', '🇸🇦'),
  hindi('hi', 'Hindi', 'हिंदी', '🇮🇳');

  final String code;
  final String englishName;
  final String nativeName;
  final String flag;

  const AppLanguage(this.code, this.englishName, this.nativeName, this.flag);

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
