// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_EventMessage _$$_EventMessageFromJson(Map<String, dynamic> json) =>
    _$_EventMessage(
      creatorId: json['creatorId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      createdAtMillis: json['createdAtMillis'] as int?,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$_EventMessageToJson(_$_EventMessage instance) =>
    <String, dynamic>{
      'creatorId': instance.creatorId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'createdAtMillis': instance.createdAtMillis,
      'message': instance.message,
    };
