// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PaymentRecord _$$_PaymentRecordFromJson(Map<String, dynamic> json) =>
    _$_PaymentRecord(
      id: json['id'] as String?,
      authUid: json['authUid'] as String?,
      communityId: json['communityId'] as String?,
      amountInCents: json['amountInCents'] as int?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      type: $enumDecodeNullable(_$PaymentTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$_PaymentRecordToJson(_$_PaymentRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authUid': instance.authUid,
      'communityId': instance.communityId,
      'amountInCents': instance.amountInCents,
      'createdDate': instance.createdDate?.toIso8601String(),
      'type': _$PaymentTypeEnumMap[instance.type],
    };

const _$PaymentTypeEnumMap = {
  PaymentType.oneTimeDonation: 'oneTimeDonation',
};
