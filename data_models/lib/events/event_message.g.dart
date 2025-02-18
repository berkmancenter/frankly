// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_EventMessage _$$_EventMessageFromJson(Map<String, dynamic> json) =>
    _$_EventMessage(
      creatorId: json['creatorId'] as String,
      createdAt: dateTimeFromTimestamp(json['createdAt']),
      createdAtMillis: json['createdAtMillis'] as int?,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$_EventMessageToJson(_$_EventMessage instance) =>
    <String, dynamic>{
      'creatorId': instance.creatorId,
      'createdAt': timestampFromDateTime(instance.createdAt),
      'createdAtMillis': instance.createdAtMillis,
      'message': instance.message,
    };
