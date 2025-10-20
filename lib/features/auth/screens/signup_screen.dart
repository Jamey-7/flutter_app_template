import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;

import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../shared/widgets/auth_button.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/forms/validators.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_title.dart';

// Set to true when social sign-in is implemented
const _kEnableSocialSignIn = true;

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final response = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Mark onboarding as complete on successful sign up
      await OnboardingService.markOnboardingComplete();

      if (mounted) {
        // If email confirmation is disabled, user gets session immediately
        // If email confirmation is enabled, session will be null
        if (response.session != null) {
          // User logged in immediately - router will redirect to paywall or app
          AppSnackBar.showSuccess(context, 'Account created successfully!');
          context.go('/app');
        } else {
          // Email verification required - go to pending screen
          context.pushReplacement(
            '/email-verification-pending',
            extra: _emailController.text.trim(),
          );
        }
      }
    } on AuthFailure catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Error: ${e.toString()}');
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
      child: Form(
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
              line1: 'Let\'s Get You,',
              line2: 'Signed Up',
              subtitle: 'Create your account to get started',
            ),

            const SizedBox(height: 24),

            // Email field
            AuthTextField.email(
              controller: _emailController,
              validator: Validators.email,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 20),

            // Password field
            AuthTextField.password(
              controller: _passwordController,
              validator: (value) => Validators.password(value, minLength: 8),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: _handleSignUp,
            ),

            const SizedBox(height: 30),

            // Sign Up button
            AuthButton.primary(
              text: 'Create Account',
              onPressed: _handleSignUp,
              isLoading: _isLoading,
              height: context.responsive<double>(
                mobile: 55,
                tablet: 60,
                desktop: 60,
              ),
            ),

            const SizedBox(height: 20),

            // Terms & Privacy disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text.rich(
                TextSpan(
                  text: 'By signing up you agree to our ',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Social sign-in section (hidden until implemented)
            if (_kEnableSocialSignIn) ...[
              const SizedBox(height: 20),

              // OR divider
              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      color: AppColors.white.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.white.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Google Sign In button
              AuthButton.social(
                text: 'Sign up with Google',
                svgIcon: 'assets/images/google-icon.svg',
                onPressed: _isLoading
                    ? null
                    : () {
                        // TODO: Implement Google Sign Up
                        AppSnackBar.showInfo(
                          context,
                          'Google Sign Up coming soon',
                        );
                      },
              ),

              // Apple Sign In button (iOS only)
              if (Platform.isIOS) ...[
                const SizedBox(height: 20),
                AuthButton.social(
                  text: 'Sign up with Apple',
                  svgIcon: 'assets/images/apple-icon.svg',
                  onPressed: _isLoading
                      ? null
                      : () {
                          // TODO: Implement Apple Sign Up
                          AppSnackBar.showInfo(
                            context,
                            'Apple Sign Up coming soon',
                          );
                        },
                ),
              ],
            ],

            const SizedBox(height: 30),

            // Already have an account? Sign In
            Center(
              child: GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        context.pushReplacement('/login');
                      },
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 15,
                    ),
                    children: const <TextSpan>[
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
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
      ),
    );
  }
}
