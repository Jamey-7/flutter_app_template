import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock classes for Supabase authentication
class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

// Note: AuthChangeEvent is an enum and cannot be mocked directly

class MockUserResponse extends Mock implements UserResponse {}

/// Helper to create a test user with specified properties
User createTestUser({
  required String id,
  required String email,
  Map<String, dynamic>? userMetadata,
  Map<String, dynamic>? appMetadata,
  DateTime? createdAt,
}) {
  final user = MockUser();
  when(() => user.id).thenReturn(id);
  when(() => user.email).thenReturn(email);
  when(() => user.userMetadata).thenReturn(userMetadata ?? {});
  when(() => user.appMetadata).thenReturn(appMetadata ?? {});
  when(() => user.createdAt)
      .thenReturn((createdAt ?? DateTime.now()).toIso8601String());
  return user;
}

/// Helper to create a test session
Session createTestSession({
  required User user,
  String? accessToken,
  String? refreshToken,
  DateTime? expiresAt,
}) {
  final session = MockSession();
  when(() => session.user).thenReturn(user);
  when(() => session.accessToken).thenReturn(accessToken ?? 'test-access-token');
  when(() => session.refreshToken)
      .thenReturn(refreshToken ?? 'test-refresh-token');
  when(() => session.expiresAt).thenReturn(
    (expiresAt ?? DateTime.now().add(const Duration(hours: 1)))
        .millisecondsSinceEpoch,
  );
  return session;
}

/// Helper to create an auth response
AuthResponse createAuthResponse({
  required User? user,
  Session? session,
}) {
  final response = MockAuthResponse();
  when(() => response.user).thenReturn(user);
  when(() => response.session).thenReturn(session);
  return response;
}

/// Helper to create a user response (for update operations)
UserResponse createUserResponse({
  required User user,
}) {
  final response = MockUserResponse();
  when(() => response.user).thenReturn(user);
  return response;
}

/// Helper to create an auth exception
AuthException createAuthException({
  required String message,
  String? statusCode,
}) {
  return AuthException(message, statusCode: statusCode);
}

/// Setup common mock behaviors for GoTrueClient
void setupMockAuthClient(MockGoTrueClient mockAuth) {
  // Setup default auth state stream
  when(() => mockAuth.onAuthStateChange).thenAnswer(
    (_) => Stream<AuthState>.empty(),
  );

  // Setup default current session/user as null
  when(() => mockAuth.currentSession).thenReturn(null);
  when(() => mockAuth.currentUser).thenReturn(null);
}

/// Setup successful sign in mock
void mockSuccessfulSignIn(
  MockGoTrueClient mockAuth, {
  required String email,
  required String password,
  required User user,
}) {
  final session = createTestSession(user: user);
  final response = createAuthResponse(user: user, session: session);

  when(() => mockAuth.signInWithPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => response);

  // Update current session/user after sign in
  when(() => mockAuth.currentSession).thenReturn(session);
  when(() => mockAuth.currentUser).thenReturn(user);
}

/// Setup successful sign up mock
void mockSuccessfulSignUp(
  MockGoTrueClient mockAuth, {
  required String email,
  required String password,
  required User user,
  Session? session,
}) {
  final response = createAuthResponse(user: user, session: session);

  when(() => mockAuth.signUp(
        email: email,
        password: password,
        emailRedirectTo: any(named: 'emailRedirectTo'),
      )).thenAnswer((_) async => response);

  // If session provided, update current session/user
  if (session != null) {
    when(() => mockAuth.currentSession).thenReturn(session);
    when(() => mockAuth.currentUser).thenReturn(user);
  }
}

/// Setup successful sign out mock
void mockSuccessfulSignOut(MockGoTrueClient mockAuth) {
  when(() => mockAuth.signOut()).thenAnswer((_) async {});

  // Clear current session/user after sign out
  when(() => mockAuth.currentSession).thenReturn(null);
  when(() => mockAuth.currentUser).thenReturn(null);
}

/// Setup password reset mock
void mockPasswordReset(
  MockGoTrueClient mockAuth, {
  required String email,
  bool shouldSucceed = true,
}) {
  if (shouldSucceed) {
    when(() => mockAuth.resetPasswordForEmail(
          email,
          redirectTo: any(named: 'redirectTo'),
        )).thenAnswer((_) async {});
  } else {
    when(() => mockAuth.resetPasswordForEmail(
          email,
          redirectTo: any(named: 'redirectTo'),
        )).thenThrow(
      createAuthException(
        message: 'Unable to send reset email',
        statusCode: '400',
      ),
    );
  }
}

/// Setup password update mock
void mockPasswordUpdate(
  MockGoTrueClient mockAuth, {
  required User user,
  bool shouldSucceed = true,
}) {
  if (shouldSucceed) {
    final response = createUserResponse(user: user);
    when(() => mockAuth.updateUser(any())).thenAnswer((_) async => response);
  } else {
    when(() => mockAuth.updateUser(any())).thenThrow(
      createAuthException(
        message: 'Unable to update password',
        statusCode: '400',
      ),
    );
  }
}

/// Setup email update mock
void mockEmailUpdate(
  MockGoTrueClient mockAuth, {
  required User user,
  bool shouldSucceed = true,
}) {
  if (shouldSucceed) {
    final response = createUserResponse(user: user);
    when(() => mockAuth.updateUser(any())).thenAnswer((_) async => response);
  } else {
    when(() => mockAuth.updateUser(any())).thenThrow(
      createAuthException(
        message: 'Unable to update email',
        statusCode: '400',
      ),
    );
  }
}

/// Setup failed sign in mock (invalid credentials)
void mockFailedSignIn(
  MockGoTrueClient mockAuth, {
  required String email,
  required String password,
}) {
  when(() => mockAuth.signInWithPassword(
        email: email,
        password: password,
      )).thenThrow(
    createAuthException(
      message: 'Invalid login credentials',
      statusCode: '400',
    ),
  );
}

/// Setup failed sign up mock (user already exists)
void mockFailedSignUp(
  MockGoTrueClient mockAuth, {
  required String email,
  required String password,
}) {
  when(() => mockAuth.signUp(
        email: email,
        password: password,
        emailRedirectTo: any(named: 'emailRedirectTo'),
      )).thenThrow(
    createAuthException(
      message: 'User already registered',
      statusCode: '400',
    ),
  );
}
