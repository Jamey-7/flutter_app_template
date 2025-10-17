import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// A reusable badge widget that indicates active subscription status.
/// Use this throughout your app to show users their premium status.
class SubscriptionBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;

  const SubscriptionBadge({
    super.key,
    this.text = 'Premium',
    this.icon = Icons.check_circle,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.success.withValues(alpha: 0.1);
    final fgColor = textColor ?? AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: fgColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: fgColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: context.textTheme.labelMedium?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
