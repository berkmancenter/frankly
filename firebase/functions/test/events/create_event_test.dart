import 'package:data_models/community/membership.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/breakouts/check_hostless_go_to_breakouts.dart';
import 'package:functions/events/create_event.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import '../util/community_test_utils.dart';
import '../util/event_test_utils.dart';
import '../util/function_test_fixture.dart';

void main() {
  String communityId = '';
  const userId = 'fakeAuthId';
  const templateId = '9654988';
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  setupTestFixture();

  setUp(() async {
    final testCommunity = Community(
      id: '12349695999',
      name: 'Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    final communityResult = await communityTestUtils.createCommunity(
      community: testCommunity,
      userId: userId,
    );
    communityId = communityResult['communityId'];
  });

  test('Emails are sent and reminders queued on event creation', () async {
    var event = Event(
      id: '12341daaaåff2837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
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
      userId: userId,
    );

    registerFallbackValue(event);

    final req = CreateEventRequest(
      eventPath: event.fullPath,
    );

    final eventEmails = MockEventEmails();
    when(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [userId],
        emailType: EventEmailType.initialSignUp,
      ),
    ).thenAnswer((_) async {
      return;
    });

    when(
      () => eventEmails.enqueueReminders(
        any(),
      ),
    ).thenAnswer((_) async {
      return;
    });

    final eventCreator = CreateEvent(eventEmailUtils: eventEmails);

    await eventCreator.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );

    verify(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [userId],
        emailType: EventEmailType.initialSignUp,
      ),
    ).called(1);

    verify(
      () => eventEmails.enqueueReminders(
        any(),
      ),
    ).called(1);
  });

  test(
      'Emails are sent and reminders queued on event creation triggered by moderator',
      () async {
    const moderatorId = '3920';
    await communityTestUtils.addCommunityMember(
      userId: moderatorId,
      communityId: communityId,
      status: MembershipStatus.mod,
    );
    var event = Event(
      id: '12341f28371',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
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
      userId: userId,
    );

    registerFallbackValue(event);

    final req = CreateEventRequest(
      eventPath: event.fullPath,
    );

    final eventEmails = MockEventEmails();
    when(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [userId],
        emailType: EventEmailType.initialSignUp,
      ),
    ).thenAnswer((_) async {
      return;
    });

    when(
      () => eventEmails.enqueueReminders(
        any(),
      ),
    ).thenAnswer((_) async {
      return;
    });

    final eventCreator = CreateEvent(eventEmailUtils: eventEmails);

    await eventCreator.action(
      req,
      CallableContext(moderatorId, null, 'fakeInstanceId'),
    );

    verify(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [userId],
        emailType: EventEmailType.initialSignUp,
      ),
    ).called(1);

    verify(
      () => eventEmails.enqueueReminders(
        any(),
      ),
    ).called(1);
  });

  test('Breakout checks scheduled on hostless event creation', () async {
    var event = Event(
      id: '12341daaaåfkl f2837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
      nullableEventType: EventType.hostless,
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
      userId: userId,
    );

    final req = CreateEventRequest(
      eventPath: event.fullPath,
    );

    registerFallbackValue(event);

    final checkHostlessGoToBreakouts = MockCheckHostlessGoToBreakouts();
    when(
      () => checkHostlessGoToBreakouts.enqueueScheduledCheck(any()),
    ).thenAnswer((_) async {});

    final eventEmails = MockEventEmails();
    when(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [userId],
        emailType: EventEmailType.initialSignUp,
      ),
    ).thenAnswer((_) async {
      return;
    });

    when(
      () => eventEmails.enqueueReminders(
        any(),
      ),
    ).thenAnswer((_) async {
      return;
    });

    final eventCreator = CreateEvent(
      eventEmailUtils: eventEmails,
      checkHostlessGoToBreakouts: checkHostlessGoToBreakouts,
    );

    await eventCreator.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );

    verify(
      () => eventEmails.sendEmailsToUsers(
        eventPath: event.fullPath,
        userIds: [userId],
        emailType: EventEmailType.initialSignUp,
      ),
    ).called(1);

    verify(
      () => eventEmails.enqueueReminders(
        any(),
      ),
    ).called(1);

    verify(
      () => checkHostlessGoToBreakouts.enqueueScheduledCheck(
        any(),
      ),
    ).called(1);
  });

  test('Error thrown if invoked by member', () async {
    const badId = '223920';
    await communityTestUtils.addCommunityMember(
      userId: badId,
      communityId: communityId,
    );

    var event = Event(
      id: '12341f28371',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
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
      userId: userId,
    );

    registerFallbackValue(event);

    final req = CreateEventRequest(
      eventPath: event.fullPath,
    );

    final eventEmails = MockEventEmails();
    final eventCreator = CreateEvent(eventEmailUtils: eventEmails);

    expect(
      () async {
        await eventCreator.action(
          req,
          CallableContext(badId, null, 'fakeInstanceId'),
        );
      },
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

class MockCheckHostlessGoToBreakouts extends Mock
    implements CheckHostlessGoToBreakouts {}
