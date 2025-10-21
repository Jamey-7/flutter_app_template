import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_themes.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/responsive/breakpoints.dart';

/// Rating prompt dialog that asks "Are you enjoying the app?"
///
/// Shows a simple dialog with two options:
/// - "Yes" (returns true) - User is happy, will show rating dialog
/// - "Not Really" (returns false) - User is unhappy, will show feedback dialog
class RatingPromptDialog extends ConsumerWidget {
  const RatingPromptDialog({super.key});

  /// Show the rating prompt dialog
  ///
  /// Returns:
  /// - true if user clicked "Yes"
  /// - false if user clicked "Not Really"
  /// - null if dialog was dismissed
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RatingPromptDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeType = ref.watch(themeTypeProvider);
    final themeData = themeType.data;

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      insetPadding: context.responsive<EdgeInsets>(
        smallMobile: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        mobile: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        tablet: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        desktop: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxlarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Heart icon with gradient
            Container(
              width: context.responsive<double>(
                smallMobile: 48,
                mobile: 52,
                tablet: 56,
                desktop: 56,
              ),
              height: context.responsive<double>(
                smallMobile: 48,
                mobile: 52,
                tablet: 56,
                desktop: 56,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeData.gradientStart.withValues(alpha: 0.15),
                    themeData.gradientEnd.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeData.gradientStart,
                    themeData.gradientEnd,
                  ],
                ).createShader(bounds),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: context.responsive<double>(
                    smallMobile: 24,
                    mobile: 26,
                    tablet: 28,
                    desktop: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title
            Text(
              'Are you enjoying the app?',
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: context.responsive<double>(
                  smallMobile: 18,
                  mobile: 20,
                  tablet: 22,
                  desktop: 22,
                ),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Message
            Text(
              'Your feedback helps us improve',
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: context.responsive<double>(
                  smallMobile: 13,
                  mobile: 14,
                  tablet: 15,
                  desktop: 15,
                ),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Buttons
            Row(
              children: [
                // Not Really button
                Expanded(
                  child: SizedBox(
                    height: context.responsive<double>(
                      smallMobile: 44,
                      mobile: 48,
                      tablet: 48,
                      desktop: 48,
                    ),
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 0,
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.large),
                        ),
                      ),
                      child: Text(
                        'Not Really',
                        style: TextStyle(
                          fontSize: context.responsive<double>(
                            smallMobile: 14,
                            mobile: 14,
                            tablet: 14,
                            desktop: 14,
                          ),
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Yes button
                Expanded(
                  child: SizedBox(
                    height: context.responsive<double>(
                      smallMobile: 44,
                      mobile: 48,
                      tablet: 48,
                      desktop: 48,
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 0,
                        ),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.large),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: context.responsive<double>(
                            smallMobile: 14,
                            mobile: 14,
                            tablet: 14,
                            desktop: 14,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
