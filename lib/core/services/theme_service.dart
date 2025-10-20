import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting theme preferences
class ThemeService {
  static const String _themeModeKey = 'theme_mode';

  /// Load the saved theme mode from SharedPreferences
  /// Returns ThemeMode.system if no preference is saved
  static Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);

      if (themeModeString == null) {
        return ThemeMode.system; // Default to system preference
      }

      // Convert string back to ThemeMode enum
      switch (themeModeString) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      // If there's any error, default to system theme
      return ThemeMode.system;
    }
  }

  /// Save the theme mode to SharedPreferences
  static Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert ThemeMode enum to string
      String themeModeString;
      switch (mode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }

      await prefs.setString(_themeModeKey, themeModeString);
    } catch (e) {
      // Silent fail - theme will just not persist
      debugPrint('Failed to save theme mode: $e');
    }
  }

  /// Clear saved theme preference (resets to system default)
  static Future<void> clearThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeModeKey);
    } catch (e) {
      debugPrint('Failed to clear theme mode: $e');
    }
  }
}
