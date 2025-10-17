import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_state.dart';
import 'auth_provider.dart';
import 'subscription_provider.dart';

final appStateProvider = Provider<AppState>(
  (ref) => AppState(
    auth: ref.watch(currentUserProvider),
    subscription: ref.watch(subscriptionProvider),
  ),
  name: 'appStateProvider',
);
