import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_template/features/subscriptions/screens/subscription_details_screen.dart';

void main() {
  group('SubscriptionDetailsScreen', () {
    testWidgets('should render without crashing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SubscriptionDetailsScreen(),
          ),
        ),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading subscription...'), findsOneWidget);
    });

    testWidgets('should have app bar with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SubscriptionDetailsScreen(),
          ),
        ),
      );

      expect(find.text('Subscription Details'), findsOneWidget);
    });

    // Note: Full widget tests with different subscription states would require:
    // 1. Creating a mock Subscription notifier class
    // 2. Overriding subscriptionProvider with the mock
    // 3. Testing UI rendering for each state
    //
    // This would follow the same pattern as integration tests
    // For now, we verify the screen can be constructed and renders initial state
    //
    // Example future test:
    // testWidgets('should display free tier info', (tester) async {
    //   await tester.pumpWidget(
    //     ProviderScope(
    //       overrides: [
    //         subscriptionProvider.overrideWith(() {
    //           return MockSubscription()..state = AsyncValue.data(SubscriptionInfo.free());
    //         }),
    //       ],
    //       child: MaterialApp(home: SubscriptionDetailsScreen()),
    //     ),
    //   );
    //   await tester.pumpAndSettle();
    //   expect(find.text('Free Tier'), findsOneWidget);
    // });
  });
}
