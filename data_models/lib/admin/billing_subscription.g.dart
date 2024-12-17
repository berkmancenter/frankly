// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BillingSubscription _$$_BillingSubscriptionFromJson(
        Map<String, dynamic> json) =>
    _$_BillingSubscription(
      stripeSubscriptionId: json['stripeSubscriptionId'] as String,
      type: json['type'] as String,
      activeUntil: json['activeUntil'] == null
          ? null
          : DateTime.parse(json['activeUntil'] as String),
      canceled: json['canceled'] as bool,
      willCancelAtPeriodEnd: json['willCancelAtPeriodEnd'] as bool,
      appliedCommunityId: json['appliedCommunityId'] as String?,
    );

Map<String, dynamic> _$$_BillingSubscriptionToJson(
        _$_BillingSubscription instance) =>
    <String, dynamic>{
      'stripeSubscriptionId': instance.stripeSubscriptionId,
      'type': instance.type,
      'activeUntil': instance.activeUntil?.toIso8601String(),
      'canceled': instance.canceled,
      'willCancelAtPeriodEnd': instance.willCancelAtPeriodEnd,
      'appliedCommunityId': instance.appliedCommunityId,
    };
