// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_post_card_attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PrePostCardAttribute _$$_PrePostCardAttributeFromJson(
        Map<String, dynamic> json) =>
    _$_PrePostCardAttribute(
      type: $enumDecode(_$PrePostCardAttributeTypeEnumMap, json['type']),
      queryParam: json['queryParam'] as String,
    );

Map<String, dynamic> _$$_PrePostCardAttributeToJson(
        _$_PrePostCardAttribute instance) =>
    <String, dynamic>{
      'type': _$PrePostCardAttributeTypeEnumMap[instance.type]!,
      'queryParam': instance.queryParam,
    };

const _$PrePostCardAttributeTypeEnumMap = {
  PrePostCardAttributeType.userId: 'userId',
  PrePostCardAttributeType.eventId: 'eventId',
  PrePostCardAttributeType.email: 'email',
};
