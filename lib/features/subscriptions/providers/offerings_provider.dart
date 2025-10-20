import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/logger/logger.dart';
import '../../../core/network/retry_helper.dart';
import 'subscription_provider.dart';

part 'offerings_provider.g.dart';

/// Provider that fetches RevenueCat offerings
///
/// Returns the available subscription packages from RevenueCat.
/// Handles loading and error states automatically via AsyncValue.
///
/// Usage:
/// ```dart
/// final offeringsAsync = ref.watch(offeringsProvider);
/// offeringsAsync.when(
///   data: (offerings) => /* display products */,
///   loading: () => /* show loading */,
///   error: (error, stack) => /* show error */,
/// );
/// ```
@riverpod
Future<Offerings?> offerings(Ref ref) async {
  try {
    // Check if test mode is enabled - return mock offerings immediately
    if (SubscriptionService.isTestMode()) {
      Logger.log(
        '🧪 Test mode: Returning mock offerings',
        tag: 'OfferingsProvider',
      );
      final mockOfferings = await SubscriptionService.getOfferings();
      final packageCount = mockOfferings?.current?.availablePackages.length ?? 0;
      Logger.log(
        '🧪 Mock offerings ready: $packageCount packages available',
        tag: 'OfferingsProvider',
      );
      return mockOfferings;
    }

    Logger.log('Fetching RevenueCat offerings', tag: 'OfferingsProvider');

    // Fetch offerings with automatic retry on failure and 15 second timeout
    final offerings = await retryWithBackoff(
      () => SubscriptionService.getOfferings().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          Logger.warning(
            'RevenueCat getOfferings timed out after 15 seconds',
            tag: 'OfferingsProvider',
          );
          throw TimeoutException('RevenueCat offerings request timed out');
        },
      ),
      maxRetries: 2,
      operationName: 'RevenueCat offerings fetch',
    );

    if (offerings == null) {
      Logger.warning('No offerings available', tag: 'OfferingsProvider');
      return null;
    }

    final packageCount = offerings.current?.availablePackages.length ?? 0;
    Logger.log(
      'Offerings fetched: $packageCount packages available',
      tag: 'OfferingsProvider',
    );

    return offerings;
  } on TimeoutException catch (e, stackTrace) {
    Logger.error(
      'RevenueCat offerings request timed out',
      e,
      stackTrace,
      tag: 'OfferingsProvider',
    );
    rethrow;
  } catch (e, stackTrace) {
    Logger.error(
      'Failed to fetch offerings after retries',
      e,
      stackTrace,
      tag: 'OfferingsProvider',
    );
    rethrow;
  }
}
