import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Simple logger service for debug and error tracking
class Logger {
  /// Log a message to console (debug/profile only)
  static void log(String message, {String? tag}) {
    if (!kReleaseMode) {
      final prefix = tag != null ? '[$tag]' : '[LOG]';
      debugPrint('$prefix $message');
    }
  }

  /// Log an error to console and Sentry
  static void error(
    String message,
    dynamic error,
    StackTrace? stackTrace, {
    String? tag,
  }) {
    final prefix = tag != null ? '[$tag]' : '[ERROR]';
    if (!kReleaseMode) {
      debugPrint('$prefix $message: $error');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }

    // Send to Sentry in all modes
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({'message': message, 'tag': tag}),
    );
  }

  /// Log a warning to console
  static void warning(String message, {String? tag}) {
    if (!kReleaseMode) {
      final prefix = tag != null ? '[$tag]' : '[WARNING]';
      debugPrint('$prefix $message');
    }
  }
}
