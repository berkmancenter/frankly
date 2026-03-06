// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_meeting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LiveMeeting _$$_LiveMeetingFromJson(Map<String, dynamic> json) =>
    _$_LiveMeeting(
      meetingId: json['meetingId'] as String?,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) =>
                  LiveMeetingParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => LiveMeetingEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentBreakoutSession: json['currentBreakoutSession'] == null
          ? null
          : BreakoutRoomSession.fromJson(
              json['currentBreakoutSession'] as Map<String, dynamic>),
      record: json['record'] as bool? ?? false,
      isMeetingCardMinimized: json['isMeetingCardMinimized'] as bool? ?? false,
      pinnedUserIds: (json['pinnedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_LiveMeetingToJson(_$_LiveMeeting instance) =>
    <String, dynamic>{
      'meetingId': instance.meetingId,
      'participants': instance.participants.map((e) => e.toJson()).toList(),
      'events': instance.events.map((e) => e.toJson()).toList(),
      'currentBreakoutSession': instance.currentBreakoutSession?.toJson(),
      'record': instance.record,
      'isMeetingCardMinimized': instance.isMeetingCardMinimized,
      'pinnedUserIds': instance.pinnedUserIds,
    };

_$_LiveMeetingParticipant _$$_LiveMeetingParticipantFromJson(
        Map<String, dynamic> json) =>
    _$_LiveMeetingParticipant(
      communityId: json['communityId'] as String?,
      meetingId: json['meetingId'] as String?,
      externalCommunityId: json['externalCommunityId'] as String?,
    );

Map<String, dynamic> _$$_LiveMeetingParticipantToJson(
        _$_LiveMeetingParticipant instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'meetingId': instance.meetingId,
      'externalCommunityId': instance.externalCommunityId,
    };

_$_LiveMeetingEvent _$$_LiveMeetingEventFromJson(Map<String, dynamic> json) =>
    _$_LiveMeetingEvent(
      event: $enumDecodeNullable(_$LiveMeetingEventTypeEnumMap, json['event']),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      agendaItem: json['agendaItem'] as String?,
      hostless: json['hostless'] as bool? ?? false,
    );

Map<String, dynamic> _$$_LiveMeetingEventToJson(_$_LiveMeetingEvent instance) =>
    <String, dynamic>{
      'event': _$LiveMeetingEventTypeEnumMap[instance.event],
      'timestamp': instance.timestamp?.toIso8601String(),
      'agendaItem': instance.agendaItem,
      'hostless': instance.hostless,
    };

const _$LiveMeetingEventTypeEnumMap = {
  LiveMeetingEventType.startMeeting: 'startMeeting',
  LiveMeetingEventType.agendaItemCompleted: 'agendaItemCompleted',
  LiveMeetingEventType.agendaItemStarted: 'agendaItemStarted',
  LiveMeetingEventType.finishMeeting: 'finishMeeting',
  LiveMeetingEventType.startVideo: 'startVideo',
};

_$_LiveMeetingRating _$$_LiveMeetingRatingFromJson(Map<String, dynamic> json) =>
    _$_LiveMeetingRating(
      ratingId: json['ratingId'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$_LiveMeetingRatingToJson(
        _$_LiveMeetingRating instance) =>
    <String, dynamic>{
      'ratingId': instance.ratingId,
      'rating': instance.rating,
    };

_$_BreakoutRoom _$$_BreakoutRoomFromJson(Map<String, dynamic> json) =>
    _$_BreakoutRoom(
      roomId: json['roomId'] as String,
      roomName: json['roomName'] as String,
      orderingPriority: json['orderingPriority'] as int,
      creatorId: json['creatorId'] as String,
      participantIds: (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      originalParticipantIdsAssignment:
          (json['originalParticipantIdsAssignment'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      flagStatus: $enumDecodeNullable(
              _$BreakoutRoomFlagStatusEnumMap, json['flagStatus'],
              unknownValue: BreakoutRoomFlagStatus.unflagged) ??
          BreakoutRoomFlagStatus.unflagged,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      record: json['record'] as bool? ?? false,
    );

Map<String, dynamic> _$$_BreakoutRoomToJson(_$_BreakoutRoom instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'roomName': instance.roomName,
      'orderingPriority': instance.orderingPriority,
      'creatorId': instance.creatorId,
      'participantIds': instance.participantIds,
      'originalParticipantIdsAssignment':
          instance.originalParticipantIdsAssignment,
      'flagStatus': _$BreakoutRoomFlagStatusEnumMap[instance.flagStatus]!,
      'createdDate': instance.createdDate?.toIso8601String(),
      'record': instance.record,
    };

const _$BreakoutRoomFlagStatusEnumMap = {
  BreakoutRoomFlagStatus.unflagged: 'unflagged',
  BreakoutRoomFlagStatus.needsHelp: 'needsHelp',
};

_$_BreakoutRoomSession _$$_BreakoutRoomSessionFromJson(
        Map<String, dynamic> json) =>
    _$_BreakoutRoomSession(
      breakoutRoomSessionId: json['breakoutRoomSessionId'] as String,
      breakoutRoomStatus: $enumDecodeNullable(
          _$BreakoutRoomStatusEnumMap, json['breakoutRoomStatus']),
      statusUpdatedTime: json['statusUpdatedTime'] == null
          ? null
          : DateTime.parse(json['statusUpdatedTime'] as String),
      assignmentMethod: $enumDecode(
          _$BreakoutAssignmentMethodEnumMap, json['assignmentMethod']),
      targetParticipantsPerRoom: json['targetParticipantsPerRoom'] as int,
      hasWaitingRoom: json['hasWaitingRoom'] as bool,
      maxRoomNumber: json['maxRoomNumber'] as int?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      scheduledTime: json['scheduledTime'] == null
          ? null
          : DateTime.parse(json['scheduledTime'] as String),
      processingId: json['processingId'] as String?,
    );

Map<String, dynamic> _$$_BreakoutRoomSessionToJson(
        _$_BreakoutRoomSession instance) =>
    <String, dynamic>{
      'breakoutRoomSessionId': instance.breakoutRoomSessionId,
      'breakoutRoomStatus':
          _$BreakoutRoomStatusEnumMap[instance.breakoutRoomStatus],
      'statusUpdatedTime': instance.statusUpdatedTime?.toIso8601String(),
      'assignmentMethod':
          _$BreakoutAssignmentMethodEnumMap[instance.assignmentMethod]!,
      'targetParticipantsPerRoom': instance.targetParticipantsPerRoom,
      'hasWaitingRoom': instance.hasWaitingRoom,
      'maxRoomNumber': instance.maxRoomNumber,
      'createdDate': instance.createdDate?.toIso8601String(),
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'processingId': instance.processingId,
    };

const _$BreakoutRoomStatusEnumMap = {
  BreakoutRoomStatus.pending: 'pending',
  BreakoutRoomStatus.processingAssignments: 'processingAssignments',
  BreakoutRoomStatus.active: 'active',
  BreakoutRoomStatus.inactive: 'inactive',
};

const _$BreakoutAssignmentMethodEnumMap = {
  BreakoutAssignmentMethod.targetPerRoom: 'targetPerRoom',
  BreakoutAssignmentMethod.smartMatch: 'smartMatch',
  BreakoutAssignmentMethod.category: 'category',
};
