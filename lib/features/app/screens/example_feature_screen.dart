import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/app_card.dart';
import '../widgets/subscription_badge.dart';

// ========================================
// Example Premium Feature Screen
// ========================================
//
// This demonstrates how to build a subscription-gated feature.
//
// Key Points:
// - This screen is only accessible via /app/example-feature route
// - The router automatically ensures users have active subscriptions
// - You can build any feature here: tools, dashboards, content, etc.
//
// To create your own features:
// 1. Copy this file as a template
// 2. Add your feature logic and UI
// 3. Add a route in app_router.dart under '/app' group
// 4. Link to it from app_home_screen.dart
//
// ========================================

class ExampleFeatureScreen extends ConsumerWidget {
  const ExampleFeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Feature'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: SubscriptionBadge(text: 'Premium Only'),
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
                  // Hero Section
                  Icon(
                    Icons.star,
                    size: 80,
                    color: context.colors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Premium Feature',
                    style: context.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This is an example of a subscription-gated feature.',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Feature Demo Card
                  AppCard.elevated(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Access Granted',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Because you have an active subscription, you can access this feature!',
                          style: context.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '🎯 Replace this with your feature:',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _BulletPoint('Data visualization tools'),
                        _BulletPoint('Advanced calculators'),
                        _BulletPoint('Content creation tools'),
                        _BulletPoint('Export/import functionality'),
                        _BulletPoint('AI-powered features'),
                        _BulletPoint('Collaborative tools'),
                        _BulletPoint('Analytics dashboards'),
                        _BulletPoint('Or anything else you imagine!'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Implementation Guide
                  AppCard.outlined(
                    color: context.colors.primary.withValues(alpha: 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.code,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Implementation Guide',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '📄 This file:\n'
                          'lib/features/app/screens/example_feature_screen.dart\n\n'
                          '🛣️ Route:\n'
                          '/app/example-feature (subscription protected)\n\n'
                          '🔐 Guard:\n'
                          'Automatically enforced by router redirect logic\n\n'
                          '📦 To add your feature:\n'
                          '1. Copy this file as your_feature_screen.dart\n'
                          '2. Replace the UI with your feature\n'
                          '3. Add route in app_router.dart\n'
                          '4. Link from app_home_screen.dart\n\n'
                          '💡 Pro Tips:\n'
                          '• Use AppCard, AppButton, AppTextField\n'
                          '• Add SubscriptionBadge for branding\n'
                          '• Handle loading states with AsyncValue\n'
                          '• Use Riverpod for state management',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Interactive Example
                  AppCard.elevated(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Interactive Example',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'This could be a form, a data entry tool, a calculator, or any interactive feature.',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  '✨ This is where your feature logic goes!',
                                ),
                                backgroundColor: context.colors.primary,
                              ),
                            );
                          },
                          icon: const Icon(Icons.touch_app),
                          label: const Text('Try It Out'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                          ),
                        ),
                      ],
                    ),
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

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
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
