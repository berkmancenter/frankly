import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:get_it/get_it.dart';
import 'package:junto_functions/functions/on_call/check_assign_to_breakouts.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:test/test.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:uuid/uuid.dart';

import '../../util/community_test_utils.dart';
import '../../util/discussion_test_utils.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  String juntoId = '';
  const userId = 'fakeAuthId';
  const topicId = '9654';
  const uuid = Uuid();
  final breakoutSessionId = uuid.v1().toString();
  GetIt.instance.registerSingleton(const Uuid());
  final communityTestUtils = CommunityTestUtils();
  final discussionTestUtils = DiscussionTestUtils();
  final liveMeetingTestUtils = LiveMeetingTestUtils();

  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);

    final testJunto = Junto(
      id: '12349999',
      name: 'Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    final juntoResult = await communityTestUtils.createJunto(junto: testJunto, userId: userId);
    juntoId = juntoResult['juntoId'];
  });

  test('Breakouts are assigned with target per room', () async {
    var discussion = Discussion(
      id: '123412837',
      status: DiscussionStatus.active,
      juntoId: juntoId,
      topicId: topicId,
      creatorId: userId,
      nullableDiscussionType: DiscussionType.hosted,
      collectionPath: '',
      agendaItems: [AgendaItem(id: '555', title: "Role call", content: "Shout out if you're here")],
    );
    discussion = await discussionTestUtils.createDiscussion(discussion: discussion, userId: userId);

    // add 4 participants
    await discussionTestUtils.joinDiscussionMultiple(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussion.id,
      participantIds: ['333', '444', '555', '666'],
      breakoutSessionId: breakoutSessionId,
    );

    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(discussion),
      meetingEvent: LiveMeetingEvent(
        agendaItem: discussion.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    await liveMeetingTestUtils.initiateBreakoutSession(
      discussion: discussion,
      breakoutSessionId: breakoutSessionId,
      userId: userId,
    );

    final req = CheckAssignToBreakoutsRequest(
      discussionPath: discussion.fullPath,
      breakoutSessionId: breakoutSessionId,
    );

    final assigner = CheckAssignToBreakouts();

    await assigner.action(req, CallableContext(userId, null, 'fakeInstanceId'));

    // Verify breakout room session was created
    final breakoutSessionPath = liveMeetingTestUtils.getBreakoutSessionDoc(
      discussion: discussion,
      breakoutSessionId: breakoutSessionId,
    );
    final breakoutSession = await firestore.document(breakoutSessionPath).get();
    final createdBreakoutSession = BreakoutRoomSession.fromJson(
      firestoreUtils.fromFirestoreJson(breakoutSession.data.toMap()),
    );

    final expectedBreakout = BreakoutRoomSession(
      breakoutRoomSessionId: breakoutSessionId,
      breakoutRoomStatus: BreakoutRoomStatus.active,
      assignmentMethod: BreakoutAssignmentMethod.targetPerRoom,
      targetParticipantsPerRoom: 2,
      hasWaitingRoom: false,
      statusUpdatedTime: createdBreakoutSession.statusUpdatedTime,
      maxRoomNumber: 2,
      createdDate: createdBreakoutSession.createdDate,
    );

    expect(createdBreakoutSession, equals(expectedBreakout));

    // get rooms and verify participants assigned to them
    final breakoutRoomsPath = liveMeetingTestUtils.getBreakoutRoomsCollection(
      discussion: discussion,
      breakoutSessionId: breakoutSessionId,
    );
    final breakoutRooms = await firestore.collection(breakoutRoomsPath).get();
    expect(breakoutRooms.documents.length, 2);

    final room1Ref = await firestore
        .collection(breakoutRoomsPath)
        .where(BreakoutRoom.kFieldRoomName, isEqualTo: '1')
        .get();
    final room1 =
        BreakoutRoom.fromJson(firestoreUtils.fromFirestoreJson(room1Ref.documents[0].data.toMap()));

    final expectedRoom1 = BreakoutRoom(
      roomId: room1.roomId,
      roomName: '1',
      creatorId: userId,
      createdDate: room1.createdDate,
      orderingPriority: 0,
      participantIds: ['333', '555'],
      originalParticipantIdsAssignment: ['333', '555'],
    );
    expect(room1, equals(expectedRoom1));

    final room2Ref = await firestore
        .collection(breakoutRoomsPath)
        .where(BreakoutRoom.kFieldRoomName, isEqualTo: '2')
        .get();
    final room2 =
        BreakoutRoom.fromJson(firestoreUtils.fromFirestoreJson(room2Ref.documents[0].data.toMap()));

    final expectedRoom2 = BreakoutRoom(
      roomId: room2.roomId,
      roomName: '2',
      creatorId: userId,
      createdDate: room2.createdDate,
      orderingPriority: 1,
      participantIds: ['444', '666'],
      originalParticipantIdsAssignment: ['444', '666'],
    );
    expect(room2, equals(expectedRoom2));
  });

  test('Breakouts are assigned with smart matching unmatched participants', () async {
    var discussion = Discussion(
      id: '12341283789',
      status: DiscussionStatus.active,
      juntoId: juntoId,
      topicId: topicId,
      creatorId: userId,
      nullableDiscussionType: DiscussionType.hosted,
      collectionPath: '',
      agendaItems: [AgendaItem(id: '555', title: "Role call", content: "Shout out if you're here")],
    );
    discussion = await discussionTestUtils.createDiscussion(discussion: discussion, userId: userId);

    // add 4 participants
    await discussionTestUtils.joinDiscussionMultiple(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussion.id,
      participantIds: ['333', '444', '555', '666'],
      breakoutSessionId: breakoutSessionId,
    );

    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(discussion),
      meetingEvent: LiveMeetingEvent(
        agendaItem: discussion.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    await liveMeetingTestUtils.initiateBreakoutSession(
        discussion: discussion,
        breakoutSessionId: breakoutSessionId,
        userId: userId,
        assignmentMethod: BreakoutAssignmentMethod.smartMatch);

    final req = CheckAssignToBreakoutsRequest(
      discussionPath: discussion.fullPath,
      breakoutSessionId: breakoutSessionId,
    );

    final assigner = CheckAssignToBreakouts();

    await assigner.action(req, CallableContext(userId, null, 'fakeInstanceId'));

    // Verify breakout room session was created
    final breakoutSessionPath = liveMeetingTestUtils.getBreakoutSessionDoc(
      discussion: discussion,
      breakoutSessionId: breakoutSessionId,
    );
    final breakoutSession = await firestore.document(breakoutSessionPath).get();
    final createdBreakoutSession = BreakoutRoomSession.fromJson(
      firestoreUtils.fromFirestoreJson(breakoutSession.data.toMap()),
    );

    final expectedBreakout = BreakoutRoomSession(
      breakoutRoomSessionId: breakoutSessionId,
      breakoutRoomStatus: BreakoutRoomStatus.active,
      assignmentMethod: BreakoutAssignmentMethod.smartMatch,
      targetParticipantsPerRoom: 2,
      hasWaitingRoom: false,
      statusUpdatedTime: createdBreakoutSession.statusUpdatedTime,
      maxRoomNumber: 2,
      createdDate: createdBreakoutSession.createdDate,
    );

    expect(createdBreakoutSession, equals(expectedBreakout));

    // get rooms and verify participants assigned to them
    final breakoutRoomsPath = liveMeetingTestUtils.getBreakoutRoomsCollection(
      discussion: discussion,
      breakoutSessionId: breakoutSessionId,
    );
    final breakoutRooms = await firestore.collection(breakoutRoomsPath).get();
    expect(breakoutRooms.documents.length, 2);

    final room1Ref = await firestore
        .collection(breakoutRoomsPath)
        .where(BreakoutRoom.kFieldRoomName, isEqualTo: '1')
        .get();
    final room1 =
        BreakoutRoom.fromJson(firestoreUtils.fromFirestoreJson(room1Ref.documents[0].data.toMap()));

    final expectedRoom1 = BreakoutRoom(
      roomId: room1.roomId,
      roomName: '1',
      creatorId: userId,
      createdDate: room1.createdDate,
      orderingPriority: 0,
      participantIds: ['333', '444'],
      originalParticipantIdsAssignment: ['333', '444'],
    );
    expect(room1, equals(expectedRoom1));

    final room2Ref = await firestore
        .collection(breakoutRoomsPath)
        .where(BreakoutRoom.kFieldRoomName, isEqualTo: '2')
        .get();
    final room2 =
        BreakoutRoom.fromJson(firestoreUtils.fromFirestoreJson(room2Ref.documents[0].data.toMap()));

    final expectedRoom2 = BreakoutRoom(
      roomId: room2.roomId,
      roomName: '2',
      creatorId: userId,
      createdDate: room2.createdDate,
      orderingPriority: 1,
      participantIds: ['555', '666'],
      originalParticipantIdsAssignment: ['555', '666'],
    );
    expect(room2, equals(expectedRoom2));
  });
}
