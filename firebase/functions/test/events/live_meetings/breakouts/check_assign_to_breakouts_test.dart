import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:get_it/get_it.dart';
import 'package:functions/events/live_meetings/breakouts/check_assign_to_breakouts.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/community.dart';
import 'package:data_models/firestore/live_meeting.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import 'package:uuid/uuid.dart';

import '../../../util/community_test_utils.dart';
import '../../../util/event_test_utils.dart';
import '../../../util/live_meeting_test_utils.dart';

void main() {
  String communityId = '';
  const userId = 'fakeAuthId';
  const templateId = '9654';
  const uuid = Uuid();
  final breakoutSessionId = uuid.v1().toString();
  GetIt.instance.registerSingleton(const Uuid());
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  final liveMeetingTestUtils = LiveMeetingTestUtils();

  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);

    final testCommunity = Community(
      id: '12349999',
      name: 'Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    final communityResult = await communityTestUtils.createCommunity(
      community: testCommunity,
      userId: userId,
    );
    communityId = communityResult['communityId'];
  });

  test('Breakouts are assigned with target per room', () async {
    var event = Event(
      id: '123412837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '555',
          title: "Role call",
          content: "Shout out if you're here",
        ),
      ],
    );
    event = await eventTestUtils.createEvent(
      event: event,
      userId: userId,
    );

    // add 4 participants
    await eventTestUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: ['333', '444', '555', '666'],
      breakoutSessionId: breakoutSessionId,
    );

    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(event),
      meetingEvent: LiveMeetingEvent(
        agendaItem: event.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    await liveMeetingTestUtils.initiateBreakoutSession(
      event: event,
      breakoutSessionId: breakoutSessionId,
      userId: userId,
    );

    final req = CheckAssignToBreakoutsRequest(
      eventPath: event.fullPath,
      breakoutSessionId: breakoutSessionId,
    );

    final assigner = CheckAssignToBreakouts();

    await assigner.action(req, CallableContext(userId, null, 'fakeInstanceId'));

    // Verify breakout room session was created
    final breakoutSessionPath = liveMeetingTestUtils.getBreakoutSessionDoc(
      event: event,
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
      event: event,
      breakoutSessionId: breakoutSessionId,
    );
    final breakoutRooms = await firestore.collection(breakoutRoomsPath).get();
    expect(breakoutRooms.documents.length, 2);

    final room1Ref = await firestore
        .collection(breakoutRoomsPath)
        .where(BreakoutRoom.kFieldRoomName, isEqualTo: '1')
        .get();
    final room1 = BreakoutRoom.fromJson(
      firestoreUtils.fromFirestoreJson(room1Ref.documents[0].data.toMap()),
    );

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
    final room2 = BreakoutRoom.fromJson(
      firestoreUtils.fromFirestoreJson(room2Ref.documents[0].data.toMap()),
    );

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

  test('Breakouts are assigned with smart matching unmatched participants',
      () async {
    var event = Event(
      id: '12341283789',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '555',
          title: "Role call",
          content: "Shout out if you're here",
        ),
      ],
    );
    event = await eventTestUtils.createEvent(
      event: event,
      userId: userId,
    );

    // add 4 participants
    await eventTestUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: ['333', '444', '555', '666'],
      breakoutSessionId: breakoutSessionId,
    );

    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(event),
      meetingEvent: LiveMeetingEvent(
        agendaItem: event.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    await liveMeetingTestUtils.initiateBreakoutSession(
      event: event,
      breakoutSessionId: breakoutSessionId,
      userId: userId,
      assignmentMethod: BreakoutAssignmentMethod.smartMatch,
    );

    final req = CheckAssignToBreakoutsRequest(
      eventPath: event.fullPath,
      breakoutSessionId: breakoutSessionId,
    );

    final assigner = CheckAssignToBreakouts();

    await assigner.action(req, CallableContext(userId, null, 'fakeInstanceId'));

    // Verify breakout room session was created
    final breakoutSessionPath = liveMeetingTestUtils.getBreakoutSessionDoc(
      event: event,
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
      event: event,
      breakoutSessionId: breakoutSessionId,
    );
    final breakoutRooms = await firestore.collection(breakoutRoomsPath).get();
    expect(breakoutRooms.documents.length, 2);

    final room1Ref = await firestore
        .collection(breakoutRoomsPath)
        .where(BreakoutRoom.kFieldRoomName, isEqualTo: '1')
        .get();
    final room1 = BreakoutRoom.fromJson(
      firestoreUtils.fromFirestoreJson(room1Ref.documents[0].data.toMap()),
    );

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
    final room2 = BreakoutRoom.fromJson(
      firestoreUtils.fromFirestoreJson(room2Ref.documents[0].data.toMap()),
    );

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
