import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call/initiate_breakouts.dart';
import 'package:junto_functions/utils/agora_api.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:mocktail/mocktail.dart';

class LiveMeetingTestUtils {
  String getLiveMeetingPath(Discussion discussion) =>
      '${discussion.fullPath}/live-meetings/${discussion.id}';

  String getBreakoutLiveMeetingPath({
    required Discussion discussion,
    required String breakoutSessionId,
    required String breakoutRoomId,
  }) {
    final path = getBreakoutRoomPath(
      discussion: discussion,
      breakoutSessionId: breakoutSessionId,
      breakoutRoomId: breakoutRoomId,
    );
    return '$path/live-meetings/$breakoutRoomId';
  }

  String getBreakoutRoomPath({
    required Discussion discussion,
    required String breakoutSessionId,
    required String breakoutRoomId,
  }) {
    final collectionPath = getBreakoutRoomsCollection(
      discussion: discussion,
      breakoutSessionId: breakoutSessionId,
    );
    return '$collectionPath/$breakoutRoomId';
  }

  String getBreakoutSessionDoc({
    required Discussion discussion,
    required String breakoutSessionId,
  }) {
    final path = getLiveMeetingPath(discussion);
    return '$path/breakout-room-sessions/$breakoutSessionId';
  }

  String getBreakoutRoomsCollection({
    required Discussion discussion,
    required String breakoutSessionId,
  }) {
    final path = getBreakoutSessionDoc(
      discussion: discussion,
      breakoutSessionId: breakoutSessionId,
    );
    return '$path/breakout-rooms';
  }

  Future<void> addMeetingEvent(
      {required String liveMeetingPath,
      String? liveMeetingId,
      required LiveMeetingEvent meetingEvent,
      BreakoutRoomSession? currentBreakoutSession,
      bool record = false}) {
    return firestore.runTransaction((transaction) async {
      final meetingPathRef = firestore.document(liveMeetingPath);
      var liveMeeting = LiveMeeting(
        events: [meetingEvent],
        meetingId: liveMeetingId,
        currentBreakoutSession: currentBreakoutSession,
        record: record,
      );

      transaction.set(
        meetingPathRef,
        DocumentData.fromMap(firestoreUtils.toFirestoreJson(liveMeeting.toJson())),
      );
    });
  }

  Future<void> initiateBreakoutSession(
      {required Discussion discussion,
      required String breakoutSessionId,
      required String userId,
      BreakoutAssignmentMethod assignmentMethod = BreakoutAssignmentMethod.targetPerRoom}) async {
    final req = InitiateBreakoutsRequest(
        discussionPath: discussion.fullPath,
        targetParticipantsPerRoom: 2,
        breakoutSessionId: breakoutSessionId,
        assignmentMethod: assignmentMethod);
    final assigner = InitiateBreakouts();

    await assigner.action(req, CallableContext(userId, null, 'fakeInstanceId'));
  }

  Future<BreakoutRoom> getBreakoutRoom({
    required Discussion discussion,
    required String breakoutSessionId,
    required String roomName,
  }) async {
    final breakoutRoomsPath = getBreakoutRoomsCollection(
      discussion: discussion,
      breakoutSessionId: breakoutSessionId,
    );

    final roomRef = await firestore
        .collection(breakoutRoomsPath)
        .where(BreakoutRoom.kFieldRoomName, isEqualTo: roomName)
        .get();

    final room =
        BreakoutRoom.fromJson(firestoreUtils.fromFirestoreJson(roomRef.documents[0].data.toMap()));

    return room;
  }

  // Live Meeting
  int uidToInt(String uid) {
    int base = 257; // A prime number slightly larger than the number of printable ASCII characters
    int hash = 0;
    int modValue = 1 << 30; // Allow 30 bit integers

    for (int i = 0; i < uid.length; i++) {
      hash = (hash * base + uid.codeUnitAt(i)) % modValue;
    }

    return hash;
  }
}

class MockAgoraUtils extends Mock implements AgoraUtils {}
