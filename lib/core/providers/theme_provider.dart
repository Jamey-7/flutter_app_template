import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/theme_service.dart';
import '../theme/app_themes.dart';

part 'theme_provider.g.dart';

/// Theme type notifier with persistence
///
/// Manages the app's selected theme (Default, Cyberpunk, Minimalist, etc.).
/// Each theme includes its own light/dark mode preference.
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
  }

  /// Set a specific theme and persist it
  void setTheme(AppThemeType type) {
    state = type;
    ThemeService.saveThemeType(type);
  }

  /// Reset to default theme
  void resetToDefault() {
    setTheme(AppThemeType.defaultTheme);
  }
}
