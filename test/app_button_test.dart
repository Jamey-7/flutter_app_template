import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_template/shared/widgets/app_button.dart';
import 'package:app_template/core/theme/app_theme.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }

  group('AppButton', () {
    testWidgets('renders primary button with text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(
            text: 'Primary Button',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders secondary button with text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.secondary(
            text: 'Secondary Button',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Secondary Button'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders text button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.text(
            text: 'Text Button',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(
            text: 'Tap Me',
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AppButton.primary(
            text: 'Disabled Button',
            onPressed: null,
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(
            text: 'Loading Button',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('does not call onPressed when isLoading is true', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(
            text: 'Loading Button',
            onPressed: () => pressed = true,
            isLoading: true,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('renders button with icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(
            text: 'Button with Icon',
            onPressed: () {},
            icon: Icons.add,
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Button with Icon'), findsOneWidget);
    });

    testWidgets('renders full width button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(
            text: 'Full Width',
            onPressed: () {},
            isFullWidth: true,
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, equals(double.infinity));
    });

    testWidgets('renders small size button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(
            text: 'Small',
            onPressed: () {},
            size: AppButtonSize.small,
          ),
        ),
      );

      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('renders medium size button (default)', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(
            text: 'Medium',
            onPressed: () {},
            size: AppButtonSize.medium,
          ),
        ),
      );

      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('renders large size button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AppButton.primary(
            text: 'Large',
            onPressed: () {},
            size: AppButtonSize.large,
          ),
        ),
      );

      expect(find.text('Large'), findsOneWidget);
    });
  });
}
