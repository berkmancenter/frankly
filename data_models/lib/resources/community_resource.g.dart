// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CommunityResource _$$_CommunityResourceFromJson(Map<String, dynamic> json) =>
    _$_CommunityResource(
      id: json['id'] as String,
      createdDate: dateTimeFromTimestamp(json['createdDate']),
      title: json['title'] as String?,
      url: json['url'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$$_CommunityResourceToJson(
        _$_CommunityResource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdDate': serverTimestamp(instance.createdDate),
      'title': instance.title,
      'url': instance.url,
      'image': instance.image,
    };
