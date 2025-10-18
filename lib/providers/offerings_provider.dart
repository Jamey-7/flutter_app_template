import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/logger/logger.dart';
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
    Logger.log('Fetching RevenueCat offerings', tag: 'OfferingsProvider');
    final offerings = await SubscriptionService.getOfferings();
    
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
  } catch (e, stackTrace) {
    Logger.error(
      'Failed to fetch offerings',
      e,
      stackTrace,
      tag: 'OfferingsProvider',
    );
    rethrow;
  }
}
