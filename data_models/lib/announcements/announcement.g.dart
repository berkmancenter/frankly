// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Announcement _$$_AnnouncementFromJson(Map<String, dynamic> json) =>
    _$_Announcement(
      id: json['id'] as String?,
      announcementStatus: $enumDecodeNullable(
              _$AnnouncementStatusEnumMap, json['announcementStatus'],
              unknownValue: AnnouncementStatus.active) ??
          AnnouncementStatus.active,
      creatorId: json['creatorId'] as String?,
      creatorDisplayName: json['creatorDisplayName'] as String?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      title: json['title'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$_AnnouncementToJson(_$_Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'announcementStatus':
          _$AnnouncementStatusEnumMap[instance.announcementStatus]!,
      'creatorId': instance.creatorId,
      'creatorDisplayName': instance.creatorDisplayName,
      'createdDate': instance.createdDate?.toIso8601String(),
      'title': instance.title,
      'message': instance.message,
    };

const _$AnnouncementStatusEnumMap = {
  AnnouncementStatus.active: 'active',
  AnnouncementStatus.removed: 'removed',
};
