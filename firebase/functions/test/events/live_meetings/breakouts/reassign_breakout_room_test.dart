import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:get_it/get_it.dart';
import 'package:functions/events/live_meetings/breakouts/reassign_breakout_room.dart';

import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
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
  const userId = 'fakeAuthId';
  const templateId = '9654';
  const uuid = Uuid();
  final breakoutSessionId = uuid.v1().toString();
  GetIt.instance.registerSingleton(const Uuid());
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  final liveMeetingUtils = LiveMeetingTestUtils();
  setupTestFixture();

  setUp(() async {
    final testCommunity = Community(
      id: '175ff',
      name: 'Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    final communityResult = await communityUtils.createCommunity(
      community: testCommunity,
      userId: userId,
    );
    communityId = communityResult['communityId'];
  });

  test('Participant is reassigned to specified breakout room', () async {
    var event = Event(
      id: '00001',
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
    event = await eventUtils.createEvent(
      event: event,
      userId: userId,
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
      userId: userId,
    );

    final req = ReassignBreakoutRoomRequest(
      eventPath: event.fullPath,
      breakoutRoomSessionId: breakoutSessionId,
      userId: '333',
      newRoomNumber: '2',
    );
    final assigner = ReassignBreakoutRoom();

    final result = await assigner.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );
    expect(result?['roomName'], equals('2'));
    expect(result?['participantIds'], equals(['444', '666', '333']));
  });
}
