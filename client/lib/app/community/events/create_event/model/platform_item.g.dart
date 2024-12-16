// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlatformItemImpl _$$PlatformItemImplFromJson(Map<String, dynamic> json) =>
    _$PlatformItemImpl(
      title: json['title'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      url: json['url'] as String?,
      platformKey:
          $enumDecodeNullable(_$PlatformKeyEnumMap, json['platformKey']),
    );

Map<String, dynamic> _$$PlatformItemImplToJson(_$PlatformItemImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'url': instance.url,
      'platformKey': _$PlatformKeyEnumMap[instance.platformKey],
    };

const _$PlatformKeyEnumMap = {
  PlatformKey.community: 'community',
  PlatformKey.googleMeet: 'googleMeet',
  PlatformKey.maps: 'maps',
  PlatformKey.microsoftTeam: 'microsoftTeam',
  PlatformKey.zoom: 'zoom',
};
