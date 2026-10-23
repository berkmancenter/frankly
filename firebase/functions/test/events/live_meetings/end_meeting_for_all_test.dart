import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/end_meeting_for_all.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../../util/community_test_utils.dart';
import '../../util/email_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  late String communityId;
  const templateId = '9654988';
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityTestUtils.createTestCommunity();
  });

  Future<Event> createTestEvent() async {
    var event = Event(
      id: 'end-meeting-test-event',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '55005',
          title: 'Test item',
          content: 'Test content',
        ),
      ],
    );
    return eventTestUtils.createEvent(event: event, userId: adminUserId);
  }

  group('EndMeetingForAll', () {
    test('sets meetingEndedAt and sends email', () async {
      final event = await createTestEvent();
      registerFallbackValue(event);
      registerFallbackValue(EventEmailType.ended);

      await liveMeetingTestUtils.addMeetingEvent(
        liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(event),
        liveMeetingId: event.id,
        meetingEvent: LiveMeetingEvent(
          event: LiveMeetingEventType.agendaItemStarted,
          timestamp: DateTime.now(),
        ),
      );

      final notificationsUtils = MockNotificationsUtils();
      when(
        () => notificationsUtils.sendEventEndedEmail(
          event: any(named: 'event'),
          communityId: communityId,
          userIds: any(named: 'userIds'),
          emailType: EventEmailType.ended,
          generateMessage: any(named: 'generateMessage'),
        ),
      ).thenAnswer((_) async {});

      final agoraUtils = MockAgoraUtils();
      final endMeeting = EndMeetingForAll(
        notificationsUtils: notificationsUtils,
        agoraUtils: agoraUtils,
      );

      final req = EndMeetingForAllRequest(eventPath: event.fullPath);
      await endMeeting.action(
        req,
        CallableContext(adminUserId, null, 'fakeInstanceId'),
      );

      // Verify meetingEndedAt was written.
      final liveMeetingPath =
          liveMeetingTestUtils.getLiveMeetingPath(event);
      final liveMeeting = await firestoreUtils.getFirestoreObject(
        path: liveMeetingPath,
        constructor: (map) => LiveMeeting.fromJson(map),
      );
      expect(liveMeeting.meetingEndedAt, isNotNull);

      // Verify email was sent.
      verify(
        () => notificationsUtils.sendEventEndedEmail(
          event: any(named: 'event'),
          communityId: communityId,
          userIds: any(named: 'userIds'),
          emailType: EventEmailType.ended,
          generateMessage: any(named: 'generateMessage'),
        ),
      ).called(1);
    });

    test('is idempotent -- second call is a no-op', () async {
      final event = await createTestEvent();
      registerFallbackValue(event);
      registerFallbackValue(EventEmailType.ended);

      await liveMeetingTestUtils.addMeetingEvent(
        liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(event),
        liveMeetingId: event.id,
        meetingEvent: LiveMeetingEvent(
          event: LiveMeetingEventType.agendaItemStarted,
          timestamp: DateTime.now(),
        ),
      );

      final notificationsUtils = MockNotificationsUtils();
      when(
        () => notificationsUtils.sendEventEndedEmail(
          event: any(named: 'event'),
          communityId: any(named: 'communityId'),
          userIds: any(named: 'userIds'),
          emailType: any(named: 'emailType'),
          generateMessage: any(named: 'generateMessage'),
        ),
      ).thenAnswer((_) async {});

      final agoraUtils = MockAgoraUtils();
      final endMeeting = EndMeetingForAll(
        notificationsUtils: notificationsUtils,
        agoraUtils: agoraUtils,
      );

      final req = EndMeetingForAllRequest(eventPath: event.fullPath);
      final context = CallableContext(adminUserId, null, 'fakeInstanceId');

      // First call sets meetingEndedAt.
      await endMeeting.action(req, context);

      // Second call returns early without sending another email.
      await endMeeting.action(req, context);

      verify(
        () => notificationsUtils.sendEventEndedEmail(
          event: any(named: 'event'),
          communityId: any(named: 'communityId'),
          userIds: any(named: 'userIds'),
          emailType: any(named: 'emailType'),
          generateMessage: any(named: 'generateMessage'),
        ),
      ).called(1);
    });

    test('rejects non-mod/admin/owner caller', () async {
      final event = await createTestEvent();

      await liveMeetingTestUtils.addMeetingEvent(
        liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(event),
        liveMeetingId: event.id,
        meetingEvent: LiveMeetingEvent(
          event: LiveMeetingEventType.agendaItemStarted,
          timestamp: DateTime.now(),
        ),
      );

      const regularUserId = 'regularUser';
      await communityTestUtils.addCommunityMember(
        userId: regularUserId,
        communityId: communityId,
        status: MembershipStatus.member,
      );
      await eventTestUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: event.id,
        uid: regularUserId,
      );

      final notificationsUtils = MockNotificationsUtils();
      final agoraUtils = MockAgoraUtils();
      final endMeeting = EndMeetingForAll(
        notificationsUtils: notificationsUtils,
        agoraUtils: agoraUtils,
      );

      final req = EndMeetingForAllRequest(eventPath: event.fullPath);
      expect(
        () => endMeeting.action(
          req,
          CallableContext(regularUserId, null, 'fakeInstanceId'),
        ),
        throwsA(isA<HttpsError>()),
      );
    });
  });
}

class MockCommunity extends Mock implements Community {}
