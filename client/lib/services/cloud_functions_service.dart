import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:junto_models/firestore/plan_capability_list.dart';
import 'package:junto_models/utils.dart';

import 'firestore/firestore_utils.dart';

class CloudFunctionsService {
  static bool usingEmulator = false;

  Future<void> initialize() async {
    if (usingEmulator) {
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    }
  }

  /// If running on web without emulators, this directs all function calls through the redirects in
  /// firebase.json to improve loading times by avoiding preflight CORS requests
  Future<Map<String, dynamic>> callFunction(String function, Map<String, dynamic> data, {bool isWeb = true}) async {
    final isLocalhost = Uri.base.origin.contains('localhost');
    final useRedirects = !usingEmulator && isWeb && !isLocalhost;
    if (useRedirects) {
      final callable = getHttpsCallableWeb(function)!;
      print('Callable origin: ${callable.origin}');
      print('Callable: ${callable.uri.toString()}');
      final result = await callable.call(data);
      return result ?? {};
    } else {
      final callable = FirebaseFunctions.instance.httpsCallable(function);
      final result = await callable.call(data);
      final resultData = result.data;
      if (resultData != null && resultData is String && resultData.trim().isEmpty) {
        return {};
      }
      return result.data ?? {};
    }
  }

  Future<DateTime> getServerTimestamp() async {
    final result = await callFunction('GetServerTimestamp', GetServerTimestampRequest().toJson());

    return GetServerTimestampResponse.fromJson(result).serverTimestamp;
  }

  Future<void> createAnnouncement(CreateAnnouncementRequest request) async {
    await callFunction('sendAnnouncement', request.toJson());
  }

  Future<void> sendDiscussionMessage(SendDiscussionMessageRequest request) async {
    loggingService.log('CloudFunctionsService.sendDiscussionMessage: Data: ${request.toJson()}');

    await callFunction('sendDiscussionMessage', request.toJson());
  }

  Future<CreateDonationCheckoutSessionResponse> createDonationCheckoutSession(
      CreateDonationCheckoutSessionRequest request) async {
    final result = await callFunction('createDonationCheckoutSession', request.toJson());
    return CreateDonationCheckoutSessionResponse.fromJson(result);
  }

  Future<void> createDiscussion(Discussion discussion) async {
    await callFunction(CreateDiscussionRequest.functionName,
        CreateDiscussionRequest(discussionPath: discussion.fullPath).toJson());
  }

  Future<PlanCapabilityList> getJuntoCapabilities(GetJuntoCapabilitiesRequest request) async {
    final result = await callFunction('getJuntoCapabilities', request.toJson());
    return PlanCapabilityList.fromJson(result);
  }

  Future<GetJuntoCalendarLinkResponse> getJuntoCalendarLink(
      GetJuntoCalendarLinkRequest request) async {
    final result = await callFunction('getJuntoCalendarLink', request.toJson());
    return GetJuntoCalendarLinkResponse.fromJson(result);
  }

  Future<void> createStripeConnectedAccount(CreateStripeConnectedAccountRequest request) async {
    await callFunction('createStripeConnectedAccount', request.toJson());
  }

  Future<CreateSubscriptionCheckoutSessionResponse> createSubscriptionCheckoutSession(
      CreateSubscriptionCheckoutSessionRequest request) async {
    final result = await callFunction('CreateSubscriptionCheckoutSession', request.toJson());
    return CreateSubscriptionCheckoutSessionResponse.fromJson(result);
  }

  Future<GetStripeBillingPortalLinkResponse> getStripeBillingPortalLink(
      GetStripeBillingPortalLinkRequest request) async {
    final result = await callFunction('getStripeBillingPortalLink', request.toJson());
    return GetStripeBillingPortalLinkResponse.fromJson(result);
  }

  Future<GetStripeConnectedAccountLinkResponse> getStripeConnectedAccountLink(
      GetStripeConnectedAccountLinkRequest request) async {
    final result = await callFunction('getStripeConnectedAccountLink', request.toJson());
    return GetStripeConnectedAccountLinkResponse.fromJson(result);
  }

