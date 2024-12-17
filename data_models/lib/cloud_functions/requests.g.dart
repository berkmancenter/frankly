// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CreateEventRequest _$$_CreateEventRequestFromJson(
        Map<String, dynamic> json) =>
    _$_CreateEventRequest(
      eventPath: json['eventPath'] as String,
    );

Map<String, dynamic> _$$_CreateEventRequestToJson(
        _$_CreateEventRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
    };

_$_CreateAnnouncementRequest _$$_CreateAnnouncementRequestFromJson(
        Map<String, dynamic> json) =>
    _$_CreateAnnouncementRequest(
      communityId: json['communityId'] as String,
      announcement: json['announcement'] == null
          ? null
          : Announcement.fromJson(json['announcement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_CreateAnnouncementRequestToJson(
        _$_CreateAnnouncementRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'announcement':
          Announcement.toJsonForCloudFunction(instance.announcement),
    };

_$_SendEventMessageRequest _$$_SendEventMessageRequestFromJson(
        Map<String, dynamic> json) =>
    _$_SendEventMessageRequest(
      communityId: json['communityId'] as String,
      templateId: json['templateId'] as String,
      eventId: json['eventId'] as String,
      eventMessage:
          EventMessage.fromJson(json['eventMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_SendEventMessageRequestToJson(
        _$_SendEventMessageRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'templateId': instance.templateId,
      'eventId': instance.eventId,
      'eventMessage':
          EventMessage.toJsonForCloudFunction(instance.eventMessage),
    };

_$_CreateDonationCheckoutSessionRequest
    _$$_CreateDonationCheckoutSessionRequestFromJson(
            Map<String, dynamic> json) =>
        _$_CreateDonationCheckoutSessionRequest(
          communityId: json['communityId'] as String,
          amountInCents: json['amountInCents'] as int,
        );

Map<String, dynamic> _$$_CreateDonationCheckoutSessionRequestToJson(
        _$_CreateDonationCheckoutSessionRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'amountInCents': instance.amountInCents,
    };

_$_CreateDonationCheckoutSessionResponse
    _$$_CreateDonationCheckoutSessionResponseFromJson(
            Map<String, dynamic> json) =>
        _$_CreateDonationCheckoutSessionResponse(
          sessionId: json['sessionId'] as String,
        );

Map<String, dynamic> _$$_CreateDonationCheckoutSessionResponseToJson(
        _$_CreateDonationCheckoutSessionResponse instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
    };

_$_CreateSubscriptionCheckoutSessionRequest
    _$$_CreateSubscriptionCheckoutSessionRequestFromJson(
            Map<String, dynamic> json) =>
        _$_CreateSubscriptionCheckoutSessionRequest(
          type: $enumDecode(_$PlanTypeEnumMap, json['type']),
          appliedCommunityId: json['appliedCommunityId'] as String,
          returnRedirectPath: json['returnRedirectPath'] as String,
        );

Map<String, dynamic> _$$_CreateSubscriptionCheckoutSessionRequestToJson(
        _$_CreateSubscriptionCheckoutSessionRequest instance) =>
    <String, dynamic>{
      'type': _$PlanTypeEnumMap[instance.type]!,
      'appliedCommunityId': instance.appliedCommunityId,
      'returnRedirectPath': instance.returnRedirectPath,
    };

const _$PlanTypeEnumMap = {
  PlanType.individual: 'individual',
  PlanType.club: 'club',
  PlanType.pro: 'pro',
  PlanType.unrestricted: 'unrestricted',
};

_$__$CreateSubscriptionCheckoutSessionResponse
    _$$__$CreateSubscriptionCheckoutSessionResponseFromJson(
            Map<String, dynamic> json) =>
        _$__$CreateSubscriptionCheckoutSessionResponse(
          sessionId: json['sessionId'] as String,
        );

Map<String, dynamic> _$$__$CreateSubscriptionCheckoutSessionResponseToJson(
        _$__$CreateSubscriptionCheckoutSessionResponse instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
    };

_$_CreateStripeConnectedAccountRequest
    _$$_CreateStripeConnectedAccountRequestFromJson(
            Map<String, dynamic> json) =>
        _$_CreateStripeConnectedAccountRequest(
          agreementId: json['agreementId'] as String,
        );

Map<String, dynamic> _$$_CreateStripeConnectedAccountRequestToJson(
        _$_CreateStripeConnectedAccountRequest instance) =>
    <String, dynamic>{
      'agreementId': instance.agreementId,
    };

_$_EmailEventReminderRequest _$$_EmailEventReminderRequestFromJson(
        Map<String, dynamic> json) =>
    _$_EmailEventReminderRequest(
      communityId: json['communityId'] as String,
      templateId: json['templateId'] as String,
      eventId: json['eventId'] as String,
      eventEmailType:
          $enumDecodeNullable(_$EventEmailTypeEnumMap, json['eventEmailType']),
    );

Map<String, dynamic> _$$_EmailEventReminderRequestToJson(
        _$_EmailEventReminderRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'templateId': instance.templateId,
      'eventId': instance.eventId,
      'eventEmailType': _$EventEmailTypeEnumMap[instance.eventEmailType],
    };

const _$EventEmailTypeEnumMap = {
  EventEmailType.initialSignUp: 'initialSignUp',
  EventEmailType.oneDayReminder: 'oneDayReminder',
  EventEmailType.oneHourReminder: 'oneHourReminder',
  EventEmailType.updated: 'updated',
  EventEmailType.canceled: 'canceled',
  EventEmailType.ended: 'ended',
};

_$_ExtendCloudTaskSchedulerRequest _$$_ExtendCloudTaskSchedulerRequestFromJson(
        Map<String, dynamic> json) =>
    _$_ExtendCloudTaskSchedulerRequest(
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      functionName: json['functionName'] as String,
      payload: json['payload'] as String,
    );

Map<String, dynamic> _$$_ExtendCloudTaskSchedulerRequestToJson(
        _$_ExtendCloudTaskSchedulerRequest instance) =>
    <String, dynamic>{
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'functionName': instance.functionName,
      'payload': instance.payload,
    };

_$_CommunityUserInfo _$$_CommunityUserInfoFromJson(Map<String, dynamic> json) =>
    _$_CommunityUserInfo(
      id: json['id'] as String,
      photoURL: json['photoURL'] as String,
      displayName: json['displayName'] as String,
    );

Map<String, dynamic> _$$_CommunityUserInfoToJson(
        _$_CommunityUserInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'photoURL': instance.photoURL,
      'displayName': instance.displayName,
    };

_$_SendGridEmail _$$_SendGridEmailFromJson(Map<String, dynamic> json) =>
    _$_SendGridEmail(
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      from: json['from'] as String,
      message: SendGridEmailMessage.fromJson(
          json['message'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_SendGridEmailToJson(_$_SendGridEmail instance) =>
    <String, dynamic>{
      'to': instance.to,
      'from': instance.from,
      'message': instance.message.toJson(),
    };

_$_EmailAttachment _$$_EmailAttachmentFromJson(Map<String, dynamic> json) =>
    _$_EmailAttachment(
      filename: json['filename'] as String,
      content: json['content'] as String,
      contentType: json['contentType'] as String,
    );

Map<String, dynamic> _$$_EmailAttachmentToJson(_$_EmailAttachment instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'content': instance.content,
      'contentType': instance.contentType,
    };

_$_SendGridEmailMessage _$$_SendGridEmailMessageFromJson(
        Map<String, dynamic> json) =>
    _$_SendGridEmailMessage(
      subject: json['subject'] as String,
      html: json['html'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => EmailAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_SendGridEmailMessageToJson(
        _$_SendGridEmailMessage instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'html': instance.html,
      'attachments': instance.attachments?.map((e) => e.toJson()).toList(),
    };

_$_GetServerTimestampRequest _$$_GetServerTimestampRequestFromJson(
        Map<String, dynamic> json) =>
    _$_GetServerTimestampRequest();

Map<String, dynamic> _$$_GetServerTimestampRequestToJson(
        _$_GetServerTimestampRequest instance) =>
    <String, dynamic>{};

_$_GetServerTimestampResponse _$$_GetServerTimestampResponseFromJson(
        Map<String, dynamic> json) =>
    _$_GetServerTimestampResponse(
      serverTimestamp: DateTime.parse(json['serverTimestamp'] as String),
    );

Map<String, dynamic> _$$_GetServerTimestampResponseToJson(
        _$_GetServerTimestampResponse instance) =>
    <String, dynamic>{
      'serverTimestamp': instance.serverTimestamp.toIso8601String(),
    };

_$_GetTwilioMeetingJoinInfoRequest _$$_GetTwilioMeetingJoinInfoRequestFromJson(
        Map<String, dynamic> json) =>
    _$_GetTwilioMeetingJoinInfoRequest(
      eventPath: json['eventPath'] as String,
    );

Map<String, dynamic> _$$_GetTwilioMeetingJoinInfoRequestToJson(
        _$_GetTwilioMeetingJoinInfoRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
    };

_$_GetMeetingJoinInfoRequest _$$_GetMeetingJoinInfoRequestFromJson(
        Map<String, dynamic> json) =>
    _$_GetMeetingJoinInfoRequest(
      eventPath: json['eventPath'] as String,
      externalCommunityId: json['externalCommunityId'] as String?,
    );

Map<String, dynamic> _$$_GetMeetingJoinInfoRequestToJson(
        _$_GetMeetingJoinInfoRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
      'externalCommunityId': instance.externalCommunityId,
    };

_$_GetMeetingJoinInfoResponse _$$_GetMeetingJoinInfoResponseFromJson(
        Map<String, dynamic> json) =>
    _$_GetMeetingJoinInfoResponse(
      identity: json['identity'] as String,
      meetingToken: json['meetingToken'] as String,
      meetingId: json['meetingId'] as String,
    );

Map<String, dynamic> _$$_GetMeetingJoinInfoResponseToJson(
        _$_GetMeetingJoinInfoResponse instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'meetingToken': instance.meetingToken,
      'meetingId': instance.meetingId,
    };

_$_GetInstantMeetingJoinInfoRequest
    _$$_GetInstantMeetingJoinInfoRequestFromJson(Map<String, dynamic> json) =>
        _$_GetInstantMeetingJoinInfoRequest(
          communityId: json['communityId'] as String,
          meetingId: json['meetingId'] as String,
          userIdentifier: json['userIdentifier'] as String,
          userDisplayName: json['userDisplayName'] as String,
          record: json['record'] as bool,
        );

Map<String, dynamic> _$$_GetInstantMeetingJoinInfoRequestToJson(
        _$_GetInstantMeetingJoinInfoRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'meetingId': instance.meetingId,
      'userIdentifier': instance.userIdentifier,
      'userDisplayName': instance.userDisplayName,
      'record': instance.record,
    };

_$_GetUserAdminDetailsRequest _$$_GetUserAdminDetailsRequestFromJson(
        Map<String, dynamic> json) =>
    _$_GetUserAdminDetailsRequest(
      userIds:
          (json['userIds'] as List<dynamic>).map((e) => e as String).toList(),
      communityId: json['communityId'] as String?,
      eventPath: json['eventPath'] as String?,
    );

Map<String, dynamic> _$$_GetUserAdminDetailsRequestToJson(
        _$_GetUserAdminDetailsRequest instance) =>
    <String, dynamic>{
      'userIds': instance.userIds,
      'communityId': instance.communityId,
      'eventPath': instance.eventPath,
    };

_$_GetUserAdminDetailsResponse _$$_GetUserAdminDetailsResponseFromJson(
        Map<String, dynamic> json) =>
    _$_GetUserAdminDetailsResponse(
      userAdminDetails: (json['userAdminDetails'] as List<dynamic>)
          .map((e) => UserAdminDetails.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_GetUserAdminDetailsResponseToJson(
        _$_GetUserAdminDetailsResponse instance) =>
    <String, dynamic>{
      'userAdminDetails':
          instance.userAdminDetails.map((e) => e.toJson()).toList(),
    };

_$_GetMeetingChatsSuggestionsDataRequest
    _$$_GetMeetingChatsSuggestionsDataRequestFromJson(
            Map<String, dynamic> json) =>
        _$_GetMeetingChatsSuggestionsDataRequest(
          eventPath: json['eventPath'] as String,
        );

Map<String, dynamic> _$$_GetMeetingChatsSuggestionsDataRequestToJson(
        _$_GetMeetingChatsSuggestionsDataRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
    };

_$_GetMeetingChatsSuggestionsDataResponse
    _$$_GetMeetingChatsSuggestionsDataResponseFromJson(
            Map<String, dynamic> json) =>
        _$_GetMeetingChatsSuggestionsDataResponse(
          chatsSuggestionsList: (json['chatsSuggestionsList'] as List<dynamic>?)
              ?.map(
                  (e) => ChatSuggestionData.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic> _$$_GetMeetingChatsSuggestionsDataResponseToJson(
        _$_GetMeetingChatsSuggestionsDataResponse instance) =>
    <String, dynamic>{
      'chatsSuggestionsList':
          instance.chatsSuggestionsList?.map((e) => e.toJson()).toList(),
    };

_$_GetMembersDataRequest _$$_GetMembersDataRequestFromJson(
        Map<String, dynamic> json) =>
    _$_GetMembersDataRequest(
      communityId: json['communityId'] as String,
      userIds:
          (json['userIds'] as List<dynamic>).map((e) => e as String).toList(),
      eventPath: json['eventPath'] as String?,
    );

Map<String, dynamic> _$$_GetMembersDataRequestToJson(
        _$_GetMembersDataRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'userIds': instance.userIds,
      'eventPath': instance.eventPath,
    };

_$_GetMembersDataResponse _$$_GetMembersDataResponseFromJson(
        Map<String, dynamic> json) =>
    _$_GetMembersDataResponse(
      membersDetailsList: (json['membersDetailsList'] as List<dynamic>?)
          ?.map((e) => MemberDetails.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_GetMembersDataResponseToJson(
        _$_GetMembersDataResponse instance) =>
    <String, dynamic>{
      'membersDetailsList':
          instance.membersDetailsList?.map((e) => e.toJson()).toList(),
    };

_$_UserAdminDetails _$$_UserAdminDetailsFromJson(Map<String, dynamic> json) =>
    _$_UserAdminDetails(
      userId: json['userId'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$$_UserAdminDetailsToJson(_$_UserAdminDetails instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
    };

_$_CreateLiveStreamRequest _$$_CreateLiveStreamRequestFromJson(
        Map<String, dynamic> json) =>
    _$_CreateLiveStreamRequest(
      communityId: json['communityId'] as String,
    );

Map<String, dynamic> _$$_CreateLiveStreamRequestToJson(
        _$_CreateLiveStreamRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

_$_CreateLiveStreamResponse _$$_CreateLiveStreamResponseFromJson(
        Map<String, dynamic> json) =>
    _$_CreateLiveStreamResponse(
      muxId: json['muxId'] as String,
      muxPlaybackId: json['muxPlaybackId'] as String,
      streamServerUrl: json['streamServerUrl'] as String,
      streamKey: json['streamKey'] as String,
    );

Map<String, dynamic> _$$_CreateLiveStreamResponseToJson(
        _$_CreateLiveStreamResponse instance) =>
    <String, dynamic>{
      'muxId': instance.muxId,
      'muxPlaybackId': instance.muxPlaybackId,
      'streamServerUrl': instance.streamServerUrl,
      'streamKey': instance.streamKey,
    };

_$_GetBreakoutRoomJoinInfoRequest _$$_GetBreakoutRoomJoinInfoRequestFromJson(
        Map<String, dynamic> json) =>
    _$_GetBreakoutRoomJoinInfoRequest(
      eventId: json['eventId'] as String,
      eventPath: json['eventPath'] as String,
      breakoutRoomId: json['breakoutRoomId'] as String,
      enableAudio: json['enableAudio'] as bool,
      enableVideo: json['enableVideo'] as bool,
    );

Map<String, dynamic> _$$_GetBreakoutRoomJoinInfoRequestToJson(
        _$_GetBreakoutRoomJoinInfoRequest instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'eventPath': instance.eventPath,
      'breakoutRoomId': instance.breakoutRoomId,
      'enableAudio': instance.enableAudio,
      'enableVideo': instance.enableVideo,
    };

_$_GetBreakoutRoomAssignmentRequest
    _$$_GetBreakoutRoomAssignmentRequestFromJson(Map<String, dynamic> json) =>
        _$_GetBreakoutRoomAssignmentRequest(
          eventId: json['eventId'] as String,
          eventPath: json['eventPath'] as String,
        );

Map<String, dynamic> _$$_GetBreakoutRoomAssignmentRequestToJson(
        _$_GetBreakoutRoomAssignmentRequest instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'eventPath': instance.eventPath,
    };

_$_GetBreakoutRoomAssignmentResponse
    _$$_GetBreakoutRoomAssignmentResponseFromJson(Map<String, dynamic> json) =>
        _$_GetBreakoutRoomAssignmentResponse(
          roomId: json['roomId'] as String?,
        );

Map<String, dynamic> _$$_GetBreakoutRoomAssignmentResponseToJson(
        _$_GetBreakoutRoomAssignmentResponse instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
    };

_$_GetHelpInMeetingRequest _$$_GetHelpInMeetingRequestFromJson(
        Map<String, dynamic> json) =>
    _$_GetHelpInMeetingRequest(
      eventPath: json['eventPath'] as String,
      externalCommunityId: json['externalCommunityId'] as String,
    );

Map<String, dynamic> _$$_GetHelpInMeetingRequestToJson(
        _$_GetHelpInMeetingRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
      'externalCommunityId': instance.externalCommunityId,
    };

_$_GenerateTwilioCompositionRequest
    _$$_GenerateTwilioCompositionRequestFromJson(Map<String, dynamic> json) =>
        _$_GenerateTwilioCompositionRequest(
          eventPath: json['eventPath'] as String,
        );

Map<String, dynamic> _$$_GenerateTwilioCompositionRequestToJson(
        _$_GenerateTwilioCompositionRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
    };

_$_DownloadTwilioCompositionRequest
    _$$_DownloadTwilioCompositionRequestFromJson(Map<String, dynamic> json) =>
        _$_DownloadTwilioCompositionRequest(
          eventPath: json['eventPath'] as String,
        );

Map<String, dynamic> _$$_DownloadTwilioCompositionRequestToJson(
        _$_DownloadTwilioCompositionRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
    };

_$_DownloadTwilioCompositionResponse
    _$$_DownloadTwilioCompositionResponseFromJson(Map<String, dynamic> json) =>
        _$_DownloadTwilioCompositionResponse(
          redirectUrl: json['redirectUrl'] as String,
        );

Map<String, dynamic> _$$_DownloadTwilioCompositionResponseToJson(
        _$_DownloadTwilioCompositionResponse instance) =>
    <String, dynamic>{
      'redirectUrl': instance.redirectUrl,
    };

_$_KickParticipantRequest _$$_KickParticipantRequestFromJson(
        Map<String, dynamic> json) =>
    _$_KickParticipantRequest(
      userToKickId: json['userToKickId'] as String,
      eventPath: json['eventPath'] as String,
      breakoutRoomId: json['breakoutRoomId'] as String?,
    );

Map<String, dynamic> _$$_KickParticipantRequestToJson(
        _$_KickParticipantRequest instance) =>
    <String, dynamic>{
      'userToKickId': instance.userToKickId,
      'eventPath': instance.eventPath,
      'breakoutRoomId': instance.breakoutRoomId,
    };

_$_ResolveJoinRequestRequest _$$_ResolveJoinRequestRequestFromJson(
        Map<String, dynamic> json) =>
    _$_ResolveJoinRequestRequest(
      communityId: json['communityId'] as String,
      userId: json['userId'] as String,
      approve: json['approve'] as bool,
    );

Map<String, dynamic> _$$_ResolveJoinRequestRequestToJson(
        _$_ResolveJoinRequestRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'userId': instance.userId,
      'approve': instance.approve,
    };

_$_InitiateBreakoutsRequest _$$_InitiateBreakoutsRequestFromJson(
        Map<String, dynamic> json) =>
    _$_InitiateBreakoutsRequest(
      eventPath: json['eventPath'] as String,
      targetParticipantsPerRoom: json['targetParticipantsPerRoom'] as int,
      breakoutSessionId: json['breakoutSessionId'] as String,
      assignmentMethod: $enumDecodeNullable(
          _$BreakoutAssignmentMethodEnumMap, json['assignmentMethod']),
      includeWaitingRoom: json['includeWaitingRoom'] as bool? ?? false,
    );

Map<String, dynamic> _$$_InitiateBreakoutsRequestToJson(
        _$_InitiateBreakoutsRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
      'targetParticipantsPerRoom': instance.targetParticipantsPerRoom,
      'breakoutSessionId': instance.breakoutSessionId,
      'assignmentMethod':
          _$BreakoutAssignmentMethodEnumMap[instance.assignmentMethod],
      'includeWaitingRoom': instance.includeWaitingRoom,
    };

const _$BreakoutAssignmentMethodEnumMap = {
  BreakoutAssignmentMethod.targetPerRoom: 'targetPerRoom',
  BreakoutAssignmentMethod.smartMatch: 'smartMatch',
  BreakoutAssignmentMethod.category: 'category',
};

_$_InitiateBreakoutsResponse _$$_InitiateBreakoutsResponseFromJson(
        Map<String, dynamic> json) =>
    _$_InitiateBreakoutsResponse(
      breakoutSessionId: json['breakoutSessionId'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
    );

Map<String, dynamic> _$$_InitiateBreakoutsResponseToJson(
        _$_InitiateBreakoutsResponse instance) =>
    <String, dynamic>{
      'breakoutSessionId': instance.breakoutSessionId,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
    };

_$_ReassignBreakoutRoomRequest _$$_ReassignBreakoutRoomRequestFromJson(
        Map<String, dynamic> json) =>
    _$_ReassignBreakoutRoomRequest(
      eventPath: json['eventPath'] as String,
      breakoutRoomSessionId: json['breakoutRoomSessionId'] as String,
      userId: json['userId'] as String,
      newRoomNumber: json['newRoomNumber'] as String?,
    );

Map<String, dynamic> _$$_ReassignBreakoutRoomRequestToJson(
        _$_ReassignBreakoutRoomRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
      'breakoutRoomSessionId': instance.breakoutRoomSessionId,
      'userId': instance.userId,
      'newRoomNumber': instance.newRoomNumber,
    };

_$_UpdateBreakoutRoomFlagStatusRequest
    _$$_UpdateBreakoutRoomFlagStatusRequestFromJson(
            Map<String, dynamic> json) =>
        _$_UpdateBreakoutRoomFlagStatusRequest(
          eventPath: json['eventPath'] as String,
          breakoutSessionId: json['breakoutSessionId'] as String,
          roomId: json['roomId'] as String,
          flagStatus: $enumDecodeNullable(
              _$BreakoutRoomFlagStatusEnumMap, json['flagStatus']),
        );

Map<String, dynamic> _$$_UpdateBreakoutRoomFlagStatusRequestToJson(
        _$_UpdateBreakoutRoomFlagStatusRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
      'breakoutSessionId': instance.breakoutSessionId,
      'roomId': instance.roomId,
      'flagStatus': _$BreakoutRoomFlagStatusEnumMap[instance.flagStatus],
    };

const _$BreakoutRoomFlagStatusEnumMap = {
  BreakoutRoomFlagStatus.unflagged: 'unflagged',
  BreakoutRoomFlagStatus.needsHelp: 'needsHelp',
};

_$_CreateCommunityRequest _$$_CreateCommunityRequestFromJson(
        Map<String, dynamic> json) =>
    _$_CreateCommunityRequest(
      community: json['community'] == null
          ? null
          : Community.fromJson(json['community'] as Map<String, dynamic>),
      agreementId: json['agreementId'] as String?,
    );

Map<String, dynamic> _$$_CreateCommunityRequestToJson(
        _$_CreateCommunityRequest instance) =>
    <String, dynamic>{
      'community': Community.toJsonForCloudFunction(instance.community),
      'agreementId': instance.agreementId,
    };

_$_CreateCommunityResponse _$$_CreateCommunityResponseFromJson(
        Map<String, dynamic> json) =>
    _$_CreateCommunityResponse(
      communityId: json['communityId'] as String,
    );

Map<String, dynamic> _$$_CreateCommunityResponseToJson(
        _$_CreateCommunityResponse instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

_$_UpdateCommunityRequest _$$_UpdateCommunityRequestFromJson(
        Map<String, dynamic> json) =>
    _$_UpdateCommunityRequest(
      community: Community.fromJson(json['community'] as Map<String, dynamic>),
      keys: (json['keys'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$_UpdateCommunityRequestToJson(
        _$_UpdateCommunityRequest instance) =>
    <String, dynamic>{
      'community': Community.toJsonForCloudFunction(instance.community),
      'keys': instance.keys,
    };

_$_GetCommunityCapabilitiesRequest _$$_GetCommunityCapabilitiesRequestFromJson(
        Map<String, dynamic> json) =>
    _$_GetCommunityCapabilitiesRequest(
      communityId: json['communityId'] as String,
    );

Map<String, dynamic> _$$_GetCommunityCapabilitiesRequestToJson(
        _$_GetCommunityCapabilitiesRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

_$_GetStripeBillingPortalLinkRequest
    _$$_GetStripeBillingPortalLinkRequestFromJson(Map<String, dynamic> json) =>
        _$_GetStripeBillingPortalLinkRequest(
          responsePath: json['responsePath'] as String,
        );

Map<String, dynamic> _$$_GetStripeBillingPortalLinkRequestToJson(
        _$_GetStripeBillingPortalLinkRequest instance) =>
    <String, dynamic>{
      'responsePath': instance.responsePath,
    };

_$_GetStripeBillingPortalLinkResponse
    _$$_GetStripeBillingPortalLinkResponseFromJson(Map<String, dynamic> json) =>
        _$_GetStripeBillingPortalLinkResponse(
          url: json['url'] as String,
        );

Map<String, dynamic> _$$_GetStripeBillingPortalLinkResponseToJson(
        _$_GetStripeBillingPortalLinkResponse instance) =>
    <String, dynamic>{
      'url': instance.url,
    };

_$_GetStripeConnectedAccountLinkRequest
    _$$_GetStripeConnectedAccountLinkRequestFromJson(
            Map<String, dynamic> json) =>
        _$_GetStripeConnectedAccountLinkRequest(
          agreementId: json['agreementId'] as String,
          responsePath: json['responsePath'] as String,
        );

Map<String, dynamic> _$$_GetStripeConnectedAccountLinkRequestToJson(
        _$_GetStripeConnectedAccountLinkRequest instance) =>
    <String, dynamic>{
      'agreementId': instance.agreementId,
      'responsePath': instance.responsePath,
    };

_$_GetStripeConnectedAccountLinkResponse
    _$$_GetStripeConnectedAccountLinkResponseFromJson(
            Map<String, dynamic> json) =>
        _$_GetStripeConnectedAccountLinkResponse(
          url: json['url'] as String,
        );

Map<String, dynamic> _$$_GetStripeConnectedAccountLinkResponseToJson(
        _$_GetStripeConnectedAccountLinkResponse instance) =>
    <String, dynamic>{
      'url': instance.url,
    };

_$_UnsubscribeFromCommunityNotificationsRequest
    _$$_UnsubscribeFromCommunityNotificationsRequestFromJson(
            Map<String, dynamic> json) =>
        _$_UnsubscribeFromCommunityNotificationsRequest(
          data: json['data'] as String,
        );

Map<String, dynamic> _$$_UnsubscribeFromCommunityNotificationsRequestToJson(
        _$_UnsubscribeFromCommunityNotificationsRequest instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

_$_CheckAdvanceMeetingGuideRequest _$$_CheckAdvanceMeetingGuideRequestFromJson(
        Map<String, dynamic> json) =>
    _$_CheckAdvanceMeetingGuideRequest(
      eventPath: json['eventPath'] as String,
      breakoutSessionId: json['breakoutSessionId'] as String?,
      breakoutRoomId: json['breakoutRoomId'] as String?,
      presentIds: (json['presentIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      userReadyAgendaId: json['userReadyAgendaId'] as String?,
    );

Map<String, dynamic> _$$_CheckAdvanceMeetingGuideRequestToJson(
        _$_CheckAdvanceMeetingGuideRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
      'breakoutSessionId': instance.breakoutSessionId,
      'breakoutRoomId': instance.breakoutRoomId,
      'presentIds': instance.presentIds,
      'userReadyAgendaId': instance.userReadyAgendaId,
    };

_$_CheckHostlessGoToBreakoutsRequest
    _$$_CheckHostlessGoToBreakoutsRequestFromJson(Map<String, dynamic> json) =>
        _$_CheckHostlessGoToBreakoutsRequest(
          eventPath: json['eventPath'] as String,
        );

Map<String, dynamic> _$$_CheckHostlessGoToBreakoutsRequestToJson(
        _$_CheckHostlessGoToBreakoutsRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
    };

_$_CheckAssignToBreakoutsRequest _$$_CheckAssignToBreakoutsRequestFromJson(
        Map<String, dynamic> json) =>
    _$_CheckAssignToBreakoutsRequest(
      eventPath: json['eventPath'] as String,
      breakoutSessionId: json['breakoutSessionId'] as String,
    );

Map<String, dynamic> _$$_CheckAssignToBreakoutsRequestToJson(
        _$_CheckAssignToBreakoutsRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
      'breakoutSessionId': instance.breakoutSessionId,
    };

_$_ResetParticipantAgendaItemsRequest
    _$$_ResetParticipantAgendaItemsRequestFromJson(Map<String, dynamic> json) =>
        _$_ResetParticipantAgendaItemsRequest(
          liveMeetingPath: json['liveMeetingPath'] as String,
        );

Map<String, dynamic> _$$_ResetParticipantAgendaItemsRequestToJson(
        _$_ResetParticipantAgendaItemsRequest instance) =>
    <String, dynamic>{
      'liveMeetingPath': instance.liveMeetingPath,
    };

_$_UpdateMembershipRequest _$$_UpdateMembershipRequestFromJson(
        Map<String, dynamic> json) =>
    _$_UpdateMembershipRequest(
      userId: json['userId'] as String,
      communityId: json['communityId'] as String,
      status: $enumDecodeNullable(_$MembershipStatusEnumMap, json['status']),
      invisible: json['invisible'] as bool?,
    );

Map<String, dynamic> _$$_UpdateMembershipRequestToJson(
        _$_UpdateMembershipRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'communityId': instance.communityId,
      'status': _$MembershipStatusEnumMap[instance.status],
      'invisible': instance.invisible,
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

_$_VoteToKickRequest _$$_VoteToKickRequestFromJson(Map<String, dynamic> json) =>
    _$_VoteToKickRequest(
      targetUserId: json['targetUserId'] as String,
      eventPath: json['eventPath'] as String,
      liveMeetingPath: json['liveMeetingPath'] as String,
      inFavor: json['inFavor'] as bool,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$_VoteToKickRequestToJson(
        _$_VoteToKickRequest instance) =>
    <String, dynamic>{
      'targetUserId': instance.targetUserId,
      'eventPath': instance.eventPath,
      'liveMeetingPath': instance.liveMeetingPath,
      'inFavor': instance.inFavor,
      'reason': instance.reason,
    };

_$_EventEndedRequest _$$_EventEndedRequestFromJson(Map<String, dynamic> json) =>
    _$_EventEndedRequest(
      eventPath: json['eventPath'] as String,
    );

Map<String, dynamic> _$$_EventEndedRequestToJson(
        _$_EventEndedRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
    };

_$_GetCommunityDonationsEnabledRequest
    _$$_GetCommunityDonationsEnabledRequestFromJson(
            Map<String, dynamic> json) =>
        _$_GetCommunityDonationsEnabledRequest(
          communityId: json['communityId'] as String,
        );

Map<String, dynamic> _$$_GetCommunityDonationsEnabledRequestToJson(
        _$_GetCommunityDonationsEnabledRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

_$_GetCommunityDonationsEnabledResponse
    _$$_GetCommunityDonationsEnabledResponseFromJson(
            Map<String, dynamic> json) =>
        _$_GetCommunityDonationsEnabledResponse(
          donationsEnabled: json['donationsEnabled'] as bool,
        );

Map<String, dynamic> _$$_GetCommunityDonationsEnabledResponseToJson(
        _$_GetCommunityDonationsEnabledResponse instance) =>
    <String, dynamic>{
      'donationsEnabled': instance.donationsEnabled,
    };

_$_GetCommunityPrePostEnabledRequest
    _$$_GetCommunityPrePostEnabledRequestFromJson(Map<String, dynamic> json) =>
        _$_GetCommunityPrePostEnabledRequest(
          communityId: json['communityId'] as String,
        );

Map<String, dynamic> _$$_GetCommunityPrePostEnabledRequestToJson(
        _$_GetCommunityPrePostEnabledRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

_$_GetCommunityPrePostEnabledResponse
    _$$_GetCommunityPrePostEnabledResponseFromJson(Map<String, dynamic> json) =>
        _$_GetCommunityPrePostEnabledResponse(
          prePostEnabled: json['prePostEnabled'] as bool,
        );

Map<String, dynamic> _$$_GetCommunityPrePostEnabledResponseToJson(
        _$_GetCommunityPrePostEnabledResponse instance) =>
    <String, dynamic>{
      'prePostEnabled': instance.prePostEnabled,
    };

_$_UpdateStripeSubscriptionPlanRequest
    _$$_UpdateStripeSubscriptionPlanRequestFromJson(
            Map<String, dynamic> json) =>
        _$_UpdateStripeSubscriptionPlanRequest(
          communityId: json['communityId'] as String,
          stripePriceId: json['stripePriceId'] as String,
          type: $enumDecode(_$PlanTypeEnumMap, json['type']),
        );

Map<String, dynamic> _$$_UpdateStripeSubscriptionPlanRequestToJson(
        _$_UpdateStripeSubscriptionPlanRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'stripePriceId': instance.stripePriceId,
      'type': _$PlanTypeEnumMap[instance.type]!,
    };

_$_CancelStripeSubscriptionPlanRequest
    _$$_CancelStripeSubscriptionPlanRequestFromJson(
            Map<String, dynamic> json) =>
        _$_CancelStripeSubscriptionPlanRequest(
          communityId: json['communityId'] as String,
        );

Map<String, dynamic> _$$_CancelStripeSubscriptionPlanRequestToJson(
        _$_CancelStripeSubscriptionPlanRequest instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

_$_GetStripeSubscriptionPlanInfoRequest
    _$$_GetStripeSubscriptionPlanInfoRequestFromJson(
            Map<String, dynamic> json) =>
        _$_GetStripeSubscriptionPlanInfoRequest(
          type: $enumDecode(_$PlanTypeEnumMap, json['type']),
        );

Map<String, dynamic> _$$_GetStripeSubscriptionPlanInfoRequestToJson(
        _$_GetStripeSubscriptionPlanInfoRequest instance) =>
    <String, dynamic>{
      'type': _$PlanTypeEnumMap[instance.type]!,
    };

_$_GetStripeSubscriptionPlanInfoResponse
    _$$_GetStripeSubscriptionPlanInfoResponseFromJson(
            Map<String, dynamic> json) =>
        _$_GetStripeSubscriptionPlanInfoResponse(
          plan: $enumDecode(_$PlanTypeEnumMap, json['plan']),
          priceInCents: json['priceInCents'] as int,
          stripePriceId: json['stripePriceId'] as String,
          name: json['name'] as String,
        );

Map<String, dynamic> _$$_GetStripeSubscriptionPlanInfoResponseToJson(
        _$_GetStripeSubscriptionPlanInfoResponse instance) =>
    <String, dynamic>{
      'plan': _$PlanTypeEnumMap[instance.plan]!,
      'priceInCents': instance.priceInCents,
      'stripePriceId': instance.stripePriceId,
      'name': instance.name,
    };

_$_GetCommunityCalendarLinkRequest _$$_GetCommunityCalendarLinkRequestFromJson(
        Map<String, dynamic> json) =>
    _$_GetCommunityCalendarLinkRequest(
      eventPath: json['eventPath'] as String,
    );

Map<String, dynamic> _$$_GetCommunityCalendarLinkRequestToJson(
        _$_GetCommunityCalendarLinkRequest instance) =>
    <String, dynamic>{
      'eventPath': instance.eventPath,
    };

_$_GetCommunityCalendarLinkResponse
    _$$_GetCommunityCalendarLinkResponseFromJson(Map<String, dynamic> json) =>
        _$_GetCommunityCalendarLinkResponse(
          googleCalendarLink: json['googleCalendarLink'] as String,
          outlookCalendarLink: json['outlookCalendarLink'] as String,
          office365CalendarLink: json['office365CalendarLink'] as String,
          icsLink: json['icsLink'] as String,
        );

Map<String, dynamic> _$$_GetCommunityCalendarLinkResponseToJson(
        _$_GetCommunityCalendarLinkResponse instance) =>
    <String, dynamic>{
      'googleCalendarLink': instance.googleCalendarLink,
      'outlookCalendarLink': instance.outlookCalendarLink,
      'office365CalendarLink': instance.office365CalendarLink,
      'icsLink': instance.icsLink,
    };

_$_GetUserIdFromAgoraIdRequest _$$_GetUserIdFromAgoraIdRequestFromJson(
        Map<String, dynamic> json) =>
    _$_GetUserIdFromAgoraIdRequest(
      agoraId: json['agoraId'] as int,
    );

Map<String, dynamic> _$$_GetUserIdFromAgoraIdRequestToJson(
        _$_GetUserIdFromAgoraIdRequest instance) =>
    <String, dynamic>{
      'agoraId': instance.agoraId,
    };

_$_GetUserIdFromAgoraIdResponse _$$_GetUserIdFromAgoraIdResponseFromJson(
        Map<String, dynamic> json) =>
    _$_GetUserIdFromAgoraIdResponse(
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$_GetUserIdFromAgoraIdResponseToJson(
        _$_GetUserIdFromAgoraIdResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
    };
