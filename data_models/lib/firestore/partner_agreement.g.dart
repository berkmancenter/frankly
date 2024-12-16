// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_agreement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PartnerAgreement _$$_PartnerAgreementFromJson(Map<String, dynamic> json) =>
    _$_PartnerAgreement(
      id: json['id'] as String,
      allowPayments: json['allowPayments'] as bool? ?? false,
      takeRate: (json['takeRate'] as num?)?.toDouble(),
      initialUserId: json['initialUserId'] as String?,
      communityId: json['communityId'] as String?,
      stripeConnectedAccountId: json['stripeConnectedAccountId'] as String?,
      stripeConnectedAccountActive:
          json['stripeConnectedAccountActive'] as bool? ?? false,
      planOverride: json['planOverride'] as String?,
    );

Map<String, dynamic> _$$_PartnerAgreementToJson(_$_PartnerAgreement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'allowPayments': instance.allowPayments,
      'takeRate': instance.takeRate,
      'initialUserId': instance.initialUserId,
      'communityId': instance.communityId,
      'stripeConnectedAccountId': instance.stripeConnectedAccountId,
      'stripeConnectedAccountActive': instance.stripeConnectedAccountActive,
      'planOverride': instance.planOverride,
    };
