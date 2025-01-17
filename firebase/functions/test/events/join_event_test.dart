import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:data_models/events/event.dart';
import 'package:functions/events/join_event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../util/community_test_utils.dart';
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

  test('Registration email sent when user joins event', () async {
    const participantId = '333';
    var event = Event(
      id: '123411000ff2837',
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

    await eventTestUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      uid: participantId,
    );

    registerFallbackValue(event);

    final eventEmails = MockEventEmails();
    when(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [participantId],
        emailType: EventEmailType.initialSignUp,
      ),
    ).thenAnswer((_) async {
      return;
    });

    final eventJoiner = JoinEvent(eventEmailUtils: eventEmails);

    await eventJoiner.action(
      event,
      CallableContext(participantId, null, 'fakeInstanceId'),
    );

    verify(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [participantId],
        emailType: EventEmailType.initialSignUp,
      ),
    ).called(1);
  });
  test('Registration email not sent when canceled user joins event', () async {
    const participantId = '444';
    var event = Event(
      id: '123411000ff283dddd7',
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

    await eventTestUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      uid: participantId,
      participantStatus: ParticipantStatus.canceled,
    );

    registerFallbackValue(event);

    final eventEmails = MockEventEmails();
    when(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [participantId],
        emailType: EventEmailType.initialSignUp,
      ),
    ).thenAnswer((_) async {
      return;
    });

    final eventJoiner = JoinEvent(eventEmailUtils: eventEmails);

    await eventJoiner.action(
      event,
      CallableContext(participantId, null, 'fakeInstanceId'),
    );

    verifyNever(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [participantId],
        emailType: EventEmailType.initialSignUp,
      ),
    );
  });
  test('Registration email not sent when reminder emails disabled', () async {
    const participantId = '555';
    var event = Event(
      id: '123411000ff28312lld7',
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
      eventSettings: const EventSettings(reminderEmails: false),
    );
    event = await eventTestUtils.createEvent(
      event: event,
      userId: adminUserId,
    );

    await eventTestUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      uid: participantId,
    );

    registerFallbackValue(event);

    final eventEmails = MockEventEmails();
    when(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [participantId],
        emailType: EventEmailType.initialSignUp,
      ),
    ).thenAnswer((_) async {
      return;
    });

    final eventJoiner = JoinEvent(eventEmailUtils: eventEmails);

    await eventJoiner.action(
      event,
      CallableContext(participantId, null, 'fakeInstanceId'),
    );

    verifyNever(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [participantId],
        emailType: EventEmailType.initialSignUp,
      ),
    );
  });
}
