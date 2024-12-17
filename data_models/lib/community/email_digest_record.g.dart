// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_digest_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_EmailDigestRecord _$$_EmailDigestRecordFromJson(Map<String, dynamic> json) =>
    _$_EmailDigestRecord(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      communityId: json['communityId'] as String?,
      type: $enumDecodeNullable(_$DigestTypeEnumMap, json['type'],
              unknownValue: DigestType.weekly) ??
          DigestType.weekly,
      sentAt: dateTimeFromTimestamp(json['sentAt']),
    );

Map<String, dynamic> _$$_EmailDigestRecordToJson(
        _$_EmailDigestRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'communityId': instance.communityId,
      'type': _$DigestTypeEnumMap[instance.type]!,
      'sentAt': serverTimestamp(instance.sentAt),
    };

const _$DigestTypeEnumMap = {
  DigestType.weekly: 'weekly',
};
