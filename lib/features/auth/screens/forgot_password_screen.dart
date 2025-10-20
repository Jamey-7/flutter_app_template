import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/auth_button.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/forms/validators.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_title.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await AuthService.resetPassword(_emailController.text.trim());

      if (mounted) {
        setState(() => _emailSent = true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Failed to send reset email. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: _emailSent ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top spacing
          SizedBox(
            height: context.responsive<double>(
              smallMobile: 60,
              mobile: 80,
              tablet: 0,
              desktop: 0,
            ),
          ),

          // Title section
          const AuthTitle(
            line1: 'Forgot',
            line2: 'Password?',
            subtitle: 'Enter your email to reset your password',
          ),

          const SizedBox(height: 24),

          // Email field
          AuthTextField.email(
            controller: _emailController,
            validator: Validators.email,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: _handleSubmit,
          ),

          const SizedBox(height: 30),

          // Send Reset Link button
          AuthButton.primary(
            text: 'Send Reset Link',
            onPressed: _handleSubmit,
            isLoading: _isLoading,
            height: context.responsive<double>(
              mobile: 55,
              tablet: 60,
              desktop: 60,
            ),
          ),

          SizedBox(
            height: context.responsive<double>(
              mobile: 40,
              tablet: 24,
              desktop: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top spacing
        SizedBox(
          height: context.responsive<double>(
            mobile: 80,
            tablet: 0,
            desktop: 0,
          ),
        ),

        // Success icon and title - centered
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Check Your Email',
              style: context.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                height: 1.2,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Message card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'We\'ve sent a password reset link to:',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _emailController.text.trim(),
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Click the link in the email to reset your password.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(
          height: context.responsive<double>(
            mobile: 40,
            tablet: 24,
            desktop: 32,
          ),
        ),

        // Send Another Email button
        Container(
          width: double.infinity,
          height: 55,
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
              backgroundColor: AppColors.white.withValues(alpha: 0.15),
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.circular),
                side: BorderSide(
                  color: AppColors.white.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              setState(() => _emailSent = false);
            },
            child: const Text(
              'Send Another Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}
