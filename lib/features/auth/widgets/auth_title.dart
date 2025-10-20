import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';

/// Reusable title component for auth screens with responsive sizing
class AuthTitle extends StatelessWidget {
  final String line1;
  final String line2;
  final String? subtitle;

  const AuthTitle({
    super.key,
    required this.line1,
    required this.line2,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          line1,
          style: context.textTheme.displayMedium?.copyWith(
            fontSize: context.responsive<double>(
              smallMobile: 38,
              mobile: 45,
              tablet: 52,
              desktop: 60,
            ),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
        Text(
          line2,
          style: context.textTheme.displayMedium?.copyWith(
            fontSize: context.responsive<double>(
              smallMobile: 38,
              mobile: 45,
              tablet: 52,
              desktop: 60,
            ),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 16),
          Text(
            subtitle!,
            style: context.textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
