# Phase 7.1: Auth Integration Tests - Implementation Plan

**Status:** Ready to implement  
**Estimated Time:** 4-6 hours  
**Dependencies:** Phases 1-6 complete ✅  
**RevenueCat Keys Required:** ❌ NO

---

## 📋 Overview

This plan covers implementing comprehensive authentication integration tests that verify the complete auth flows without requiring RevenueCat API keys. Tests will use **mocked Supabase responses** and **provider overrides** to simulate real-world scenarios.

---

## 🎯 Goals

1. ✅ Test complete auth flows end-to-end
2. ✅ Verify router redirects work correctly with auth state
3. ✅ Ensure session persistence across app restarts
4. ✅ Validate error handling and edge cases
5. ✅ NO external API dependencies (fully mocked)
6. ✅ Fast, reliable, deterministic tests

---

## 📦 Step 1: Add Test Dependencies

### 1.1 Update `pubspec.yaml`

Add integration test dependencies:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Existing dependencies
  flutter_lints: ^6.0.0
  build_runner: ^2.4.13
  freezed: ^3.0.0
  json_serializable: ^6.8.0
  riverpod_generator: ^3.0.2
  
  # NEW: Integration testing
  integration_test:
    sdk: flutter
  mocktail: ^1.0.0  # For mocking Supabase
```

**Why these packages:**
- `integration_test`: Flutter's official integration testing framework
- `mocktail`: Modern mocking library (better than mockito for our use case)

### 1.2 Run Installation

```bash
flutter pub get
```

**Estimated Time:** 5 minutes

---

## 🛠️ Step 2: Create Test Helper Utilities

### 2.1 Create Mock Supabase Client

**File:** `test/helpers/mock_supabase.dart`

**Purpose:** Mock Supabase auth responses without real API calls

**Key Features:**
- Mock `GoTrueClient` for auth operations
- Simulate successful/failed auth responses
- Control auth state changes
- Simulate network delays

**Implementation:**
```dart
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}
class MockSession extends Mock implements Session {}
class MockAuthStateChange extends Mock implements AuthChangeEvent {}

// Helper to create test users
User createTestUser({
  required String id,
  required String email,
}) {
  final user = MockUser();
  when(() => user.id).thenReturn(id);
  when(() => user.email).thenReturn(email);
  return user;
}

// Helper to create auth responses
AuthResponse createAuthResponse({
  required User? user,
  Session? session,
}) {
  final response = MockAuthResponse();
  when(() => response.user).thenReturn(user);
  when(() => response.session).thenReturn(session);
  return response;
}
```

### 2.2 Create Test Provider Overrides

**File:** `test/helpers/test_providers.dart`

**Purpose:** Override Riverpod providers with test data

**Key Features:**
- Override `currentUserProvider` with mock users
- Override `subscriptionProvider` with free tier (no RevenueCat needed)
- Create test `ProviderContainer` instances

**Implementation:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../lib/providers/auth_provider.dart';
import '../lib/providers/subscription_provider.dart';
import '../lib/models/subscription_info.dart';

// Create a test container with overrides
ProviderContainer createTestContainer({
  User? user,
  SubscriptionInfo? subscription,
}) {
  return ProviderContainer(
    overrides: [
      if (user != null)
        currentUserProvider.overrideWith((ref) => Stream.value(user)),
      if (subscription != null)
        subscriptionProvider.overrideWith((ref) async => subscription),
    ],
  );
}

// Create authenticated test container
ProviderContainer createAuthenticatedContainer({
  required String email,
  bool isPremium = false,
}) {
  final user = createTestUser(
    id: 'test-user-id',
    email: email,
  );
  
  final subscription = isPremium
      ? SubscriptionInfo(
          isActive: true,
          tier: 'premium',
          expirationDate: DateTime.now().add(Duration(days: 30)),
          productIdentifier: 'test_premium_monthly',
        )
      : SubscriptionInfo.free();
  
  return createTestContainer(user: user, subscription: subscription);
}
```

### 2.3 Create Test Utilities

**File:** `test/helpers/test_utils.dart`

**Purpose:** Common test utilities and helpers

**Key Features:**
- Pump and settle helpers
- Find widget helpers
- Navigation helpers
- Delay simulation

**Implementation:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Wait for all animations and async operations
Future<void> pumpAndSettleWithDelay(
  WidgetTester tester, {
  Duration delay = const Duration(milliseconds: 100),
}) async {
  await tester.pump(delay);
  await tester.pumpAndSettle();
}

// Find button by text
Finder findButtonByText(String text) {
  return find.widgetWithText(ElevatedButton, text)
      .or(find.widgetWithText(OutlinedButton, text))
      .or(find.widgetWithText(TextButton, text));
}

// Enter text in field
Future<void> enterText(
  WidgetTester tester,
  String label,
  String text,
) async {
  final field = find.widgetWithText(TextField, label);
  await tester.enterText(field, text);
  await tester.pump();
}

