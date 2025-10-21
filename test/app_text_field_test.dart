import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_template/shared/widgets/app_text_field.dart';
import 'package:app_template/shared/forms/validators.dart';
import 'package:app_template/core/theme/app_theme.dart';
import 'package:app_template/core/theme/app_themes.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.fromThemeData(AppThemeData.minimalist()),
      home: Scaffold(body: child),
    );
  }

  group('AppTextField', () {
    testWidgets('renders text field with label', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AppTextField(
            label: 'Username',
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders text field with hint text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AppTextField(
            hintText: 'Enter your username',
          ),
        ),
      );

      expect(find.text('Enter your username'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        createTestWidget(
          AppTextField(
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test');
      expect(changedValue, equals('test'));
    });

    testWidgets('shows validation error', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Form(
            child: AppTextField(
              label: 'Email',
              validator: Validators.email,
            ),
          ),
        ),
      );

      final formState = tester.state<FormState>(find.byType(Form));
      
      formState.validate();
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('password field has visibility toggle', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AppTextField(
            label: 'Password',
            type: AppTextFieldType.password,
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AppTextField(
            label: 'Password',
            type: AppTextFieldType.password,
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('renders prefix icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AppTextField(
            label: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('renders suffix icon (non-password)', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AppTextField(
            label: 'Search',
            suffixIcon: Icon(Icons.search),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('disabled field cannot be edited', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AppTextField(
            label: 'Disabled',
            enabled: false,
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('different field types can be created', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Column(
            children: const [
              AppTextField(
                label: 'Email',
                type: AppTextFieldType.email,
              ),
              AppTextField(
                label: 'Number',
                type: AppTextFieldType.number,
              ),
              AppTextField(
                label: 'Phone',
                type: AppTextFieldType.phone,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Number'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
    });

    testWidgets('controller controls text value', (tester) async {
      final controller = TextEditingController(text: 'Initial value');

      await tester.pumpWidget(
        createTestWidget(
          AppTextField(
            label: 'Controlled',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Initial value'), findsOneWidget);

      controller.text = 'Updated value';
      await tester.pump();

      expect(find.text('Updated value'), findsOneWidget);
    });
  });
}
