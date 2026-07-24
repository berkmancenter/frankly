import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../live_meeting_utils.dart';
import '../../../on_call_function.dart';
import '../../../utils/infra/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/utils/utils.dart';

class GetBreakoutRoomJoinInfo
    extends OnCallMethod<GetBreakoutRoomJoinInfoRequest> {
  LiveMeetingUtils liveMeetingUtils;
  GetBreakoutRoomJoinInfo({LiveMeetingUtils? liveMeetingUtils})
      : liveMeetingUtils = liveMeetingUtils ?? LiveMeetingUtils(),
        super(
          'GetBreakoutRoomJoinInfo',
          (jsonMap) => GetBreakoutRoomJoinInfoRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetBreakoutRoomJoinInfoRequest request,
    CallableContext context,
  ) async {
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    // Verify user is a participant
    final participant = await firestoreUtils.getFirestoreObject(
      path: '${request.eventPath}/event-participants/${context.authUid}',
      constructor: (map) => Participant.fromJson(map),
    );
    if (participant.status != ParticipantStatus.active) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final liveMeetingPath =
        '${request.eventPath}/live-meetings/${request.eventId}';
    final liveMeeting = await firestoreUtils.getFirestoreObject(
      path: liveMeetingPath,
      constructor: (map) => LiveMeeting.fromJson(map),
    );

    final membershipDoc = await firestore
        .document(
          'memberships/${context.authUid}/community-membership/${event.communityId}',
        )
        .get();
    final membership = Membership.fromJson(
      firestoreUtils.fromFirestoreJson(membershipDoc.data.toMap()),
    );
    final isModOrCreator =
        event.creatorId == context.authUid || membership.isMod;

    // Verify user is a member of this breakout room
    final breakoutRoomDoc = await firestore
        .document(
          '$liveMeetingPath/breakout-room-sessions/${liveMeeting.currentBreakoutSession?.breakoutRoomSessionId}/breakout-rooms/${request.breakoutRoomId}',
        )
        .get();

    final breakoutRoom = BreakoutRoom.fromJson(
      firestoreUtils.fromFirestoreJson(breakoutRoomDoc.data.toMap()),
    );
    final isParticipantInBreakoutRoom =
        breakoutRoom.participantIds.contains(context.authUid);

    if (!isParticipantInBreakoutRoom && !isModOrCreator) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final currentBreakoutSession = liveMeeting.currentBreakoutSession;
    if (currentBreakoutSession == null) {
      throw HttpsError(
        HttpsError.failedPrecondition,
        'no active breakout session',
        null,
      );
    }

    final breakoutRoomPath =
        '$liveMeetingPath/breakout-room-sessions/${currentBreakoutSession.breakoutRoomSessionId}/breakout-rooms/${request.breakoutRoomId}';

    final joinInfo = await liveMeetingUtils.getBreakoutRoomJoinInfo(
      communityId: event.communityId,
      eventId: request.eventId,
      breakoutSessionId: currentBreakoutSession.breakoutRoomSessionId ?? '',
      breakoutRoomPath: breakoutRoomPath,
      meetingId: breakoutRoom.roomId,
      userId: context.authUid!,
      record: breakoutRoom.record,
      existingRecordingSessionId: breakoutRoom.recordingSessionId,
      participantIds: breakoutRoom.participantIds,
    );

    // Map this user's Agora numeric UID to their Firebase user ID on the
    // recording session doc. The download-transcripts function uses this map
    // to replace raw Agora UIDs with display names in exported transcripts.
    //
    // We re-read the breakout room doc here because the local `breakoutRoom`
    // variable was fetched before `getBreakoutRoomJoinInfo` ran. If this is
    // the first user to join, `_startBreakoutRecording` will have created a
    // new recording session and written its ID to this doc in Firestore, but
    // our local snapshot still has the old (null) value.
    final updatedBreakoutSnap =
        await firestore.document(breakoutRoomPath).get();
    if (updatedBreakoutSnap.exists) {
      final updatedRoom = BreakoutRoom.fromJson(
        firestoreUtils.fromFirestoreJson(updatedBreakoutSnap.data.toMap()),
      );
      final sessionId = updatedRoom.recordingSessionId;
      if (sessionId != null) {
        await liveMeetingUtils.recordUidMapping(
          sessionId: sessionId,
          agoraUid: uidToInt(context.authUid!),
          userId: context.authUid!,
        );
      }
    }

    return joinInfo.toJson();
  }
}
