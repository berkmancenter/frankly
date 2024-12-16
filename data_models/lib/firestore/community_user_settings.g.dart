// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CommunityUserSettings _$$_CommunityUserSettingsFromJson(
        Map<String, dynamic> json) =>
    _$_CommunityUserSettings(
      userId: json['userId'] as String?,
      communityId: json['communityId'] as String?,
      notifyEvents: $enumDecodeNullable(
          _$NotificationEmailTypeEnumMap, json['notifyEvents']),
      notifyAnnouncements: $enumDecodeNullable(
          _$NotificationEmailTypeEnumMap, json['notifyAnnouncements']),
    );

Map<String, dynamic> _$$_CommunityUserSettingsToJson(
        _$_CommunityUserSettings instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'communityId': instance.communityId,
      'notifyEvents': _$NotificationEmailTypeEnumMap[instance.notifyEvents],
      'notifyAnnouncements':
          _$NotificationEmailTypeEnumMap[instance.notifyAnnouncements],
    };

const _$NotificationEmailTypeEnumMap = {
  NotificationEmailType.none: 'none',
  NotificationEmailType.immediate: 'immediate',
};
