import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/subscription_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/app_card.dart';
import '../widgets/subscription_badge.dart';

// ========================================
// TODO: This is where you build your app!
// ========================================
//
// This section is only accessible to users with active subscriptions.
// Add your app's core features here.
//
// Examples of what to build:
// - Main dashboard
// - Data visualization
// - User-generated content
// - Premium tools
// - Advanced features
// - Any functionality you want to gate behind a subscription
//
// The subscription guard in the router ensures only paid users can access this.
//
// How to add new features:
// 1. Create new screens in lib/features/app/screens/
// 2. Add routes in lib/core/router/app_router.dart under the '/app' route group
// 3. Link to them from this screen
//
// ========================================

class AppHomeScreen extends ConsumerWidget {
  const AppHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium App'),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsivePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subscription Status Badge
                  Center(
                    child: subscriptionAsync.when(
                      data: (subscription) => subscription.isActive
                          ? const SubscriptionBadge()
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Welcome Section
                  Text(
                    'Welcome to Premium! 🎉',
                    style: context.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'You have full access to all premium features.',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Instructions Card for Developers
                  AppCard.outlined(
                    color: context.colors.primary.withValues(alpha: 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'For Developers',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'This is the premium app section. Build your app features here!',
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '📁 Location: lib/features/app/\n\n'
                          '✅ Users who reach this screen have:\n'
                          '  • Authenticated successfully\n'
                          '  • Subscribed to premium\n'
                          '  • Active subscription status\n\n'
                          '🚀 What to build here:\n'
                          '  • Your app\'s core functionality\n'
                          '  • Premium features and tools\n'
                          '  • User dashboards\n'
                          '  • Any subscription-gated content\n\n'
                          '🔒 Subscription Guard:\n'
                          '  Routes under /app/* are automatically protected.\n'
                          '  Free users are redirected to the paywall.\n\n'
                          '💡 See example_feature_screen.dart for a template.',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Example Features Section
                  Text(
                    'Example Features',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Replace these with your actual app features',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Example Feature Cards
                  FeatureCard(
                    icon: Icons.analytics_outlined,
                    title: 'Example Feature',
                    description: 'This demonstrates a gated premium feature',
                    onTap: () {
                      context.push('/app/example-feature');
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FeatureCard(
                    icon: Icons.dashboard_outlined,
                    title: 'Your Feature Here',
                    description: 'Add your own features by creating new screens',
                    onTap: () {
                      // TODO: Navigate to your feature
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Create your feature in lib/features/app/screens/',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FeatureCard(
                    icon: Icons.settings_applications_outlined,
                    title: 'Another Feature',
                    description: 'Build unlimited features for your subscribers',
                    onTap: () {
                      // TODO: Navigate to your feature
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Add route in lib/core/router/app_router.dart',
                          ),
                        ),
                      );
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

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(
                  icon,
                  color: context.colors.primary,
                  size: 32,
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
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
