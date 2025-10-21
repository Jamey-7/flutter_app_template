import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum AuthTextFieldType {
  email,
  password,
  text,
}

/// Styled text field for auth screens with white text on dark background
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final AuthTextFieldType type;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onFieldSubmitted;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.type,
    required this.label,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  const AuthTextField.email({
    super.key,
    required this.controller,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.enabled = true,
  })  : type = AuthTextFieldType.email,
        label = 'Email';

  const AuthTextField.password({
    super.key,
    required this.controller,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.enabled = true,
  })  : type = AuthTextFieldType.password,
        label = 'Password';

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.authShadow,
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        enabled: widget.enabled,
        obscureText: widget.type == AuthTextFieldType.password && _obscurePassword,
        keyboardType: widget.type == AuthTextFieldType.email
            ? TextInputType.emailAddress
            : TextInputType.text,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted != null
            ? (_) => widget.onFieldSubmitted!()
            : null,
        cursorColor: AppColors.white,
        style: context.textTheme.bodyLarge?.copyWith(
          color: AppColors.white,
        ),
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: context.textTheme.bodyLarge?.copyWith(
            color: AppColors.white.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            _getPrefixIcon(),
            size: 20,
            color: AppColors.white.withValues(alpha: 0.7),
          ),
          suffixIcon: widget.type == AuthTextFieldType.password
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
            borderSide: const BorderSide(
              color: AppColors.authBorderLight,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
            borderSide: const BorderSide(
              color: AppColors.authBorderLight,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
            borderSide: const BorderSide(
              color: AppColors.authBorderFocused,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: AppColors.authInputFill,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  IconData _getPrefixIcon() {
    switch (widget.type) {
      case AuthTextFieldType.email:
        return Icons.email_outlined;
      case AuthTextFieldType.password:
        return Icons.lock_outline;
      case AuthTextFieldType.text:
        return Icons.person_outline;
    }
  }
}
