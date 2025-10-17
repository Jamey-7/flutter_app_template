import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum AppLoadingSize {
  small,
  medium,
  large,
}

class AppLoadingIndicator extends StatelessWidget {
  final AppLoadingSize size;
  final String? message;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.size = AppLoadingSize.medium,
    this.message,
    this.color,
  });

  const AppLoadingIndicator.small({
    super.key,
    this.message,
    this.color,
  }) : size = AppLoadingSize.small;

  const AppLoadingIndicator.large({
    super.key,
    this.message,
    this.color,
  }) : size = AppLoadingSize.large;

  @override
  Widget build(BuildContext context) {
    final sizeValue = switch (size) {
      AppLoadingSize.small => 16.0,
      AppLoadingSize.medium => 24.0,
      AppLoadingSize.large => 40.0,
    };

    final indicator = SizedBox(
      width: sizeValue,
      height: sizeValue,
      child: CircularProgressIndicator(
        strokeWidth: size == AppLoadingSize.small ? 2 : 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? context.colors.primary,
        ),
      ),
    );

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return indicator;
  }
}

class AppLinearProgress extends StatelessWidget {
  final double? value;
  final Color? color;
  final Color? backgroundColor;

  const AppLinearProgress({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? context.colors.primary,
      ),
      backgroundColor: backgroundColor ?? AppColors.grey200,
    );
  }
}
