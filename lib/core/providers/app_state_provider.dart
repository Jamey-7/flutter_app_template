import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/app_state.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/subscriptions/providers/subscription_provider.dart';

part 'app_state_provider.g.dart';

/// Combined application state provider
/// Combines auth and subscription state into a single AppState object
@riverpod
AppState appState(Ref ref) {
  return AppState(
    auth: ref.watch(currentUserProvider),
    subscription: ref.watch(subscriptionProvider),
  );
}
