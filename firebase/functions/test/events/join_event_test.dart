import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/community.dart';
import 'package:functions/events/join_event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:functions/utils/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import '../util/community_test_utils.dart';
import '../util/event_test_utils.dart';

void main() {
  String communityId = '';
  const userId = 'fakeAuthId';
  const templateId = '9654988';
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();

  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);

    final testCommunity = Community(
      id: '123492115999',
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

  test('Registration email sent when user joins event', () async {
    const participantId = '333';
    var event = Event(
      id: '123411000ff2837',
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
      return null;
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
      return null;
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
      eventSettings: const EventSettings(reminderEmails: false),
    );
    event = await eventTestUtils.createEvent(
      event: event,
      userId: userId,
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
      return null;
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
