// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Combined application state provider
/// Combines auth and subscription state into a single AppState object

@ProviderFor(appState)
const appStateProvider = AppStateProvider._();

/// Combined application state provider
/// Combines auth and subscription state into a single AppState object

final class AppStateProvider
    extends $FunctionalProvider<AppState, AppState, AppState>
    with $Provider<AppState> {
  /// Combined application state provider
  /// Combines auth and subscription state into a single AppState object
  const AppStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStateHash();

  @$internal
  @override
  $ProviderElement<AppState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppState create(Ref ref) {
    return appState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppState>(value),
    );
  }
}

String _$appStateHash() => r'221ebbe64d51a1e1ecaffae750c9c78ec3e65718';
