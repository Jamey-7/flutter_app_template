// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionInfo _$SubscriptionInfoFromJson(Map<String, dynamic> json) =>
    _SubscriptionInfo(
      isActive: json['isActive'] as bool,
      tier: json['tier'] as String,
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      productIdentifier: json['productIdentifier'] as String?,
    );

Map<String, dynamic> _$SubscriptionInfoToJson(_SubscriptionInfo instance) =>
    <String, dynamic>{
      'isActive': instance.isActive,
      'tier': instance.tier,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'productIdentifier': instance.productIdentifier,
    };
