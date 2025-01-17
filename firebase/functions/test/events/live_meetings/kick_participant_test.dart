import 'package:data_models/community/membership.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/kick_participant.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  late String communityId;
  const targetUserId = 'testUser2';
  const templateId = '9654';
  const liveMeetingId = 'testMeeting123';
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  late Event testEvent;
  late MockAgoraUtils mockAgoraUtils;
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityUtils.createTestCommunity();

    // Create test event
    testEvent = Event(
      id: '5678',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hostless,
      collectionPath: '',
    );
    testEvent = await eventUtils.createEvent(
      event: testEvent,
      userId: adminUserId,
    );

    // Add participant
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: targetUserId,
      participantStatus: ParticipantStatus.active,
    );
    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(testEvent),
      liveMeetingId: liveMeetingId,
      meetingEvent: LiveMeetingEvent(
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    mockAgoraUtils = MockAgoraUtils();
    when(
      () => mockAgoraUtils.kickParticipant(
        roomId: any(named: 'roomId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) => Future.value());
  });

  test('Event creator can successfully kick participant', () async {
    final req = KickParticipantRequest(
      eventPath: testEvent.fullPath,
      userToKickId: targetUserId,
      breakoutRoomId: null,
    );

    final kickParticipant = KickParticipant(agoraUtils: mockAgoraUtils);

    await kickParticipant.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    verify(
      () => mockAgoraUtils.kickParticipant(
        roomId: liveMeetingId,
        userId: targetUserId,
      ),
    ).called(1);
  });

  test('Moderator can successfully kick participant', () async {
    // Create moderator user
    const modUserId = 'modUser';
    await communityUtils.addCommunityMember(
      communityId: communityId,
      userId: modUserId,
      status: MembershipStatus.mod,
    );

    final req = KickParticipantRequest(
      eventPath: testEvent.fullPath,
      userToKickId: targetUserId,
      breakoutRoomId: null,
    );

    final kickParticipant = KickParticipant(agoraUtils: mockAgoraUtils);

    await kickParticipant.action(
      req,
      CallableContext(modUserId, null, 'fakeInstanceId'),
    );

    verify(
      () => mockAgoraUtils.kickParticipant(
        roomId: liveMeetingId,
        userId: targetUserId,
      ),
    ).called(1);
  });

  test('Regular user cannot kick participant', () async {
    // Create regular user
    const regularUserId = 'regularUser';
    await communityUtils.addCommunityMember(
      communityId: communityId,
      userId: regularUserId,
      status: MembershipStatus.member,
    );

    final req = KickParticipantRequest(
      eventPath: testEvent.fullPath,
      userToKickId: targetUserId,
      breakoutRoomId: null,
    );

    final kickParticipant = KickParticipant();

    expect(
      () => kickParticipant.action(
        req,
        CallableContext(regularUserId, null, 'fakeInstanceId'),
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

  test('Successfully kicks participant from breakout room', () async {
    const breakoutRoomId = 'breakoutRoom123';
    final req = KickParticipantRequest(
      eventPath: testEvent.fullPath,
      userToKickId: targetUserId,
      breakoutRoomId: breakoutRoomId,
    );

    final kickParticipant = KickParticipant(agoraUtils: mockAgoraUtils);

    await kickParticipant.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    verify(
      () => mockAgoraUtils.kickParticipant(
        roomId: breakoutRoomId,
        userId: targetUserId,
      ),
    ).called(1);
  });
}
