import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:get_it/get_it.dart';
import 'package:functions/events/live_meetings/breakouts/get_breakout_room_assignment.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:uuid/uuid.dart';
import '../../../util/community_test_utils.dart';
import '../../../util/event_test_utils.dart';
import '../../../util/function_test_fixture.dart';
import '../../../util/live_meeting_test_utils.dart';

void main() {
  String communityId = '';
  const templateId = '9654';
  const uuid = Uuid();
  final breakoutSessionId = uuid.v1().toString();
  GetIt.instance.registerSingleton(const Uuid());
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  final liveMeetingUtils = LiveMeetingTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityUtils.createTestCommunity();
  });

  test('Room assignment is returned', () async {
    var event = Event(
      id: '5678',
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
    event = await eventUtils.createEvent(
      event: event,
      userId: adminUserId,
    );

    await eventUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: ['333', '444', '555', '666'],
      breakoutSessionId: breakoutSessionId,
    );

    // add Community members
    await communityUtils.addCommunityMember(
      userId: '333',
      communityId: communityId,
    );
    await communityUtils.addCommunityMember(
      userId: '444',
      communityId: communityId,
    );
    await communityUtils.addCommunityMember(
      userId: '555',
      communityId: communityId,
    );
    await communityUtils.addCommunityMember(
      userId: '666',
      communityId: communityId,
    );

    await liveMeetingUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingUtils.getLiveMeetingPath(event),
      meetingEvent: LiveMeetingEvent(
        agendaItem: event.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    await liveMeetingUtils.initiateBreakoutSession(
      event: event,
      breakoutSessionId: breakoutSessionId,
      userId: adminUserId,
    );

    // Retrieve a created breakout room
    final breakoutRoom = await liveMeetingUtils.getBreakoutRoom(
      event: event,
      breakoutSessionId: breakoutSessionId,
      roomName: '1',
    );

    final req = GetBreakoutRoomAssignmentRequest(
      eventId: event.id,
      eventPath: event.fullPath,
    );

    final roomInfo = GetBreakoutRoomAssignment();

    //First user should have been put into room 1 by bucket assignment
    final result = await roomInfo.action(
      req,
      CallableContext('333', null, 'fakeInstanceId'),
    );
    final expectedResult = {'roomId': breakoutRoom.roomId};
    expect(result, equals(expectedResult));
  });
}
