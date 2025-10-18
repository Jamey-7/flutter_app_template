import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/forms/validators.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // First, re-authenticate the user with their password
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser?.email == null) {
        throw Exception('No current user email found');
      }

      await AuthService.signIn(
        email: currentUser!.email!,
        password: _passwordController.text,
      );

      // Then update the email
      await AuthService.updateEmail(_newEmailController.text.trim());

      if (mounted) {
        await AppDialog.show(
          context,
          type: AppDialogType.success,
          title: 'Email Update Requested',
          message:
              'We\'ve sent a confirmation email to your new address. Please check your email and click the verification link to complete the change.',
          confirmText: 'OK',
        );

        if (mounted) {
          context.pop();
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
          'Failed to update email. Please check your password and try again.',
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
        title: const Text('Change Email'),
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
                      Icons.email_outlined,
                      size: 80,
                      color: context.colors.primary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Update Your Email',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Enter your new email address and current password to confirm.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppTextField(
                      controller: _newEmailController,
                      type: AppTextFieldType.email,
                      label: 'New Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: Validators.email,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _passwordController,
                      type: AppTextFieldType.password,
                      label: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: Validators.required,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSubmit(),
                      helperText: 'Enter your current password to confirm',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton.primary(
                      text: 'Update Email',
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
