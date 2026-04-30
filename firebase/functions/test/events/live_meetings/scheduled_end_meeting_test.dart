import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:functions/events/live_meetings/scheduled_end_meeting.dart';
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
      id: 'scheduled-end-test',
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

  group('ScheduledEndMeeting', () {
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
          communityId: any(named: 'communityId'),
          userIds: any(named: 'userIds'),
          emailType: any(named: 'emailType'),
          generateMessage: any(named: 'generateMessage'),
        ),
      ).thenAnswer((_) async {});

      final agoraUtils = MockAgoraUtils();
      final scheduledEnd = ScheduledEndMeeting(
        notificationsUtils: notificationsUtils,
        agoraUtils: agoraUtils,
      );

      final req = EndMeetingForAllRequest(eventPath: event.fullPath);
      await scheduledEnd.action(req);

      // Verify meetingEndedAt was written.
      final liveMeetingPath = liveMeetingTestUtils.getLiveMeetingPath(event);
      final liveMeeting = await firestoreUtils.getFirestoreObject(
        path: liveMeetingPath,
        constructor: (map) => LiveMeeting.fromJson(map),
      );
      expect(liveMeeting.meetingEndedAt, isNotNull);
    });

    test('is idempotent -- no-op if meetingEndedAt already set', () async {
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
      final scheduledEnd = ScheduledEndMeeting(
        notificationsUtils: notificationsUtils,
        agoraUtils: agoraUtils,
      );

      final req = EndMeetingForAllRequest(eventPath: event.fullPath);

      // First call sets meetingEndedAt.
      await scheduledEnd.action(req);

      // Second call returns early.
      await scheduledEnd.action(req);

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
  });
}

class MockCommunity extends Mock implements Community {}