  Future<CreateJuntoResponse> createJunto(CreateJuntoRequest request) async {
    final result = await callFunction('createJunto', request.toJson());
    return CreateJuntoResponse.fromJson(result);
  }

  Future<void> updateJunto(UpdateJuntoRequest request) async {
    loggingService.log('CloudFunctionsService.updateJunto: DataMap: ${request.toJson()}');
    await callFunction('UpdateJunto', request.toJson());
  }

  Future<void> joinDiscussion(Discussion discussion) async {
    final data = discussion.toJson()
      ..remove('createdDate')
      ..remove('discussionEmailLog')
      ..['scheduledTime'] = encodeDateTimeForJson(
        discussion.scheduledTime,
      );

    await callFunction('joinDiscussion', data);
  }

  Future<GetMeetingJoinInfoResponse> getMeetingJoinInfo(GetMeetingJoinInfoRequest request) async {
    final result = await callFunction('GetMeetingJoinInfo', request.toJson());

    return GetMeetingJoinInfoResponse.fromJson(result);
  }

  Future<GetMeetingChatsSuggestionsDataResponse> getMeetingChatSuggestionData({
    required GetMeetingChatsSuggestionsDataRequest request,
  }) async {
    final result = await callFunction('GetMeetingChatSuggestionData', request.toJson());

    return GetMeetingChatsSuggestionsDataResponse.fromJson(result);
  }

  Future<GetMembersDataResponse> getMembersData({
    required GetMembersDataRequest request,
  }) async {
    final result = await callFunction('GetMembersData', request.toJson());

    return GetMembersDataResponse.fromJson(fromFirestoreJson(result));
  }

  Future<GetMeetingJoinInfoResponse> getBreakoutRoomJoinInfo(
      GetBreakoutRoomJoinInfoRequest request) async {
    final result = await callFunction('GetBreakoutRoomJoinInfo', request.toJson());

    print('Breakout room join info');
    print(result);
    return GetMeetingJoinInfoResponse.fromJson(result);
  }

  Future<CreateLiveStreamResponse> createLiveStream({required String juntoId}) async {
    final request = CreateLiveStreamRequest(juntoId: juntoId);

    final result = await callFunction('CreateLiveStream', request.toJson());

    return CreateLiveStreamResponse.fromJson(result);
  }

  /// Regular `result` doesn't work on macos.
  /// type '_InternalLinkedHashMap<Object?, Object?>' is not a subtype of type 'Map<String, dynamic>' in type cast
  /// Additionally Map<String,dynamic>.from doesn't work as well.
  Map<String, dynamic> getDecodedData(data, {bool isWeb = true}) {
    if (isWeb) {
      return data;
    } else {
      return jsonDecode(jsonEncode(data));
    }
  }

  Future<GetUserAdminDetailsResponse> getUserAdminDetails(
      GetUserAdminDetailsRequest request) async {
    final result = await callFunction('GetUserAdminDetails', request.toJson());

    return GetUserAdminDetailsResponse.fromJson(getDecodedData(result));
  }

  Future<GetUserIdFromAgoraIdResponse> getUserIdFromAgoraId(
      GetUserIdFromAgoraIdRequest request) async {
    final result = await callFunction('GetUserIdFromAgoraId', request.toJson());

    return GetUserIdFromAgoraIdResponse.fromJson(getDecodedData(result));
  }

  /// Possibly poorly named.
  /// This assigns a user to a breakout room if they arrive after the initial assignment.
  Future<GetBreakoutRoomAssignmentResponse> getBreakoutRoomAssignment(
      GetBreakoutRoomAssignmentRequest request) async {
    final result = await callFunction('GetBreakoutRoomAssignment', request.toJson());

    return GetBreakoutRoomAssignmentResponse.fromJson(result);
  }

  Future<void> kickParticipant({required KickParticipantRequest request}) async {
    await callFunction('KickParticipant', request.toJson());
  }

