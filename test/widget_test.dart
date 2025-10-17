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

// Mock notifiers for testing
class MockCurrentUserNotifier extends CurrentUserNotifier {
  final User? _user;
  
  MockCurrentUserNotifier(this._user);
  
  @override
  Stream<User?> build() {
    return Stream.value(_user);
  }
}

class MockSubscriptionNotifier extends SubscriptionNotifier {
  final SubscriptionInfo _subscription;
  
  MockSubscriptionNotifier(this._subscription);
  
  @override
  Future<SubscriptionInfo> build() async {
    return _subscription;
  }
}

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

  group('Provider Override Tests', () {
    test('currentUserProvider can be overridden with AsyncValue', () {
      // Create a mock user for testing
      final mockUser = User(
        id: 'test-user-id',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'test@example.com',
      );

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith(() => MockCurrentUserNotifier(mockUser)),
        ],
      );

      final userAsync = container.read(currentUserProvider);
      
      expect(
        userAsync.whenOrNull(data: (user) => user?.email),
        'test@example.com',
      );
      expect(
        userAsync.whenOrNull(data: (user) => user?.id),
        'test-user-id',
      );

      container.dispose();
    });

    test('subscriptionProvider can be overridden with AsyncValue', () {
      final mockSubscription = SubscriptionInfo(
        isActive: true,
        tier: 'premium',
        expirationDate: DateTime.now().add(const Duration(days: 30)),
        productIdentifier: 'com.example.premium',
      );

      final container = ProviderContainer(
        overrides: [
          subscriptionProvider.overrideWith(() => MockSubscriptionNotifier(mockSubscription)),
        ],
      );

      final subscriptionAsync = container.read(subscriptionProvider);

      expect(
        subscriptionAsync.whenOrNull(data: (sub) => sub.isActive),
        true,
      );
      expect(
        subscriptionAsync.whenOrNull(data: (sub) => sub.tier),
        'premium',
      );
      expect(
        subscriptionAsync.whenOrNull(data: (sub) => sub.productIdentifier),
        'com.example.premium',
      );

      container.dispose();
    });

    test('appStateProvider correctly combines overridden providers', () {
      final mockUser = User(
        id: 'test-user-id',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'authenticated@example.com',
      );

      final mockSubscription = SubscriptionInfo(
        isActive: true,
        tier: 'premium',
      );

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith(() => MockCurrentUserNotifier(mockUser)),
          subscriptionProvider.overrideWith(() => MockSubscriptionNotifier(mockSubscription)),
        ],
      );

      final appState = container.read(appStateProvider);

      expect(appState.isAuthenticated, true);
      expect(appState.user?.email, 'authenticated@example.com');
      expect(appState.subscriptionValue.tier, 'premium');
      expect(appState.hasActiveSubscription, true);
      expect(appState.needsPaywall, false);

      container.dispose();
    });
  });
}
