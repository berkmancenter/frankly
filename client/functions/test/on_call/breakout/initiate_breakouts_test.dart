import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:get_it/get_it.dart';
import 'package:junto_functions/functions/on_call/initiate_breakouts.dart';
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
      id: '9966',
      name: 'Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    final juntoResult = await communityTestUtils.createJunto(junto: testJunto, userId: userId);
    juntoId = juntoResult['juntoId'];
  });

  test('Breakouts are initiated for a hosted event', () async {
    var discussion = Discussion(
      id: '07482735',
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

    final req = InitiateBreakoutsRequest(
      discussionPath: discussion.fullPath,
      targetParticipantsPerRoom: 2,
      breakoutSessionId: breakoutSessionId,
    );
    final assigner = InitiateBreakouts();

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

  test('Breakouts are initiated for a hostless event', () async {
    var discussion = Discussion(
      id: '07482735',
      status: DiscussionStatus.active,
      juntoId: juntoId,
      topicId: topicId,
      creatorId: userId,
      nullableDiscussionType: DiscussionType.hostless,
      collectionPath: '',
      agendaItems: [AgendaItem(id: '555', title: "Role call", content: "Shout out if you're here")],
    );
    discussion = await discussionTestUtils.createDiscussion(discussion: discussion, userId: userId);
    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(discussion),
      meetingEvent: LiveMeetingEvent(
        agendaItem: discussion.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    final req = InitiateBreakoutsRequest(
      discussionPath: discussion.fullPath,
      targetParticipantsPerRoom: 2,
      breakoutSessionId: breakoutSessionId,
      assignmentMethod: BreakoutAssignmentMethod.category,
      includeWaitingRoom: true,
    );
    final assigner = InitiateBreakouts();

    // TODO we may be able to reorganize to mock out the functions scheduler to avoid exception
    try {
      await assigner.action(req, CallableContext(userId, null, 'fakeInstanceId'));
    } catch (e) {
      //Expect enqueuing to fail, can proceed with validating that the data was updated
    }

    final meetingRef =
        await firestore.document(liveMeetingTestUtils.getLiveMeetingPath(discussion)).get();
    final meeting = LiveMeeting.fromJson(firestoreUtils.fromFirestoreJson(meetingRef.data.toMap()));
    expect(meeting.currentBreakoutSession, isNotNull);

    final expectedBreakout = BreakoutRoomSession(
      breakoutRoomSessionId: breakoutSessionId,
      breakoutRoomStatus: BreakoutRoomStatus.pending,
      assignmentMethod: BreakoutAssignmentMethod.category,
      targetParticipantsPerRoom: 2,
      hasWaitingRoom: true,
      statusUpdatedTime: meeting.currentBreakoutSession!.statusUpdatedTime,
      createdDate: meeting.currentBreakoutSession!.createdDate,
      scheduledTime: meeting.currentBreakoutSession!.scheduledTime,
    );

    expect(meeting.currentBreakoutSession, equals(expectedBreakout));
  });

  test('Breakouts not initiated for a hostless event where session already initiated', () async {
    var discussion = Discussion(
      id: '07482735',
      status: DiscussionStatus.active,
      juntoId: juntoId,
      topicId: topicId,
      creatorId: userId,
      nullableDiscussionType: DiscussionType.hostless,
      collectionPath: '',
      agendaItems: [AgendaItem(id: '555', title: "Role call", content: "Shout out if you're here")],
    );
    discussion = await discussionTestUtils.createDiscussion(discussion: discussion, userId: userId);

    final expectedBreakout = BreakoutRoomSession(
      breakoutRoomSessionId: breakoutSessionId,
      breakoutRoomStatus: BreakoutRoomStatus.pending,
      assignmentMethod: BreakoutAssignmentMethod.category,
      targetParticipantsPerRoom: 2,
      hasWaitingRoom: true,
    );

    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(discussion),
      meetingEvent: LiveMeetingEvent(
        agendaItem: discussion.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
      currentBreakoutSession: expectedBreakout,
    );

    final req = InitiateBreakoutsRequest(
      discussionPath: discussion.fullPath,
      targetParticipantsPerRoom: 2,
      breakoutSessionId: breakoutSessionId,
      assignmentMethod: BreakoutAssignmentMethod.category,
      includeWaitingRoom: true,
    );
    final assigner = InitiateBreakouts();

    // no exception currently means it didn't try to enqueue request to initiate breakouts since already initiated
    await assigner.action(req, CallableContext(userId, null, 'fakeInstanceId'));
  });

  test('Breakouts are initiated for a hostless event with a different breakout session ID',
      () async {
    var discussion = Discussion(
      id: '07482735',
      status: DiscussionStatus.active,
      juntoId: juntoId,
      topicId: topicId,
      creatorId: userId,
      nullableDiscussionType: DiscussionType.hostless,
      collectionPath: '',
      agendaItems: [AgendaItem(id: '555', title: "Role call", content: "Shout out if you're here")],
    );
    discussion = await discussionTestUtils.createDiscussion(discussion: discussion, userId: userId);

    final currentBreakout = BreakoutRoomSession(
      breakoutRoomSessionId: 'notTheRightOne',
      breakoutRoomStatus: BreakoutRoomStatus.inactive,
      assignmentMethod: BreakoutAssignmentMethod.category,
      targetParticipantsPerRoom: 2,
      hasWaitingRoom: true,
    );

    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(discussion),
      meetingEvent: LiveMeetingEvent(
        agendaItem: discussion.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
      currentBreakoutSession: currentBreakout,
    );

    final req = InitiateBreakoutsRequest(
      discussionPath: discussion.fullPath,
      targetParticipantsPerRoom: 2,
      breakoutSessionId: breakoutSessionId,
      assignmentMethod: BreakoutAssignmentMethod.category,
      includeWaitingRoom: true,
    );
    final assigner = InitiateBreakouts();

    // TODO we may be able to reorganize to mock out the functions scheduler to avoid exception
    try {
      await assigner.action(req, CallableContext(userId, null, 'fakeInstanceId'));
    } catch (e) {
      //Expect enqueuing to fail, can proceed with validating that the data was updated
    }

    // verify breakout room session was updated
    final meetingRef =
        await firestore.document(liveMeetingTestUtils.getLiveMeetingPath(discussion)).get();
    final meeting = LiveMeeting.fromJson(firestoreUtils.fromFirestoreJson(meetingRef.data.toMap()));
    expect(meeting.currentBreakoutSession, isNotNull);

    final expectedBreakout = BreakoutRoomSession(
      breakoutRoomSessionId: breakoutSessionId,
      breakoutRoomStatus: BreakoutRoomStatus.pending,
      assignmentMethod: BreakoutAssignmentMethod.category,
      targetParticipantsPerRoom: 2,
      hasWaitingRoom: true,
      statusUpdatedTime: meeting.currentBreakoutSession!.statusUpdatedTime,
      createdDate: meeting.currentBreakoutSession!.createdDate,
      scheduledTime: meeting.currentBreakoutSession!.scheduledTime,
    );

    expect(meeting.currentBreakoutSession, equals(expectedBreakout));
  });
}
