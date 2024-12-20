import 'package:data_models/firestore/event.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:data_models/firestore/community.dart';
import 'package:functions/events/event_ended.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop hide EventType;
import '../util/community_test_utils.dart';
import '../util/event_test_utils.dart';

void main() {
  String communityId = '';
  const userId = 'fakeAuthId';
  const templateId = '9654988';
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();

  setUp(() async {
    setFirebaseAppFactory(
      () => admin_interop.FirebaseAdmin.instance.initializeApp()!,
    );

    final testCommunity = Community(
      id: '123496953333999',
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

  test('Email sent when event has ended', () async {
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
      return null;
    });

    final eventEnded = EventEnded(notificationsUtils: notificationsUtils);

    await eventEnded.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );

    final capturedMessage = verify(
      () => notificationsUtils.sendEventEndedEmail(
        event: any(named: 'event'),
        communityId: communityId,
        userIds: [userId],
        emailType: EventEmailType.ended,
        generateMessage: captureAny(named: 'generateMessage'),
      ),
    ).captured.first(MockCommunity(), MockUserRecord());
    expect(capturedMessage.subject, equals('Thanks for joining'));
    expect(capturedMessage.html, isNotNull);
  });
}

class MockCommunity extends Mock implements Community {}

class MockUserRecord extends Mock implements admin_interop.UserRecord {}
