// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Theme type notifier with persistence
///
/// Manages the app's selected theme (Default, Cyberpunk, Minimalist, etc.).
/// Each theme includes its own light/dark mode preference.
///
/// Usage:
/// ```dart
/// // Watch selected theme
/// final theme = ref.watch(themeTypeProvider);
///
/// // Change theme
/// ref.read(themeTypeProvider.notifier).setTheme(AppThemeType.cyberpunk);
/// ```

@ProviderFor(ThemeTypeNotifier)
const themeTypeProvider = ThemeTypeNotifierProvider._();

/// Theme type notifier with persistence
///
/// Manages the app's selected theme (Default, Cyberpunk, Minimalist, etc.).
/// Each theme includes its own light/dark mode preference.
///
/// Usage:
/// ```dart
/// // Watch selected theme
/// final theme = ref.watch(themeTypeProvider);
///
/// // Change theme
/// ref.read(themeTypeProvider.notifier).setTheme(AppThemeType.cyberpunk);
/// ```
final class ThemeTypeNotifierProvider
    extends $NotifierProvider<ThemeTypeNotifier, AppThemeType> {
  /// Theme type notifier with persistence
  ///
  /// Manages the app's selected theme (Default, Cyberpunk, Minimalist, etc.).
  /// Each theme includes its own light/dark mode preference.
  ///
  /// Usage:
  /// ```dart
  /// // Watch selected theme
  /// final theme = ref.watch(themeTypeProvider);
  ///
  /// // Change theme
  /// ref.read(themeTypeProvider.notifier).setTheme(AppThemeType.cyberpunk);
  /// ```
  const ThemeTypeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeTypeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeTypeNotifierHash();

  @$internal
  @override
  ThemeTypeNotifier create() => ThemeTypeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeType>(value),
    );
  }
}

String _$themeTypeNotifierHash() => r'064a259c345198d61662325382036be54b73c8e8';

/// Theme type notifier with persistence
///
/// Manages the app's selected theme (Default, Cyberpunk, Minimalist, etc.).
/// Each theme includes its own light/dark mode preference.
///
/// Usage:
/// ```dart
/// // Watch selected theme
/// final theme = ref.watch(themeTypeProvider);
///
/// // Change theme
/// ref.read(themeTypeProvider.notifier).setTheme(AppThemeType.cyberpunk);
/// ```

abstract class _$ThemeTypeNotifier extends $Notifier<AppThemeType> {
  AppThemeType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppThemeType, AppThemeType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppThemeType, AppThemeType>,
              AppThemeType,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
