import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_themes.dart';
import '../../core/providers/theme_provider.dart';

/// Button with gradient border for onboarding screens
/// Mirrors the AuthButton.primary design but works in onboarding context
class OnboardingButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const OnboardingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current theme, but force Default Dark if user selected a light theme
    final themeType = ref.watch(themeTypeProvider);
    final effectiveTheme = themeType.data.mode == ThemeMode.light
        ? AppThemeData.defaultTheme()  // Force Default Dark for onboarding screens
        : themeType.data;               // Use selected dark theme

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.circular),
        gradient: LinearGradient(
          colors: [effectiveTheme.gradientStart, effectiveTheme.gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.authShadow,
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.authButtonBackground,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.circular),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(AppColors.authButtonBackground),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: AppColors.white,
                          fontSize: 17,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        icon,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: AppColors.white,
                      fontSize: 17,
                      letterSpacing: 0.5,
                    ),
                  ),
      ),
    );
  }
}
