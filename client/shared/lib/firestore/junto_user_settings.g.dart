// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'junto_user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_JuntoUserSettings _$$_JuntoUserSettingsFromJson(Map<String, dynamic> json) =>
    _$_JuntoUserSettings(
      userId: json['userId'] as String?,
      juntoId: json['juntoId'] as String?,
      notifyEvents: $enumDecodeNullable(
          _$NotificationEmailTypeEnumMap, json['notifyEvents']),
      notifyAnnouncements: $enumDecodeNullable(
          _$NotificationEmailTypeEnumMap, json['notifyAnnouncements']),
    );

Map<String, dynamic> _$$_JuntoUserSettingsToJson(
        _$_JuntoUserSettings instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'juntoId': instance.juntoId,
      'notifyEvents': _$NotificationEmailTypeEnumMap[instance.notifyEvents],
      'notifyAnnouncements':
          _$NotificationEmailTypeEnumMap[instance.notifyAnnouncements],
    };

const _$NotificationEmailTypeEnumMap = {
  NotificationEmailType.none: 'none',
  NotificationEmailType.immediate: 'immediate',
};
