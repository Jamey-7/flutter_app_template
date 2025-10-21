import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_themes.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/responsive/breakpoints.dart';

enum AppDialogType {
  confirmation,
  error,
  success,
  info,
}

class AppDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    AppDialogType type = AppDialogType.info,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final theme = Theme.of(context);
          final themeType = ref.watch(themeTypeProvider);
          final themeData = themeType.data;

          return Dialog(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            surfaceTintColor: Colors.transparent,
            insetPadding: context.responsive<EdgeInsets>(
              smallMobile: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
              mobile: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              tablet: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              desktop: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xxlarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with gradient
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
                        _getIcon(type),
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
                    title,
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
                    message,
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
                      if (cancelText != null) ...[
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
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
                                side: BorderSide(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.large),
                                ),
                              ),
                              child: Text(
                                cancelText,
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
                      ],
                      if (confirmText != null)
                        Expanded(
                          child: SizedBox(
                            height: context.responsive<double>(
                              smallMobile: 44,
                              mobile: 48,
                              tablet: 48,
                              desktop: 48,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                onConfirm?.call();
                                Navigator.of(context).pop(true);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.large),
                                ),
                              ),
                              child: Text(
                                confirmText,
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
        },
      ),
    );
  }

  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AppDialogType.confirmation,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
    );
  }

  static Future<bool?> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onRetry,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AppDialogType.error,
      confirmText: onRetry != null ? 'Retry' : buttonText,
      cancelText: onRetry != null ? 'Cancel' : null,
      onConfirm: onRetry,
    );
  }

  static Future<bool?> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onDismiss,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AppDialogType.success,
      confirmText: buttonText,
      onConfirm: onDismiss,
    );
  }

  static Future<bool?> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AppDialogType.info,
      confirmText: buttonText,
    );
  }

  static IconData _getIcon(AppDialogType type) {
    return switch (type) {
      AppDialogType.confirmation => Icons.logout,
      AppDialogType.error => Icons.error_outline,
      AppDialogType.success => Icons.check_circle_outline,
      AppDialogType.info => Icons.info_outline,
    };
  }
}
