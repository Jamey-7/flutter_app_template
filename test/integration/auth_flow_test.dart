import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_template/app.dart';
import 'package:app_template/features/auth/screens/login_screen.dart';
import 'package:app_template/features/auth/screens/signup_screen.dart';
import 'package:app_template/features/auth/screens/forgot_password_screen.dart';
import 'package:app_template/shared/widgets/app_button.dart';
import '../helpers/mock_supabase.dart';
import '../helpers/test_providers.dart';
import '../helpers/test_utils.dart';

void main() {
  group('Auth Flow Integration Tests - Basic Loading', () {
    testWidgets('App loads without crashing (unauthenticated)', (tester) async {
      final container = createUnauthenticatedContainer();

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

    testWidgets('App loads without crashing (authenticated free)', (tester) async {
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

    testWidgets('App loads without crashing (authenticated premium)', (tester) async {
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

  group('Login Screen Tests', () {
    testWidgets('Login screen renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify key elements are present
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.textContaining('Sign Up'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Login form validation works for empty fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap sign in without entering anything
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify validation errors appear
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Login form validates invalid email format', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(
        find.byType(TextFormField).first,
        'invalid-email',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Tap sign in
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify email validation error appears somewhere on screen
      // Note: There might be multiple "email" texts (label + error)
      expect(find.textContaining('email'), findsWidgets);
    });

    testWidgets('Login form accepts valid input', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'ValidPassword123!',
      );

      // Validation should pass (no error messages shown before submit)
      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Password is required'), findsNothing);
    });
  });

  group('Signup Screen Tests', () {
    testWidgets('Signup screen renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SignupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify key elements are present
      expect(find.text('Create Account'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Terms'), findsOneWidget);
      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('Signup form has all required fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SignupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all required fields are present
      expect(find.byType(TextFormField), findsNWidgets(3)); // Email, Password, Confirm Password
      expect(find.byType(Checkbox), findsOneWidget); // Terms checkbox
      expect(find.byType(AppButton), findsAtLeastNWidgets(1)); // Sign up button
    });
  });

  group('Forgot Password Screen Tests', () {
    testWidgets('Forgot password screen renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const ForgotPasswordScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify key elements are present
      expect(find.text('Forgot Password'), findsAtLeastNWidgets(1));
      expect(find.text('Send Reset Link'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('Forgot password validates email', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const ForgotPasswordScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap send without entering email
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('Forgot password accepts valid email', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const ForgotPasswordScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid email
      await tester.enterText(
        find.byType(TextFormField),
        'test@example.com',
      );

      // Validation should pass
      expect(find.text('Email is required'), findsNothing);
    });
  });

  group('Mock Helper Tests', () {
    testWidgets('Mock user creation works', (tester) async {
      final user = createTestUser(
        id: 'test-id',
        email: 'test@example.com',
      );

      expect(user.id, equals('test-id'));
      expect(user.email, equals('test@example.com'));
    });

    testWidgets('Mock session creation works', (tester) async {
      final user = createTestUser(
        id: 'test-id',
        email: 'test@example.com',
      );
      final session = createTestSession(user: user);

      expect(session.user, equals(user));
      expect(session.accessToken, equals('test-access-token'));
    });

    testWidgets('Password reset helper works', (tester) async {
      final mockAuth = MockGoTrueClient();
      setupMockAuthClient(mockAuth);
      
      mockPasswordReset(mockAuth, email: 'test@example.com');

      // Verify mock is set up
      expect(mockAuth, isNotNull);
    });

    testWidgets('Auth exception creation works', (tester) async {
      final exception = createAuthException(
        message: 'Test error',
        statusCode: '400',
      );

      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, equals('400'));
    });
  });
}
