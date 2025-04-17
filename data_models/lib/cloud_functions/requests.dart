import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/announcements/announcement.dart';
import 'package:data_models/chat/chat_suggestion_data.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/event_message.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/community/member_details.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/admin/plan_capability_list.dart';

part 'requests.freezed.dart';
part 'requests.g.dart';

class SerializeableRequest {
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateEventRequest
    with _$CreateEventRequest
    implements SerializeableRequest {
  static const functionName = 'createEvent';

  factory CreateEventRequest({
    required String eventPath,
  }) = _CreateEventRequest;

  factory CreateEventRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateEventRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateAnnouncementRequest
    with _$CreateAnnouncementRequest
    implements SerializeableRequest {
  factory CreateAnnouncementRequest({
    required String communityId,
    @JsonKey(toJson: Announcement.toJsonForCloudFunction)
    Announcement? announcement,
  }) = _CreateAnnouncementRequest;

  factory CreateAnnouncementRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAnnouncementRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class SendEventMessageRequest
    with _$SendEventMessageRequest
    implements SerializeableRequest {
  factory SendEventMessageRequest({
    required String communityId,
    required String templateId,
    required String eventId,
    @JsonKey(toJson: EventMessage.toJsonForCloudFunction)
    required EventMessage eventMessage,
  }) = _SendEventMessageRequest;

  factory SendEventMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendEventMessageRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateDonationCheckoutSessionRequest
    with _$CreateDonationCheckoutSessionRequest
    implements SerializeableRequest {
  factory CreateDonationCheckoutSessionRequest({
    required String communityId,
    required int amountInCents,
  }) = _CreateDonationCheckoutSessionRequest;

  factory CreateDonationCheckoutSessionRequest.fromJson(
          Map<String, dynamic> json) =>
      _$CreateDonationCheckoutSessionRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateDonationCheckoutSessionResponse
    with _$CreateDonationCheckoutSessionResponse
    implements SerializeableRequest {
  factory CreateDonationCheckoutSessionResponse({
    required String sessionId,
  }) = _CreateDonationCheckoutSessionResponse;

  factory CreateDonationCheckoutSessionResponse.fromJson(
          Map<String, dynamic> json) =>
      _$CreateDonationCheckoutSessionResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateSubscriptionCheckoutSessionRequest
    with _$CreateSubscriptionCheckoutSessionRequest
    implements SerializeableRequest {
  factory CreateSubscriptionCheckoutSessionRequest({
    required PlanType type,
    required String appliedCommunityId,
    required String returnRedirectPath,
  }) = _CreateSubscriptionCheckoutSessionRequest;

  factory CreateSubscriptionCheckoutSessionRequest.fromJson(
          Map<String, dynamic> json) =>
      _$CreateSubscriptionCheckoutSessionRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateSubscriptionCheckoutSessionResponse
    with _$CreateSubscriptionCheckoutSessionResponse
    implements SerializeableRequest {
  factory CreateSubscriptionCheckoutSessionResponse({
    required String sessionId,
  }) = __$CreateSubscriptionCheckoutSessionResponse;

  factory CreateSubscriptionCheckoutSessionResponse.fromJson(
          Map<String, dynamic> json) =>
      _$CreateSubscriptionCheckoutSessionResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateStripeConnectedAccountRequest
    with _$CreateStripeConnectedAccountRequest
    implements SerializeableRequest {
  factory CreateStripeConnectedAccountRequest({
    required String agreementId,
  }) = _CreateStripeConnectedAccountRequest;

  factory CreateStripeConnectedAccountRequest.fromJson(
          Map<String, dynamic> json) =>
      _$CreateStripeConnectedAccountRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class EmailEventReminderRequest
    with _$EmailEventReminderRequest
    implements SerializeableRequest {
  factory EmailEventReminderRequest({
    required String communityId,
    required String templateId,
    required String eventId,
    EventEmailType? eventEmailType,
  }) = _EmailEventReminderRequest;

  factory EmailEventReminderRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailEventReminderRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class ExtendCloudTaskSchedulerRequest
    with _$ExtendCloudTaskSchedulerRequest
    implements SerializeableRequest {
  factory ExtendCloudTaskSchedulerRequest({
    required DateTime scheduledTime,
    required String functionName,
    required String payload,
  }) = _ExtendCloudTaskSchedulerRequest;

  factory ExtendCloudTaskSchedulerRequest.fromJson(Map<String, dynamic> json) =>
      _$ExtendCloudTaskSchedulerRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CommunityUserInfo with _$CommunityUserInfo {
  factory CommunityUserInfo({
    required String id,
    required String photoURL,
    required String displayName,
  }) = _CommunityUserInfo;

  factory CommunityUserInfo.fromJson(Map<String, dynamic> json) =>
      _$CommunityUserInfoFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class SendGridEmail with _$SendGridEmail {
  factory SendGridEmail({
    required List<String> to,
    required String from,
    required SendGridEmailMessage message,
  }) = _SendGridEmail;

  factory SendGridEmail.fromJson(Map<String, dynamic> json) =>
      _$SendGridEmailFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class EmailAttachment with _$EmailAttachment {
  factory EmailAttachment({
    required String filename,
    required String content,
    required String contentType,
  }) = _EmailAttachment;

  factory EmailAttachment.fromJson(Map<String, dynamic> json) =>
      _$EmailAttachmentFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class SendGridEmailMessage with _$SendGridEmailMessage {
  factory SendGridEmailMessage({
    required String subject,
    required String html,
    List<EmailAttachment>? attachments,
  }) = _SendGridEmailMessage;

  factory SendGridEmailMessage.fromJson(Map<String, dynamic> json) =>
      _$SendGridEmailMessageFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetServerTimestampRequest
    with _$GetServerTimestampRequest
    implements SerializeableRequest {
  static const functionName = 'GetServerTimestamp';

  factory GetServerTimestampRequest() = _GetServerTimestampRequest;

  factory GetServerTimestampRequest.fromJson(Map<String, dynamic> json) =>
      _$GetServerTimestampRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetServerTimestampResponse
    with _$GetServerTimestampResponse
    implements SerializeableRequest {
  factory GetServerTimestampResponse({
    required DateTime serverTimestamp,
  }) = _GetServerTimestampResponse;

  factory GetServerTimestampResponse.fromJson(Map<String, dynamic> json) =>
      _$GetServerTimestampResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetTwilioMeetingJoinInfoRequest
    with _$GetTwilioMeetingJoinInfoRequest
    implements SerializeableRequest {
  factory GetTwilioMeetingJoinInfoRequest({
    required String eventPath,
  }) = _GetTwilioMeetingJoinInfoRequest;

  factory GetTwilioMeetingJoinInfoRequest.fromJson(Map<String, dynamic> json) =>
      _$GetTwilioMeetingJoinInfoRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetMeetingJoinInfoRequest
    with _$GetMeetingJoinInfoRequest
    implements SerializeableRequest {
  factory GetMeetingJoinInfoRequest({
    required String eventPath,
    // External ID of this user when provided by communities
    String? externalCommunityId,
  }) = _GetMeetingJoinInfoRequest;

  factory GetMeetingJoinInfoRequest.fromJson(Map<String, dynamic> json) =>
      _$GetMeetingJoinInfoRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetMeetingJoinInfoResponse with _$GetMeetingJoinInfoResponse {
  factory GetMeetingJoinInfoResponse({
    required String identity,
    required String meetingToken,
    required String meetingId,
  }) = _GetMeetingJoinInfoResponse;

  factory GetMeetingJoinInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$GetMeetingJoinInfoResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetInstantMeetingJoinInfoRequest
    with _$GetInstantMeetingJoinInfoRequest
    implements SerializeableRequest {
  factory GetInstantMeetingJoinInfoRequest({
    required String communityId,
    required String meetingId,
    required String userIdentifier,
    required String userDisplayName,
    required bool record,
  }) = _GetInstantMeetingJoinInfoRequest;

  factory GetInstantMeetingJoinInfoRequest.fromJson(
          Map<String, dynamic> json) =>
      _$GetInstantMeetingJoinInfoRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetUserAdminDetailsRequest
    with _$GetUserAdminDetailsRequest
    implements SerializeableRequest {
  factory GetUserAdminDetailsRequest({
    required List<String> userIds,
    String? communityId,
    String? eventPath,
  }) = _GetUserAdminDetailsRequest;

  factory GetUserAdminDetailsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetUserAdminDetailsRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetUserAdminDetailsResponse with _$GetUserAdminDetailsResponse {
  factory GetUserAdminDetailsResponse({
    required List<UserAdminDetails> userAdminDetails,
  }) = _GetUserAdminDetailsResponse;

  factory GetUserAdminDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUserAdminDetailsResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetMeetingChatsSuggestionsDataRequest
    with _$GetMeetingChatsSuggestionsDataRequest
    implements SerializeableRequest {
  factory GetMeetingChatsSuggestionsDataRequest({
    required String eventPath,
  }) = _GetMeetingChatsSuggestionsDataRequest;

  factory GetMeetingChatsSuggestionsDataRequest.fromJson(
          Map<String, dynamic> json) =>
      _$GetMeetingChatsSuggestionsDataRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetMeetingChatsSuggestionsDataResponse
    with _$GetMeetingChatsSuggestionsDataResponse {
  factory GetMeetingChatsSuggestionsDataResponse({
    List<ChatSuggestionData>? chatsSuggestionsList,
  }) = _GetMeetingChatsSuggestionsDataResponse;

  factory GetMeetingChatsSuggestionsDataResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetMeetingChatsSuggestionsDataResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetMembersDataRequest
    with _$GetMembersDataRequest
    implements SerializeableRequest {
  factory GetMembersDataRequest({
    required String communityId,
    required List<String> userIds,
    String? eventPath,
  }) = _GetMembersDataRequest;

  factory GetMembersDataRequest.fromJson(Map<String, dynamic> json) =>
      _$GetMembersDataRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetMembersDataResponse with _$GetMembersDataResponse {
  factory GetMembersDataResponse({
    List<MemberDetails>? membersDetailsList,
  }) = _GetMembersDataResponse;

  factory GetMembersDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetMembersDataResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UserAdminDetails with _$UserAdminDetails {
  factory UserAdminDetails({
    String? userId,
    String? email,
  }) = _UserAdminDetails;

  factory UserAdminDetails.fromJson(Map<String, dynamic> json) =>
      _$UserAdminDetailsFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateLiveStreamRequest
    with _$CreateLiveStreamRequest
    implements SerializeableRequest {
  factory CreateLiveStreamRequest({
    required String communityId,
  }) = _CreateLiveStreamRequest;

  factory CreateLiveStreamRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateLiveStreamRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateLiveStreamResponse
    with _$CreateLiveStreamResponse
    implements SerializeableRequest {
  factory CreateLiveStreamResponse({
    required String muxId,
    required String muxPlaybackId,
    required String streamServerUrl,
    required String streamKey,
  }) = _CreateLiveStreamResponse;

  factory CreateLiveStreamResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateLiveStreamResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetBreakoutRoomJoinInfoRequest
    with _$GetBreakoutRoomJoinInfoRequest
    implements SerializeableRequest {
  factory GetBreakoutRoomJoinInfoRequest({
    required String eventId,
    required String eventPath,
    required String breakoutRoomId,
    required bool enableAudio,
    required bool enableVideo,
  }) = _GetBreakoutRoomJoinInfoRequest;

  factory GetBreakoutRoomJoinInfoRequest.fromJson(Map<String, dynamic> json) =>
      _$GetBreakoutRoomJoinInfoRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetBreakoutRoomAssignmentRequest
    with _$GetBreakoutRoomAssignmentRequest
    implements SerializeableRequest {
  factory GetBreakoutRoomAssignmentRequest({
    required String eventId,
    required String eventPath,
  }) = _GetBreakoutRoomAssignmentRequest;

  factory GetBreakoutRoomAssignmentRequest.fromJson(
          Map<String, dynamic> json) =>
      _$GetBreakoutRoomAssignmentRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetBreakoutRoomAssignmentResponse
    with _$GetBreakoutRoomAssignmentResponse
    implements SerializeableRequest {
  factory GetBreakoutRoomAssignmentResponse({
    required String? roomId,
  }) = _GetBreakoutRoomAssignmentResponse;

  factory GetBreakoutRoomAssignmentResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetBreakoutRoomAssignmentResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetHelpInMeetingRequest
    with _$GetHelpInMeetingRequest
    implements SerializeableRequest {
  factory GetHelpInMeetingRequest({
    required String eventPath,
    required String externalCommunityId,
  }) = _GetHelpInMeetingRequest;

  factory GetHelpInMeetingRequest.fromJson(Map<String, dynamic> json) =>
      _$GetHelpInMeetingRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GenerateTwilioCompositionRequest
    with _$GenerateTwilioCompositionRequest
    implements SerializeableRequest {
  factory GenerateTwilioCompositionRequest({
    required String eventPath,
  }) = _GenerateTwilioCompositionRequest;

  factory GenerateTwilioCompositionRequest.fromJson(
          Map<String, dynamic> json) =>
      _$GenerateTwilioCompositionRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class DownloadTwilioCompositionRequest
    with _$DownloadTwilioCompositionRequest
    implements SerializeableRequest {
  factory DownloadTwilioCompositionRequest({
    required String eventPath,
  }) = _DownloadTwilioCompositionRequest;

  factory DownloadTwilioCompositionRequest.fromJson(
          Map<String, dynamic> json) =>
      _$DownloadTwilioCompositionRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class DownloadTwilioCompositionResponse
    with _$DownloadTwilioCompositionResponse
    implements SerializeableRequest {
  factory DownloadTwilioCompositionResponse({
    required String redirectUrl,
  }) = _DownloadTwilioCompositionResponse;

  factory DownloadTwilioCompositionResponse.fromJson(
          Map<String, dynamic> json) =>
      _$DownloadTwilioCompositionResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class KickParticipantRequest
    with _$KickParticipantRequest
    implements SerializeableRequest {
  factory KickParticipantRequest({
    required String userToKickId,
    required String eventPath,
    String? breakoutRoomId,
  }) = _KickParticipantRequest;

  factory KickParticipantRequest.fromJson(Map<String, dynamic> json) =>
      _$KickParticipantRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class ResolveJoinRequestRequest
    with _$ResolveJoinRequestRequest
    implements SerializeableRequest {
  factory ResolveJoinRequestRequest({
    required String communityId,
    required String userId,
    required bool approve,
  }) = _ResolveJoinRequestRequest;

  factory ResolveJoinRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$ResolveJoinRequestRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class InitiateBreakoutsRequest
    with _$InitiateBreakoutsRequest
    implements SerializeableRequest {
  static const String functionName = 'InitiateBreakouts';

  factory InitiateBreakoutsRequest({
    required String eventPath,
    required int targetParticipantsPerRoom,
    required String breakoutSessionId,
    @JsonKey(unknownEnumValue: null) BreakoutAssignmentMethod? assignmentMethod,
    @Default(false) bool includeWaitingRoom,
  }) = _InitiateBreakoutsRequest;

  factory InitiateBreakoutsRequest.fromJson(Map<String, dynamic> json) =>
      _$InitiateBreakoutsRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class InitiateBreakoutsResponse
    with _$InitiateBreakoutsResponse
    implements SerializeableRequest {
  factory InitiateBreakoutsResponse({
    required String breakoutSessionId,
    required DateTime scheduledTime,
  }) = _InitiateBreakoutsResponse;

  factory InitiateBreakoutsResponse.fromJson(Map<String, dynamic> json) =>
      _$InitiateBreakoutsResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class ReassignBreakoutRoomRequest
    with _$ReassignBreakoutRoomRequest
    implements SerializeableRequest {
  factory ReassignBreakoutRoomRequest({
    required String eventPath,
    required String breakoutRoomSessionId,
    required String userId,

    /// This is a little bit hacky. This can be the waiting room ID constant,
    /// the assign new room ID constant, or the integer room name of the room
    /// being assigned to.
    String? newRoomNumber,
  }) = _ReassignBreakoutRoomRequest;

  factory ReassignBreakoutRoomRequest.fromJson(Map<String, dynamic> json) =>
      _$ReassignBreakoutRoomRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UpdateBreakoutRoomFlagStatusRequest
    with _$UpdateBreakoutRoomFlagStatusRequest
    implements SerializeableRequest {
  factory UpdateBreakoutRoomFlagStatusRequest({
    required String eventPath,
    required String breakoutSessionId,
    required String roomId,
    @JsonKey(unknownEnumValue: null) BreakoutRoomFlagStatus? flagStatus,
  }) = _UpdateBreakoutRoomFlagStatusRequest;

  factory UpdateBreakoutRoomFlagStatusRequest.fromJson(
          Map<String, dynamic> json) =>
      _$UpdateBreakoutRoomFlagStatusRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateCommunityRequest
    with _$CreateCommunityRequest
    implements SerializeableRequest {
  factory CreateCommunityRequest({
    @JsonKey(toJson: Community.toJsonForCloudFunction) Community? community,
    String? agreementId,
  }) = _CreateCommunityRequest;

  factory CreateCommunityRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCommunityRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateCommunityResponse
    with _$CreateCommunityResponse
    implements SerializeableRequest {
  factory CreateCommunityResponse({
    required String communityId,
  }) = _CreateCommunityResponse;

  factory CreateCommunityResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateCommunityResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UpdateCommunityRequest
    with _$UpdateCommunityRequest
    implements SerializeableRequest {
  factory UpdateCommunityRequest({
    @JsonKey(toJson: Community.toJsonForCloudFunction)
    required Community community,
    required List<String> keys,
  }) = _UpdateCommunityRequest;

  factory UpdateCommunityRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommunityRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetCommunityCapabilitiesRequest
    with _$GetCommunityCapabilitiesRequest
    implements SerializeableRequest {
  factory GetCommunityCapabilitiesRequest({
    required String communityId,
  }) = _GetCommunityCapabilitiesRequest;

  factory GetCommunityCapabilitiesRequest.fromJson(Map<String, dynamic> json) =>
      _$GetCommunityCapabilitiesRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetStripeBillingPortalLinkRequest
    with _$GetStripeBillingPortalLinkRequest
    implements SerializeableRequest {
  factory GetStripeBillingPortalLinkRequest({
    required String responsePath,
  }) = _GetStripeBillingPortalLinkRequest;

  factory GetStripeBillingPortalLinkRequest.fromJson(
          Map<String, dynamic> json) =>
      _$GetStripeBillingPortalLinkRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetStripeBillingPortalLinkResponse
    with _$GetStripeBillingPortalLinkResponse
    implements SerializeableRequest {
  factory GetStripeBillingPortalLinkResponse({
    required String url,
  }) = _GetStripeBillingPortalLinkResponse;

  factory GetStripeBillingPortalLinkResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetStripeBillingPortalLinkResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetStripeConnectedAccountLinkRequest
    with _$GetStripeConnectedAccountLinkRequest
    implements SerializeableRequest {
  factory GetStripeConnectedAccountLinkRequest({
    required String agreementId,
    required String responsePath,
  }) = _GetStripeConnectedAccountLinkRequest;

  factory GetStripeConnectedAccountLinkRequest.fromJson(
          Map<String, dynamic> json) =>
      _$GetStripeConnectedAccountLinkRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetStripeConnectedAccountLinkResponse
    with _$GetStripeConnectedAccountLinkResponse
    implements SerializeableRequest {
  factory GetStripeConnectedAccountLinkResponse({
    required String url,
  }) = _GetStripeConnectedAccountLinkResponse;

  factory GetStripeConnectedAccountLinkResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetStripeConnectedAccountLinkResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UnsubscribeFromCommunityNotificationsRequest
    with _$UnsubscribeFromCommunityNotificationsRequest
    implements SerializeableRequest {
  factory UnsubscribeFromCommunityNotificationsRequest({
    required String data,
  }) = _UnsubscribeFromCommunityNotificationsRequest;

  factory UnsubscribeFromCommunityNotificationsRequest.fromJson(
          Map<String, dynamic> json) =>
      _$UnsubscribeFromCommunityNotificationsRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CheckAdvanceMeetingGuideRequest
    with _$CheckAdvanceMeetingGuideRequest
    implements SerializeableRequest {
  factory CheckAdvanceMeetingGuideRequest({
    required String eventPath,
    String? breakoutSessionId,
    String? breakoutRoomId,
    required List<String> presentIds,
    String? userReadyAgendaId,
  }) = _CheckAdvanceMeetingGuideRequest;

  factory CheckAdvanceMeetingGuideRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckAdvanceMeetingGuideRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CheckHostlessGoToBreakoutsRequest
    with _$CheckHostlessGoToBreakoutsRequest
    implements SerializeableRequest {
  static const functionName = 'CheckHostlessGoToBreakouts';

  factory CheckHostlessGoToBreakoutsRequest({
    required String eventPath,
  }) = _CheckHostlessGoToBreakoutsRequest;

  factory CheckHostlessGoToBreakoutsRequest.fromJson(
          Map<String, dynamic> json) =>
      _$CheckHostlessGoToBreakoutsRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CheckAssignToBreakoutsRequest
    with _$CheckAssignToBreakoutsRequest
    implements SerializeableRequest {
  static const functionName = 'CheckAssignToBreakouts';

  factory CheckAssignToBreakoutsRequest({
    required String eventPath,
    required String breakoutSessionId,
  }) = _CheckAssignToBreakoutsRequest;

  factory CheckAssignToBreakoutsRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckAssignToBreakoutsRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class ResetParticipantAgendaItemsRequest
    with _$ResetParticipantAgendaItemsRequest
    implements SerializeableRequest {
  factory ResetParticipantAgendaItemsRequest({
    required String liveMeetingPath,
  }) = _ResetParticipantAgendaItemsRequest;

  factory ResetParticipantAgendaItemsRequest.fromJson(
          Map<String, dynamic> json) =>
      _$ResetParticipantAgendaItemsRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UpdateMembershipRequest
    with _$UpdateMembershipRequest
    implements SerializeableRequest {
  factory UpdateMembershipRequest({
    required String userId,
    required String communityId,
    @JsonKey(unknownEnumValue: null) required MembershipStatus? status,
    bool? invisible,
  }) = _UpdateMembershipRequest;

  factory UpdateMembershipRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMembershipRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class VoteToKickRequest
    with _$VoteToKickRequest
    implements SerializeableRequest {
  factory VoteToKickRequest({
    required String targetUserId,
    required String eventPath,

    /// This can be the path to a live meeting or a breakout room live meeting
    required String liveMeetingPath,
    required bool inFavor,
    String? reason,
  }) = _VoteToKickRequest;

  factory VoteToKickRequest.fromJson(Map<String, dynamic> json) =>
      _$VoteToKickRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class EventEndedRequest
    with _$EventEndedRequest
    implements SerializeableRequest {
  factory EventEndedRequest({
    required String eventPath,
  }) = _EventEndedRequest;

  factory EventEndedRequest.fromJson(Map<String, dynamic> json) =>
      _$EventEndedRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetCommunityDonationsEnabledRequest
    with _$GetCommunityDonationsEnabledRequest
    implements SerializeableRequest {
  factory GetCommunityDonationsEnabledRequest({
    required String communityId,
  }) = _GetCommunityDonationsEnabledRequest;

  factory GetCommunityDonationsEnabledRequest.fromJson(
          Map<String, dynamic> json) =>
      _$GetCommunityDonationsEnabledRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetCommunityDonationsEnabledResponse
    with _$GetCommunityDonationsEnabledResponse
    implements SerializeableRequest {
  factory GetCommunityDonationsEnabledResponse({
    required bool donationsEnabled,
  }) = _GetCommunityDonationsEnabledResponse;

  factory GetCommunityDonationsEnabledResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetCommunityDonationsEnabledResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetCommunityPrePostEnabledRequest
    with _$GetCommunityPrePostEnabledRequest
    implements SerializeableRequest {
  factory GetCommunityPrePostEnabledRequest({
    required String communityId,
  }) = _GetCommunityPrePostEnabledRequest;

  factory GetCommunityPrePostEnabledRequest.fromJson(
          Map<String, dynamic> json) =>
      _$GetCommunityPrePostEnabledRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetCommunityPrePostEnabledResponse
    with _$GetCommunityPrePostEnabledResponse
    implements SerializeableRequest {
  factory GetCommunityPrePostEnabledResponse({
    required bool prePostEnabled,
  }) = _GetCommunityPrePostEnabledResponse;

  factory GetCommunityPrePostEnabledResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetCommunityPrePostEnabledResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UpdateStripeSubscriptionPlanRequest
    with _$UpdateStripeSubscriptionPlanRequest
    implements SerializeableRequest {
  factory UpdateStripeSubscriptionPlanRequest({
    required String communityId,

    /// Identifier of the specific "price" object associated with a subscription in Stripe
    required String stripePriceId,
    required PlanType type,
  }) = _UpdateStripeSubscriptionPlanRequest;

  factory UpdateStripeSubscriptionPlanRequest.fromJson(
          Map<String, dynamic> json) =>
      _$UpdateStripeSubscriptionPlanRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CancelStripeSubscriptionPlanRequest
    with _$CancelStripeSubscriptionPlanRequest
    implements SerializeableRequest {
  factory CancelStripeSubscriptionPlanRequest({
    required String communityId,
  }) = _CancelStripeSubscriptionPlanRequest;

  factory CancelStripeSubscriptionPlanRequest.fromJson(
          Map<String, dynamic> json) =>
      _$CancelStripeSubscriptionPlanRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetStripeSubscriptionPlanInfoRequest
    with _$GetStripeSubscriptionPlanInfoRequest
    implements SerializeableRequest {
  factory GetStripeSubscriptionPlanInfoRequest({
    required PlanType type,
  }) = _GetStripeSubscriptionPlanInfoRequest;

  factory GetStripeSubscriptionPlanInfoRequest.fromJson(
          Map<String, dynamic> json) =>
      _$GetStripeSubscriptionPlanInfoRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetStripeSubscriptionPlanInfoResponse
    with _$GetStripeSubscriptionPlanInfoResponse
    implements SerializeableRequest {
  factory GetStripeSubscriptionPlanInfoResponse({
    required PlanType plan,
    required int priceInCents,

    /// Identifier of the specific "price" object associated with a subscription in Stripe
    required String stripePriceId,
    required String name,
  }) = _GetStripeSubscriptionPlanInfoResponse;

  factory GetStripeSubscriptionPlanInfoResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetStripeSubscriptionPlanInfoResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetCommunityCalendarLinkRequest
    with _$GetCommunityCalendarLinkRequest
    implements SerializeableRequest {
  static const functionName = 'getCommunityCalendarLink';

  factory GetCommunityCalendarLinkRequest({
    required String eventPath,
  }) = _GetCommunityCalendarLinkRequest;

  factory GetCommunityCalendarLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$GetCommunityCalendarLinkRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetCommunityCalendarLinkResponse
    with _$GetCommunityCalendarLinkResponse
    implements SerializeableRequest {
  factory GetCommunityCalendarLinkResponse({
    required String googleCalendarLink,
    required String outlookCalendarLink,
    required String office365CalendarLink,
    required String icsLink,
  }) = _GetCommunityCalendarLinkResponse;

  factory GetCommunityCalendarLinkResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetCommunityCalendarLinkResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetUserIdFromAgoraIdRequest
    with _$GetUserIdFromAgoraIdRequest
    implements SerializeableRequest {
  factory GetUserIdFromAgoraIdRequest({required int agoraId}) =
      _GetUserIdFromAgoraIdRequest;

  factory GetUserIdFromAgoraIdRequest.fromJson(Map<String, dynamic> json) =>
      _$GetUserIdFromAgoraIdRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetUserIdFromAgoraIdResponse
    with _$GetUserIdFromAgoraIdResponse
    implements SerializeableRequest {
  factory GetUserIdFromAgoraIdResponse({required String userId}) =
      _GetUserIdFromAgoraIdResponse;

  factory GetUserIdFromAgoraIdResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUserIdFromAgoraIdResponseFromJson(json);
}
