import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/breakouts/check_hostless_go_to_breakouts.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import '../../../util/community_test_utils.dart';
import '../../../util/event_test_utils.dart';
import '../../../util/function_test_fixture.dart';
import '../../../util/live_meeting_test_utils.dart';

void main() {
  late String communityId;
  const templateId = '9654';
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityTestUtils.createTestCommunity();
  });

  test('Breakouts are initiated for a hostless event', () async {
    var event = Event(
      id: '1234',
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
      scheduledTime: DateTime.now().subtract(const Duration(minutes: 5)),
      waitingRoomInfo: const WaitingRoomInfo(durationSeconds: 60),
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

    final req = CheckHostlessGoToBreakoutsRequest(eventPath: event.fullPath);
    final checker = CheckHostlessGoToBreakouts();
    // We may be able to reorganize to mock out the functions scheduler to avoid exception
    try {
      await checker.action(
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
      breakoutRoomSessionId: event.id, // this is expected for hostless events
      breakoutRoomStatus: BreakoutRoomStatus.pending,
      assignmentMethod: BreakoutAssignmentMethod.targetPerRoom,
      targetParticipantsPerRoom: 8, //default
      hasWaitingRoom: true,
      statusUpdatedTime: meeting.currentBreakoutSession!.statusUpdatedTime,
      createdDate: meeting.currentBreakoutSession!.createdDate,
      scheduledTime: meeting.currentBreakoutSession!.scheduledTime,
    );

    expect(meeting.currentBreakoutSession, equals(expectedBreakout));
  });
}
