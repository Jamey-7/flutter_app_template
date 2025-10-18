import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';

enum AuthButtonType {
  primary,
  social,
}

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AuthButtonType type;
  final String? svgIcon;
  final double height;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = AuthButtonType.primary,
    this.svgIcon,
    this.height = 55,
  });

  const AuthButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.height = 55,
  })  : type = AuthButtonType.primary,
        svgIcon = null;

  const AuthButton.social({
    super.key,
    required this.text,
    required this.svgIcon,
    this.onPressed,
    this.isLoading = false,
    this.height = 55,
  }) : type = AuthButtonType.social;

  @override
  Widget build(BuildContext context) {
    if (type == AuthButtonType.primary) {
      return _buildGradientBorderedButton(context);
    } else {
      return _buildSocialButton(context);
    }
  }

  Widget _buildGradientBorderedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.circular),
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
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
          backgroundColor: const Color(0xFF0C0C0C),
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.circular),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(const Color(0xFF0C0C0C)),
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
            : Text(
                text,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.circular),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black.withValues(alpha: 0.3),
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.circular),
            side: BorderSide(
              color: AppColors.white.withValues(alpha: 0.2),
              width: 1.0,
            ),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (svgIcon != null)
                    SvgPicture.asset(
                      svgIcon!,
                      height: 24.0,
                      width: 24.0,
                      colorFilter: svgIcon!.contains('apple')
                          ? const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            )
                          : null,
                    ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
