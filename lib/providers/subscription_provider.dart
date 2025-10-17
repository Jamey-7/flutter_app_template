import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/logger/logger.dart';
import '../models/subscription_info.dart';
import 'auth_provider.dart';

class SubscriptionNotifier extends AsyncNotifier<SubscriptionInfo> {
  @override
  Future<SubscriptionInfo> build() async {
    if (!_isRevenueCatSupported()) {
      Logger.warning(
        'RevenueCat unsupported on this platform, using free tier',
        tag: 'SubscriptionNotifier',
      );
      return SubscriptionInfo.free();
    }

    ref.keepAlive();
    ref.listen<AsyncValue<User?>>(currentUserProvider, (previous, next) async {
      if (next.isLoading) {
        return;
      }

      if (next.hasError && next.error != null) {
        Logger.error(
          'Auth provider error',
          next.error!,
          next.stackTrace,
          tag: 'SubscriptionNotifier',
        );
        state = AsyncValue.data(SubscriptionInfo.free());
        return;
      }

      final previousId = previous?.whenOrNull(data: (user) => user?.id);
      final nextId = next.whenOrNull(data: (user) => user?.id);

      if (nextId == null) {
        Logger.log('Auth cleared, resetting subscription to free', tag: 'SubscriptionNotifier');
        state = AsyncValue.data(SubscriptionInfo.free());
        return;
      }

      if (previousId != nextId) {
        Logger.log(
          'Auth state changed for $nextId, refreshing subscription',
          tag: 'SubscriptionNotifier',
        );
        await refreshSubscription();
      }
    });

    return _fetchSubscription();
  }

  Future<void> refreshSubscription() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchSubscription);
  }

  Future<SubscriptionInfo> _fetchSubscription() async {
    try {
      Logger.log('Fetching subscription info', tag: 'SubscriptionNotifier');

      final customerInfo = await Purchases.getCustomerInfo();
      final active = customerInfo.entitlements.active;

      if (active.isEmpty) {
        Logger.log('No active subscription', tag: 'SubscriptionNotifier');
        return SubscriptionInfo.free();
      }

      final entitlement = active.values.first;
      Logger.log(
        'Active subscription found: ${entitlement.identifier}',
        tag: 'SubscriptionNotifier',
      );

      return SubscriptionInfo(
        isActive: true,
        tier: entitlement.identifier,
        expirationDate: entitlement.expirationDate != null
            ? DateTime.tryParse(entitlement.expirationDate!)
            : null,
        productIdentifier: entitlement.productIdentifier,
      );
    } on PlatformException catch (e, stackTrace) {
      Logger.error('RevenueCat platform error', e, stackTrace, tag: 'SubscriptionNotifier');
      return SubscriptionInfo.free();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to fetch subscription info, defaulting to free',
        e,
        stackTrace,
        tag: 'SubscriptionNotifier',
      );
      return SubscriptionInfo.free();
    }
  }
}

final subscriptionProvider = AsyncNotifierProvider<SubscriptionNotifier, SubscriptionInfo>(
  SubscriptionNotifier.new,
  name: 'subscriptionProvider',
);

/// Subscription service for purchase operations
class SubscriptionService {
  /// Initialize RevenueCat with API key
  static Future<void> initialize(String apiKey) async {
    try {
      Logger.log('Initializing RevenueCat', tag: 'SubscriptionService');
      if (!_isRevenueCatSupported()) {
        Logger.warning(
          'Skipping RevenueCat initialization: unsupported platform',
          tag: 'SubscriptionService',
        );
        return;
      }

      await Purchases.configure(PurchasesConfiguration(apiKey));
      Logger.log('RevenueCat initialized', tag: 'SubscriptionService');
    } catch (e, stackTrace) {
      Logger.error(
        'RevenueCat initialization failed',
        e,
        stackTrace,
        tag: 'SubscriptionService',
      );
      rethrow;
    }
  }

  /// Get available offerings
  static Future<Offerings?> getOfferings() async {
    try {
      Logger.log('Fetching offerings', tag: 'SubscriptionService');
      final offerings = await Purchases.getOfferings();
      Logger.log(
        'Offerings fetched: ${offerings.current?.availablePackages.length ?? 0} packages',
        tag: 'SubscriptionService',
      );
      return offerings;
    } catch (e, stackTrace) {
      Logger.error('Failed to fetch offerings', e, stackTrace, tag: 'SubscriptionService');
      return null;
    }
  }

  /// Purchase a package
  static Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      Logger.log('Purchasing package: ${package.identifier}', tag: 'SubscriptionService');
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      Logger.log('Purchase successful', tag: 'SubscriptionService');
      return purchaseResult.customerInfo;
    } catch (e, stackTrace) {
      Logger.error('Purchase failed', e, stackTrace, tag: 'SubscriptionService');
      rethrow;
    }
  }

  /// Restore purchases
  static Future<CustomerInfo> restorePurchases() async {
    try {
      Logger.log('Restoring purchases', tag: 'SubscriptionService');
      final customerInfo = await Purchases.restorePurchases();
      Logger.log('Purchases restored', tag: 'SubscriptionService');
      return customerInfo;
    } catch (e, stackTrace) {
      Logger.error('Restore purchases failed', e, stackTrace, tag: 'SubscriptionService');
      rethrow;
    }
  }
}

bool _isRevenueCatSupported() {
  if (kIsWeb) return false;
  if (!Platform.isIOS && !Platform.isAndroid && !Platform.isMacOS) {
    return false;
  }
  return true;
}
