import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/firestore/announcement.dart';
import 'package:junto_models/firestore/chat_suggestion_data.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/discussion_message.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/member_details.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/firestore/plan_capability_list.dart';

part 'requests.freezed.dart';
part 'requests.g.dart';

class SerializeableRequest {
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

@Freezed(makeCollectionsUnmodifiable: false)
class AddNewFieldRequest with _$AddNewFieldRequest implements SerializeableRequest {
  factory AddNewFieldRequest({
    required String collectionName,
    required Map<String, dynamic> fieldWithValue,
  }) = _AddNewFieldRequest;

  factory AddNewFieldRequest.fromJson(Map<String, dynamic> json) =>
      _$AddNewFieldRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class RemoveExistingFieldRequest with _$RemoveExistingFieldRequest implements SerializeableRequest {
  factory RemoveExistingFieldRequest({
    required String collectionName,
    required String field,
  }) = _RemoveFieldRequest;

  factory RemoveExistingFieldRequest.fromJson(Map<String, dynamic> json) =>
      _$RemoveExistingFieldRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateDiscussionRequest with _$CreateDiscussionRequest implements SerializeableRequest {
  static const functionName = 'createDiscussion';

  factory CreateDiscussionRequest({
    required String discussionPath,
  }) = _CreateDiscussionRequest;

  factory CreateDiscussionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDiscussionRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateAnnouncementRequest with _$CreateAnnouncementRequest implements SerializeableRequest {
  factory CreateAnnouncementRequest({
    required String juntoId,
    @JsonKey(toJson: Announcement.toJsonForCloudFunction) Announcement? announcement,
  }) = _CreateAnnouncementRequest;

  factory CreateAnnouncementRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAnnouncementRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class SendDiscussionMessageRequest
    with _$SendDiscussionMessageRequest
    implements SerializeableRequest {
  factory SendDiscussionMessageRequest({
    required String juntoId,
    required String topicId,
    required String discussionId,
    @JsonKey(toJson: DiscussionMessage.toJsonForCloudFunction)
    required DiscussionMessage discussionMessage,
  }) = _SendDiscussionMessageRequest;

  factory SendDiscussionMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendDiscussionMessageRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateDonationCheckoutSessionRequest
    with _$CreateDonationCheckoutSessionRequest
    implements SerializeableRequest {
  factory CreateDonationCheckoutSessionRequest({
    required String juntoId,
    required int amountInCents,
  }) = _CreateDonationCheckoutSessionRequest;

  factory CreateDonationCheckoutSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDonationCheckoutSessionRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateDonationCheckoutSessionResponse
    with _$CreateDonationCheckoutSessionResponse
    implements SerializeableRequest {
  factory CreateDonationCheckoutSessionResponse({
    required String sessionId,
  }) = _CreateDonationCheckoutSessionResponse;

  factory CreateDonationCheckoutSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateDonationCheckoutSessionResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateSubscriptionCheckoutSessionRequest
    with _$CreateSubscriptionCheckoutSessionRequest
    implements SerializeableRequest {
  factory CreateSubscriptionCheckoutSessionRequest({
    required PlanType type,
    required String appliedJuntoId,
    required String returnRedirectPath,
  }) = _CreateSubscriptionCheckoutSessionRequest;

  factory CreateSubscriptionCheckoutSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSubscriptionCheckoutSessionRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateSubscriptionCheckoutSessionResponse
    with _$CreateSubscriptionCheckoutSessionResponse
    implements SerializeableRequest {
  factory CreateSubscriptionCheckoutSessionResponse({
    required String sessionId,
  }) = __$CreateSubscriptionCheckoutSessionResponse;

  factory CreateSubscriptionCheckoutSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSubscriptionCheckoutSessionResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateStripeConnectedAccountRequest
    with _$CreateStripeConnectedAccountRequest
    implements SerializeableRequest {
  factory CreateStripeConnectedAccountRequest({
    required String agreementId,
  }) = _CreateStripeConnectedAccountRequest;

  factory CreateStripeConnectedAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStripeConnectedAccountRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class EmailDiscussionReminderRequest
    with _$EmailDiscussionReminderRequest
    implements SerializeableRequest {
  factory EmailDiscussionReminderRequest({
    required String juntoId,
    required String topicId,
    required String discussionId,
    DiscussionEmailType? discussionEmailType,
  }) = _EmailDiscussionReminderRequest;

  factory EmailDiscussionReminderRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailDiscussionReminderRequestFromJson(json);
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
class JuntoUserInfo with _$JuntoUserInfo {
  factory JuntoUserInfo({
    required String id,
    required String photoURL,
    required String displayName,
  }) = _JuntoUserInfo;

  factory JuntoUserInfo.fromJson(Map<String, dynamic> json) => _$JuntoUserInfoFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class SendGridEmail with _$SendGridEmail {
  factory SendGridEmail({
    required List<String> to,
    required String from,
    required SendGridEmailMessage message,
  }) = _SendGridEmail;

  factory SendGridEmail.fromJson(Map<String, dynamic> json) => _$SendGridEmailFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class EmailAttachment with _$EmailAttachment {
  factory EmailAttachment({
    required String filename,
    required String content,
    required String contentType,
  }) = _EmailAttachment;

  factory EmailAttachment.fromJson(Map<String, dynamic> json) => _$EmailAttachmentFromJson(json);
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
class GetServerTimestampRequest with _$GetServerTimestampRequest implements SerializeableRequest {
  static const functionName = 'GetServerTimestamp';

  factory GetServerTimestampRequest() = _GetServerTimestampRequest;

  factory GetServerTimestampRequest.fromJson(Map<String, dynamic> json) =>
      _$GetServerTimestampRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetServerTimestampResponse with _$GetServerTimestampResponse implements SerializeableRequest {
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
    required String discussionPath,
  }) = _GetTwilioMeetingJoinInfoRequest;

  factory GetTwilioMeetingJoinInfoRequest.fromJson(Map<String, dynamic> json) =>
      _$GetTwilioMeetingJoinInfoRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetMeetingJoinInfoRequest with _$GetMeetingJoinInfoRequest implements SerializeableRequest {
  factory GetMeetingJoinInfoRequest({
    required String discussionPath,
    // External ID of this user when provided by communities such as Unify America.
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
    required String juntoId,
    required String meetingId,
    required String userIdentifier,
    required String userDisplayName,
    required bool record,
  }) = _GetInstantMeetingJoinInfoRequest;

  factory GetInstantMeetingJoinInfoRequest.fromJson(Map<String, dynamic> json) =>
      _$GetInstantMeetingJoinInfoRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetUserAdminDetailsRequest with _$GetUserAdminDetailsRequest implements SerializeableRequest {
  factory GetUserAdminDetailsRequest({
    required List<String> userIds,
    String? juntoId,
    String? discussionPath,
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
    required String discussionPath,
  }) = _GetMeetingChatsSuggestionsDataRequest;

  factory GetMeetingChatsSuggestionsDataRequest.fromJson(Map<String, dynamic> json) =>
      _$GetMeetingChatsSuggestionsDataRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetMeetingChatsSuggestionsDataResponse with _$GetMeetingChatsSuggestionsDataResponse {
  factory GetMeetingChatsSuggestionsDataResponse({
    List<ChatSuggestionData>? chatsSuggestionsList,
  }) = _GetMeetingChatsSuggestionsDataResponse;

  factory GetMeetingChatsSuggestionsDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetMeetingChatsSuggestionsDataResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetMembersDataRequest with _$GetMembersDataRequest implements SerializeableRequest {
  factory GetMembersDataRequest({
    required String juntoId,
    required List<String> userIds,
    String? discussionPath,
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

  factory UserAdminDetails.fromJson(Map<String, dynamic> json) => _$UserAdminDetailsFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateLiveStreamRequest with _$CreateLiveStreamRequest implements SerializeableRequest {
  factory CreateLiveStreamRequest({
    required String juntoId,
  }) = _CreateLiveStreamRequest;

  factory CreateLiveStreamRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateLiveStreamRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateLiveStreamResponse with _$CreateLiveStreamResponse implements SerializeableRequest {
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
    required String discussionId,
    required String discussionPath,
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
    required String discussionId,
    required String discussionPath,
  }) = _GetBreakoutRoomAssignmentRequest;

  factory GetBreakoutRoomAssignmentRequest.fromJson(Map<String, dynamic> json) =>
      _$GetBreakoutRoomAssignmentRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetBreakoutRoomAssignmentResponse
    with _$GetBreakoutRoomAssignmentResponse
    implements SerializeableRequest {
  factory GetBreakoutRoomAssignmentResponse({
    required String? roomId,
  }) = _GetBreakoutRoomAssignmentResponse;

  factory GetBreakoutRoomAssignmentResponse.fromJson(Map<String, dynamic> json) =>
      _$GetBreakoutRoomAssignmentResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetHelpInMeetingRequest with _$GetHelpInMeetingRequest implements SerializeableRequest {
  factory GetHelpInMeetingRequest({
    required String discussionPath,
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
    required String discussionPath,
  }) = _GenerateTwilioCompositionRequest;

  factory GenerateTwilioCompositionRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateTwilioCompositionRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class DownloadTwilioCompositionRequest
    with _$DownloadTwilioCompositionRequest
    implements SerializeableRequest {
  factory DownloadTwilioCompositionRequest({
    required String discussionPath,
  }) = _DownloadTwilioCompositionRequest;

  factory DownloadTwilioCompositionRequest.fromJson(Map<String, dynamic> json) =>
      _$DownloadTwilioCompositionRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class DownloadTwilioCompositionResponse
    with _$DownloadTwilioCompositionResponse
    implements SerializeableRequest {
  factory DownloadTwilioCompositionResponse({
    required String redirectUrl,
  }) = _DownloadTwilioCompositionResponse;

  factory DownloadTwilioCompositionResponse.fromJson(Map<String, dynamic> json) =>
      _$DownloadTwilioCompositionResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class KickParticipantRequest
    with _$KickParticipantRequest
    implements SerializeableRequest {
  factory KickParticipantRequest({
    required String userToKickId,
    required String discussionPath,
    String? breakoutRoomId,
  }) = _KickParticipantRequest;

  factory KickParticipantRequest.fromJson(Map<String, dynamic> json) =>
      _$KickParticipantRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class OnUnifyCancellationRequest with _$OnUnifyCancellationRequest implements SerializeableRequest {
  factory OnUnifyCancellationRequest({
    required String meetingId,
    required String participantId,
  }) = _OnUnifyCancellationRequest;

  factory OnUnifyCancellationRequest.fromJson(Map<String, dynamic> json) =>
      _$OnUnifyCancellationRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class ResolveJoinRequestRequest with _$ResolveJoinRequestRequest implements SerializeableRequest {
  factory ResolveJoinRequestRequest({
    required String juntoId,
    required String userId,
    required bool approve,
  }) = _ResolveJoinRequestRequest;

  factory ResolveJoinRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$ResolveJoinRequestRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class InitiateBreakoutsRequest with _$InitiateBreakoutsRequest implements SerializeableRequest {
  static const String functionName = 'InitiateBreakouts';

  factory InitiateBreakoutsRequest({
    required String discussionPath,
    required int targetParticipantsPerRoom,
    required String breakoutSessionId,
    @JsonKey(unknownEnumValue: null) BreakoutAssignmentMethod? assignmentMethod,
    @Default(false) bool includeWaitingRoom,
  }) = _InitiateBreakoutsRequest;

  factory InitiateBreakoutsRequest.fromJson(Map<String, dynamic> json) =>
      _$InitiateBreakoutsRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class InitiateBreakoutsResponse with _$InitiateBreakoutsResponse implements SerializeableRequest {
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
    required String discussionPath,
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
    required String discussionPath,
    required String breakoutSessionId,
    required String roomId,
    @JsonKey(unknownEnumValue: null) BreakoutRoomFlagStatus? flagStatus,
  }) = _UpdateBreakoutRoomFlagStatusRequest;

  factory UpdateBreakoutRoomFlagStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateBreakoutRoomFlagStatusRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateJuntoRequest with _$CreateJuntoRequest implements SerializeableRequest {
  factory CreateJuntoRequest({
    @JsonKey(toJson: Junto.toJsonForCloudFunction) Junto? junto,
    String? agreementId,
  }) = _CreateJuntoRequest;

  factory CreateJuntoRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateJuntoRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CreateJuntoResponse with _$CreateJuntoResponse implements SerializeableRequest {
  factory CreateJuntoResponse({
    required String juntoId,
  }) = _CreateJuntoResponse;

  factory CreateJuntoResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateJuntoResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UpdateJuntoRequest with _$UpdateJuntoRequest implements SerializeableRequest {
  factory UpdateJuntoRequest({
    @JsonKey(toJson: Junto.toJsonForCloudFunction) required Junto junto,
    required List<String> keys,
  }) = _UpdateJuntoRequest;

  factory UpdateJuntoRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateJuntoRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetJuntoCapabilitiesRequest
    with _$GetJuntoCapabilitiesRequest
    implements SerializeableRequest {
  factory GetJuntoCapabilitiesRequest({
    required String juntoId,
  }) = _GetJuntoCapabilitiesRequest;

  factory GetJuntoCapabilitiesRequest.fromJson(Map<String, dynamic> json) =>
      _$GetJuntoCapabilitiesRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetStripeBillingPortalLinkRequest
    with _$GetStripeBillingPortalLinkRequest
    implements SerializeableRequest {
  factory GetStripeBillingPortalLinkRequest({
    required String responsePath,
  }) = _GetStripeBillingPortalLinkRequest;

  factory GetStripeBillingPortalLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$GetStripeBillingPortalLinkRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetStripeBillingPortalLinkResponse
    with _$GetStripeBillingPortalLinkResponse
    implements SerializeableRequest {
  factory GetStripeBillingPortalLinkResponse({
    required String url,
  }) = _GetStripeBillingPortalLinkResponse;

  factory GetStripeBillingPortalLinkResponse.fromJson(Map<String, dynamic> json) =>
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

  factory GetStripeConnectedAccountLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$GetStripeConnectedAccountLinkRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetStripeConnectedAccountLinkResponse
    with _$GetStripeConnectedAccountLinkResponse
    implements SerializeableRequest {
  factory GetStripeConnectedAccountLinkResponse({
    required String url,
  }) = _GetStripeConnectedAccountLinkResponse;

  factory GetStripeConnectedAccountLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$GetStripeConnectedAccountLinkResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UnsubscribeFromJuntoNotificationsRequest
    with _$UnsubscribeFromJuntoNotificationsRequest
    implements SerializeableRequest {
  factory UnsubscribeFromJuntoNotificationsRequest({
    required String data,
  }) = _UnsubscribeFromJuntoNotificationsRequest;

  factory UnsubscribeFromJuntoNotificationsRequest.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribeFromJuntoNotificationsRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CheckAdvanceMeetingGuideRequest
    with _$CheckAdvanceMeetingGuideRequest
    implements SerializeableRequest {
  factory CheckAdvanceMeetingGuideRequest({
    required String discussionPath,
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
    required String discussionPath,
  }) = _CheckHostlessGoToBreakoutsRequest;

  factory CheckHostlessGoToBreakoutsRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckHostlessGoToBreakoutsRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CheckAssignToBreakoutsRequest
    with _$CheckAssignToBreakoutsRequest
    implements SerializeableRequest {
  static const functionName = 'CheckAssignToBreakouts';

  factory CheckAssignToBreakoutsRequest({
    required String discussionPath,
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

  factory ResetParticipantAgendaItemsRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetParticipantAgendaItemsRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UpdateMembershipRequest with _$UpdateMembershipRequest implements SerializeableRequest {
  factory UpdateMembershipRequest({
    required String userId,
    required String juntoId,
    @JsonKey(unknownEnumValue: null) required MembershipStatus? status,
    bool? invisible,
  }) = _UpdateMembershipRequest;

  factory UpdateMembershipRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMembershipRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class VoteToKickRequest with _$VoteToKickRequest implements SerializeableRequest {
  factory VoteToKickRequest({
    required String targetUserId,
    required String discussionPath,

    /// This can be the path to a live meeting or a breakout room live meeting
    required String liveMeetingPath,
    required bool inFavor,
    String? reason,
  }) = _VoteToKickRequest;

  factory VoteToKickRequest.fromJson(Map<String, dynamic> json) =>
      _$VoteToKickRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class DiscussionEndedRequest with _$DiscussionEndedRequest implements SerializeableRequest {
  factory DiscussionEndedRequest({
    required String discussionPath,
  }) = _DiscussionEndedRequest;

  factory DiscussionEndedRequest.fromJson(Map<String, dynamic> json) =>
      _$DiscussionEndedRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetJuntoDonationsEnabledRequest
    with _$GetJuntoDonationsEnabledRequest
    implements SerializeableRequest {
  factory GetJuntoDonationsEnabledRequest({
    required String juntoId,
  }) = _GetJuntoDonationsEnabledRequest;

  factory GetJuntoDonationsEnabledRequest.fromJson(Map<String, dynamic> json) =>
      _$GetJuntoDonationsEnabledRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetJuntoDonationsEnabledResponse
    with _$GetJuntoDonationsEnabledResponse
    implements SerializeableRequest {
  factory GetJuntoDonationsEnabledResponse({
    required bool donationsEnabled,
  }) = _GetJuntoDonationsEnabledResponse;

  factory GetJuntoDonationsEnabledResponse.fromJson(Map<String, dynamic> json) =>
      _$GetJuntoDonationsEnabledResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetJuntoPrePostEnabledRequest
    with _$GetJuntoPrePostEnabledRequest
    implements SerializeableRequest {
  factory GetJuntoPrePostEnabledRequest({
    required String juntoId,
  }) = _GetJuntoPrePostEnabledRequest;

  factory GetJuntoPrePostEnabledRequest.fromJson(Map<String, dynamic> json) =>
      _$GetJuntoPrePostEnabledRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetJuntoPrePostEnabledResponse
    with _$GetJuntoPrePostEnabledResponse
    implements SerializeableRequest {
  factory GetJuntoPrePostEnabledResponse({
    required bool prePostEnabled,
  }) = _GetJuntoPrePostEnabledResponse;

  factory GetJuntoPrePostEnabledResponse.fromJson(Map<String, dynamic> json) =>
      _$GetJuntoPrePostEnabledResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UpdateStripeSubscriptionPlanRequest
    with _$UpdateStripeSubscriptionPlanRequest
    implements SerializeableRequest {
  factory UpdateStripeSubscriptionPlanRequest({
    required String juntoId,

    /// Identifier of the specific "price" object associated with a subscription in Stripe
    required String stripePriceId,
    required PlanType type,
  }) = _UpdateStripeSubscriptionPlanRequest;

  factory UpdateStripeSubscriptionPlanRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateStripeSubscriptionPlanRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class CancelStripeSubscriptionPlanRequest
    with _$CancelStripeSubscriptionPlanRequest
    implements SerializeableRequest {
  factory CancelStripeSubscriptionPlanRequest({
    required String juntoId,
  }) = _CancelStripeSubscriptionPlanRequest;

  factory CancelStripeSubscriptionPlanRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelStripeSubscriptionPlanRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetStripeSubscriptionPlanInfoRequest
    with _$GetStripeSubscriptionPlanInfoRequest
    implements SerializeableRequest {
  factory GetStripeSubscriptionPlanInfoRequest({
    required PlanType type,
  }) = _GetStripeSubscriptionPlanInfoRequest;

  factory GetStripeSubscriptionPlanInfoRequest.fromJson(Map<String, dynamic> json) =>
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

  factory GetStripeSubscriptionPlanInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$GetStripeSubscriptionPlanInfoResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetJuntoCalendarLinkRequest
    with _$GetJuntoCalendarLinkRequest
    implements SerializeableRequest {
  static const functionName = 'getJuntoCalendarLink';

  factory GetJuntoCalendarLinkRequest({
    required String discussionPath,
  }) = _GetJuntoCalendarLinkRequest;

  factory GetJuntoCalendarLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$GetJuntoCalendarLinkRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetJuntoCalendarLinkResponse
    with _$GetJuntoCalendarLinkResponse
    implements SerializeableRequest {
  factory GetJuntoCalendarLinkResponse({
    required String googleCalendarLink,
    required String outlookCalendarLink,
    required String office365CalendarLink,
    required String icsLink,
  }) = _GetJuntoCalendarLinkResponse;

  factory GetJuntoCalendarLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$GetJuntoCalendarLinkResponseFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetUserIdFromAgoraIdRequest
    with _$GetUserIdFromAgoraIdRequest
    implements SerializeableRequest {
  factory GetUserIdFromAgoraIdRequest({required int agoraId}) = _GetUserIdFromAgoraIdRequest;

  factory GetUserIdFromAgoraIdRequest.fromJson(Map<String, dynamic> json) =>
      _$GetUserIdFromAgoraIdRequestFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class GetUserIdFromAgoraIdResponse
    with _$GetUserIdFromAgoraIdResponse
    implements SerializeableRequest {
  factory GetUserIdFromAgoraIdResponse({required String userId}) = _GetUserIdFromAgoraIdResponse;

  factory GetUserIdFromAgoraIdResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUserIdFromAgoraIdResponseFromJson(json);
}
