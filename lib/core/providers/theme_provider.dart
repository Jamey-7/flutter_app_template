import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/theme_service.dart';

part 'theme_provider.g.dart';

/// Theme mode notifier with persistence
///
/// Manages the app's theme mode (light/dark/system) and persists
/// the user's preference using SharedPreferences.
///
/// Usage:
/// ```dart
/// // Watch theme mode
/// final themeMode = ref.watch(themeModeProvider);
///
/// // Toggle theme
/// ref.read(themeModeProvider.notifier).toggleTheme();
///
/// // Set specific theme
/// ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
/// ```
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    // Load saved theme asynchronously
    _loadSavedTheme();
    // Return initial state (will be updated when saved theme loads)
    return ThemeMode.system;
  }

  /// Load the saved theme preference on initialization
  Future<void> _loadSavedTheme() async {
    final savedTheme = await ThemeService.loadThemeMode();
    state = savedTheme;
  }

  /// Toggle between light and dark mode
  /// Does not use system mode when toggling
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else {
      setTheme(ThemeMode.light);
    }
  }

  /// Set a specific theme mode and persist it
  void setTheme(ThemeMode mode) {
    state = mode;
    ThemeService.saveThemeMode(mode);
  }

  /// Reset to system theme
  void resetToSystem() {
    setTheme(ThemeMode.system);
  }
}
