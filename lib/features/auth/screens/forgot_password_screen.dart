import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/auth_button.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/forms/validators.dart';

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
                    child: Transform.translate(
                      offset: context.responsive<Offset>(
                        mobile: Offset.zero,
                        tablet: const Offset(0, -20),
                        desktop: const Offset(0, -20),
                      ),
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
                      child: _emailSent ? _buildSuccessView() : _buildFormView(),
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

          // Title section - left aligned
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forgot',
                style: context.textTheme.displayMedium?.copyWith(
                  fontSize: context.responsive<double>(
                    smallMobile: 38,
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
                'Password?',
                style: context.textTheme.displayMedium?.copyWith(
                  fontSize: context.responsive<double>(
                    smallMobile: 38,
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
                'Enter your email to reset your password',
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
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSubmit(),
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
