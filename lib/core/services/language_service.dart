import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting language preferences using SharedPreferences
class LanguageService {
  static const String _languageKey = 'app_language';

  /// Load saved language code from SharedPreferences
  /// Returns saved language code or 'en' as default
  static Future<String> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      return savedLanguage ?? 'en'; // Default to English
    } catch (e) {
      print('Error loading language: $e');
      return 'en'; // Fallback to English on error
    }
  }

  /// Save language code to SharedPreferences
  static Future<void> saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  /// Clear saved language preference
  static Future<void> clearLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageKey);
    } catch (e) {
      print('Error clearing language: $e');
    }
  }
}
