import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/forms/validators.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.updatePassword(_passwordController.text);

      if (mounted) {
        // Show success dialog
        await AppDialog.show(
          context,
          type: AppDialogType.success,
          title: 'Password Reset Successfully',
          message:
              'Your password has been changed. You can now sign in with your new password.',
          confirmText: 'Go to Sign In',
        );

        if (mounted) {
          context.go('/login');
        }
      }
    } on AuthFailure catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Failed to reset password. Please try again.',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsivePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_open,
                      size: 80,
                      color: context.colors.primary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Create New Password',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Enter your new password below.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppTextField(
                      controller: _passwordController,
                      type: AppTextFieldType.password,
                      label: 'New Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (value) =>
                          Validators.password(value, minLength: 8),
                      textInputAction: TextInputAction.next,
                      helperText: 'At least 8 characters',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _confirmPasswordController,
                      type: AppTextFieldType.password,
                      label: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (value) => Validators.match(
                        value,
                        _passwordController.text,
                        fieldName: 'Passwords',
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton.primary(
                      text: 'Reset Password',
                      onPressed: _handleSubmit,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      icon: Icons.check,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
