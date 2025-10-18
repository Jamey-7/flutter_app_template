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
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      AppSnackBar.showError(
        context,
        'Please accept the Terms & Conditions',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final response = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // If email confirmation is disabled, user gets session immediately
        // If email confirmation is enabled, session will be null
        if (response.session != null) {
          // User logged in immediately - go to welcome
          AppSnackBar.showSuccess(context, 'Account created successfully!');
          context.go('/welcome');
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
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Background Image
            Image.asset(
              'assets/images/login-image.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0.4),
                    AppColors.black.withValues(alpha: 0.6),
                    AppColors.black.withValues(alpha: 0.9),
                    AppColors.black,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - topPadding,
                  ),
                  child: Align(
                    alignment: context.isMobile
                      ? Alignment.topCenter
                      : Alignment.center,
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: context.responsive<double>(
                            mobile: context.screenWidth,
                            tablet: 600,
                            desktop: 500,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsiveHorizontalPadding,
                          ),
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
                                  mobile: 80,
                                  tablet: 0,
                                  desktop: 0,
                                ),
                              ),

                              // Title section - left aligned
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome,',
                                    style: context.textTheme.displayMedium?.copyWith(
                                      fontSize: context.responsive<double>(
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
                                    'Sign Up',
                                    style: context.textTheme.displayMedium?.copyWith(
                                      fontSize: context.responsive<double>(
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
                              const SizedBox(height: 16),
                              Text(
                                'Create your account to get started',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 35),

                          // Email field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.medium),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              cursorColor: AppColors.white,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: AppColors.white,
                              ),
                              validator: Validators.email,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.white.withValues(alpha: 0.7),
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                  color: AppColors.white.withValues(alpha: 0.7),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  borderSide: BorderSide(
                                    color: AppColors.white.withValues(alpha: 0.3),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  borderSide: BorderSide(
                                    color: AppColors.white.withValues(alpha: 0.3),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  borderSide: BorderSide(
                                    color: AppColors.white.withValues(alpha: 0.7),
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 1.0,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.black.withValues(alpha: 0.6),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Password field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.medium),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleSignUp(),
                              cursorColor: AppColors.white,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: AppColors.white,
                              ),
                              validator: (value) =>
                                  Validators.password(value, minLength: 8),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.white.withValues(alpha: 0.7),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: 20,
                                  color: AppColors.white.withValues(alpha: 0.7),
                                ),
                                suffixIcon: IconButton(
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
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  borderSide: BorderSide(
                                    color: AppColors.white.withValues(alpha: 0.3),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  borderSide: BorderSide(
                                    color: AppColors.white.withValues(alpha: 0.3),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  borderSide: BorderSide(
                                    color: AppColors.white.withValues(alpha: 0.7),
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 1.0,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  borderSide: const BorderSide(
                                    color: AppColors.error,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.black.withValues(alpha: 0.6),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Terms & Conditions checkbox
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: _isLoading
                                      ? null
                                      : (value) {
                                          setState(
                                              () => _acceptedTerms = value ?? false);
                                        },
                                  fillColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return AppColors.white;
                                      }
                                      return Colors.transparent;
                                    },
                                  ),
                                  checkColor: AppColors.black,
                                  side: BorderSide(
                                    color: AppColors.white.withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I accept the ',
                                    style: TextStyle(
                                      color: AppColors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
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
                            ],
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
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Back button - positioned top-left
            Positioned(
              top: topPadding,
              left: 12,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.white,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
