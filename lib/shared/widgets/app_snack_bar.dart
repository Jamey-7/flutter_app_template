import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum AppSnackBarType {
  success,
  error,
  info,
  warning,
}

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = _getColors(type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIcon(type),
              color: colors.$2,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.$2),
              ),
            ),
          ],
        ),
        backgroundColor: colors.$1,
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: colors.$2,
                onPressed: onAction ?? () {},
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(context, message, type: AppSnackBarType.success, duration: duration);
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 6),
  }) {
    show(context, message, type: AppSnackBarType.error, duration: duration);
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(context, message, type: AppSnackBarType.info, duration: duration);
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    show(context, message, type: AppSnackBarType.warning, duration: duration);
  }

  static (Color, Color) _getColors(AppSnackBarType type) {
    return switch (type) {
      AppSnackBarType.success => (AppColors.success, AppColors.white),
      AppSnackBarType.error => (AppColors.error, AppColors.white),
      AppSnackBarType.info => (AppColors.info, AppColors.white),
      AppSnackBarType.warning => (AppColors.warning, AppColors.white),
    };
  }

  static IconData _getIcon(AppSnackBarType type) {
    return switch (type) {
      AppSnackBarType.success => Icons.check_circle_outline,
      AppSnackBarType.error => Icons.error_outline,
      AppSnackBarType.info => Icons.info_outline,
      AppSnackBarType.warning => Icons.warning_amber_rounded,
    };
  }
}
