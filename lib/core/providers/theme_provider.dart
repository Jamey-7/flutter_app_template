import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/theme_service.dart';
import '../theme/app_themes.dart';

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

/// Theme type notifier with persistence
///
/// Manages the app's selected theme (Default, Cyberpunk, Minimalist, etc.)
/// and automatically sets the corresponding light/dark mode.
///
/// Usage:
/// ```dart
/// // Watch selected theme
/// final theme = ref.watch(themeTypeProvider);
///
/// // Change theme
/// ref.read(themeTypeProvider.notifier).setTheme(AppThemeType.cyberpunk);
/// ```
@Riverpod(keepAlive: true)
class ThemeTypeNotifier extends _$ThemeTypeNotifier {
  @override
  AppThemeType build() {
    // Load saved theme asynchronously
    _loadSavedTheme();
    // Return initial state (will be updated when saved theme loads)
    return AppThemeType.defaultTheme;
  }

  /// Load the saved theme preference on initialization
  Future<void> _loadSavedTheme() async {
    final savedTheme = await ThemeService.loadThemeType();
    state = savedTheme;

    // Automatically set the theme mode based on the selected theme
    final themeData = savedTheme.data;
    ref.read(themeModeProvider.notifier).setTheme(themeData.mode);
  }

  /// Set a specific theme and update the theme mode accordingly
  void setTheme(AppThemeType type) {
    state = type;
    ThemeService.saveThemeType(type);

    // Automatically set the corresponding light/dark mode
    final themeData = type.data;
    ref.read(themeModeProvider.notifier).setTheme(themeData.mode);
  }

  /// Reset to default theme
  void resetToDefault() {
    setTheme(AppThemeType.defaultTheme);
  }
}
