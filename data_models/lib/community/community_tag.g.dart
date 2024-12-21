// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CommunityTag _$$_CommunityTagFromJson(Map<String, dynamic> json) =>
    _$_CommunityTag(
      taggedItemType:
          $enumDecodeNullable(_$TaggedItemTypeEnumMap, json['taggedItemType']),
      definitionId: json['definitionId'] as String,
      communityId: json['communityId'] as String?,
      taggedItemId: json['taggedItemId'] as String,
    );

Map<String, dynamic> _$$_CommunityTagToJson(_$_CommunityTag instance) =>
    <String, dynamic>{
      'taggedItemType': _$TaggedItemTypeEnumMap[instance.taggedItemType],
      'definitionId': instance.definitionId,
      'communityId': instance.communityId,
      'taggedItemId': instance.taggedItemId,
    };

const _$TaggedItemTypeEnumMap = {
  TaggedItemType.community: 'community',
  TaggedItemType.template: 'template',
  TaggedItemType.resource: 'resource',
  TaggedItemType.profile: 'profile',
};
