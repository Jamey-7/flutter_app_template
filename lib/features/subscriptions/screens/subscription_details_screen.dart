import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/logger/logger.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/app/widgets/subscription_badge.dart';
import '../providers/subscription_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_snack_bar.dart';

class SubscriptionDetailsScreen extends ConsumerWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
      ),
      body: SafeArea(
        child: subscriptionAsync.when(
          data: (subscription) => SingleChildScrollView(
            padding: EdgeInsets.all(context.responsivePadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Current Subscription Card
                    _buildSubscriptionCard(context, subscription),
                    const SizedBox(height: AppSpacing.xl),

                    // Manage Subscription Section
                    if (subscription.isActive) ...[
                      Text(
                        'Manage Subscription',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildManageSubscriptionCard(context),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // Benefits Section
                    Text(
                      'Premium Benefits',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildBenefitsCard(context),
                    const SizedBox(height: AppSpacing.xl),

                    // Cancellation Info
                    if (subscription.isActive) ...[
                      Text(
                        'Cancellation Information',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildCancellationInfoCard(context, subscription),
                    ],
                  ],
                ),
              ),
            ),
          ),
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLoadingIndicator(size: AppLoadingSize.large),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Loading subscription...',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load subscription',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.secondary(
                  text: 'Retry',
                  onPressed: () => ref.invalidate(subscriptionProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, subscription) {
    return AppCard.elevated(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                subscription.isActive ? Icons.check_circle : Icons.info_outline,
                color: subscription.isActive ? AppColors.success : AppColors.warning,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.isActive ? 'Active Subscription' : 'Free Tier',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SubscriptionBadge(
                      text: subscription.tier.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          _buildInfoRow(
            context,
            label: 'Tier',
            value: subscription.tier.toUpperCase(),
            icon: Icons.card_membership,
          ),
          if (subscription.expirationDate != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              context,
              label: subscription.isActive ? 'Renews On' : 'Expired On',
              value: _formatDate(subscription.expirationDate!),
              icon: Icons.calendar_today,
            ),
          ],
          if (subscription.productIdentifier != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              context,
              label: 'Product',
              value: subscription.productIdentifier!,
              icon: Icons.shopping_bag,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManageSubscriptionCard(BuildContext context) {
    return AppCard.elevated(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: context.colors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Manage in Store',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'To change your plan, cancel, or manage billing, use your device\'s store settings.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (Platform.isIOS) ...[
            AppButton.secondary(
              text: 'Manage in App Store',
              onPressed: () => _openAppStore(context),
              icon: Icons.apple,
              isFullWidth: true,
            ),
          ] else if (Platform.isAndroid) ...[
            AppButton.secondary(
              text: 'Manage in Play Store',
              onPressed: () => _openPlayStore(context),
              icon: Icons.shop,
              isFullWidth: true,
            ),
          ] else ...[
            Text(
              'Platform-specific management not available on this device.',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitsCard(BuildContext context) {
    return AppCard.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have access to:',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildBenefitItem(
            context,
            icon: Icons.check_circle,
            text: 'Full access to all premium features',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildBenefitItem(
            context,
            icon: Icons.check_circle,
            text: 'Priority customer support',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildBenefitItem(
            context,
            icon: Icons.check_circle,
            text: 'Regular updates and new features',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildBenefitItem(
            context,
            icon: Icons.check_circle,
            text: 'Ad-free experience',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildBenefitItem(
            context,
            icon: Icons.check_circle,
            text: 'Unlimited usage',
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationInfoCard(BuildContext context, subscription) {
    return AppCard.outlined(
      color: AppColors.info.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'How to Cancel',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (Platform.isIOS) ...[
            _buildCancellationStep('1. Open Settings on your device'),
            _buildCancellationStep('2. Tap your name, then Subscriptions'),
            _buildCancellationStep('3. Select this subscription'),
            _buildCancellationStep('4. Tap Cancel Subscription'),
          ] else if (Platform.isAndroid) ...[
            _buildCancellationStep('1. Open Play Store app'),
            _buildCancellationStep('2. Tap Menu → Subscriptions'),
            _buildCancellationStep('3. Select this subscription'),
            _buildCancellationStep('4. Tap Cancel subscription'),
          ] else ...[
            Text(
              'Please contact support for cancellation assistance.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.warning, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'You\'ll have access until ${subscription.expirationDate != null ? _formatDate(subscription.expirationDate!) : 'the end of your billing period'}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.success, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationStep(String step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        step,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _openAppStore(BuildContext context) async {
    try {
      final url = Uri.parse('https://apps.apple.com/account/subscriptions');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          AppSnackBar.showError(context, 'Could not open App Store');
        }
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to open App Store', e, stackTrace, tag: 'SubscriptionDetails');
      if (context.mounted) {
        AppSnackBar.showError(context, 'Failed to open App Store');
      }
    }
  }

  Future<void> _openPlayStore(BuildContext context) async {
    try {
      // This opens the subscriptions page in Play Store
      final url = Uri.parse('https://play.google.com/store/account/subscriptions');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          AppSnackBar.showError(context, 'Could not open Play Store');
        }
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to open Play Store', e, stackTrace, tag: 'SubscriptionDetails');
      if (context.mounted) {
        AppSnackBar.showError(context, 'Failed to open Play Store');
      }
    }
  }
}
