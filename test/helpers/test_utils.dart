import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wait for all animations and async operations to complete
Future<void> pumpAndSettleWithDelay(
  WidgetTester tester, {
  Duration delay = const Duration(milliseconds: 100),
}) async {
  await tester.pump(delay);
  await tester.pumpAndSettle();
}

/// Find a button by its text content
Finder findButtonByText(String text) {
  return find.ancestor(
    of: find.text(text),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is ElevatedButton ||
          widget is OutlinedButton ||
          widget is TextButton,
    ),
  );
}

/// Enter text in a text field and wait for the UI to update
Future<void> enterText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pump();
}

/// Tap a widget and wait for animations to complete
Future<void> tapAndSettle(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Tap a button by its text and wait for animations
Future<void> tapButtonByText(
  WidgetTester tester,
  String text,
) async {
  final button = findButtonByText(text);
  await tapAndSettle(tester, button);
}

/// Verify that text exists on screen
void expectText(String text) {
  expect(find.text(text), findsOneWidget);
}

/// Verify that text does not exist on screen
void expectNoText(String text) {
  expect(find.text(text), findsNothing);
}

/// Verify that a loading indicator is shown
void expectLoading() {
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
}

/// Verify that no loading indicator is shown
void expectNotLoading() {
  expect(find.byType(CircularProgressIndicator), findsNothing);
}

/// Create a test email address
String testEmail([String prefix = 'test']) {
  return '$prefix@example.com';
}

/// Create a test password
String testPassword([String password = 'TestPassword123!']) {
  return password;
}

/// Create a Material app wrapper for widget tests
Widget createTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}
