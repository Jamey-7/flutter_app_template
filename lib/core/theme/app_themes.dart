import 'package:flutter/material.dart';

/// Available app themes
enum AppThemeType {
  defaultTheme,
  cyberpunk,
  minimalist,
}

/// Extension to get theme data from enum
extension AppThemeTypeExtension on AppThemeType {
  String get displayName {
    switch (this) {
      case AppThemeType.defaultTheme:
        return 'Default';
      case AppThemeType.cyberpunk:
        return 'Cyberpunk';
      case AppThemeType.minimalist:
        return 'Minimalist';
    }
  }

  String get description {
    switch (this) {
      case AppThemeType.defaultTheme:
        return 'Classic dark theme with clean design';
      case AppThemeType.cyberpunk:
        return 'Neon colors with futuristic vibes';
      case AppThemeType.minimalist:
        return 'Clean and simple light theme';
    }
  }

  /// Get the theme data for this theme type
  AppThemeData get data {
    switch (this) {
      case AppThemeType.defaultTheme:
        return AppThemeData.defaultTheme();
      case AppThemeType.cyberpunk:
        return AppThemeData.cyberpunk();
      case AppThemeType.minimalist:
        return AppThemeData.minimalist();
    }
  }
}

/// Theme data containing all colors and settings for a theme
class AppThemeData {
  final String name;
  final ThemeMode mode; // Force light or dark mode
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceNeutral;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color textPrimary;
  final Color textSecondary;
  final Color gradientStart;
  final Color gradientEnd;

  const AppThemeData({
    required this.name,
    required this.mode,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceNeutral,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.textPrimary,
    required this.textSecondary,
    required this.gradientStart,
    required this.gradientEnd,
  });

  /// Default dark theme (current theme)
  factory AppThemeData.defaultTheme() {
    return const AppThemeData(
      name: 'Default',
      mode: ThemeMode.dark,
      primary: Color(0xFFFFFFFF), // White
      secondary: Color(0xFF7C3AED), // Purple
      background: Color(0xFF0F0F0F), // Dark background
      surface: Color(0xFF000000), // Pure black
      surfaceNeutral: Color(0xFF1A1A1A), // Dark surface neutral
      error: Color(0xFFEF4444),
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      info: Color(0xFF3B82F6),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFF9CA3AF),
      gradientStart: Color(0xFFFA6464), // Red
      gradientEnd: Color(0xFF19A2E6), // Blue
    );
  }

  /// Cyberpunk theme - neon green/cyan colors, dark mode
  factory AppThemeData.cyberpunk() {
    return const AppThemeData(
      name: 'Cyberpunk',
      mode: ThemeMode.dark,
      primary: Color(0xFF00FF9F), // Neon green
      secondary: Color(0xFF00E5FF), // Bright cyan
      background: Color(0xFF0A0A0A), // Almost black
      surface: Color(0xFF000000), // Pure black
      surfaceNeutral: Color(0xFF0F1A15), // Dark with green tint
      error: Color(0xFFFF0055),
      success: Color(0xFF00FF88),
      warning: Color(0xFFFFDD00),
      info: Color(0xFF00E5FF),
      textPrimary: Color(0xFFE0FFE0), // Slight green tint on white
      textSecondary: Color(0xFF80FFD0), // Green-cyan secondary
      gradientStart: Color(0xFF00FF9F), // Neon green
      gradientEnd: Color(0xFF00E5FF), // Cyan
    );
  }

  /// Minimalist theme - clean and simple, light mode
  factory AppThemeData.minimalist() {
    return const AppThemeData(
      name: 'Minimalist',
      mode: ThemeMode.light,
      primary: Color(0xFF000000), // Black
      secondary: Color(0xFF6B7280), // Grey
      background: Color(0xFFFFFFFF), // White
      surface: Color(0xFFFFFFFF), // White
      surfaceNeutral: Color(0xFFF9FAFB), // Very light grey
      error: Color(0xFFDC2626),
      success: Color(0xFF059669),
      warning: Color(0xFFD97706),
      info: Color(0xFF2563EB),
      textPrimary: Color(0xFF111827),
      textSecondary: Color(0xFF6B7280),
      gradientStart: Color(0xFF000000), // Black
      gradientEnd: Color(0xFF4B5563), // Grey
    );
  }
}
