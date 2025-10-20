import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/auth_button.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/forms/validators.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_title.dart';

// Set to true when social sign-in is implemented
const _kEnableSocialSignIn = true;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await AuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Navigate to welcome screen - router will handle redirect based on subscription
      if (mounted) {
        context.go('/welcome');
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
              line1: 'Hello,',
              line2: 'Sign In',
              subtitle: 'Continue where you left off',
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
              validator: (value) => Validators.password(value, minLength: 6),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: _handleSignIn,
            ),

            const SizedBox(height: 30),

            // Sign In button
            AuthButton.primary(
              text: 'Sign In',
              onPressed: _handleSignIn,
              isLoading: _isLoading,
              height: context.responsive<double>(
                mobile: 55,
                tablet: 60,
                desktop: 60,
              ),
            ),

            // Social sign-in section (hidden until implemented)
            if (_kEnableSocialSignIn) ...[
              const SizedBox(height: 25),

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
                text: 'Sign in with Google',
                svgIcon: 'assets/images/google-icon.svg',
                onPressed: _isLoading
                    ? null
                    : () {
                        // TODO: Implement Google Sign In
                        AppSnackBar.showInfo(
                          context,
                          'Google Sign In coming soon',
                        );
                      },
              ),

              // Apple Sign In button (iOS only)
              if (Platform.isIOS) ...[
                const SizedBox(height: 20),
                AuthButton.social(
                  text: 'Sign in with Apple',
                  svgIcon: 'assets/images/apple-icon.svg',
                  onPressed: _isLoading
                      ? null
                      : () {
                          // TODO: Implement Apple Sign In
                          AppSnackBar.showInfo(
                            context,
                            'Apple Sign In coming soon',
                          );
                        },
                ),
              ],
            ],

            const SizedBox(height: 30),

            // Don't have an account? Sign Up
            Center(
              child: GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        context.push('/signup');
                      },
                child: RichText(
                  text: TextSpan(
                    text: 'Don\'t have an account? ',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 15,
                    ),
                    children: const <TextSpan>[
                      TextSpan(
                        text: 'Sign Up',
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

            const SizedBox(height: 20),

            // Forgot Password?
            Center(
              child: GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        context.push('/forgot-password');
                      },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
