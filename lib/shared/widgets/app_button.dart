import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum AppButtonVariant {
  primary,
  secondary,
  text,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  }) : variant = AppButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null && !isLoading;
    final effectiveOnPressed = isLoading || isDisabled ? null : onPressed;

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: _getMinSize(),
            maximumSize: isFullWidth ? Size.infinite : null,
            padding: _getPadding(),
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            disabledBackgroundColor: AppColors.grey300,
            disabledForegroundColor: AppColors.grey500,
          ),
          child: _buildContent(context, isDisabled),
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: _getMinSize(),
            maximumSize: isFullWidth ? Size.infinite : null,
            padding: _getPadding(),
            foregroundColor: context.colors.primary,
            side: BorderSide(
              color: isDisabled ? AppColors.grey300 : context.colors.primary,
            ),
            disabledForegroundColor: AppColors.grey500,
          ),
          child: _buildContent(context, isDisabled),
        ),
      AppButtonVariant.text => TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            minimumSize: _getMinSize(),
            maximumSize: isFullWidth ? Size.infinite : null,
            padding: _getPadding(),
            foregroundColor: context.colors.primary,
            disabledForegroundColor: AppColors.grey500,
          ),
          child: _buildContent(context, isDisabled),
        ),
    };

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildContent(BuildContext context, bool isDisabled) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary
                ? context.colors.onPrimary
                : context.colors.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      final iconColor = _resolveForegroundColor(context, isDisabled);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getIconSize(),
            color: iconColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: _getTextStyle(context, isDisabled)),
        ],
      );
    }

    return Text(text, style: _getTextStyle(context, isDisabled));
  }

  Size _getMinSize() {
    return switch (size) {
      AppButtonSize.small => const Size(64, 36),
      AppButtonSize.medium => const Size(88, 48),
      AppButtonSize.large => const Size(120, 56),
    };
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      AppButtonSize.large => const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
    };
  }

  double _getIconSize() {
    return switch (size) {
      AppButtonSize.small => 16,
      AppButtonSize.medium => 20,
      AppButtonSize.large => 24,
    };
  }

  TextStyle? _getTextStyle(BuildContext context, bool isDisabled) {
    final baseStyle = switch (size) {
      AppButtonSize.small => context.textTheme.labelMedium,
      AppButtonSize.medium => context.textTheme.labelLarge,
      AppButtonSize.large => context.textTheme.titleMedium,
    };

    final color = _resolveForegroundColor(context, isDisabled);
    return baseStyle?.copyWith(color: color);
  }

  Color _resolveForegroundColor(BuildContext context, bool isDisabled) {
    if (isDisabled) {
      return AppColors.grey500;
    }

    return switch (variant) {
      AppButtonVariant.primary => context.colors.onPrimary,
      AppButtonVariant.secondary => context.colors.primary,
      AppButtonVariant.text => context.colors.primary,
    };
  }
}
