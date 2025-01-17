import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:get_it/get_it.dart';
import 'package:functions/events/live_meetings/breakouts/initiate_breakouts.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:uuid/uuid.dart';

import '../../../util/community_test_utils.dart';
import '../../../util/event_test_utils.dart';
import '../../../util/function_test_fixture.dart';
import '../../../util/live_meeting_test_utils.dart';

void main() {
  late String communityId;
  const templateId = '9654';
  const uuid = Uuid();
  final breakoutSessionId = uuid.v1().toString();
  GetIt.instance.registerSingleton(const Uuid());
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityTestUtils.createTestCommunity();
  });

  test('Breakouts are initiated for a hosted event', () async {
    var event = Event(
      id: '07482735',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
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
      userId: adminUserId,
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

    final req = InitiateBreakoutsRequest(
      eventPath: event.fullPath,
      targetParticipantsPerRoom: 2,
      breakoutSessionId: breakoutSessionId,
    );
    final assigner = InitiateBreakouts();

    await assigner.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

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
      creatorId: adminUserId,
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
      creatorId: adminUserId,
      createdDate: room2.createdDate,
      orderingPriority: 1,
      participantIds: ['444', '666'],
      originalParticipantIdsAssignment: ['444', '666'],
    );
    expect(room2, equals(expectedRoom2));
  });

  test('Breakouts are initiated for a hostless event', () async {
    var event = Event(
      id: '07482735',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hostless,
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
      userId: adminUserId,
    );
    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(event),
      meetingEvent: LiveMeetingEvent(
        agendaItem: event.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    final req = InitiateBreakoutsRequest(
      eventPath: event.fullPath,
      targetParticipantsPerRoom: 2,
      breakoutSessionId: breakoutSessionId,
      assignmentMethod: BreakoutAssignmentMethod.category,
      includeWaitingRoom: true,
    );
    final assigner = InitiateBreakouts();

    // TODO we may be able to reorganize to mock out the functions scheduler to avoid exception
    try {
      await assigner.action(
        req,
        CallableContext(adminUserId, null, 'fakeInstanceId'),
      );
    } catch (e) {
      //Expect enqueuing to fail, can proceed with validating that the data was updated
    }

    final meetingRef = await firestore
        .document(liveMeetingTestUtils.getLiveMeetingPath(event))
        .get();
    final meeting = LiveMeeting.fromJson(
      firestoreUtils.fromFirestoreJson(meetingRef.data.toMap()),
    );
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

  test(
      'Breakouts not initiated for a hostless event where session already initiated',
      () async {
    var event = Event(
      id: '07482735',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hostless,
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
      userId: adminUserId,
    );

    final expectedBreakout = BreakoutRoomSession(
      breakoutRoomSessionId: breakoutSessionId,
      breakoutRoomStatus: BreakoutRoomStatus.pending,
      assignmentMethod: BreakoutAssignmentMethod.category,
      targetParticipantsPerRoom: 2,
      hasWaitingRoom: true,
    );

    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(event),
      meetingEvent: LiveMeetingEvent(
        agendaItem: event.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
      currentBreakoutSession: expectedBreakout,
    );

    final req = InitiateBreakoutsRequest(
      eventPath: event.fullPath,
      targetParticipantsPerRoom: 2,
      breakoutSessionId: breakoutSessionId,
      assignmentMethod: BreakoutAssignmentMethod.category,
      includeWaitingRoom: true,
    );
    final assigner = InitiateBreakouts();

    // no exception currently means it didn't try to enqueue request to initiate breakouts since already initiated
    await assigner.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );
  });

  test(
      'Breakouts are initiated for a hostless event with a different breakout session ID',
      () async {
    var event = Event(
      id: '07482735',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hostless,
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
      userId: adminUserId,
    );

    final currentBreakout = BreakoutRoomSession(
      breakoutRoomSessionId: 'notTheRightOne',
      breakoutRoomStatus: BreakoutRoomStatus.inactive,
      assignmentMethod: BreakoutAssignmentMethod.category,
      targetParticipantsPerRoom: 2,
      hasWaitingRoom: true,
    );

    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(event),
      meetingEvent: LiveMeetingEvent(
        agendaItem: event.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
      currentBreakoutSession: currentBreakout,
    );

    final req = InitiateBreakoutsRequest(
      eventPath: event.fullPath,
      targetParticipantsPerRoom: 2,
      breakoutSessionId: breakoutSessionId,
      assignmentMethod: BreakoutAssignmentMethod.category,
      includeWaitingRoom: true,
    );
    final assigner = InitiateBreakouts();

    // TODO we may be able to reorganize to mock out the functions scheduler to avoid exception
    try {
      await assigner.action(
        req,
        CallableContext(adminUserId, null, 'fakeInstanceId'),
      );
    } catch (e) {
      //Expect enqueuing to fail, can proceed with validating that the data was updated
    }

    // verify breakout room session was updated
    final meetingRef = await firestore
        .document(liveMeetingTestUtils.getLiveMeetingPath(event))
        .get();
    final meeting = LiveMeeting.fromJson(
      firestoreUtils.fromFirestoreJson(meetingRef.data.toMap()),
    );
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
