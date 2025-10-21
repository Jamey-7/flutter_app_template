import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/logger/logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/responsive/breakpoints.dart';
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

    // Get current theme, but force Default Dark if user selected a light theme
    final themeType = ref.watch(themeTypeProvider);
    final effectiveTheme = themeType.data.mode == ThemeMode.light
        ? AppThemeData.defaultTheme()  // Force Default Dark for paywall
        : themeType.data;               // Use selected dark theme

    return Scaffold(
      body: offeringsAsync.when(
        data: (offerings) => _buildOfferingsContent(offerings, effectiveTheme),
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
                      color: AppColors.white,
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
                        color: AppColors.white,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Failed to load subscription plans',
                        style: context.textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
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
              right: AppSpacing.sm,
              child: IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.white,
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

  Widget _buildOfferingsContent(Offerings? offerings, AppThemeData effectiveTheme) {
    // Auto-select yearly package on first load
    if (offerings != null && offerings.current != null) {
      final packages = offerings.current!.availablePackages;
      if (_selectedPackageId == null && packages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final yearlyPackage = packages.firstWhere(
            (pkg) => pkg.packageType == PackageType.annual,
            orElse: () => packages.first,
          );
          setState(() {
            _selectedPackageId = yearlyPackage.identifier;
          });
        });
      }
    }

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
                      color: AppColors.white,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No Plans Available',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Subscription plans are not configured yet. Please try again later.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
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
            right: AppSpacing.sm,
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.white,
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
                      color: AppColors.white,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No Plans Available',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No subscription packages found.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
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
            right: AppSpacing.sm,
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.white,
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
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive<double>(
                    smallMobile: AppSpacing.md,
                    mobile: AppSpacing.md,
                    tablet: AppSpacing.lg,
                    desktop: AppSpacing.lg,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Spacing to prevent overlap with close button
                    SizedBox(
                      height: context.responsive<double>(
                        smallMobile: 60,
                        mobile: 80,
                        tablet: 40,
                        desktop: 40,
                      ),
                    ),

                    // Bottom Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        _buildHeader(),
                        const SizedBox(height: AppSpacing.xl),

                        // Product Cards - Yearly first, then Monthly
                        ...packages.where((pkg) => pkg.packageType == PackageType.annual).map((package) => _buildProductCard(package, effectiveTheme)),
                        ...packages.where((pkg) => pkg.packageType == PackageType.monthly).map((package) => _buildProductCard(package, effectiveTheme)),

                        const SizedBox(height: AppSpacing.sm),

                        // Subscribe Button
                        _buildSubscribeButton(effectiveTheme),

                        // Restore Purchases Button
                        _buildRestoreButton(),

                        // Terms & Conditions
                        _buildTermsFooter(),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Close button positioned over the image - only show if user has active subscription
        if (ref.watch(subscriptionProvider).value?.isActive ?? false)
          Positioned(
            top: topPadding,
            left: AppSpacing.sm,
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.white,
                size: 28,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

        // Settings button in top right
        Positioned(
          top: topPadding,
          right: AppSpacing.sm,
          child: IconButton(
            icon: Icon(
              MingCuteIcons.mgc_settings_1_line,
              color: AppColors.white.withValues(alpha: 0.6),
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
          style: context.textTheme.displayMedium?.copyWith(
            color: AppColors.white,
            fontSize: context.responsive<double>(
              smallMobile: 38,
              mobile: 45,
              tablet: 52,
              desktop: 60,
            ),
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
        Text(
          'Access',
          style: context.textTheme.displayMedium?.copyWith(
            color: AppColors.white,
            fontSize: context.responsive<double>(
              smallMobile: 38,
              mobile: 45,
              tablet: 52,
              desktop: 60,
            ),
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
        Text(
          'Now',
          style: context.textTheme.displayMedium?.copyWith(
            color: AppColors.white,
            fontSize: context.responsive<double>(
              smallMobile: 38,
              mobile: 45,
              tablet: 52,
              desktop: 60,
            ),
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: AppColors.white.withValues(alpha: 0.9),
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'All Features Included',
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
                fontSize: context.responsive<double>(
                  smallMobile: 14,
                  mobile: 16,
                  tablet: 18,
                  desktop: 18,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(
              Icons.devices,
              color: AppColors.white.withValues(alpha: 0.9),
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'All Platforms Supported',
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
                fontSize: context.responsive<double>(
                  smallMobile: 14,
                  mobile: 16,
                  tablet: 18,
                  desktop: 18,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductCard(Package package, AppThemeData effectiveTheme) {
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
        padding: const EdgeInsets.only(bottom: AppSpacing.md - 2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              color: Colors.transparent,
              elevation: AppElevation.none,
              margin: const EdgeInsets.only(top: AppSpacing.xs, bottom: 0.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xxlarge),
              ),
              child: Container(
                padding: isSelected ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [effectiveTheme.gradientStart, effectiveTheme.gradientEnd],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(AppRadius.xxlarge),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.authButtonBackground,
                    borderRadius: BorderRadius.circular(AppRadius.xxlarge - 2),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: AppColors.authBorderLight,
                            width: 1.5,
                          ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.md + 2),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isYearly ? 'Yearly' : 'Monthly',
                            style: context.textTheme.titleMedium?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isYearly ? '\$0.38 / week' : '\$1.25 / week',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
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
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? effectiveTheme.gradientEnd
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? effectiveTheme.gradientEnd
                                    : AppColors.white.withValues(alpha: 0.7),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.white,
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
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [effectiveTheme.gradientStart, effectiveTheme.gradientEnd],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(AppRadius.xxlarge),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.authShadow,
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs + 1, horizontal: AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: AppColors.authButtonBackground,
                      borderRadius: BorderRadius.circular(AppRadius.xxlarge),
                      border: !isSelected
                          ? Border.all(
                              color: AppColors.authBorderLight,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Text(
                      'Best Value',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildSubscribeButton(AppThemeData effectiveTheme) {
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.circular),
          gradient: LinearGradient(
            colors: [effectiveTheme.gradientStart, effectiveTheme.gradientEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.authShadow,
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
            elevation: AppElevation.none,
            backgroundColor: AppColors.authButtonBackground,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.circular),
            ),
          ),
          child: _isPurchasing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Text(
                  'Subscribe',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: AppColors.white,
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
      ),
      child: Text(
        _isRestoring ? 'Restoring...' : 'Restore Purchase',
        style: context.textTheme.labelLarge?.copyWith(
          color: AppColors.white.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTermsFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text(
        'Cancel anytime in App Store. Subscriptions renew automatically. By subscribing you accept our Privacy Policy & Terms.',
        style: context.textTheme.bodySmall?.copyWith(
          color: AppColors.white,
          height: 1.5,
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
