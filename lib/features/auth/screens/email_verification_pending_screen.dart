import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_snack_bar.dart';

class EmailVerificationPendingScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationPendingScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailVerificationPendingScreen> createState() =>
      _EmailVerificationPendingScreenState();
}

class _EmailVerificationPendingScreenState
    extends ConsumerState<EmailVerificationPendingScreen> {
  bool _isResending = false;

  Future<void> _handleResend() async {
    setState(() => _isResending = true);

    try {
      // Resend verification by signing up again (Supabase will resend verification)
      await AuthService.signUp(
        email: widget.email,
        password: 'dummy', // Password doesn't matter for resend
      );

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          'Verification email sent! Check your inbox.',
        );
      }
    } on AuthFailure catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Failed to resend email');
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        context.pushReplacement('/login');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Error signing out');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsivePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.mark_email_unread_outlined,
                        size: 80,
                        color: context.colors.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Check Your Email',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'We\'ve sent a verification link to:\n\n${widget.email}\n\nClick the link in the email to verify your account.',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard.elevated(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Didn\'t receive the email?',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '• Check your spam folder\n'
                          '• Verify the email address is correct\n'
                          '• Request a new verification email',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton.secondary(
                          text: 'Resend Verification Email',
                          onPressed: _handleResend,
                          isLoading: _isResending,
                          isFullWidth: true,
                          icon: Icons.refresh,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton.text(
                    text: 'Back to Sign In',
                    onPressed: () {
                      context.pushReplacement('/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
