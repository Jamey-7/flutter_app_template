import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'logger/logger.dart';

/// Provider observer for logging and error tracking
/// Logs provider lifecycle events and sends errors to Sentry
final class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    if (kDebugMode) {
      Logger.log(
        'Provider added: ${context.provider.name ?? context.provider.runtimeType}',
        tag: 'ProviderObserver',
      );
    }
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (kDebugMode) {
      Logger.log(
        'Provider updated: ${context.provider.name ?? context.provider.runtimeType}',
        tag: 'ProviderObserver',
      );
    }
  }

  @override
  void didDisposeProvider(
    ProviderObserverContext context,
  ) {
    if (kDebugMode) {
      Logger.log(
        'Provider disposed: ${context.provider.name ?? context.provider.runtimeType}',
        tag: 'ProviderObserver',
      );
    }
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    Logger.error(
      'Provider failed: ${context.provider.name ?? context.provider.runtimeType}',
      error,
      stackTrace,
      tag: 'ProviderObserver',
    );

    // Send to Sentry with provider context
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'provider': context.provider.name ?? context.provider.runtimeType.toString(),
        'type': 'provider_error',
      }),
    );
  }
}
