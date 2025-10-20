// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Theme mode notifier with persistence
///
/// Manages the app's theme mode (light/dark/system) and persists
/// the user's preference using SharedPreferences.
///
/// Usage:
/// ```dart
/// // Watch theme mode
/// final themeMode = ref.watch(themeModeProvider);
///
/// // Toggle theme
/// ref.read(themeModeProvider.notifier).toggleTheme();
///
/// // Set specific theme
/// ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
/// ```

@ProviderFor(ThemeModeNotifier)
const themeModeProvider = ThemeModeNotifierProvider._();

/// Theme mode notifier with persistence
///
/// Manages the app's theme mode (light/dark/system) and persists
/// the user's preference using SharedPreferences.
///
/// Usage:
/// ```dart
/// // Watch theme mode
/// final themeMode = ref.watch(themeModeProvider);
///
/// // Toggle theme
/// ref.read(themeModeProvider.notifier).toggleTheme();
///
/// // Set specific theme
/// ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
/// ```
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeMode> {
  /// Theme mode notifier with persistence
  ///
  /// Manages the app's theme mode (light/dark/system) and persists
  /// the user's preference using SharedPreferences.
  ///
  /// Usage:
  /// ```dart
  /// // Watch theme mode
  /// final themeMode = ref.watch(themeModeProvider);
  ///
  /// // Toggle theme
  /// ref.read(themeModeProvider.notifier).toggleTheme();
  ///
  /// // Set specific theme
  /// ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
  /// ```
  const ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'43f24d0de152a162d3f6520725eae93fc485dbaa';

/// Theme mode notifier with persistence
///
/// Manages the app's theme mode (light/dark/system) and persists
/// the user's preference using SharedPreferences.
///
/// Usage:
/// ```dart
/// // Watch theme mode
/// final themeMode = ref.watch(themeModeProvider);
///
/// // Toggle theme
/// ref.read(themeModeProvider.notifier).toggleTheme();
///
/// // Set specific theme
/// ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
/// ```

abstract class _$ThemeModeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
