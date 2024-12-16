// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_guide.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ParticipantAgendaItemDetails _$$_ParticipantAgendaItemDetailsFromJson(
        Map<String, dynamic> json) =>
    _$_ParticipantAgendaItemDetails(
      userId: json['userId'] as String?,
      agendaItemId: json['agendaItemId'] as String?,
      meetingId: json['meetingId'] as String?,
      readyToAdvance: json['readyToAdvance'] as bool?,
      handRaisedTime: dateTimeFromTimestamp(json['handRaisedTime']),
      pollResponse: json['pollResponse'] as String?,
      wordCloudResponses: (json['wordCloudResponses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) =>
                  MeetingUserSuggestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      videoCurrentTime: (json['videoCurrentTime'] as num?)?.toDouble(),
      videoDuration: (json['videoDuration'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$_ParticipantAgendaItemDetailsToJson(
        _$_ParticipantAgendaItemDetails instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'agendaItemId': instance.agendaItemId,
      'meetingId': instance.meetingId,
      'readyToAdvance': instance.readyToAdvance,
      'handRaisedTime': timestampFromDateTime(instance.handRaisedTime),
      'pollResponse': instance.pollResponse,
      'wordCloudResponses': instance.wordCloudResponses,
      'suggestions': instance.suggestions.map((e) => e.toJson()).toList(),
      'videoCurrentTime': instance.videoCurrentTime,
      'videoDuration': instance.videoDuration,
    };

_$_MeetingUserSuggestion _$$_MeetingUserSuggestionFromJson(
        Map<String, dynamic> json) =>
    _$_MeetingUserSuggestion(
      id: json['id'] as String,
      suggestion: json['suggestion'] as String,
      likedByIds: (json['likedByIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dislikedByIds: (json['dislikedByIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdDate: dateTimeFromTimestamp(json['createdDate']),
    );

Map<String, dynamic> _$$_MeetingUserSuggestionToJson(
        _$_MeetingUserSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'suggestion': instance.suggestion,
      'likedByIds': instance.likedByIds,
      'dislikedByIds': instance.dislikedByIds,
      'createdDate': timestampFromDateTime(instance.createdDate),
    };

_$_ParticipantAgendaItemDetailsMeta
    _$$_ParticipantAgendaItemDetailsMetaFromJson(Map<String, dynamic> json) =>
        _$_ParticipantAgendaItemDetailsMeta(
          documentPath: json['documentPath'] as String,
          voterId: json['voterId'] as String,
          likeType: $enumDecode(_$LikeTypeEnumMap, json['likeType']),
          userSuggestionId: json['userSuggestionId'] as String,
        );

Map<String, dynamic> _$$_ParticipantAgendaItemDetailsMetaToJson(
        _$_ParticipantAgendaItemDetailsMeta instance) =>
    <String, dynamic>{
      'documentPath': instance.documentPath,
      'voterId': instance.voterId,
      'likeType': _$LikeTypeEnumMap[instance.likeType]!,
      'userSuggestionId': instance.userSuggestionId,
    };

const _$LikeTypeEnumMap = {
  LikeType.like: 'like',
  LikeType.neutral: 'neutral',
  LikeType.dislike: 'dislike',
};