// Tap button and wait
Future<void> tapAndSettle(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
```

**Estimated Time:** 1-1.5 hours

---

## 🧪 Step 3: Implement Auth Flow Tests

### 3.1 Create Base Integration Test File

**File:** `test/integration/auth_flow_test.dart`

### 3.2 Test: Signup → Login → Logout Flow

**Test Name:** `'Complete auth flow: signup, login, logout'`

**Steps:**
1. Start app (unauthenticated state)
2. Navigate to signup screen
3. Fill in email, password, confirm password
4. Accept terms and conditions
5. Submit signup form
6. Verify success message shown
7. Verify navigation to email verification pending screen
8. Mock email verification completion
9. Navigate to login screen
10. Fill in email and password
11. Submit login form
12. Verify navigation to welcome screen (authenticated)
13. Navigate to settings
14. Tap sign out button
15. Confirm sign out dialog
16. Verify navigation back to welcome screen (unauthenticated)

**Assertions:**
- ✅ Signup form validates correctly
- ✅ Success messages appear
- ✅ Navigation happens correctly
- ✅ Auth state changes are reflected in UI
- ✅ Sign out clears session

**Mock Strategy:**
```dart
// Mock successful signup
when(() => mockAuth.signUp(
  email: any(named: 'email'),
  password: any(named: 'password'),
  emailRedirectTo: any(named: 'emailRedirectTo'),
)).thenAnswer((_) async => createAuthResponse(
  user: createTestUser(id: 'new-user', email: 'test@example.com'),
));

// Mock successful login
when(() => mockAuth.signInWithPassword(
  email: any(named: 'email'),
  password: any(named: 'password'),
)).thenAnswer((_) async => createAuthResponse(
  user: createTestUser(id: 'test-user', email: 'test@example.com'),
));

// Mock sign out
when(() => mockAuth.signOut()).thenAnswer((_) async => {});
```

### 3.3 Test: Password Reset Flow

**Test Name:** `'Password reset flow: request reset, update password'`

**Steps:**
1. Start app (unauthenticated)
2. Navigate to login screen
3. Tap "Forgot Password?" link
4. Enter email address
5. Submit reset request
6. Verify success message
7. Mock receiving reset link (simulate deep link)
8. Navigate to reset password screen
9. Enter new password and confirmation
10. Submit new password
11. Verify success dialog
12. Verify navigation to login screen
13. Login with new password
14. Verify successful login

**Assertions:**
- ✅ Reset email request succeeds
- ✅ Deep link handling works
- ✅ Password update succeeds
- ✅ Can login with new password
- ✅ Error handling for invalid tokens

**Mock Strategy:**
```dart
// Mock password reset request
when(() => mockAuth.resetPasswordForEmail(
  any(),
  redirectTo: any(named: 'redirectTo'),
)).thenAnswer((_) async => {});

// Mock password update
when(() => mockAuth.updateUser(
  any(),
)).thenAnswer((_) async => UserResponse(user: testUser));
```

### 3.4 Test: Session Persistence

**Test Name:** `'Session persists across app restarts'`

**Steps:**
1. Start app and login
2. Verify authenticated state
3. Simulate app restart (dispose and recreate widget tree)
4. Verify user is still authenticated
5. Verify subscription state is maintained
6. Navigate to protected route
7. Verify access is granted

**Assertions:**
- ✅ Session persists after restart
- ✅ User data is restored
- ✅ Router guards work correctly
- ✅ No re-authentication required

**Mock Strategy:**
```dart
// Mock persistent session
when(() => mockAuth.currentSession).thenReturn(testSession);
when(() => mockAuth.currentUser).thenReturn(testUser);
```

### 3.5 Test: Auth Error Handling

**Test Name:** `'Handles auth errors gracefully'`

**Test Cases:**
- Invalid credentials on login
- Email already exists on signup
- Network error during auth
- Weak password error
- Invalid email format

**Assertions:**
- ✅ Error messages are user-friendly
- ✅ UI shows error states
- ✅ Forms remain editable after error
- ✅ Retry mechanism works

**Mock Strategy:**
```dart
// Mock auth failure
when(() => mockAuth.signInWithPassword(
  email: any(named: 'email'),
  password: any(named: 'password'),
)).thenThrow(AuthException('Invalid login credentials', statusCode: '400'));
```

**Estimated Time:** 2-3 hours

---

## 🧪 Step 4: Implement Router Integration Tests

### 4.1 Create Router Test File

**File:** `test/integration/router_test.dart`

### 4.2 Test: Unauthenticated Redirects

**Test Name:** `'Redirects unauthenticated users to welcome screen'`

**Steps:**
1. Start app without auth
2. Attempt to navigate to `/home`
3. Verify redirect to `/welcome`
4. Attempt to navigate to `/app`
5. Verify redirect to `/welcome`
6. Attempt to navigate to `/settings`
7. Verify redirect to `/welcome`

**Assertions:**
- ✅ Protected routes are blocked
- ✅ Redirects happen automatically
- ✅ No flash of protected content

### 4.3 Test: Subscription Guards

**Test Name:** `'Redirects free users to paywall when accessing premium routes'`

**Steps:**
1. Login as free user
2. Attempt to navigate to `/app`
3. Verify redirect to `/paywall`
4. Attempt to navigate to `/home`
5. Verify redirect to `/paywall`

**Assertions:**
- ✅ Free users can't access premium routes
- ✅ Paywall is shown correctly
- ✅ Can dismiss paywall and return to welcome

### 4.4 Test: Deep Link Handling

**Test Name:** `'Handles deep links correctly'`

**Test Cases:**
- Password reset link
- Email verification link
- Magic link authentication

**Assertions:**
- ✅ Deep links are parsed correctly
- ✅ Appropriate screens are shown
- ✅ Auth state is updated

**Estimated Time:** 1-1.5 hours

---

## ✅ Step 5: Run Tests and Verify

### 5.1 Run All Tests

```bash
# Run all tests
flutter test

# Run only integration tests
flutter test test/integration/

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 5.2 Verify Test Results

**Expected Results:**
- ✅ All auth flow tests pass
- ✅ All router tests pass
- ✅ No flaky tests
- ✅ Tests run in < 30 seconds
- ✅ Code coverage > 70% for auth code

### 5.3 Update Documentation

Update `RECOMMENDED_ROADMAP.md`:
```markdown
## ✅ **Phase 7.1: Auth Integration Tests** (COMPLETE)

**Status:** ✅ 100% Complete
**Time Spent:** ~4-6 hours
**Tests Added:** 8 integration tests
**Coverage:** 75%+ for auth flows

### 7.1 Integration Tests ✅
- ✅ `test/integration/auth_flow_test.dart` (5 tests)
  - Complete signup → login → logout flow
  - Password reset flow
  - Session persistence
  - Error handling
  - Edge cases
  
- ✅ `test/integration/router_test.dart` (3 tests)
  - Unauthenticated redirects
  - Subscription guards
  - Deep link handling

### Test Helpers Created ✅
- ✅ `test/helpers/mock_supabase.dart` - Mock Supabase client
- ✅ `test/helpers/test_providers.dart` - Provider overrides
- ✅ `test/helpers/test_utils.dart` - Common utilities

**All tests pass without requiring RevenueCat API keys!** ✅
```

**Estimated Time:** 30 minutes

---

## 📊 Summary

### Total Time Estimate: 4-6 hours

| Step | Task | Time |
|------|------|------|
| 1 | Add test dependencies | 5 min |
| 2 | Create test helpers | 1-1.5 hrs |
| 3 | Implement auth flow tests | 2-3 hrs |
| 4 | Implement router tests | 1-1.5 hrs |
| 5 | Run tests and verify | 30 min |

### Files to Create (6 new files)

**Test Helpers:**
1. `test/helpers/mock_supabase.dart` (~150 lines)
2. `test/helpers/test_providers.dart` (~100 lines)
3. `test/helpers/test_utils.dart` (~80 lines)

**Integration Tests:**
4. `test/integration/auth_flow_test.dart` (~400 lines)
5. `test/integration/router_test.dart` (~250 lines)

**Documentation:**
6. `PHASE_7_AUTH_TESTS_PLAN.md` (this file)

### Dependencies to Add (2 packages)

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  mocktail: ^1.0.0
```

---

## 🎯 Success Criteria

- ✅ All auth flows tested end-to-end
- ✅ Tests run without external API dependencies
- ✅ Tests are fast (< 30 seconds total)
- ✅ Tests are deterministic (no flakiness)
- ✅ Code coverage > 70% for auth code
- ✅ No RevenueCat keys required
- ✅ Clear error messages on test failures
- ✅ Tests serve as documentation

---

## 🚀 Next Steps After Completion

1. **Phase 7.2:** Subscription flow tests (with mocked RevenueCat)
2. **Phase 7.3:** Code coverage analysis
3. **Phase 7.4:** Performance testing
4. **Phase 8:** Platform-specific testing (optional)

---

## 💡 Key Design Decisions

### Why Mock Supabase?
- ✅ Tests run without internet connection
- ✅ Tests are fast and deterministic
- ✅ No test data pollution in real database
- ✅ Can simulate error conditions easily
- ✅ No API rate limits

### Why Use Mocktail?
- ✅ Modern, null-safe mocking library
- ✅ Better syntax than mockito
- ✅ No code generation required for mocks
- ✅ Great error messages
- ✅ Easy to verify interactions

### Why Integration Tests First?
- ✅ Most valuable tests (test real user flows)
- ✅ Catch integration issues early
- ✅ Verify router guards work correctly
- ✅ Test auth state management
- ✅ Build confidence in the system

---

## 📝 Notes

- Tests use **mocked Supabase** - no real API calls
- Tests use **provider overrides** for subscription state
- Tests are **deterministic** - no flaky tests
- Tests are **fast** - run in seconds, not minutes
- Tests are **comprehensive** - cover happy path and error cases
- Tests are **maintainable** - clear structure and helpers

**Ready to implement!** 🚀
