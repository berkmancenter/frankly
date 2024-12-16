// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'junto_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_JuntoTag _$$_JuntoTagFromJson(Map<String, dynamic> json) => _$_JuntoTag(
      taggedItemType:
          $enumDecodeNullable(_$TaggedItemTypeEnumMap, json['taggedItemType']),
      definitionId: json['definitionId'] as String,
      juntoId: json['juntoId'] as String?,
      taggedItemId: json['taggedItemId'] as String,
    );

Map<String, dynamic> _$$_JuntoTagToJson(_$_JuntoTag instance) =>
    <String, dynamic>{
      'taggedItemType': _$TaggedItemTypeEnumMap[instance.taggedItemType],
      'definitionId': instance.definitionId,
      'juntoId': instance.juntoId,
      'taggedItemId': instance.taggedItemId,
    };

const _$TaggedItemTypeEnumMap = {
  TaggedItemType.junto: 'junto',
  TaggedItemType.topic: 'topic',
  TaggedItemType.resource: 'resource',
  TaggedItemType.profile: 'profile',
};
