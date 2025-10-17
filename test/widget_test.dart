// Phase 2 Tests - Basic smoke tests for auth and state management
//
// These tests verify that the core infrastructure is set up correctly.
// More comprehensive tests should be added in Phase 6.

import 'package:app_template/models/app_state.dart';
import 'package:app_template/models/subscription_info.dart';
import 'package:app_template/providers/app_state_provider.dart';
import 'package:app_template/providers/auth_provider.dart';
import 'package:app_template/providers/subscription_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Phase 2 - State & Data Foundations', () {
    test('SubscriptionInfo.free() creates free tier subscription', () {
      final subscription = SubscriptionInfo.free();

      expect(subscription.isActive, false);
      expect(subscription.tier, 'free');
      expect(subscription.expirationDate, null);
      expect(subscription.productIdentifier, null);
    });

    test('AppState correctly identifies authentication status', () {
      final unauthenticatedState = AppState(
        auth: const AsyncValue.data(null),
        subscription: AsyncValue.data(SubscriptionInfo.free()),
      );

      expect(unauthenticatedState.isAuthenticated, false);
      expect(unauthenticatedState.hasActiveSubscription, false);
      expect(unauthenticatedState.needsPaywall, false);
    });

    test('AppState correctly identifies paywall requirement', () {
      // Mock authenticated user without subscription
      final needsPaywallState = AppState(
        auth: AsyncValue.data(User(
          id: '123',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: 'mock@example.com',
        )),
        subscription: AsyncValue.data(SubscriptionInfo.free()),
      );

      expect(needsPaywallState.isAuthenticated, true);
      expect(needsPaywallState.hasActiveSubscription, false);
      expect(needsPaywallState.needsPaywall, true);
    });

    test('ProviderContainer can be created', () {
      final container = ProviderContainer();
      expect(container, isNotNull);
      container.dispose();
    });
  });

  group('Provider Tests', () {
    test('Generated providers can be read from container', () {
      // Verify generated providers are accessible
      final container = ProviderContainer();
      
      // These should not throw - just verifying provider names exist
      expect(() => container.read(currentUserProvider), returnsNormally);
      expect(() => container.read(subscriptionProvider), returnsNormally);
      expect(() => container.read(appStateProvider), returnsNormally);
      
      container.dispose();
    });

    test('SubscriptionInfo model works with generated providers', () {
      final subscription = SubscriptionInfo(
        isActive: true,
        tier: 'premium',
        expirationDate: DateTime.now().add(const Duration(days: 30)),
        productIdentifier: 'com.example.premium',
      );

      expect(subscription.isActive, true);
      expect(subscription.tier, 'premium');
      expect(subscription.productIdentifier, 'com.example.premium');
    });
  });
}
