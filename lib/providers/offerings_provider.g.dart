// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offerings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that fetches RevenueCat offerings
///
/// Returns the available subscription packages from RevenueCat.
/// Handles loading and error states automatically via AsyncValue.
///
/// Usage:
/// ```dart
/// final offeringsAsync = ref.watch(offeringsProvider);
/// offeringsAsync.when(
///   data: (offerings) => /* display products */,
///   loading: () => /* show loading */,
///   error: (error, stack) => /* show error */,
/// );
/// ```

@ProviderFor(offerings)
const offeringsProvider = OfferingsProvider._();

/// Provider that fetches RevenueCat offerings
///
/// Returns the available subscription packages from RevenueCat.
/// Handles loading and error states automatically via AsyncValue.
///
/// Usage:
/// ```dart
/// final offeringsAsync = ref.watch(offeringsProvider);
/// offeringsAsync.when(
///   data: (offerings) => /* display products */,
///   loading: () => /* show loading */,
///   error: (error, stack) => /* show error */,
/// );
/// ```

final class OfferingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Offerings?>,
          Offerings?,
          FutureOr<Offerings?>
        >
    with $FutureModifier<Offerings?>, $FutureProvider<Offerings?> {
  /// Provider that fetches RevenueCat offerings
  ///
  /// Returns the available subscription packages from RevenueCat.
  /// Handles loading and error states automatically via AsyncValue.
  ///
  /// Usage:
  /// ```dart
  /// final offeringsAsync = ref.watch(offeringsProvider);
  /// offeringsAsync.when(
  ///   data: (offerings) => /* display products */,
  ///   loading: () => /* show loading */,
  ///   error: (error, stack) => /* show error */,
  /// );
  /// ```
  const OfferingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offeringsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offeringsHash();

  @$internal
  @override
  $FutureProviderElement<Offerings?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Offerings?> create(Ref ref) {
    return offerings(ref);
  }
}

String _$offeringsHash() => r'6e421362ce0317afe4abd2d308bce04678ea0d5c';
