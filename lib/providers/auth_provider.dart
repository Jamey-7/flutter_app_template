import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/logger/logger.dart';
import '../core/supabase_client.dart';

class CurrentUserNotifier extends StreamNotifier<User?> {
  @override
  Stream<User?> build() {
    ref.keepAlive();
    Logger.log('Initializing auth state stream', tag: 'AuthProvider');

    return supabase.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      Logger.log(
        'Auth state changed: ${user != null ? 'signed in (${user.email})' : 'signed out'}',
        tag: 'AuthProvider',
      );
      return user;
    });
  }
}

/// Provider for current authenticated user
/// Streams auth state changes from Supabase
final currentUserProvider = StreamNotifierProvider<CurrentUserNotifier, User?>(
  CurrentUserNotifier.new,
  name: 'currentUserProvider',
);

/// Auth service for sign in/out operations
class AuthService {
  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      Logger.log('Attempting sign in for: $email', tag: 'AuthService');
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      Logger.log('Sign in successful', tag: 'AuthService');
      return response;
    } on AuthException catch (e, stackTrace) {
      Logger.error(
        'Sign in failed with auth exception',
        e,
        stackTrace,
        tag: 'AuthService',
      );
      throw AuthFailure(_mapAuthError(e));
    } catch (e, stackTrace) {
      Logger.error('Sign in failed', e, stackTrace, tag: 'AuthService');
      throw const AuthFailure('Unable to sign in. Please try again.');
    }
  }

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      Logger.log('Attempting sign up for: $email', tag: 'AuthService');
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      Logger.log('Sign up successful', tag: 'AuthService');
      return response;
    } on AuthException catch (e, stackTrace) {
      Logger.error(
        'Sign up failed with auth exception',
        e,
        stackTrace,
        tag: 'AuthService',
      );
      throw AuthFailure(_mapAuthError(e));
    } catch (e, stackTrace) {
      Logger.error('Sign up failed', e, stackTrace, tag: 'AuthService');
      throw const AuthFailure('Unable to create account. Please try again.');
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      Logger.log('Attempting sign out', tag: 'AuthService');
      await supabase.auth.signOut();
      Logger.log('Sign out successful', tag: 'AuthService');
    } catch (e, stackTrace) {
      Logger.error('Sign out failed', e, stackTrace, tag: 'AuthService');
      rethrow;
    }
  }

  /// Reset password for email
  static Future<void> resetPassword(String email) async {
    try {
      Logger.log('Requesting password reset for: $email', tag: 'AuthService');
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: _passwordResetRedirect(),
      );
      Logger.log('Password reset email sent', tag: 'AuthService');
    } catch (e, stackTrace) {
      Logger.error('Password reset failed', e, stackTrace, tag: 'AuthService');
      rethrow;
    }
  }
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

String _mapAuthError(AuthException exception) {
  if (exception.statusCode == '400') {
    final message = exception.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (message.contains('user already registered')) {
      return 'An account already exists for this email.';
    }
  }
  return exception.message.isNotEmpty
      ? exception.message
      : 'Authentication failed. Please try again.';
}

String? _passwordResetRedirect() {
  const fallback = String.fromEnvironment('SUPABASE_PASSWORD_RESET_REDIRECT');
  return fallback.isEmpty ? null : fallback;
}
