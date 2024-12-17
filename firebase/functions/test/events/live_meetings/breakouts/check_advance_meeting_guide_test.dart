import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:get_it/get_it.dart';
import 'package:functions/events/live_meetings/breakouts/check_advance_meeting_guide.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/firestore_utils.dart';
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

  test('Agenda is advanced when half the participants are ready', () async {
    var event = Event(
      id: '12341dff2837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
      nullableEventType: EventType
          .hosted, //intentionally set to hosted even though we are simulating a hostless event to avoid enqueueing the CheckAssignToBreakoutServer, which causes an error
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '55005',
          title: "Role call",
          content: "Shout out if you're here",
        ),
      ],
    );
    event = await eventTestUtils.createEvent(
      event: event,
      userId: userId,
    );

    // add 8 participants
    await eventTestUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: ['333', '444', '555', '666', '777', '888', '999', '000'],
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

    final breakoutRoom = await liveMeetingTestUtils.getBreakoutRoom(
      event: event,
      breakoutSessionId: breakoutSessionId,
      roomName: '1',
    );

    final guideAdvancer = CheckAdvanceMeetingGuide();
    final req = CheckAdvanceMeetingGuideRequest(
      eventPath: event.fullPath,
      presentIds: ['333', '555', '777', '999'],
      userReadyAgendaId: event.agendaItems.first.id,
      breakoutRoomId: breakoutRoom.roomId,
      breakoutSessionId: breakoutSessionId,
    );

    await guideAdvancer.action(
      req,
      CallableContext('333', null, 'fakeInstanceId'),
    );
    // check participant marked as ready
    final documentId =
        '${liveMeetingTestUtils.getBreakoutLiveMeetingPath(breakoutRoomId: breakoutRoom.roomId, event: event, breakoutSessionId: breakoutSessionId)}/participant-agenda-item-details/${event.agendaItems.first.id}/participant-details/333';
    final participantDetailsDoc = await firestore.document(documentId).get();
    final createdDetails = ParticipantAgendaItemDetails.fromJson(
      firestoreUtils.fromFirestoreJson(participantDetailsDoc.data.toMap()),
    );
    final expectedDetails = ParticipantAgendaItemDetails(
      userId: '333',
      agendaItemId: '55005',
      meetingId: createdDetails.meetingId,
      readyToAdvance: true,
    );
    expect(createdDetails, equals(expectedDetails));

    // call again with another participant, which should be enough to advance (half of total participants)
    await guideAdvancer.action(
      req,
      CallableContext('555', null, 'fakeInstanceId'),
    );

    final meetingPathSnap = await firestore
        .document(
          liveMeetingTestUtils.getBreakoutLiveMeetingPath(
            breakoutRoomId: breakoutRoom.roomId,
            event: event,
            breakoutSessionId: breakoutSessionId,
          ),
        )
        .get();
    // agenda should be advanced to finished
    final createdMeeting = LiveMeeting.fromJson(
      firestoreUtils.fromFirestoreJson(meetingPathSnap.data.toMap()),
    );
    expect(createdMeeting.events.length, equals(2));
    expect(
      createdMeeting.events[1].event,
      equals(LiveMeetingEventType.finishMeeting),
    );
  });

  test('Agenda is not advanced when less than half the participants are ready',
      () async {
    var event = Event(
      id: '12341dff2dfdf837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
      nullableEventType: EventType
          .hosted, //intentionally set to hosted even though we are simulating a hostless event to avoid enqueueing the CheckAssignToBreakoutServer, which causes an error
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '55005',
          title: "Role call",
          content: "Shout out if you're here",
        ),
      ],
    );
    event = await eventTestUtils.createEvent(
      event: event,
      userId: userId,
    );

    // add 8 participants
    await eventTestUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: ['333', '444', '555', '666', '777', '888', '999', '000'],
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

    final breakoutRoom = await liveMeetingTestUtils.getBreakoutRoom(
      event: event,
      breakoutSessionId: breakoutSessionId,
      roomName: '1',
    );

    final guideAdvancer = CheckAdvanceMeetingGuide();
    final req = CheckAdvanceMeetingGuideRequest(
      eventPath: event.fullPath,
      presentIds: ['333', '555', '777', '999'],
      userReadyAgendaId: event.agendaItems.first.id,
      breakoutRoomId: breakoutRoom.roomId,
      breakoutSessionId: breakoutSessionId,
    );

    await guideAdvancer.action(
      req,
      CallableContext('333', null, 'fakeInstanceId'),
    );
    // check participant marked as ready
    final documentId =
        '${liveMeetingTestUtils.getBreakoutLiveMeetingPath(breakoutRoomId: breakoutRoom.roomId, event: event, breakoutSessionId: breakoutSessionId)}/participant-agenda-item-details/${event.agendaItems.first.id}/participant-details/333';
    final participantDetailsDoc = await firestore.document(documentId).get();
    final createdDetails = ParticipantAgendaItemDetails.fromJson(
      firestoreUtils.fromFirestoreJson(participantDetailsDoc.data.toMap()),
    );
    final expectedDetails = ParticipantAgendaItemDetails(
      userId: '333',
      agendaItemId: '55005',
      meetingId: createdDetails.meetingId,
      readyToAdvance: true,
    );
    expect(createdDetails, equals(expectedDetails));

    final meetingPathSnap = await firestore
        .document(
          liveMeetingTestUtils.getBreakoutLiveMeetingPath(
            breakoutRoomId: breakoutRoom.roomId,
            event: event,
            breakoutSessionId: breakoutSessionId,
          ),
        )
        .get();
    // agenda should not be advanced
    final createdMeeting = LiveMeeting.fromJson(
      firestoreUtils.fromFirestoreJson(meetingPathSnap.data.toMap()),
    );
    expect(createdMeeting.events.length, equals(1));
    expect(
      createdMeeting.events[0].event,
      equals(LiveMeetingEventType.agendaItemStarted),
    );
  });
}
