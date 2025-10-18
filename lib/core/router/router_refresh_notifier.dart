import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_state.dart';
import '../providers/app_state_provider.dart';

/// Notifier that triggers router redirect re-evaluation
/// when app state changes (auth or subscription)
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this._ref) {
    // Listen to app state and notify router when it changes
    _ref.listen<AppState>(
      appStateProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref _ref;

  /// Get current app state for redirect logic
  AppState get appState => _ref.read(appStateProvider);
}

/// Provider for router refresh notifier
final routerRefreshProvider = Provider<RouterRefreshNotifier>(
  (ref) => RouterRefreshNotifier(ref),
  name: 'routerRefreshProvider',
);
