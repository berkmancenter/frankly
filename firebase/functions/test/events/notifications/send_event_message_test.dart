import 'package:data_models/community/community.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/event_message.dart';
import 'package:data_models/templates/template.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/notifications/send_event_message.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop hide EventType;
import '../../util/community_test_utils.dart';
import '../../util/email_test_utils.dart';
import '../../util/event_test_utils.dart';

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
      id: '123496953333999ddddd',
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

  test('Event message sent and stored in database', () async {
    var template =
        const Template(id: templateId, title: 'All the things to discuss');

    template = await eventTestUtils.createTemplate(
      communityId: communityId,
      template: template,
      creatorId: userId,
    );

    var event = Event(
      id: '12341daaaåff2837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      scheduledTime: DateTime.now(),
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
    registerFallbackValue(const Template(id: templateId));
    registerFallbackValue(
      ({
        required community,
        required user,
        required unsubscribeUrl,
      }) =>
          SendGridEmailMessage(
        subject: 'Dummy Subject',
        html: 'Dummy HTML',
      ),
    );

    const msg = 'Something Important has happened';
    final eventMessage = EventMessage(
      creatorId: userId,
      createdAt: DateTime.now(),
      message: msg,
    );

    final req = SendEventMessageRequest(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      eventMessage: eventMessage,
    );

    final notificationsUtils = MockNotificationsUtils();
    when(
      () => notificationsUtils.sendEmailToEventParticipants(
        event: any(named: 'event'),
        communityId: communityId,
        template: any(named: 'template'),
        generateMessage: any(named: 'generateMessage'),
      ),
    ).thenAnswer((_) async {
      return;
    });

    final eventMsgr = SendEventMessage(notificationsUtils: notificationsUtils);

    await eventMsgr.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );

    final capturedMessage = verify(
      () => notificationsUtils.sendEmailToEventParticipants(
        event: any(named: 'event'),
        template: any(named: 'template'),
        communityId: communityId,
        generateMessage: captureAny(named: 'generateMessage'),
      ),
    ).captured.first(
          community: MockCommunity(),
          user: MockUserRecord(),
          unsubscribeUrl: 'http://unsubscribe.me',
        );
    expect(
      capturedMessage.subject,
      equals('New Message in Event ${event.title}'),
    );
    expect(capturedMessage.html, contains(msg));

    // verify event message added to firestore
    final eventMsgs = await firestore
        .collection(
          'community/$communityId/templates/$templateId/events/${event.id}/event-messages',
        )
        .get();
    expect(eventMsgs.documents.length, 1);

    final createdMsg = EventMessage.fromJson(
      firestoreUtils.fromFirestoreJson(eventMsgs.documents.first.data.toMap()),
    );

    expect(createdMsg.message, equals(eventMessage.message));
  });
}

class MockCommunity extends Mock implements Community {}
