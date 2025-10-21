import 'package:flutter/material.dart';
import 'app_themes.dart';

class AppTheme {
  /// Build a ThemeData from AppThemeData
  static ThemeData fromThemeData(AppThemeData themeData) {
    final isLight = themeData.mode == ThemeMode.light;

    // Create base ColorScheme and customize with theme data
    final baseScheme = isLight ? ColorScheme.light() : ColorScheme.dark();
    final colorScheme = baseScheme.copyWith(
      primary: themeData.primary,
      onPrimary: themeData.surface,
      secondary: themeData.secondary,
      onSecondary: themeData.surface,
      error: themeData.error,
      onError: Colors.white,
      surface: themeData.surface,
      onSurface: themeData.textPrimary,
      surfaceContainerHighest: themeData.surfaceNeutral,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: themeData.background,
      appBarTheme: AppBarTheme(
        backgroundColor: themeData.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: AppTypography.textTheme.apply(
        bodyColor: themeData.textPrimary,
        displayColor: themeData.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(88, 48),
          // backgroundColor and foregroundColor will use colorScheme.primary and onPrimary by default
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xlarge),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xlarge),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xlarge),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: themeData.surfaceNeutral,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: themeData.textSecondary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: themeData.textSecondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: themeData.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: themeData.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: themeData.error, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.small,
        color: themeData.surfaceNeutral,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: themeData.surfaceNeutral,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: themeData.surfaceNeutral,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }
}

/// Static color constants for use in widgets
///
/// **IMPORTANT:** Most widgets should use theme colors via `Theme.of(context).colorScheme`
/// instead of these static values. These are kept for:
/// - Auth screens (fixed dark aesthetic)
/// - Legacy compatibility
/// - Reference values (grey scale)
class AppColors {
  // Neutral colors (for auth screens and legacy code)
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Status colors (constant across all themes for semantic meaning)
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Auth-specific colors (used in auth screens with fixed dark aesthetic)
  static const Color authButtonBackground = Color(0xFF0C0C0C); // Near-black button background
  static const Color authInputFill = Color(0x99000000); // 60% black (text field background)
  static const Color authShadow = Color(0x33000000); // 20% black (shadow overlay)
  static const Color authBorderLight = Color(0x4DFFFFFF); // 30% white (normal border)
  static const Color authBorderFocused = Color(0xB3FFFFFF); // 70% white (focused border)

  // Grey scale (Tailwind CSS scale - useful for hardcoded reference values)
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Text colors (semantic aliases for grey scale)
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey600;

  // Overlay colors (used for image overlays in gradients)
  static const Color overlayLight = Color(0x33000000); // Black 20%
  static const Color overlayMedium = Color(0x66000000); // Black 40%
  static const Color overlayDark = Color(0x99000000); // Black 60%
  static const Color overlayDarker = Color(0xE6000000); // Black 90%
}

/// Predefined gradients for consistent use across the app
/// Note: For theme-specific gradients, use AppThemeData.gradientStart/End
class AppGradients {
  /// Brand accent gradient (red to blue) - Used in auth screens
  /// For theme-specific gradients, use theme.gradientStart/End instead
  static const LinearGradient brandAccent = LinearGradient(
    colors: [
      Color(0xFFFA6464), // Red
      Color(0xFF19A2E6), // Blue
    ],
  );

  /// Dark overlay gradient - Use for images with light text on top
  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.overlayMedium,
      AppColors.overlayDark,
      AppColors.overlayDarker,
      Color(0xFF000000), // Black
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  /// Light overlay gradient - Use for images with dark text on top (light mode)
  static const LinearGradient lightOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x33FFFFFF), // White 20%
      Color(0x66FFFFFF), // White 40%
      Color(0xCCFFFFFF), // White 80%
      Color(0xFFFFFFFF), // White
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  /// Shimmer gradient - Use for loading skeleton screens
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFF5F5F5),
      Color(0xFFE0E0E0),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}

class AppTypography {
  static const String fontFamily = 'System';
  
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w700,
      height: 1.12,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w700,
      height: 1.15,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      height: 1.22,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.28,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.33,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.42,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.15,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.42,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.42,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.33,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: 0.5,
    ),
  );
}

class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double mlg = 20.0; // Medium-Large: between md and lg
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class AppRadius {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double xlarge = 16.0;
  static const double xxlarge = 24.0;
  static const double circular = 9999.0;
}

class AppElevation {
  static const double none = 0.0;
  static const double small = 2.0;
  static const double medium = 4.0;
  static const double large = 8.0;
  static const double xlarge = 16.0;
}

extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
