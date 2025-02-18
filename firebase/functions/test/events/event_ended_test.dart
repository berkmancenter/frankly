import 'package:data_models/events/event.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:data_models/community/community.dart';
import 'package:functions/events/event_ended.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import '../util/community_test_utils.dart';
import '../util/email_test_utils.dart';
import '../util/event_test_utils.dart';
import '../util/function_test_fixture.dart';

void main() {
  late String communityId;
  const templateId = '9654988';
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityTestUtils.createTestCommunity();
  });

  test('Email sent when event has ended', () async {
    var event = Event(
      id: '12341daaaåff2837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
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
      userId: adminUserId,
    );

    registerFallbackValue(event);

    final req = EventEndedRequest(
      eventPath: event.fullPath,
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
    ).thenAnswer((_) async {
      return;
    });

    final eventEnded = EventEnded(notificationsUtils: notificationsUtils);

    await eventEnded.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    final capturedMessage = verify(
      () => notificationsUtils.sendEventEndedEmail(
        event: any(named: 'event'),
        communityId: communityId,
        userIds: [adminUserId],
        emailType: EventEmailType.ended,
        generateMessage: captureAny(named: 'generateMessage'),
      ),
    ).captured.first(MockCommunity(), MockUserRecord());
    expect(capturedMessage.subject, equals('Thanks for joining'));
    expect(capturedMessage.html, isNotNull);
  });
}

class MockCommunity extends Mock implements Community {}
