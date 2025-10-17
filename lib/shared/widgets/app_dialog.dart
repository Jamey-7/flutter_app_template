import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'app_button.dart';

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
      builder: (context) => AlertDialog(
        icon: Icon(
          _getIcon(type),
          color: _getIconColor(type),
          size: 48,
        ),
        title: Text(
          title,
          style: context.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
        ),
        actions: [
          if (cancelText != null)
            AppButton.secondary(
              text: cancelText,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          if (confirmText != null)
            AppButton.primary(
              text: confirmText,
              onPressed: () {
                onConfirm?.call();
                Navigator.of(context).pop(true);
              },
            ),
        ],
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
      AppDialogType.confirmation => Icons.help_outline,
      AppDialogType.error => Icons.error_outline,
      AppDialogType.success => Icons.check_circle_outline,
      AppDialogType.info => Icons.info_outline,
    };
  }

  static Color _getIconColor(AppDialogType type) {
    return switch (type) {
      AppDialogType.confirmation => AppColors.info,
      AppDialogType.error => AppColors.error,
      AppDialogType.success => AppColors.success,
      AppDialogType.info => AppColors.info,
    };
  }
}
