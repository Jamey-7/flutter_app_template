import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'subscription_info.dart';

part 'app_state.freezed.dart';

/// Combined application state (auth + subscription)
@freezed
sealed class AppState with _$AppState {
  const factory AppState({
    required AsyncValue<User?> auth,
    required AsyncValue<SubscriptionInfo> subscription,
  }) = _AppState;

  const AppState._();

  /// Check if user is authenticated
  bool get isAuthenticated => auth.when(
        data: (u) => u != null,
        loading: () => false,
        error: (e, s) => false,
      );

  /// Check if user has active subscription
  bool get hasActiveSubscription => subscription.when(
        data: (info) => info.isActive,
        loading: () => false,
        error: (e, s) => false,
      );

  /// Check if user needs to see paywall
  bool get needsPaywall => isAuthenticated && !hasActiveSubscription;

  bool get isLoading => auth.isLoading || subscription.isLoading;

  bool get hasError => auth.hasError || subscription.hasError;

  User? get user => auth.whenOrNull(data: (u) => u);

  SubscriptionInfo get subscriptionValue => subscription.when(
        data: (info) => info,
        loading: () => SubscriptionInfo.free(),
        error: (e, s) => SubscriptionInfo.free(),
      );
}
