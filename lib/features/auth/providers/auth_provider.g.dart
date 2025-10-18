// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(CurrentUser)
const currentUserProvider = CurrentUserProvider._();

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
final class CurrentUserProvider
    extends $StreamNotifierProvider<CurrentUser, User?> {
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
  const CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  CurrentUser create() => CurrentUser();
}

String _$currentUserHash() => r'7c5ff55c26c8823f0af412b5a1135b5291288fa8';

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

abstract class _$CurrentUser extends $StreamNotifier<User?> {
  Stream<User?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<User?>, User?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<User?>, User?>,
              AsyncValue<User?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
