import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
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
class _UnauthenticatedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                  // Feature Highlights
                  AppCard.elevated(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What you get:',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _FeatureItem(
                          icon: Icons.analytics_outlined,
                          title: 'Advanced Analytics',
                          description: 'Track your progress with detailed insights',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _FeatureItem(
                          icon: Icons.star_outline,
                          title: 'Premium Features',
                          description: 'Unlock powerful tools and capabilities',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _FeatureItem(
                          icon: Icons.support_agent_outlined,
                          title: 'Priority Support',
                          description: 'Get help when you need it',
                        ),
                      ],
                    ),
                  ),
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
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Info Card
                  AppCard.elevated(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: context.colors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email ?? 'User',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Subscription Status
                  subscriptionAsync.when(
                    data: (subscription) {
                      return AppCard.elevated(
                        color: AppColors.warning.withValues(alpha: 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: AppColors.warning.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.workspace_premium_outlined,
                                        size: 16,
                                        color: AppColors.warning,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        subscription.tier.toUpperCase(),
                                        style: context.textTheme.labelMedium?.copyWith(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Unlock Premium Features',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Subscribe to get access to all premium features and tools.',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Premium Features List
                            _LockedFeature('Advanced Analytics Dashboard'),
                            _LockedFeature('Premium Tools & Utilities'),
                            _LockedFeature('Priority Customer Support'),
                            _LockedFeature('Ad-Free Experience'),
                            _LockedFeature('Exclusive Content & Updates'),

                            const SizedBox(height: AppSpacing.xl),

                            // Subscribe Button
                            AppButton.primary(
                              text: 'Subscribe to Unlock Premium',
                              onPressed: () {
                                context.push('/paywall');
                              },
                              icon: Icons.upgrade,
                              isFullWidth: true,
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const AppCard.elevated(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    error: (error, _) => AppCard.elevated(
                      child: Text('Error loading subscription: $error'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Sign Out Button
                  AppButton.text(
                    text: 'Sign Out',
                    onPressed: () => _handleSignOut(context),
                    icon: Icons.logout,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Feature item widget for unauthenticated view
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Icon(
            icon,
            color: context.colors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Locked feature item for authenticated view
class _LockedFeature extends StatelessWidget {
  final String text;

  const _LockedFeature(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
