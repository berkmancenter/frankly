// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'junto_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_JuntoResource _$$_JuntoResourceFromJson(Map<String, dynamic> json) =>
    _$_JuntoResource(
      id: json['id'] as String,
      createdDate: dateTimeFromTimestamp(json['createdDate']),
      title: json['title'] as String?,
      url: json['url'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$$_JuntoResourceToJson(_$_JuntoResource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdDate': serverTimestamp(instance.createdDate),
      'title': instance.title,
      'url': instance.url,
      'image': instance.image,
    };
