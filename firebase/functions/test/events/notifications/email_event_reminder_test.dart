import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';

import 'package:functions/events/notifications/email_event_reminder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';

void main() {
  late String communityId;
  const templateId = '9654988';
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityTestUtils.createTestCommunity();
  });

  test('One day reminder email sent to registered participants', () async {
    const participantIds = ['893', '299', '065'];
    var event = Event(
      id: '123411000ff2837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      scheduledTime: DateTime.now().add(const Duration(hours: 24)),
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

    await eventTestUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: participantIds,
    );

    registerFallbackValue(event);

    final eventEmails = MockEventEmails();
    when(
      () => eventEmails.sendEmailsToUsers(
        transaction: any(named: 'transaction'),
        event: any(named: 'event'),
        eventPath: any(named: 'eventPath'),
        userIds: any(named: 'userIds'),
        emailType: EventEmailType.oneDayReminder,
      ),
    ).thenAnswer((_) async {
      return;
    });

    final emailReminder = EmailEventReminder(eventEmailUtils: eventEmails);

    final req = EmailEventReminderRequest(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      eventEmailType: EventEmailType.oneDayReminder,
    );

    await emailReminder.action(req);

    verify(
      () => eventEmails.sendEmailsToUsers(
        transaction: any(named: 'transaction'),
        event: any(named: 'event'),
        eventPath: event.fullPath,
        userIds: any(
          named: 'userIds',
          that: unorderedEquals([...participantIds, adminUserId]),
        ),
        emailType: EventEmailType.oneDayReminder,
      ),
    ).called(1);
  });

  test('One hour reminder email sent to registered participants', () async {
    const participantIds = ['893', '299', '065'];
    var event = Event(
      id: '123411ddd000ff2837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
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

    await eventTestUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: participantIds,
    );

    registerFallbackValue(event);

    final eventEmails = MockEventEmails();
    when(
      () => eventEmails.sendEmailsToUsers(
        transaction: any(named: 'transaction'),
        event: any(named: 'event'),
        eventPath: any(named: 'eventPath'),
        userIds: any(named: 'userIds'),
        emailType: EventEmailType.oneHourReminder,
      ),
    ).thenAnswer((_) async {
      return;
    });

    final emailReminder = EmailEventReminder(eventEmailUtils: eventEmails);

    final req = EmailEventReminderRequest(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      eventEmailType: EventEmailType.oneHourReminder,
    );

    await emailReminder.action(req);

    verify(
      () => eventEmails.sendEmailsToUsers(
        transaction: any(named: 'transaction'),
        event: any(named: 'event'),
        eventPath: event.fullPath,
        userIds: any(
          named: 'userIds',
          that: unorderedEquals([...participantIds, adminUserId]),
        ),
        emailType: EventEmailType.oneHourReminder,
      ),
    ).called(1);
  });

  test('Email not sent if not within correct timer period', () async {
    const participantIds = ['893', '299', '065'];
    var event = Event(
      id: '123411ddd000ff2837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      scheduledTime: DateTime.now().add(const Duration(hours: 3)),
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

    await eventTestUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: participantIds,
    );

    registerFallbackValue(event);

    final eventEmails = MockEventEmails();
    when(
      () => eventEmails.sendEmailsToUsers(
        transaction: any(named: 'transaction'),
        event: any(named: 'event'),
        eventPath: any(named: 'eventPath'),
        userIds: any(named: 'userIds'),
        emailType: EventEmailType.oneHourReminder,
      ),
    ).thenAnswer((_) async {
      return;
    });

    final emailReminder = EmailEventReminder(eventEmailUtils: eventEmails);

    final req = EmailEventReminderRequest(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      eventEmailType: EventEmailType.oneHourReminder,
    );

    await emailReminder.action(req);

    verifyNever(
      () => eventEmails.sendEmailsToUsers(
        transaction: any(named: 'transaction'),
        event: any(named: 'event'),
        eventPath: event.fullPath,
        userIds: any(
          named: 'userIds',
          that: unorderedEquals([...participantIds, adminUserId]),
        ),
        emailType: EventEmailType.oneHourReminder,
      ),
    );
  });

  test('Email not sent if reminders disabled', () async {
    const participantIds = ['893', '299', '065'];
    var event = Event(
      id: '123411ddd000ff2837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
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

    await eventTestUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: participantIds,
    );

    registerFallbackValue(event);

    final eventEmails = MockEventEmails();
    when(
      () => eventEmails.sendEmailsToUsers(
        transaction: any(named: 'transaction'),
        event: any(named: 'event'),
        eventPath: any(named: 'eventPath'),
        userIds: any(named: 'userIds'),
        emailType: EventEmailType.oneHourReminder,
      ),
    ).thenAnswer((_) async {
      return;
    });

    final emailReminder = EmailEventReminder(eventEmailUtils: eventEmails);

    final req = EmailEventReminderRequest(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      eventEmailType: EventEmailType.oneHourReminder,
    );

    await emailReminder.action(req);

    verifyNever(
      () => eventEmails.sendEmailsToUsers(
        transaction: any(named: 'transaction'),
        event: any(named: 'event'),
        eventPath: event.fullPath,
        userIds: any(
          named: 'userIds',
          that: unorderedEquals([...participantIds, adminUserId]),
        ),
        emailType: EventEmailType.oneHourReminder,
      ),
    );
  });

  // TODO email suppression
}
