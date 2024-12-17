// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CommunityResource _$$_CommunityResourceFromJson(Map<String, dynamic> json) =>
    _$_CommunityResource(
      id: json['id'] as String,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      title: json['title'] as String?,
      url: json['url'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$$_CommunityResourceToJson(
        _$_CommunityResource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdDate': instance.createdDate?.toIso8601String(),
      'title': instance.title,
      'url': instance.url,
      'image': instance.image,
    };
