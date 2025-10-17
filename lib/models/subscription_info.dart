import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_info.freezed.dart';
part 'subscription_info.g.dart';

/// Subscription information from RevenueCat
@freezed
sealed class SubscriptionInfo with _$SubscriptionInfo {
  const factory SubscriptionInfo({
    required bool isActive,
    required String tier,
    DateTime? expirationDate,
    String? productIdentifier,
  }) = _SubscriptionInfo;

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInfoFromJson(json);

  /// Default free tier subscription
  factory SubscriptionInfo.free() => const SubscriptionInfo(
        isActive: false,
        tier: 'free',
      );
}
