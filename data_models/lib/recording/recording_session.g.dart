// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_RecordingSession _$$_RecordingSessionFromJson(Map<String, dynamic> json) =>
    _$_RecordingSession(
      sessionId: json['sessionId'] as String?,
      communityId: json['communityId'] as String,
      eventId: json['eventId'] as String,
      roomId: json['roomId'] as String,
      roomType: $enumDecode(_$RecordingRoomTypeEnumMap, json['roomType'],
          unknownValue: RecordingRoomType.main),
      status: $enumDecode(_$RecordingSessionStatusEnumMap, json['status'],
          unknownValue: RecordingSessionStatus.failed),
      startedBy: json['startedBy'] as String? ?? 'system',
      startedAt: dateTimeFromTimestamp(json['startedAt']),
      stoppedAt: dateTimeFromTimestamp(json['stoppedAt']),
      breakoutSessionId: json['breakoutSessionId'] as String?,
      agoraResourceId: json['agoraResourceId'] as String?,
      agoraSid: json['agoraSid'] as String?,
      agoraRttAgentId: json['agoraRttAgentId'] as String?,
      rttLanguage: json['rttLanguage'] as String?,
      gcsPrefix: json['gcsPrefix'] as String?,
      chatPath: json['chatPath'] as String?,
      errorMessage: json['errorMessage'] as String?,
      artifactPaths: (json['artifactPaths'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      participantIds: (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      uidToDisplayName:
          (json['uidToDisplayName'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const {},
    );

Map<String, dynamic> _$$_RecordingSessionToJson(_$_RecordingSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'communityId': instance.communityId,
      'eventId': instance.eventId,
      'roomId': instance.roomId,
      'roomType': _$RecordingRoomTypeEnumMap[instance.roomType]!,
      'status': _$RecordingSessionStatusEnumMap[instance.status]!,
      'startedBy': instance.startedBy,
      'startedAt': serverTimestamp(instance.startedAt),
      'stoppedAt': serverTimestampOrNull(instance.stoppedAt),
      'breakoutSessionId': instance.breakoutSessionId,
      'agoraResourceId': instance.agoraResourceId,
      'agoraSid': instance.agoraSid,
      'agoraRttAgentId': instance.agoraRttAgentId,
      'rttLanguage': instance.rttLanguage,
      'gcsPrefix': instance.gcsPrefix,
      'chatPath': instance.chatPath,
      'errorMessage': instance.errorMessage,
      'artifactPaths': instance.artifactPaths,
      'participantIds': instance.participantIds,
      'uidToDisplayName': instance.uidToDisplayName,
    };

const _$RecordingRoomTypeEnumMap = {
  RecordingRoomType.main: 'main',
  RecordingRoomType.breakout: 'breakout',
};

const _$RecordingSessionStatusEnumMap = {
  RecordingSessionStatus.starting: 'starting',
  RecordingSessionStatus.recording: 'recording',
  RecordingSessionStatus.stopping: 'stopping',
  RecordingSessionStatus.stopped: 'stopped',
  RecordingSessionStatus.failed: 'failed',
};
