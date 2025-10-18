import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/logger/logger.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/offerings_provider.dart';
import '../providers/subscription_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String? _purchasingPackageId;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Required'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/welcome'),
          tooltip: 'Close',
        ),
      ),
      body: SafeArea(
        child: offeringsAsync.when(
          data: (offerings) => _buildOfferingsContent(offerings),
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLoadingIndicator(size: AppLoadingSize.large),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Loading plans...',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => ErrorState(
            message: 'Failed to load subscription plans',
            onRetry: () => ref.invalidate(offeringsProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferingsContent(Offerings? offerings) {
    if (offerings == null || offerings.current == null) {
      return EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'No Plans Available',
        subtitle: 'Subscription plans are not configured yet. Please try again later.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(offeringsProvider),
      );
    }

    final packages = offerings.current!.availablePackages;

    if (packages.isEmpty) {
      return EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'No Plans Available',
        subtitle: 'No subscription packages found.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(offeringsProvider),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: AppSpacing.xl),

              // Product Cards
              ...packages.map((package) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildProductCard(package),
                  )),
              const SizedBox(height: AppSpacing.lg),

              // Feature Comparison
              _buildFeatureComparison(),
              const SizedBox(height: AppSpacing.xl),

              // Restore Purchases Button
              AppButton.text(
                text: _isRestoring ? 'Restoring...' : 'Restore Purchases',
                onPressed: _isRestoring ? null : _handleRestorePurchases,
                isLoading: _isRestoring,
              ),
              const SizedBox(height: AppSpacing.md),

              // Terms & Conditions
              _buildTermsFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.workspace_premium,
            size: 64,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Unlock Premium Features',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Choose a plan to access all features and content',
          style: context.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProductCard(Package package) {
    final product = package.storeProduct;
    final isPurchasing = _purchasingPackageId == package.identifier;
    final isYearly = package.packageType == PackageType.annual;

    // Calculate savings for annual plans
    String? savingsText;
    if (isYearly) {
      savingsText = 'Best Value • Save up to 40%';
    }

    return AppCard.elevated(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badge for best value
          if (savingsText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                savingsText,
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Product Title
          Text(
            product.title,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Product Description
          Text(
            product.description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Pricing
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                product.priceString,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _getBillingPeriodText(package.packageType),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Subscribe Button
          AppButton.primary(
            text: isPurchasing ? 'Processing...' : 'Subscribe',
            onPressed: isPurchasing ? null : () => _handlePurchase(package),
            isLoading: isPurchasing,
            isFullWidth: true,
            icon: Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return AppCard.outlined(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Included',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureItem(
            icon: Icons.check_circle,
            text: 'Full access to all features',
            isIncluded: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildFeatureItem(
            icon: Icons.check_circle,
            text: 'Priority support',
            isIncluded: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildFeatureItem(
            icon: Icons.check_circle,
            text: 'Regular updates and improvements',
            isIncluded: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildFeatureItem(
            icon: Icons.check_circle,
            text: 'Ad-free experience',
            isIncluded: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildFeatureItem(
            icon: Icons.check_circle,
            text: 'Cancel anytime',
            isIncluded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required bool isIncluded,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isIncluded ? AppColors.success : AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isIncluded ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsFooter() {
    return Text(
      'By subscribing, you agree to our Terms of Service and Privacy Policy. '
      'Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period. '
      'Manage subscriptions in your App Store or Play Store account settings.',
      style: context.textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  String _getBillingPeriodText(PackageType packageType) {
    switch (packageType) {
      case PackageType.monthly:
        return '/month';
      case PackageType.annual:
        return '/year';
      case PackageType.weekly:
        return '/week';
      case PackageType.twoMonth:
        return '/2 months';
      case PackageType.threeMonth:
        return '/3 months';
      case PackageType.sixMonth:
        return '/6 months';
      case PackageType.lifetime:
        return 'one-time';
      default:
        return '';
    }
  }

  Future<void> _handlePurchase(Package package) async {
    setState(() {
      _purchasingPackageId = package.identifier;
    });

    try {
      Logger.log(
        'Starting purchase for package: ${package.identifier}',
        tag: 'PaywallScreen',
      );

      final customerInfo = await SubscriptionService.purchasePackage(package);

      // Check if purchase was successful
      final hasActiveEntitlement = customerInfo.entitlements.active.isNotEmpty;

      if (hasActiveEntitlement) {
        Logger.log('Purchase successful', tag: 'PaywallScreen');

        // Refresh subscription state
        ref.invalidate(subscriptionProvider);

        if (mounted) {
          // Show success dialog
          await AppDialog.showSuccess(
            context,
            title: 'Welcome to Premium!',
            message: 'Your subscription is now active. Enjoy all premium features!',
          );

          // Navigate to app
          if (mounted) {
            context.go('/app');
          }
        }
      } else {
        Logger.warning('Purchase completed but no active entitlement', tag: 'PaywallScreen');
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Purchase completed but subscription not active. Please contact support.',
          );
        }
      }
    } on PlatformException catch (e) {
      Logger.error('Purchase failed with platform exception', e, null, tag: 'PaywallScreen');

      if (mounted) {
        // Handle user cancellation silently
        if (e.code == 'purchase_cancelled' || e.code == '1') {
          Logger.log('User cancelled purchase', tag: 'PaywallScreen');
          // Don't show error for cancellation
        } else if (e.code == 'product_already_purchased') {
          AppSnackBar.showInfo(context, 'You already have an active subscription!');
          ref.invalidate(subscriptionProvider);
        } else if (e.message?.contains('network') == true) {
          AppSnackBar.showError(context, 'Network error. Please check your connection.');
        } else {
          AppSnackBar.showError(
            context,
            'Purchase failed: ${e.message ?? "Unknown error"}',
          );
        }
      }
    } catch (e, stackTrace) {
      Logger.error('Purchase failed', e, stackTrace, tag: 'PaywallScreen');
      if (mounted) {
        AppSnackBar.showError(context, 'Purchase failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _purchasingPackageId = null;
        });
      }
    }
  }

  Future<void> _handleRestorePurchases() async {
    setState(() {
      _isRestoring = true;
    });

    try {
      Logger.log('Restoring purchases', tag: 'PaywallScreen');
      final customerInfo = await SubscriptionService.restorePurchases();

      final hasActiveEntitlement = customerInfo.entitlements.active.isNotEmpty;

      // Refresh subscription state
      ref.invalidate(subscriptionProvider);

      if (mounted) {
        if (hasActiveEntitlement) {
          AppSnackBar.showSuccess(context, 'Purchases restored successfully!');
          // Navigate to app if subscription is active
          context.go('/app');
        } else {
          AppSnackBar.showInfo(context, 'No active subscriptions found');
        }
      }
    } on PlatformException catch (e) {
      Logger.error('Restore purchases failed', e, null, tag: 'PaywallScreen');
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Failed to restore purchases: ${e.message ?? "Unknown error"}',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('Restore purchases failed', e, stackTrace, tag: 'PaywallScreen');
      if (mounted) {
        AppSnackBar.showError(context, 'Failed to restore purchases');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }
}
