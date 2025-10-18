import '../logger/logger.dart';

/// Retry a network operation with exponential backoff
///
/// This helper function wraps async operations and automatically retries them
/// if they fail, with increasing delays between attempts.
///
/// Usage:
/// ```dart
/// final result = await retryWithBackoff(
///   () => apiCall(),
///   maxRetries: 3,
/// );
/// ```
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
  String? operationName,
}) async {
  int attempt = 0;
  Duration delay = initialDelay;

  while (true) {
    try {
      attempt++;
      final operationLabel = operationName ?? 'operation';

      if (attempt > 1) {
        Logger.log(
          'Retry attempt $attempt/$maxRetries for $operationLabel',
          tag: 'RetryHelper',
        );
      }

      final result = await operation();

      if (attempt > 1) {
        Logger.log(
          '$operationLabel succeeded on attempt $attempt',
          tag: 'RetryHelper',
        );
      }

      return result;
    } catch (e, stackTrace) {
      final operationLabel = operationName ?? 'operation';

      if (attempt >= maxRetries) {
        Logger.error(
          '$operationLabel failed after $maxRetries attempts',
          e,
          stackTrace,
          tag: 'RetryHelper',
        );
        rethrow;
      }

      Logger.warning(
        '$operationLabel failed (attempt $attempt/$maxRetries), retrying in ${delay.inSeconds}s: $e',
        tag: 'RetryHelper',
      );

      // Wait before retrying with exponential backoff
      await Future.delayed(delay);

      // Double the delay for next attempt (exponential backoff)
      delay *= 2;
    }
  }
}
