// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_MediaItem _$$_MediaItemFromJson(Map<String, dynamic> json) => _$_MediaItem(
      url: json['url'] as String,
      type: $enumDecode(_$MediaTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$_MediaItemToJson(_$_MediaItem instance) =>
    <String, dynamic>{
      'url': instance.url,
      'type': _$MediaTypeEnumMap[instance.type]!,
    };

const _$MediaTypeEnumMap = {
  MediaType.image: 'image',
  MediaType.video: 'video',
};
