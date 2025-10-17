import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_state_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/app_loading_indicator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await AuthService.signOut();
                ref.invalidate(subscriptionProvider);
              } catch (e) {
                if (context.mounted) {
                  AppSnackBar.showError(context, 'Error signing out: $e');
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsivePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome!',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                appState.subscription.when(
                  data: (_) => 'You are successfully authenticated and have an active subscription.',
                  loading: () => 'Loading subscription details...',
                  error: (error, _) => 'Subscription status unavailable: $error',
                ),
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              _StateCard(
                title: 'Authentication State',
                icon: Icons.person_outline,
                children: [
                  _InfoRow(
                    label: 'Status',
                    value: appState.isAuthenticated ? 'Signed In' : 'Signed Out',
                    valueColor: appState.isAuthenticated ? AppColors.success : AppColors.error,
                  ),
                  if (appState.user != null) ...[
                    _InfoRow(
                      label: 'Email',
                      value: appState.user!.email ?? 'N/A',
                    ),
                    _InfoRow(
                      label: 'User ID',
                      value: '${appState.user!.id.substring(0, 8)}...',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              appState.subscription.when(
                data: (subscription) => _StateCard(
                  title: 'Subscription State',
                  icon: Icons.card_membership_outlined,
                  children: [
                    _InfoRow(
                      label: 'Status',
                      value: subscription.isActive ? 'Active' : 'Inactive',
                      valueColor: subscription.isActive ? AppColors.success : AppColors.warning,
                    ),
                    _InfoRow(
                      label: 'Tier',
                      value: subscription.tier.toUpperCase(),
                    ),
                    if (subscription.expirationDate != null)
                      _InfoRow(
                        label: 'Expires',
                        value: _formatDate(subscription.expirationDate!),
                      ),
                    if (subscription.productIdentifier != null)
                      _InfoRow(
                        label: 'Product',
                        value: subscription.productIdentifier!,
                      ),
                  ],
                ),
                loading: () => const _StateCard(
                  title: 'Subscription State',
                  icon: Icons.card_membership_outlined,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: AppLinearProgress(),
                    ),
                  ],
                ),
                error: (error, _) => _StateCard(
                  title: 'Subscription State',
                  icon: Icons.warning_amber_rounded,
                  children: [
                    Text('Failed to load subscription: $error'),
                    const SizedBox(height: AppSpacing.md),
                    AppButton.primary(
                      text: 'Retry',
                      onPressed: () => ref.read(subscriptionProvider.notifier).refreshSubscription(),
                      icon: Icons.refresh,
                      size: AppButtonSize.small,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppCard.flat(
                color: AppColors.info.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Phase 3 Complete! UI foundation system is now in place.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _StateCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _StateCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: context.textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
