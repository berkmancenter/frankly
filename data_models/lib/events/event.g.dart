// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Event _$$_EventFromJson(Map<String, dynamic> json) => _$_Event(
      id: json['id'] as String,
      status: $enumDecodeNullable(_$EventStatusEnumMap, json['status'],
              unknownValue: EventStatus.active) ??
          EventStatus.active,
      nullableEventType:
          $enumDecodeNullable(_$EventTypeEnumMap, json['eventType']),
      collectionPath: json['collectionPath'] as String,
      communityId: json['communityId'] as String,
      templateId: json['templateId'] as String,
      creatorId: json['creatorId'] as String,
      prerequisiteTemplateId: json['prerequisiteTemplateId'] as String?,
      creatorDisplayName: json['creatorDisplayName'] as String?,
      createdDate: dateTimeFromTimestamp(json['createdDate']),
      scheduledTime: dateTimeFromTimestamp(json['scheduledTime']),
      scheduledTimeZone: json['scheduledTimeZone'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
      minParticipants: json['minParticipants'] as int?,
      maxParticipants: json['maxParticipants'] as int?,
      agendaItems: (json['agendaItems'] as List<dynamic>?)
              ?.map((e) => AgendaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      waitingRoomInfo: json['waitingRoomInfo'] == null
          ? null
          : WaitingRoomInfo.fromJson(
              json['waitingRoomInfo'] as Map<String, dynamic>),
      breakoutRoomDefinition: BreakoutRoomDefinition.fromJsonMigration(
          json['breakoutRoomDefinition'] as Map<String, dynamic>?),
      isLocked: json['isLocked'] as bool? ?? false,
      liveStreamInfo: json['liveStreamInfo'] == null
          ? null
          : LiveStreamInfo.fromJson(
              json['liveStreamInfo'] as Map<String, dynamic>),
      preEventCardData: json['preEventCardData'] == null
          ? null
          : PrePostCard.fromJson(
              json['preEventCardData'] as Map<String, dynamic>),
      postEventCardData: json['postEventCardData'] == null
          ? null
          : PrePostCard.fromJson(
              json['postEventCardData'] as Map<String, dynamic>),
      externalPlatform: json['externalPlatform'] == null
          ? null
          : PlatformItem.fromJson(
              json['externalPlatform'] as Map<String, dynamic>),
      eventSettings: json['eventSettings'] == null
          ? null
          : EventSettings.fromJson(
              json['eventSettings'] as Map<String, dynamic>),
      durationInMinutes: json['durationInMinutes'] as int? ?? 60,
      externalCommunityId: json['externalCommunityId'] as String?,
      externalCommunityStatus: json['externalCommunityStatus'] as String?,
      participantCountEstimate: json['participantCountEstimate'] as int?,
      presentParticipantCountEstimate:
          json['presentParticipantCountEstimate'] as int?,
      breakoutMatchIdsToRecord: json['breakoutMatchIdsToRecord'] ?? const [],
    );

Map<String, dynamic> _$$_EventToJson(_$_Event instance) => <String, dynamic>{
      'id': instance.id,
      'status': _$EventStatusEnumMap[instance.status]!,
      'eventType': _$EventTypeEnumMap[instance.nullableEventType],
      'collectionPath': instance.collectionPath,
      'communityId': instance.communityId,
      'templateId': instance.templateId,
      'creatorId': instance.creatorId,
      'prerequisiteTemplateId': instance.prerequisiteTemplateId,
      'creatorDisplayName': instance.creatorDisplayName,
      'createdDate': serverTimestamp(instance.createdDate),
      'scheduledTime': timestampFromDateTime(instance.scheduledTime),
      'scheduledTimeZone': instance.scheduledTimeZone,
      'title': instance.title,
      'description': instance.description,
      'image': instance.image,
      'isPublic': instance.isPublic,
      'minParticipants': instance.minParticipants,
      'maxParticipants': instance.maxParticipants,
      'agendaItems': instance.agendaItems.map((e) => e.toJson()).toList(),
      'waitingRoomInfo': instance.waitingRoomInfo?.toJson(),
      'breakoutRoomDefinition': instance.breakoutRoomDefinition?.toJson(),
      'isLocked': instance.isLocked,
      'liveStreamInfo': instance.liveStreamInfo?.toJson(),
      'preEventCardData': instance.preEventCardData?.toJson(),
      'postEventCardData': instance.postEventCardData?.toJson(),
      'externalPlatform': instance.externalPlatform?.toJson(),
      'eventSettings': instance.eventSettings?.toJson(),
      'durationInMinutes': instance.durationInMinutes,
      'externalCommunityId': instance.externalCommunityId,
      'externalCommunityStatus': instance.externalCommunityStatus,
      'participantCountEstimate': instance.participantCountEstimate,
      'presentParticipantCountEstimate':
          instance.presentParticipantCountEstimate,
      'breakoutMatchIdsToRecord': instance.breakoutMatchIdsToRecord,
    };

const _$EventStatusEnumMap = {
  EventStatus.active: 'active',
  EventStatus.canceled: 'canceled',
};

const _$EventTypeEnumMap = {
  EventType.hosted: 'hosted',
  EventType.hostless: 'hostless',
  EventType.livestream: 'livestream',
};

_$_EventSettings _$$_EventSettingsFromJson(Map<String, dynamic> json) =>
    _$_EventSettings(
      reminderEmails: json['reminderEmails'] as bool?,
      chat: json['chat'] as bool?,
      showChatMessagesInRealTime: json['showChatMessagesInRealTime'] as bool?,
      talkingTimer: json['talkingTimer'] as bool?,
      allowPredefineBreakoutsOnHosted:
          json['allowPredefineBreakoutsOnHosted'] as bool?,
      defaultStageView: json['defaultStageView'] as bool?,
      enableBreakoutsByCategory: json['enableBreakoutsByCategory'] as bool?,
      allowMultiplePeopleOnStage: json['allowMultiplePeopleOnStage'] as bool?,
      showSmartMatchingForBreakouts:
          json['showSmartMatchingForBreakouts'] as bool?,
      alwaysRecord: json['alwaysRecord'] as bool?,
      enablePrerequisites: json['enablePrerequisites'] as bool?,
      agendaPreview: json['agendaPreview'] as bool?,
    );

Map<String, dynamic> _$$_EventSettingsToJson(_$_EventSettings instance) =>
    <String, dynamic>{
      'reminderEmails': instance.reminderEmails,
      'chat': instance.chat,
      'showChatMessagesInRealTime': instance.showChatMessagesInRealTime,
      'talkingTimer': instance.talkingTimer,
      'allowPredefineBreakoutsOnHosted':
          instance.allowPredefineBreakoutsOnHosted,
      'defaultStageView': instance.defaultStageView,
      'enableBreakoutsByCategory': instance.enableBreakoutsByCategory,
      'allowMultiplePeopleOnStage': instance.allowMultiplePeopleOnStage,
      'showSmartMatchingForBreakouts': instance.showSmartMatchingForBreakouts,
      'alwaysRecord': instance.alwaysRecord,
      'enablePrerequisites': instance.enablePrerequisites,
      'agendaPreview': instance.agendaPreview,
    };

_$_LiveStreamInfo _$$_LiveStreamInfoFromJson(Map<String, dynamic> json) =>
    _$_LiveStreamInfo(
      muxId: json['muxId'] as String?,
      muxPlaybackId: json['muxPlaybackId'] as String?,
      muxStatus: json['muxStatus'] as String?,
      latestAssetPlaybackId: json['latestAssetPlaybackId'] as String?,
      liveStreamWaitingTextOverride:
          json['liveStreamWaitingTextOverride'] as String?,
      resetStream: json['resetStream'] as bool?,
    );

Map<String, dynamic> _$$_LiveStreamInfoToJson(_$_LiveStreamInfo instance) =>
    <String, dynamic>{
      'muxId': instance.muxId,
      'muxPlaybackId': instance.muxPlaybackId,
      'muxStatus': instance.muxStatus,
      'latestAssetPlaybackId': instance.latestAssetPlaybackId,
      'liveStreamWaitingTextOverride': instance.liveStreamWaitingTextOverride,
      'resetStream': instance.resetStream,
    };

_$_Participant _$$_ParticipantFromJson(Map<String, dynamic> json) =>
    _$_Participant(
      id: json['id'] as String,
      communityId: json['communityId'] as String?,
      externalCommunityId: json['externalCommunityId'] as String?,
      templateId: json['templateId'] as String?,
      lastUpdatedTime: dateTimeFromTimestamp(json['lastUpdatedTime']),
      createdDate: dateTimeFromTimestamp(json['createdDate']),
      scheduledTime: dateTimeFromTimestamp(json['scheduledTime']),
      status: $enumDecodeNullable(_$ParticipantStatusEnumMap, json['status']),
      isPresent: json['isPresent'] as bool? ?? false,
      availableForBreakoutSessionId:
          json['availableForBreakoutSessionId'] as String?,
      membershipStatus: $enumDecodeNullable(
          _$MembershipStatusEnumMap, json['membershipStatus']),
      currentBreakoutRoomId: json['currentBreakoutRoomId'] as String?,
      muteOverride: json['muteOverride'] as bool? ?? false,
      joinParameters: (json['joinParameters'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      breakoutRoomSurveyQuestions: (json['breakoutRoomSurveyQuestions']
                  as List<dynamic>?)
              ?.map((e) => BreakoutQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mostRecentPresentTime:
          dateTimeFromTimestamp(json['mostRecentPresentTime']),
      zipCode: json['zipCode'] as String?,
    );

Map<String, dynamic> _$$_ParticipantToJson(_$_Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'communityId': instance.communityId,
      'externalCommunityId': instance.externalCommunityId,
      'templateId': instance.templateId,
      'lastUpdatedTime': serverTimestamp(instance.lastUpdatedTime),
      'createdDate': instance.createdDate?.toIso8601String(),
      'scheduledTime': serverTimestamp(instance.scheduledTime),
      'status': _$ParticipantStatusEnumMap[instance.status],
      'isPresent': instance.isPresent,
      'availableForBreakoutSessionId': instance.availableForBreakoutSessionId,
      'membershipStatus': _$MembershipStatusEnumMap[instance.membershipStatus],
      'currentBreakoutRoomId': instance.currentBreakoutRoomId,
      'muteOverride': instance.muteOverride,
      'joinParameters': instance.joinParameters,
      'breakoutRoomSurveyQuestions':
          instance.breakoutRoomSurveyQuestions.map((e) => e.toJson()).toList(),
      'mostRecentPresentTime':
          serverTimestampOrNull(instance.mostRecentPresentTime),
      'zipCode': instance.zipCode,
    };

const _$ParticipantStatusEnumMap = {
  ParticipantStatus.active: 'active',
  ParticipantStatus.canceled: 'canceled',
  ParticipantStatus.banned: 'banned',
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.banned: 'banned',
  MembershipStatus.nonmember: 'nonmember',
  MembershipStatus.attendee: 'attendee',
  MembershipStatus.member: 'member',
  MembershipStatus.facilitator: 'facilitator',
  MembershipStatus.mod: 'mod',
  MembershipStatus.admin: 'admin',
  MembershipStatus.owner: 'owner',
};

_$_PrivateLiveStreamInfo _$$_PrivateLiveStreamInfoFromJson(
        Map<String, dynamic> json) =>
    _$_PrivateLiveStreamInfo(
      streamServerUrl: json['streamServerUrl'] as String?,
      streamKey: json['streamKey'] as String?,
    );

Map<String, dynamic> _$$_PrivateLiveStreamInfoToJson(
        _$_PrivateLiveStreamInfo instance) =>
    <String, dynamic>{
      'streamServerUrl': instance.streamServerUrl,
      'streamKey': instance.streamKey,
    };

_$_EventEmailLog _$$_EventEmailLogFromJson(Map<String, dynamic> json) =>
    _$_EventEmailLog(
      userId: json['userId'] as String?,
      eventEmailType:
          $enumDecodeNullable(_$EventEmailTypeEnumMap, json['eventEmailType']),
      createdDate: dateTimeFromTimestamp(json['createdDate']),
      sendId: json['sendId'] as String?,
    );

Map<String, dynamic> _$$_EventEmailLogToJson(_$_EventEmailLog instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventEmailType': _$EventEmailTypeEnumMap[instance.eventEmailType],
      'createdDate': timestampFromDateTime(instance.createdDate),
      'sendId': instance.sendId,
    };

const _$EventEmailTypeEnumMap = {
  EventEmailType.initialSignUp: 'initialSignUp',
  EventEmailType.oneDayReminder: 'oneDayReminder',
  EventEmailType.oneHourReminder: 'oneHourReminder',
  EventEmailType.updated: 'updated',
  EventEmailType.canceled: 'canceled',
  EventEmailType.ended: 'ended',
};

_$_AgendaItem _$$_AgendaItemFromJson(Map<String, dynamic> json) =>
    _$_AgendaItem(
      id: json['id'] as String,
      priority: json['priority'] as int?,
      creatorId: json['creatorId'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      videoType: $enumDecodeNullable(
              _$AgendaItemVideoTypeEnumMap, json['videoType']) ??
          AgendaItemVideoType.url,
      nullableType: $enumDecodeNullable(_$AgendaItemTypeEnumMap, json['type']),
      videoUrl: json['videoUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      pollAnswers: (json['pollAnswers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      timeInSeconds:
          json['timeInSeconds'] as int? ?? AgendaItem.kDefaultTimeInSeconds,
      suggestionsButtonText: json['suggestionsButtonText'] as String?,
    );

Map<String, dynamic> _$$_AgendaItemToJson(_$_AgendaItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'priority': instance.priority,
      'creatorId': instance.creatorId,
      'title': instance.title,
      'content': instance.content,
      'videoType': _$AgendaItemVideoTypeEnumMap[instance.videoType]!,
      'type': _$AgendaItemTypeEnumMap[instance.nullableType],
      'videoUrl': instance.videoUrl,
      'imageUrl': instance.imageUrl,
      'pollAnswers': instance.pollAnswers,
      'timeInSeconds': instance.timeInSeconds,
      'suggestionsButtonText': instance.suggestionsButtonText,
    };

const _$AgendaItemVideoTypeEnumMap = {
  AgendaItemVideoType.youtube: 'youtube',
  AgendaItemVideoType.vimeo: 'vimeo',
  AgendaItemVideoType.url: 'url',
};

const _$AgendaItemTypeEnumMap = {
  AgendaItemType.text: 'text',
  AgendaItemType.video: 'video',
  AgendaItemType.image: 'image',
  AgendaItemType.poll: 'poll',
  AgendaItemType.wordCloud: 'wordCloud',
  AgendaItemType.userSuggestions: 'userSuggestions',
};

_$_SuggestedAgendaItem _$$_SuggestedAgendaItemFromJson(
        Map<String, dynamic> json) =>
    _$_SuggestedAgendaItem(
      id: json['id'] as String?,
      creatorId: json['creatorId'] as String?,
      content: json['content'] as String?,
      createdDate: dateTimeFromTimestamp(json['createdDate']),
      upvotedUserIds: (json['upvotedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      downvotedUserIds: (json['downvotedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_SuggestedAgendaItemToJson(
        _$_SuggestedAgendaItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'content': instance.content,
      'createdDate': serverTimestamp(instance.createdDate),
      'upvotedUserIds': instance.upvotedUserIds,
      'downvotedUserIds': instance.downvotedUserIds,
    };

_$_BreakoutRoomDefinition _$$_BreakoutRoomDefinitionFromJson(
        Map<String, dynamic> json) =>
    _$_BreakoutRoomDefinition(
      creatorId: json['creatorId'] as String?,
      targetParticipants: json['targetParticipants'] as int?,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => SurveyQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      breakoutQuestions: (json['breakoutQuestions'] as List<dynamic>?)
              ?.map((e) => BreakoutQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => BreakoutCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      assignmentMethod: $enumDecodeNullable(
              _$BreakoutAssignmentMethodEnumMap, json['assignmentMethod'],
              unknownValue: BreakoutAssignmentMethod.targetPerRoom) ??
          BreakoutAssignmentMethod.targetPerRoom,
    );

Map<String, dynamic> _$$_BreakoutRoomDefinitionToJson(
        _$_BreakoutRoomDefinition instance) =>
    <String, dynamic>{
      'creatorId': instance.creatorId,
      'targetParticipants': instance.targetParticipants,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'breakoutQuestions':
          instance.breakoutQuestions.map((e) => e.toJson()).toList(),
      'categories': instance.categories.map((e) => e.toJson()).toList(),
      'assignmentMethod':
          _$BreakoutAssignmentMethodEnumMap[instance.assignmentMethod]!,
    };

const _$BreakoutAssignmentMethodEnumMap = {
  BreakoutAssignmentMethod.targetPerRoom: 'targetPerRoom',
  BreakoutAssignmentMethod.smartMatch: 'smartMatch',
  BreakoutAssignmentMethod.category: 'category',
};

_$_SurveyQuestion _$$_SurveyQuestionFromJson(Map<String, dynamic> json) =>
    _$_SurveyQuestion(
      answerOptions: (json['answerOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      answerIndex: json['answerIndex'] as int?,
      id: json['id'] as String?,
      question: json['question'] as String?,
    );

Map<String, dynamic> _$$_SurveyQuestionToJson(_$_SurveyQuestion instance) =>
    <String, dynamic>{
      'answerOptions': instance.answerOptions,
      'answerIndex': instance.answerIndex,
      'id': instance.id,
      'question': instance.question,
    };

_$_BreakoutQuestion _$$_BreakoutQuestionFromJson(Map<String, dynamic> json) =>
    _$_BreakoutQuestion(
      id: json['id'] as String,
      title: json['title'] as String,
      answerOptionId: json['answerOptionId'] as String,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => BreakoutAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_BreakoutQuestionToJson(_$_BreakoutQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'answerOptionId': instance.answerOptionId,
      'answers': instance.answers.map((e) => e.toJson()).toList(),
    };

_$_BreakoutAnswer _$$_BreakoutAnswerFromJson(Map<String, dynamic> json) =>
    _$_BreakoutAnswer(
      id: json['id'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => BreakoutAnswerOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_BreakoutAnswerToJson(_$_BreakoutAnswer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'options': instance.options.map((e) => e.toJson()).toList(),
    };

_$_BreakoutAnswerOption _$$_BreakoutAnswerOptionFromJson(
        Map<String, dynamic> json) =>
    _$_BreakoutAnswerOption(
      id: json['id'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$$_BreakoutAnswerOptionToJson(
        _$_BreakoutAnswerOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };

_$_BreakoutCategory _$$_BreakoutCategoryFromJson(Map<String, dynamic> json) =>
    _$_BreakoutCategory(
      id: json['id'] as String,
      category: json['category'] as String,
    );

Map<String, dynamic> _$$_BreakoutCategoryToJson(_$_BreakoutCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
    };

_$_PlatformItem _$$_PlatformItemFromJson(Map<String, dynamic> json) =>
    _$_PlatformItem(
      url: json['url'] as String?,
      platformKey:
          $enumDecodeNullable(_$PlatformKeyEnumMap, json['platformKey']) ??
              PlatformKey.community,
    );

Map<String, dynamic> _$$_PlatformItemToJson(_$_PlatformItem instance) =>
    <String, dynamic>{
      'url': instance.url,
      'platformKey': _$PlatformKeyEnumMap[instance.platformKey]!,
    };

const _$PlatformKeyEnumMap = {
  PlatformKey.community: 'community',
  PlatformKey.googleMeet: 'googleMeet',
  PlatformKey.maps: 'maps',
  PlatformKey.microsoftTeam: 'microsoftTeam',
  PlatformKey.zoom: 'zoom',
};

_$_WaitingRoomInfo _$$_WaitingRoomInfoFromJson(Map<String, dynamic> json) =>
    _$_WaitingRoomInfo(
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      waitingMediaBufferSeconds: json['waitingMediaBufferSeconds'] as int? ?? 0,
      content: json['content'] as String?,
      waitingMediaItem: json['waitingMediaItem'] == null
          ? null
          : MediaItem.fromJson(
              json['waitingMediaItem'] as Map<String, dynamic>),
      introMediaItem: json['introMediaItem'] == null
          ? null
          : MediaItem.fromJson(json['introMediaItem'] as Map<String, dynamic>),
      enableChat: json['enableChat'] as bool? ?? false,
      loopWaitingVideo: json['loopWaitingVideo'] as bool? ?? false,
    );

Map<String, dynamic> _$$_WaitingRoomInfoToJson(_$_WaitingRoomInfo instance) =>
    <String, dynamic>{
      'durationSeconds': instance.durationSeconds,
      'waitingMediaBufferSeconds': instance.waitingMediaBufferSeconds,
      'content': instance.content,
      'waitingMediaItem': instance.waitingMediaItem?.toJson(),
      'introMediaItem': instance.introMediaItem?.toJson(),
      'enableChat': instance.enableChat,
      'loopWaitingVideo': instance.loopWaitingVideo,
    };
