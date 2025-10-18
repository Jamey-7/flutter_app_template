import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Create a basic test ProviderContainer
/// Note: For integration tests, we typically don't override providers
/// Instead, we test the actual app behavior with mocked backend services
ProviderContainer createTestContainer() {
  return ProviderContainer();
}

/// Create a test container (unauthenticated)
/// For integration tests, auth state is controlled by mocked Supabase
ProviderContainer createUnauthenticatedContainer() {
  return ProviderContainer();
}

/// Create a test container (authenticated free user)
/// For integration tests, auth state is controlled by mocked Supabase
ProviderContainer createAuthenticatedFreeContainer({
  String email = 'test@example.com',
  String userId = 'test-user-id',
}) {
  return ProviderContainer();
}

/// Create a test container (authenticated premium user)
/// For integration tests, auth state is controlled by mocked Supabase
ProviderContainer createAuthenticatedPremiumContainer({
  String email = 'premium@example.com',
  String userId = 'premium-user-id',
  String tier = 'premium',
  int daysUntilExpiration = 30,
}) {
  return ProviderContainer();
}

/// Create a test container (expired subscription)
/// For integration tests, auth state is controlled by mocked Supabase
ProviderContainer createExpiredSubscriptionContainer({
  String email = 'expired@example.com',
  String userId = 'expired-user-id',
}) {
  return ProviderContainer();
}
