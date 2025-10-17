import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum AppCardVariant {
  elevated,
  outlined,
  flat,
}

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
  });

  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
  }) : variant = AppCardVariant.elevated;

  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
  }) : variant = AppCardVariant.outlined;

  const AppCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
  }) : variant = AppCardVariant.flat;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.md);

    final content = Padding(
      padding: effectivePadding,
      child: child,
    );

    final card = switch (variant) {
      AppCardVariant.elevated => Card(
          elevation: AppElevation.small,
          color: color,
          margin: margin ?? EdgeInsets.zero,
          child: content,
        ),
      AppCardVariant.outlined => Card(
          elevation: 0,
          color: color ?? Colors.transparent,
          margin: margin ?? EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
            side: BorderSide(
              color: context.colors.outline,
              width: 1,
            ),
          ),
          child: content,
        ),
      AppCardVariant.flat => Card(
          elevation: 0,
          color: color ?? AppColors.grey50,
          margin: margin ?? EdgeInsets.zero,
          child: content,
        ),
    };

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: card,
      );
    }

    return card;
  }
}
