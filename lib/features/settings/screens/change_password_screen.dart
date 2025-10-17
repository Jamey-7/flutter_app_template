import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/forms/validators.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // First, re-authenticate with current password
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser?.email == null) {
        throw Exception('No current user email found');
      }

      await AuthService.signIn(
        email: currentUser!.email!,
        password: _currentPasswordController.text,
      );

      // Then update the password
      await AuthService.updatePassword(_newPasswordController.text);

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          'Password changed successfully!',
        );
        context.pop();
      }
    } on AuthFailure catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Failed to change password. Please check your current password and try again.',
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
        title: const Text('Change Password'),
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
                      Icons.lock_reset,
                      size: 80,
                      color: context.colors.primary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Change Your Password',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Enter your current password and choose a new one.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppTextField(
                      controller: _currentPasswordController,
                      type: AppTextFieldType.password,
                      label: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: Validators.required,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _newPasswordController,
                      type: AppTextFieldType.password,
                      label: 'New Password',
                      prefixIcon: const Icon(Icons.lock_open),
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
                      prefixIcon: const Icon(Icons.lock_open),
                      validator: (value) => Validators.match(
                        value,
                        _newPasswordController.text,
                        fieldName: 'Passwords',
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton.primary(
                      text: 'Change Password',
                      onPressed: _handleSubmit,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      icon: Icons.check,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton.text(
                      text: 'Cancel',
                      onPressed: _isLoading
                          ? null
                          : () {
                              context.pop();
                            },
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
