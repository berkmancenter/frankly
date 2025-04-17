import 'dart:convert';

import 'package:client/services.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';

class CloudFunctionsLiveMeetingService {
  Future<GetMeetingJoinInfoResponse> getMeetingJoinInfo(
    GetMeetingJoinInfoRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'GetMeetingJoinInfo',
      request.toJson(),
    );

    return GetMeetingJoinInfoResponse.fromJson(result);
  }

  Future<GetMeetingChatsSuggestionsDataResponse> getMeetingChatSuggestionData({
    required GetMeetingChatsSuggestionsDataRequest request,
  }) async {
    final result = await cloudFunctions.callFunction(
      'GetMeetingChatSuggestionData',
      request.toJson(),
    );

    return GetMeetingChatsSuggestionsDataResponse.fromJson(result);
  }

  Future<GetMeetingJoinInfoResponse> getBreakoutRoomJoinInfo(
    GetBreakoutRoomJoinInfoRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'GetBreakoutRoomJoinInfo',
      request.toJson(),
    );

    print('Breakout room join info');
    print(result);
    return GetMeetingJoinInfoResponse.fromJson(result);
  }

  Future<CreateLiveStreamResponse> createLiveStream({
    required String communityId,
  }) async {
    final request = CreateLiveStreamRequest(communityId: communityId);

    final result =
        await cloudFunctions.callFunction('CreateLiveStream', request.toJson());

    return CreateLiveStreamResponse.fromJson(result);
  }

  /// Possibly poorly named.
  /// This assigns a user to a breakout room if they arrive after the initial assignment.
  Future<GetBreakoutRoomAssignmentResponse> getBreakoutRoomAssignment(
    GetBreakoutRoomAssignmentRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'GetBreakoutRoomAssignment',
      request.toJson(),
    );

    return GetBreakoutRoomAssignmentResponse.fromJson(result);
  }

  Future<void> kickParticipant({
    required KickParticipantRequest request,
  }) async {
    await cloudFunctions.callFunction('KickParticipant', request.toJson());
  }

  Future<void> updateBreakoutRoomFlagStatus({
    required UpdateBreakoutRoomFlagStatusRequest request,
  }) async {
    await cloudFunctions.callFunction(
      'UpdateBreakoutRoomFlagStatus',
      request.toJson(),
    );
  }

  Future<void> checkAdvanceMeetingGuide(
    CheckAdvanceMeetingGuideRequest request,
  ) async {
    await cloudFunctions.callFunction(
      'CheckAdvanceMeetingGuide',
      request.toJson(),
    );
  }

  Future<void> checkAssignToBreakouts(
    CheckAssignToBreakoutsRequest request,
  ) async {
    await cloudFunctions.callFunction(
      CheckAssignToBreakoutsRequest.functionName,
      request.toJson(),
    );
  }

  Future<void> checkHostlessGoToBreakouts(
    CheckHostlessGoToBreakoutsRequest request,
  ) async {
    await cloudFunctions.callFunction(
      CheckHostlessGoToBreakoutsRequest.functionName,
      request.toJson(),
    );
  }

  Future<void> initiateBreakouts(InitiateBreakoutsRequest request) async {
    await cloudFunctions.callFunction(
      InitiateBreakoutsRequest.functionName,
      request.toJson(),
    );
  }

  Future<BreakoutRoom> reassignBreakoutRoom(
    ReassignBreakoutRoomRequest reassignBreakoutRoomRequest,
  ) async {
    final response = await cloudFunctions.callFunction(
      'ReassignBreakoutRoom',
      reassignBreakoutRoomRequest.toJson(),
    );

    print('Reassign breakout room');
    print(response);
    return BreakoutRoom.fromJson(response);
  }

  Future<void> toggleLikeDislikeOnMeetingUserSuggestion(
    ParticipantAgendaItemDetailsMeta request,
  ) async {
    final HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable('toggleLikeDislikeOnMeetingUserSuggestion');

    await callable.call(request.toJson());
  }

  Future<GetUserIdFromAgoraIdResponse> getUserIdFromAgoraId(
    GetUserIdFromAgoraIdRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'GetUserIdFromAgoraId',
      request.toJson(),
    );

    return GetUserIdFromAgoraIdResponse.fromJson(getDecodedData(result));
  }

  Future<void> resetParticipantAgendaItems({
    required ResetParticipantAgendaItemsRequest request,
  }) async {
    await cloudFunctions.callFunction(
      'ResetParticipantAgendaItems',
      request.toJson(),
    );
  }

  Future<void> voteToKick(VoteToKickRequest request) async {
    await cloudFunctions.callFunction('VoteToKick', request.toJson());
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
}