  Future<void> resolveJoinRequest(ResolveJoinRequestRequest request) async {
    await callFunction('resolveJoinRequest', request.toJson());
  }

  Future<void> updateBreakoutRoomFlagStatus({
    required UpdateBreakoutRoomFlagStatusRequest request,
  }) async {
    await callFunction('UpdateBreakoutRoomFlagStatus', request.toJson());
  }

  Future<void> resetParticipantAgendaItems({
    required ResetParticipantAgendaItemsRequest request,
  }) async {
    await callFunction('ResetParticipantAgendaItems', request.toJson());
  }

  Future<void> unsubscribeFromJuntoNotifications({
    required UnsubscribeFromJuntoNotificationsRequest request,
  }) async {
    await callFunction('unsubscribeFromJuntoNotifications', request.toJson());
  }

  Future<void> checkAdvanceMeetingGuide(CheckAdvanceMeetingGuideRequest request) async {
    await callFunction('CheckAdvanceMeetingGuide', request.toJson());
  }

  Future<void> checkAssignToBreakouts(CheckAssignToBreakoutsRequest request) async {
    await callFunction(CheckAssignToBreakoutsRequest.functionName, request.toJson());
  }

  Future<void> checkHostlessGoToBreakouts(CheckHostlessGoToBreakoutsRequest request) async {
    await callFunction(CheckHostlessGoToBreakoutsRequest.functionName, request.toJson());
  }

  Future<void> initiateBreakouts(InitiateBreakoutsRequest request) async {
    await callFunction(InitiateBreakoutsRequest.functionName, request.toJson());
  }

  Future<BreakoutRoom> reassignBreakoutRoom(
      ReassignBreakoutRoomRequest reassignBreakoutRoomRequest) async {
    final response =
        await callFunction('ReassignBreakoutRoom', reassignBreakoutRoomRequest.toJson());

    print("Reassign breakout room");
    print(response);
    return BreakoutRoom.fromJson(response);
  }

  Future<void> updateMembership(UpdateMembershipRequest request) async {
    await callFunction('updateMembership', request.toJson());
  }

  Future<void> voteToKick(VoteToKickRequest request) async {
    await callFunction('VoteToKick', request.toJson());
  }

  Future<void> discussionEnded(DiscussionEndedRequest request) async {
    loggingService.log('CloudFunctionsService.discussionEnded: Data: ${request.toJson()}');
    await callFunction('discussionEnded', request.toJson());
  }

  Future<GetJuntoDonationsEnabledResponse> getJuntoDonationsEnabled(
      GetJuntoDonationsEnabledRequest request) async {
    final result = await callFunction('GetJuntoDonationsEnabled', request.toJson());

    return GetJuntoDonationsEnabledResponse.fromJson(result);
  }

  Future<GetJuntoPrePostEnabledResponse> getJuntoPrePostEnabled(
      GetJuntoPrePostEnabledRequest request) async {
    final result = await callFunction('GetJuntoPrePostEnabled', request.toJson());

    return GetJuntoPrePostEnabledResponse.fromJson(result);
  }

  Future<void> cancelStripeSubscriptionPlan(CancelStripeSubscriptionPlanRequest request) async {
    await callFunction('CancelStripeSubscriptionPlan', request.toJson());
  }

  Future<void> updateStripeSubscriptionPlan(UpdateStripeSubscriptionPlanRequest request) async {
    await callFunction('UpdateStripeSubscriptionPlan', request.toJson());
  }

  Future<GetStripeSubscriptionPlanInfoResponse> getStripeSubscriptionPlanInfo(
      GetStripeSubscriptionPlanInfoRequest request) async {
    final result = await callFunction('GetStripeSubscriptionPlanInfo', request.toJson());

    return GetStripeSubscriptionPlanInfoResponse.fromJson(result);
  }

  Future<void> toggleLikeDislikeOnMeetingUserSuggestion(
    ParticipantAgendaItemDetailsMeta request,
  ) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('toggleLikeDislikeOnMeetingUserSuggestion');

    await callable.call(request.toJson());
  }
}
