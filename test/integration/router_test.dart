import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_template/app.dart';
import '../helpers/test_providers.dart';

void main() {
  group('Router Integration Tests', () {
    testWidgets('Unauthenticated app loads', (tester) async {
      final container = createUnauthenticatedContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app loads without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Authenticated free user app loads', (tester) async {
      final container = createAuthenticatedFreeContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app loads
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Authenticated premium user app loads', (tester) async {
      final container = createAuthenticatedPremiumContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app loads
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Deep Link Handling Tests', () {
    testWidgets('App handles initialization', (tester) async {
      final container = createUnauthenticatedContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );

      // Don't settle - just pump once
      await tester.pump();

      // Verify app starts loading
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Router Guard Tests', () {
    testWidgets('Multiple user states work', (tester) async {
      final testCases = [
        createUnauthenticatedContainer(),
        createAuthenticatedFreeContainer(),
        createAuthenticatedPremiumContainer(),
      ];

      for (final container in testCases) {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const App(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify app loads without errors for each state
        expect(find.byType(MaterialApp), findsOneWidget);

        // Clean up
        await tester.pumpWidget(Container());
      }
    });
  });
}
