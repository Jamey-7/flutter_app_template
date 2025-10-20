import 'package:purchases_flutter/purchases_flutter.dart';

/// Mock subscription offerings for development and testing
///
/// This provides a complete mock implementation of RevenueCat offerings
/// that can be used when SUBSCRIPTION_TEST_MODE=true in .env
///
/// Products:
/// - Monthly: $2.99/month (mock_monthly)
/// - Yearly: $9.99/year (mock_yearly)
class MockOfferings {
  /// Create mock offerings with monthly and yearly packages
  static Offerings createMockOfferings() {
    // Create mock store products
    final monthlyProduct = _createMockStoreProduct(
      identifier: 'mock_monthly',
      title: 'Monthly Subscription',
      description: 'Access all premium features with a monthly subscription',
      price: 2.99,
      priceString: '\$2.99',
      currencyCode: 'USD',
      subscriptionPeriod: 'P1M', // ISO 8601: 1 month
    );

    final yearlyProduct = _createMockStoreProduct(
      identifier: 'mock_yearly',
      title: 'Yearly Subscription',
      description: 'Access all premium features with a yearly subscription',
      price: 9.99,
      priceString: '\$9.99',
      currencyCode: 'USD',
      subscriptionPeriod: 'P1Y', // ISO 8601: 1 year
    );

    // Create mock packages
    final monthlyPackage = _createMockPackage(
      identifier: '\$rc_monthly',
      packageType: PackageType.monthly,
      product: monthlyProduct,
    );

    final yearlyPackage = _createMockPackage(
      identifier: '\$rc_annual',
      packageType: PackageType.annual,
      product: yearlyProduct,
    );

    // Create mock offering with both packages
    final currentOffering = _createMockOffering(
      identifier: 'default',
      serverDescription: 'Default offering',
      packages: [monthlyPackage, yearlyPackage],
    );

    // Create mock offerings collection
    return _createMockOfferingsCollection(
      currentOffering: currentOffering,
      allOfferings: {'default': currentOffering},
    );
  }

  /// Create a mock StoreProduct
  static StoreProduct _createMockStoreProduct({
    required String identifier,
    required String title,
    required String description,
    required double price,
    required String priceString,
    required String currencyCode,
    required String subscriptionPeriod,
  }) {
    return StoreProduct(
      identifier,
      description,
      title,
      price,
      priceString,
      currencyCode,
      discounts: const <StoreProductDiscount>[],
      productCategory: ProductCategory.subscription,
      presentedOfferingContext: PresentedOfferingContext('default', null, null),
      subscriptionPeriod: subscriptionPeriod,
    );
  }

  /// Create a mock Package
  static Package _createMockPackage({
    required String identifier,
    required PackageType packageType,
    required StoreProduct product,
  }) {
    return Package(
      identifier,
      packageType,
      product,
      PresentedOfferingContext('default', null, null),
    );
  }

  /// Create a mock Offering
  static Offering _createMockOffering({
    required String identifier,
    required String serverDescription,
    required List<Package> packages,
  }) {
    final monthlyPackage = packages.firstWhere(
      (package) => package.packageType == PackageType.monthly,
      orElse: () => packages.first,
    );

    final annualPackage = packages.firstWhere(
      (package) => package.packageType == PackageType.annual,
      orElse: () => packages.first,
    );

    return Offering(
      identifier,
      serverDescription,
      const <String, Object>{
        'source': 'mock',
        'isTestMode': true,
      },
      packages,
      annual: annualPackage.packageType == PackageType.annual ? annualPackage : null,
      monthly: monthlyPackage.packageType == PackageType.monthly ? monthlyPackage : null,
    );
  }

  /// Create a mock Offerings collection
  static Offerings _createMockOfferingsCollection({
    required Offering? currentOffering,
    required Map<String, Offering> allOfferings,
  }) {
    return Offerings(allOfferings, current: currentOffering);
  }

  /// Create mock CustomerInfo for successful test purchases
  static CustomerInfo createMockCustomerInfo({
    required bool hasActiveSubscription,
    String? productIdentifier,
  }) {
    final now = DateTime.now();
    final expirationDate = now.add(const Duration(days: 365));

    return CustomerInfo.fromJson({
      'schema_version': '4',
      'request_date': now.toIso8601String(),
      'request_date_ms': now.millisecondsSinceEpoch,
      'subscriber': {
        'first_seen': now.toIso8601String(),
        'original_app_user_id': 'mock_user_id',
        'subscriptions': hasActiveSubscription
            ? {
                productIdentifier ?? 'mock_monthly': {
                  'expires_date': expirationDate.toIso8601String(),
                  'purchase_date': now.toIso8601String(),
                  'original_purchase_date': now.toIso8601String(),
                  'ownership_type': 'PURCHASED',
                  'period_type': 'NORMAL',
                  'store': 'APP_STORE',
                  'is_sandbox': true,
                  'unsubscribe_detected_at': null,
                  'billing_issues_detected_at': null,
                  'grace_period_expires_date': null,
                  'refunded_at': null,
                  'auto_resume_date': null,
                }
              }
            : {},
        'non_subscriptions': {},
        'entitlements': hasActiveSubscription
            ? {
                'premium': {
                  'expires_date': expirationDate.toIso8601String(),
                  'product_identifier': productIdentifier ?? 'mock_monthly',
                  'purchase_date': now.toIso8601String(),
                }
              }
            : {},
        'original_application_version': '1.0',
        'original_purchase_date': now.toIso8601String(),
        'management_url': null,
      },
    });
  }
}
