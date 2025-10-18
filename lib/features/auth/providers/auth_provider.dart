import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logger/logger.dart';
import '../../../core/supabase_client.dart';

part 'auth_provider.g.dart';

/// Current user provider with automatic session recovery
/// 
/// Handles token expiration gracefully:
/// - Valid tokens: auto-refreshed by Supabase
/// - Invalid/expired tokens: cleared and treated as signed out
/// - Prevents provider rebuild cascades with .distinct()
/// 
/// To test error recovery manually:
/// 1. Sign in normally
/// 2. In Supabase dashboard: Delete user's refresh token from auth.refresh_tokens
/// 3. Hot restart app → should redirect to welcome (not error/loop)
@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  Stream<User?> build() {
    ref.keepAlive();
    Logger.log('Initializing auth state stream', tag: 'AuthProvider');

    return supabase.auth.onAuthStateChange
        .map((data) {
          final user = data.session?.user;
          Logger.log(
            'Auth state changed: ${user != null ? 'signed in (${user.email})' : 'signed out'}',
            tag: 'AuthProvider',
          );
          return user;
        })
        .handleError((error) {
          // Gracefully handle invalid refresh token errors
          if (error is AuthException) {
            final isInvalidToken = error.code == 'refresh_token_not_found' ||
                error.message.toLowerCase().contains('invalid refresh token');
            
            if (isInvalidToken) {
              Logger.warning(
                'Invalid refresh token detected, clearing session: ${error.message}',
                tag: 'AuthProvider',
              );
              // Clear the invalid session asynchronously (non-blocking)
              supabase.auth.signOut().catchError((e) {
                Logger.error(
                  'Failed to clear invalid session',
                  e,
                  null,
                  tag: 'AuthProvider',
                );
              });
              // Return null instead of throwing - treats as signed out
              return null;
            }
          }
          
          // Log and re-throw other errors
          Logger.error('Auth stream error', error, null, tag: 'AuthProvider');
          throw error;
        })
        .distinct((prev, next) => prev?.id == next?.id); // Prevent duplicate emissions
  }
}

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
    String? emailRedirectTo,
  }) async {
    try {
      Logger.log('Attempting sign up for: $email', tag: 'AuthService');
      
      // Get redirect URL from environment or use provided one
      final redirectUrl = emailRedirectTo ?? _getRedirectUrl();
      
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: redirectUrl,
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
        redirectTo: _getRedirectUrl(),
      );
      Logger.log('Password reset email sent', tag: 'AuthService');
    } catch (e, stackTrace) {
      Logger.error('Password reset failed', e, stackTrace, tag: 'AuthService');
      rethrow;
    }
  }

  /// Update user password (after reset)
  static Future<void> updatePassword(String newPassword) async {
    try {
      Logger.log('Updating user password', tag: 'AuthService');
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      Logger.log('Password updated successfully', tag: 'AuthService');
    } on AuthException catch (e, stackTrace) {
      Logger.error('Password update failed', e, stackTrace, tag: 'AuthService');
      throw AuthFailure(_mapAuthError(e));
    } catch (e, stackTrace) {
      Logger.error('Password update failed', e, stackTrace, tag: 'AuthService');
      throw const AuthFailure('Unable to update password. Please try again.');
    }
  }

  /// Update user email
  static Future<void> updateEmail(String newEmail) async {
    try {
      Logger.log('Updating user email', tag: 'AuthService');
      await supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );
      Logger.log('Email update requested successfully', tag: 'AuthService');
    } on AuthException catch (e, stackTrace) {
      Logger.error('Email update failed', e, stackTrace, tag: 'AuthService');
      throw AuthFailure(_mapAuthError(e));
    } catch (e, stackTrace) {
      Logger.error('Email update failed', e, stackTrace, tag: 'AuthService');
      throw const AuthFailure('Unable to update email. Please try again.');
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

/// Get the redirect URL from environment variables
String? _getRedirectUrl() {
  const redirectUrl = String.fromEnvironment('SUPABASE_REDIRECT_URL');
  return redirectUrl.isEmpty ? null : redirectUrl;
}
