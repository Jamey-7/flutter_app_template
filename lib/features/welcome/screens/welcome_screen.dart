import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snack_bar.dart';

/// Welcome/Landing screen - serves as the main entry point and "home base"
/// for users without active subscriptions.
///
/// Two views:
/// 1. Unauthenticated: Shows app branding, features, login/signup buttons
/// 2. Authenticated (Free): Shows user info, locked features, subscribe CTA
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return _UnauthenticatedView();
        } else {
          return _AuthenticatedView(ref: ref, user: user);
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unauthenticated view - shows app branding and login/signup options
class _UnauthenticatedView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle theme',
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icon
                  Icon(
                    Icons.flutter_dash,
                    size: 100,
                    color: context.colors.primary,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // App Name
                  Text(
                    'App Template',
                    style: context.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Tagline
                  Text(
                    'Your subscription-based Flutter app',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  const SizedBox(height: AppSpacing.xxl),

                  // Sign In Button
                  AppButton.primary(
                    text: 'Sign In',
                    onPressed: () {
                      context.push('/login');
                    },
                    icon: Icons.login,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Create Account Button
                  AppButton.secondary(
                    text: 'Create Account',
                    onPressed: () {
                      context.push('/signup');
                    },
                    icon: Icons.person_add,
                    isFullWidth: true,
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

/// Authenticated view - shows user info and subscribe CTA
class _AuthenticatedView extends ConsumerWidget {
  final WidgetRef ref;
  final dynamic user;

  const _AuthenticatedView({
    required this.ref,
    required this.user,
  });

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await AuthService.signOut();
      ref.invalidate(subscriptionProvider);
      if (context.mounted) {
        AppSnackBar.showSuccess(context, 'Signed out successfully');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, 'Error signing out: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsivePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome back!',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user.email ?? 'User',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.primary(
                    text: 'Subscribe',
                    onPressed: () {
                      context.push('/paywall');
                    },
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton.text(
                    text: 'Sign Out',
                    onPressed: () => _handleSignOut(context),
                    icon: Icons.logout,
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

