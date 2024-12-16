import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call/live_meeting_utils.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/membership.dart';

class GetBreakoutRoomJoinInfo extends OnCallMethod<GetBreakoutRoomJoinInfoRequest> {
  LiveMeetingUtils liveMeetingUtils;
  GetBreakoutRoomJoinInfo({LiveMeetingUtils? liveMeetingUtils})
      : liveMeetingUtils = liveMeetingUtils ?? LiveMeetingUtils(),
        super('GetBreakoutRoomJoinInfo',
            (jsonMap) => GetBreakoutRoomJoinInfoRequest.fromJson(jsonMap));

  @override
  Future<Map<String, dynamic>> action(
      GetBreakoutRoomJoinInfoRequest request, CallableContext context) async {
    final discussion = await firestoreUtils.getFirestoreObject(
      path: request.discussionPath,
      constructor: (map) => Discussion.fromJson(map),
    );

    // Verify user is a participant
    final participant = await firestoreUtils.getFirestoreObject(
      path: '${request.discussionPath}/discussion-participants/${context?.authUid}',
      constructor: (map) => Participant.fromJson(map),
    );
    if (participant.status != ParticipantStatus.active) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final liveMeetingPath = '${request.discussionPath}/live-meetings/${request.discussionId}';
    final liveMeeting = await firestoreUtils.getFirestoreObject(
      path: liveMeetingPath,
      constructor: (map) => LiveMeeting.fromJson(map),
    );

    final membershipDoc = await firestore
        .document('memberships/${context?.authUid}/junto-membership/${discussion.juntoId}')
        .get();
    final membership =
        Membership.fromJson(firestoreUtils.fromFirestoreJson(membershipDoc.data?.toMap() ?? {}));
    final isModOrCreator = discussion.creatorId == context?.authUid || membership.isMod;

    // Verify user is a member of this breakout room
    final breakoutRoomDoc = await firestore
        .document(
            '$liveMeetingPath/breakout-room-sessions/${liveMeeting.currentBreakoutSession?.breakoutRoomSessionId}/breakout-rooms/${request.breakoutRoomId}')
        .get();

    final breakoutRoom =
        BreakoutRoom.fromJson(firestoreUtils.fromFirestoreJson(breakoutRoomDoc.data.toMap()));
    final isParticipantInBreakoutRoom = breakoutRoom.participantIds.contains(context?.authUid);

    if (!isParticipantInBreakoutRoom && !isModOrCreator) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final joinInfo = await liveMeetingUtils.getBreakoutRoomJoinInfo(
      juntoId: discussion.juntoId,
      meetingId: breakoutRoom.roomId,
      userId: context!.authUid!,
      record: breakoutRoom.record,
    );

    return joinInfo.toJson();
  }
}
