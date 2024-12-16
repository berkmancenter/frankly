// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twilio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TwilioParticipant _$$_TwilioParticipantFromJson(Map<String, dynamic> json) =>
    _$_TwilioParticipant(
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
      participantSid: json['participantSid'] as String?,
      participantIdentity: json['participantIdentity'] as String?,
      joinTime: dateTimeFromTimestamp(json['joinTime']),
      leaveTime: dateTimeFromTimestamp(json['leaveTime']),
      duration: json['duration'] as int?,
    );

Map<String, dynamic> _$$_TwilioParticipantToJson(
        _$_TwilioParticipant instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'roomName': instance.roomName,
      'participantSid': instance.participantSid,
      'participantIdentity': instance.participantIdentity,
      'joinTime': timestampFromDateTime(instance.joinTime),
      'leaveTime': timestampFromDateTime(instance.leaveTime),
      'duration': instance.duration,
    };
