import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/live_meeting_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:functions/events/live_meetings/get_meeting_join_info.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:uuid/uuid.dart';
import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  String communityId = '';
  const userId = 'fakeAuthId';
  const templateId = '9654';
  GetIt.instance.registerSingleton(const Uuid());
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityUtils.createTestCommunity();
  });

  test('Meeting join info is returned for active participant', () async {
    // Create test event
    var event = Event(
      id: '5678',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '555',
          title: "Test Agenda",
          content: "Test Content",
        ),
      ],
    );
    event = await eventUtils.createEvent(
      event: event,
      userId: userId,
    );

    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(event),
      meetingEvent: LiveMeetingEvent(
        agendaItem: event.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    // Create test public user info
    final publicUserInfo = PublicUserInfo(
      id: userId,
      displayName: 'Test User',
      agoraId: 123,
      imageUrl: 'http://example.com/image.jpg',
    );

    await liveMeetingTestUtils.addPublicUser(publicUser: publicUserInfo);

    final req = GetMeetingJoinInfoRequest(
      eventPath: event.fullPath,
    );
    final agoraUtils = MockAgoraUtils();
    when(
      () => agoraUtils.createToken(
        uid: liveMeetingTestUtils.uidToInt(userId),
        roomId: event.id,
      ),
    ).thenReturn('fakeToken');

    final getMeetingJoinInfo = GetMeetingJoinInfo(
      liveMeetingUtils: LiveMeetingUtils(agoraUtils: agoraUtils),
    );

    final result = await getMeetingJoinInfo.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );

    expect(result, isA<Map<String, dynamic>>());
    expect(result['identity'], equals(userId));
    expect(result['meetingToken'], equals('fakeToken'));
    expect(result['meetingId'], equals(event.id));
  });

  test('Throws unauthorized error for inactive participant', () async {
    var event = Event(
      id: '5678',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [],
    );
    event = await eventUtils.createEvent(
      event: event,
      userId: userId,
    );

    // Join event as inactive participant
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      uid: userId,
      participantStatus: ParticipantStatus.banned,
    );

    final req = GetMeetingJoinInfoRequest(
      eventPath: event.fullPath,
    );

    final getMeetingJoinInfo = GetMeetingJoinInfo();

    expect(
      () => getMeetingJoinInfo.action(
        req,
        CallableContext(userId, null, 'fakeInstanceId'),
      ),
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.failedPrecondition &&
              e.message == 'unauthorized',
        ),
      ),
    );
  });
}
