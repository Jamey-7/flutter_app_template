import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logger/logger.dart';
import '../../../core/network/retry_helper.dart';
import '../models/subscription_info.dart';
import '../../auth/providers/auth_provider.dart';

part 'subscription_provider.g.dart';

@riverpod
class Subscription extends _$Subscription {
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
        // Check if it's a token error we can ignore
        final error = next.error;
        final isTokenError = error is AuthException &&
            (error.code == 'refresh_token_not_found' ||
             error.message.toLowerCase().contains('invalid refresh token'));
        
        if (isTokenError) {
          Logger.log(
            'Auth token error detected, resetting to free tier',
            tag: 'SubscriptionNotifier',
          );
        } else {
          Logger.error(
            'Auth provider error',
            error!,
            next.stackTrace,
            tag: 'SubscriptionNotifier',
          );
        }
        
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
      if (!SubscriptionService._isInitialized) {
        Logger.log(
          'RevenueCat not initialized, using free tier',
          tag: 'SubscriptionNotifier',
        );
        return SubscriptionInfo.free();
      }

      Logger.log('Fetching subscription info', tag: 'SubscriptionNotifier');

      // Fetch customer info with automatic retry on failure and 15 second timeout
      final customerInfo = await retryWithBackoff(
        () => Purchases.getCustomerInfo().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            Logger.warning(
              'RevenueCat getCustomerInfo timed out after 15 seconds',
              tag: 'SubscriptionNotifier',
            );
            throw TimeoutException('RevenueCat request timed out');
          },
        ),
        maxRetries: 2,
        operationName: 'RevenueCat customer info fetch',
      );

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
      Logger.error('RevenueCat platform error after retries', e, stackTrace, tag: 'SubscriptionNotifier');
      return SubscriptionInfo.free();
    } on TimeoutException catch (e, stackTrace) {
      Logger.error(
        'RevenueCat request timed out, defaulting to free tier',
        e,
        stackTrace,
        tag: 'SubscriptionNotifier',
      );
      return SubscriptionInfo.free();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to fetch subscription info after retries, defaulting to free',
        e,
        stackTrace,
        tag: 'SubscriptionNotifier',
      );
      return SubscriptionInfo.free();
    }
  }
}

/// Subscription service for purchase operations
class SubscriptionService {
  static bool _isInitialized = false;

  /// Initialize RevenueCat with platform-specific API keys
  static Future<void> initialize({
    String? iosApiKey,
    String? androidApiKey,
  }) async {
    try {
      Logger.log('Initializing RevenueCat', tag: 'SubscriptionService');
      
      if (!_isRevenueCatSupported()) {
        Logger.warning(
          'Skipping RevenueCat initialization: unsupported platform',
          tag: 'SubscriptionService',
        );
        return;
      }

      // Detect platform and use appropriate key
      String? apiKey;
      if (Platform.isIOS || Platform.isMacOS) {
        apiKey = iosApiKey;
        if (apiKey == null || apiKey.isEmpty) {
          Logger.warning(
            'RevenueCat iOS API key not configured',
            tag: 'SubscriptionService',
          );
          return;
        }
      } else if (Platform.isAndroid) {
        apiKey = androidApiKey;
        if (apiKey == null || apiKey.isEmpty) {
          Logger.warning(
            'RevenueCat Android API key not configured',
            tag: 'SubscriptionService',
          );
          return;
        }
      }

      // Final safety check (should never happen due to platform checks above)
      if (apiKey == null || apiKey.isEmpty) {
        Logger.warning(
          'RevenueCat API key not available for this platform',
          tag: 'SubscriptionService',
        );
        return;
      }

      await Purchases.configure(PurchasesConfiguration(apiKey));
      _isInitialized = true;
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
