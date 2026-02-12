import 'package:data_models/community/membership.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:data_models/user_input/poll_data.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/get_meeting_poll_data.dart';
import 'package:functions/utils/infra/firebase_auth_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  late String communityId;
  const templateId = '9654';
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  final mockFirebaseAuthUtils = MockFirebaseAuthUtils();
  firebaseAuthUtils = mockFirebaseAuthUtils;
  setupTestFixture();

  setUp(() async {
    communityId = await communityUtils.createTestCommunity();
  });

  test('Poll data is returned correctly for event creator', () async {
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
          id: '111',
          title: "Poll Question 1",
          content: "What is your favorite color?",
          nullableType: AgendaItemType.poll,
        ),
        AgendaItem(
          id: '222',
          title: "Poll Question 2",
          content: "How many years of experience?",
          nullableType: AgendaItemType.poll,
        ),
      ],
    );

    event = await eventUtils.createEvent(
      event: event,
      userId: adminUserId,
    );

    // Add test participants
    await eventUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: ['333', '444'],
      breakoutSessionId: null,
    );

    // Add Community members
    await communityUtils.addCommunityMember(
      userId: '333',
      communityId: communityId,
    );
    await communityUtils.addCommunityMember(
      userId: '444',
      communityId: communityId,
    );

    // Add public user info
    final publicUserInfo1 = PublicUserInfo(
      id: '333',
      displayName: 'Test User 1',
      agoraId: 123,
    );
    await liveMeetingTestUtils.addPublicUser(publicUser: publicUserInfo1);

    final publicUserInfo2 = PublicUserInfo(
      id: '444',
      displayName: 'Test User 2',
      agoraId: 456,
    );
    await liveMeetingTestUtils.addPublicUser(publicUser: publicUserInfo2);

    // Add poll responses
    final liveMeetingPath = liveMeetingTestUtils.getLiveMeetingPath(event);

    await liveMeetingTestUtils.addParticipantAgendaItemDetails(
      event: event,
      participantAgendaItemDetails: ParticipantAgendaItemDetails(
        userId: '333',
        meetingId: liveMeetingPath.split('/').last,
        pollResponse: 'Blue',
      ),
      agendaItemId: '111',
    );

    await liveMeetingTestUtils.addParticipantAgendaItemDetails(
      event: event,
      participantAgendaItemDetails: ParticipantAgendaItemDetails(
        userId: '444',
        meetingId: liveMeetingPath.split('/').last,
        pollResponse: '5-10 years',
      ),
      agendaItemId: '222',
    );

    // Mock auth utils
    final userRecord1 = MockUserRecord();
    when(() => userRecord1.uid).thenReturn('333');
    when(() => userRecord1.email).thenReturn('user1@example.com');
    when(() => userRecord1.displayName).thenReturn('Test User 1');
    when(() => mockFirebaseAuthUtils.getUser('333'))
        .thenAnswer((_) async => userRecord1);

    final userRecord2 = MockUserRecord();
    when(() => userRecord2.uid).thenReturn('444');
    when(() => userRecord2.email).thenReturn('user2@example.com');
    when(() => userRecord2.displayName).thenReturn('Test User 2');
    when(() => mockFirebaseAuthUtils.getUser('444'))
        .thenAnswer((_) async => userRecord2);

    final req = GetMeetingPollDataRequest(
      eventPath: event.fullPath,
    );

    final pollDataFunction = GetMeetingPollData();

    final result = await pollDataFunction.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    expect(result['polls'], isNotNull);
    final polls = (result['polls'] as List)
        .map((item) => PollData.fromJson(item))
        .toList();
    expect(polls.length, equals(2));

    // Verify first poll response
    final poll1 = polls.firstWhere((p) => p.agendaItemId == '111');
    expect(poll1.userId, equals('333'));
    expect(poll1.userName, equals('Test User 1'));
    expect(poll1.userEmail, equals('user1@example.com'));
    expect(poll1.pollQuestion, equals('What is your favorite color?'));
    expect(poll1.pollResponse, equals('Blue'));
    expect(poll1.roomId, equals(event.id));

    // Verify second poll response
    final poll2 = polls.firstWhere((p) => p.agendaItemId == '222');
    expect(poll2.userId, equals('444'));
    expect(poll2.userName, equals('Test User 2'));
    expect(poll2.userEmail, equals('user2@example.com'));
    expect(poll2.pollQuestion, equals('How many years of experience?'));
    expect(poll2.pollResponse, equals('5-10 years'));
    expect(poll2.roomId, equals(event.id));
  });

  test('Poll data is returned correctly for admin user', () async {
    // Add admin user to community
    await communityUtils.addCommunityMember(
      userId: adminUserId,
      communityId: communityId,
      status: MembershipStatus.admin,
    );

    var event = Event(
      id: '5679',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: '999',
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '333',
          title: "Admin Poll",
          content: "Admin poll question?",
          nullableType: AgendaItemType.poll,
        ),
      ],
    );

    event = await eventUtils.createEvent(
      event: event,
      userId: '999',
    );

    final req = GetMeetingPollDataRequest(
      eventPath: event.fullPath,
    );

    final pollDataFunction = GetMeetingPollData();

    final result = await pollDataFunction.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    expect(result['polls'], isNotNull);
  });

  test('Empty list returned when no poll responses exist', () async {
    var event = Event(
      id: '5680',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '444',
          title: "Unanswered Poll",
          content: "What is your opinion?",
          nullableType: AgendaItemType.poll,
        ),
      ],
    );

    event = await eventUtils.createEvent(
      event: event,
      userId: adminUserId,
    );

    final req = GetMeetingPollDataRequest(
      eventPath: event.fullPath,
    );

    final pollDataFunction = GetMeetingPollData();

    final result = await pollDataFunction.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    expect(result['polls'], isNotNull);
    final polls = result['polls'] as List;
    expect(polls.length, equals(0));
  });

  test('Uses public user info when display name is empty', () async {
    var event = Event(
      id: '5681',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '555',
          title: "Poll with no display name",
          content: "Question?",
          nullableType: AgendaItemType.poll,
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
      participantIds: ['777'],
      breakoutSessionId: null,
    );

    await communityUtils.addCommunityMember(
      userId: '777',
      communityId: communityId,
    );

    final publicUserInfo = PublicUserInfo(
      id: '777',
      displayName: 'Public Name',
      agoraId: 789,
    );
    await liveMeetingTestUtils.addPublicUser(publicUser: publicUserInfo);

    final liveMeetingPath = liveMeetingTestUtils.getLiveMeetingPath(event);
    await liveMeetingTestUtils.addParticipantAgendaItemDetails(
      event: event,
      participantAgendaItemDetails: ParticipantAgendaItemDetails(
        userId: '777',
        meetingId: liveMeetingPath.split('/').last,
        pollResponse: 'Answer',
      ),
      agendaItemId: '555',
    );

    // Mock user record with empty display name
    final userRecord = MockUserRecord();
    when(() => userRecord.uid).thenReturn('777');
    when(() => userRecord.email).thenReturn('user777@example.com');
    when(() => userRecord.displayName).thenReturn('');
    when(() => mockFirebaseAuthUtils.getUser('777'))
        .thenAnswer((_) async => userRecord);

    final req = GetMeetingPollDataRequest(
      eventPath: event.fullPath,
    );

    final pollDataFunction = GetMeetingPollData();

    final result = await pollDataFunction.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    final polls = (result['polls'] as List)
        .map((item) => PollData.fromJson(item))
        .toList();
    expect(polls.length, equals(1));
    expect(polls.first.userName, equals('Public Name'));
  });
}
