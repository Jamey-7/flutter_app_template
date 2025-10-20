import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/logger/logger.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/offerings_provider.dart';
import '../providers/subscription_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_snack_bar.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String? _selectedPackageId;
  bool _isPurchasing = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      body: offeringsAsync.when(
        data: (offerings) => _buildOfferingsContent(offerings),
        loading: () => Stack(
          children: [
            // Background Image
            Image.asset(
              'assets/images/paywall-image.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.darkOverlay,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLoadingIndicator(size: AppLoadingSize.large),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Loading plans...',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => Stack(
          children: [
            // Background Image
            Image.asset(
              'assets/images/paywall-image.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.darkOverlay,
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Failed to load subscription plans',
                        style: context.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton.primary(
                        text: 'Retry',
                        onPressed: () => ref.invalidate(offeringsProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top,
              right: 12,
              child: IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => context.push('/settings'),
                tooltip: 'Settings',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferingsContent(Offerings? offerings) {
    if (offerings == null || offerings.current == null) {
      return Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/paywall-image.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.darkOverlay,
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No Plans Available',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Subscription plans are not configured yet. Please try again later.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton.primary(
                      text: 'Retry',
                      onPressed: () => ref.invalidate(offeringsProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 12,
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => context.push('/settings'),
              tooltip: 'Settings',
            ),
          ),
        ],
      );
    }

    final packages = offerings.current!.availablePackages;

    if (packages.isEmpty) {
      return Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/paywall-image.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.darkOverlay,
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No Plans Available',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No subscription packages found.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton.primary(
                      text: 'Retry',
                      onPressed: () => ref.invalidate(offeringsProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 12,
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => context.push('/settings'),
              tooltip: 'Settings',
            ),
          ),
        ],
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Background Image
        Image.asset(
          'assets/images/paywall-image.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),

        // Gradient Overlay
        Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.darkOverlay,
          ),
        ),

        // Scrollable Content
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight - topPadding),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Spacing to prevent overlap with close button
                    const SizedBox(height: 60.0),

                    // Bottom Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        _buildHeader(),
                        const SizedBox(height: 30),

                        // Product Cards
                        ...packages.map((package) => _buildProductCard(package)),

                        const SizedBox(height: 8.0),

                        // Subscribe Button
                        _buildSubscribeButton(),

                        const SizedBox(height: 0.0),

                        // Restore Purchases Button
                        _buildRestoreButton(),

                        const SizedBox(height: 0.0),

                        // Terms & Conditions
                        _buildTermsFooter(),

                        const SizedBox(height: 30),
                      ],
                    ),

                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Close button positioned over the image
        Positioned(
          top: topPadding,
          left: 12,
          child: IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        // Settings button in top right
        Positioned(
          top: topPadding,
          right: 12,
          child: IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unlock',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
        Text(
          'Access',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
        Text(
          'Now',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Colors.white.withValues(alpha: 0.9),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'All Features Included',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.devices,
              color: Colors.white.withValues(alpha: 0.9),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'All Platforms Supported',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductCard(Package package) {
    final product = package.storeProduct;
    final isYearly = package.packageType == PackageType.annual;
    final isSelected = _selectedPackageId == package.identifier;
    final bestDeal = isYearly;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageId = package.identifier;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              color: Colors.transparent,
              elevation: 0,
              margin: const EdgeInsets.only(top: 5.0, bottom: 0.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                padding: isSelected ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.brandAccent : null,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.authButtonBackground,
                    borderRadius: BorderRadius.circular(18.0),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isYearly ? 'Yearly' : 'Monthly',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            isYearly ? '\$0.38 / week' : '\$1.25 / week',
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isYearly
                                    ? '${product.priceString} / Year'
                                    : '${product.priceString} / Month',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF19A2E6)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF19A2E6)
                                    : Colors.white.withValues(alpha: 0.7),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (bestDeal)
              Positioned(
                top: -8,
                right: 15,
                child: Container(
                  padding: isSelected ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppGradients.brandAccent : null,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: AppColors.authButtonBackground,
                      borderRadius: BorderRadius.circular(20.0),
                      border: !isSelected
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 2,
                            )
                          : null,
                    ),
                    child: const Text(
                      'Best Value',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    final offerings = ref.read(offeringsProvider).value;
    if (offerings == null || offerings.current == null) return const SizedBox.shrink();

    final packages = offerings.current!.availablePackages;

    // Default to yearly if nothing selected yet
    if (_selectedPackageId == null && packages.isNotEmpty) {
      final yearlyPackage = packages.firstWhere(
        (pkg) => pkg.packageType == PackageType.annual,
        orElse: () => packages.first,
      );
      _selectedPackageId = yearlyPackage.identifier;
    }

    final selectedPackage = packages.firstWhere(
      (pkg) => pkg.identifier == _selectedPackageId,
      orElse: () => packages.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          gradient: AppGradients.brandAccent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedPackageId != null && !_isPurchasing
              ? () => _handlePurchase(selectedPackage)
              : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.authButtonBackground,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(fontSize: 18.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
          child: _isPurchasing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Subscribe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: _isRestoring ? null : _handleRestorePurchases,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        _isRestoring ? 'Restoring...' : 'Restore Purchase',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTermsFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        'Cancel anytime in App Store. Subscriptions renew automatically. By subscribing you accept our Privacy Policy & Terms.',
        style: const TextStyle(
          fontSize: 12.0,
          height: 1.5,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _handlePurchase(Package package) async {
    setState(() {
      _isPurchasing = true;
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
          final isTestMode = SubscriptionService.isTestMode();
          await AppDialog.showSuccess(
            context,
            title: isTestMode ? 'Test Purchase Successful!' : 'Welcome to Premium!',
            message: isTestMode
                ? 'This is a test purchase (no real transaction). Your subscription is now active for testing purposes!'
                : 'Your subscription is now active. Enjoy all premium features!',
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
          _isPurchasing = false;
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
