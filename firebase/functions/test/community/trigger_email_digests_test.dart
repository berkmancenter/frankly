import 'package:data_models/community/community.dart';
import 'package:data_models/community/email_digest_record.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/community/community_user_settings.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/utils/infra/firebase_auth_utils.dart';
import 'package:functions/utils/send_email_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:functions/community/trigger_email_digests.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop hide EventType;
import 'package:functions/utils/infra/firestore_utils.dart';

import '../util/community_test_utils.dart';
import '../util/email_test_utils.dart';
import '../util/event_test_utils.dart';
import '../util/function_test_fixture.dart';

void main() {
  const memberId = 'memberUser';
  const adminUserId = 'adminUser';
  const templateId = '123777';
  String communityId = '';
  final mockFirebaseAuthUtils = MockFirebaseAuthUtils();
  final mockNotificationsUtils = MockNotificationsUtils();
  final mockSendEmailClient = MockSendEmailClient();
  firebaseAuthUtils = mockFirebaseAuthUtils;
  sendEmailClient = mockSendEmailClient;
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  setupTestFixture();

  setUp(() async {
    // Create test community
    final communityResult = await communityTestUtils.createCommunity(
      community: Community(
        id: '1992123911',
        name: 'Testing Community',
        isPublic: true,
        communitySettings: const CommunitySettings(
          disableEmailDigests: false,
        ),
      ),
      userId: adminUserId,
    );
    communityId = communityResult['communityId'];

    // Add regular member
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: memberId,
      status: MembershipStatus.member,
    );
  });

  test('Should send digest emails for upcoming events to subscribed members',
      () async {
    final triggerEmailDigests = TriggerEmailDigests(
      notificationsUtils: mockNotificationsUtils,
    );

    var template =
        const Template(id: templateId, title: 'All the things to discuss');

    template = await eventTestUtils.createTemplate(
      communityId: communityId,
      template: template,
      creatorId: adminUserId,
    );

    // Create test event
    final now = DateTime.now();
    final event = Event(
      id: '12341234',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [],
      scheduledTime: now.add(const Duration(days: 7)),
      isPublic: true,
    );

    await eventTestUtils.createEvent(
      event: event,
      userId: adminUserId,
    );

    when(
      () => mockSendEmailClient.sendEmails(any()),
    ).thenAnswer((_) async => {});

    // Mock user record
    final userRecord = MockUserRecord();
    when(() => userRecord.uid).thenReturn(memberId);
    when(() => userRecord.email).thenReturn('member@example.com');

    final adminRecord = MockUserRecord();
    when(() => adminRecord.uid).thenReturn(adminUserId);
    when(() => adminRecord.email).thenReturn('admin@example.com');

    when(() => mockFirebaseAuthUtils.getUsers([memberId]))
        .thenAnswer((_) async => [userRecord]);

    when(() => mockFirebaseAuthUtils.getUsers([adminUserId]))
        .thenAnswer((_) async => [adminRecord]);

    // Mock notifications utils
    when(() => mockNotificationsUtils.getUnsubscribeUrl(userId: memberId))
        .thenReturn('https://example.com/unsubscribe');
    when(() => mockNotificationsUtils.getUnsubscribeUrl(userId: adminUserId))
        .thenReturn('https://example.com/unsubscribe');

    // Set user notification preferences
    await firestore
        .document(
          '/privateUserData/$memberId/communityUserSettings/$communityId',
        )
        .setData(
          admin_interop.DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              CommunityUserSettings(
                notifyEvents: NotificationEmailType.immediate,
              ).toJson(),
            ),
          ),
        );

    await firestore
        .document(
          '/privateUserData/$adminUserId/communityUserSettings/$communityId',
        )
        .setData(
          admin_interop.DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              CommunityUserSettings(
                notifyEvents: NotificationEmailType.immediate,
              ).toJson(),
            ),
          ),
        );

    // Trigger the function
    await triggerEmailDigests.action(MockEventContext());

    // Verify email was sent
    verify(() => sendEmailClient.sendEmails(any())).called(1);
  });

  test('Should not send digest if community has disabled email digests',
      () async {
    // Update community settings to disable digests
    await firestore.document('community/$communityId').setData(
          admin_interop.DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              Community(
                id: communityId,
                name: 'Testing Community',
                isPublic: true,
                communitySettings: const CommunitySettings(
                  disableEmailDigests: true,
                ),
              ).toJson(),
            ),
          ),
        );

    when(
      () => mockSendEmailClient.sendEmails(any()),
    ).thenAnswer((_) async => {});
    final triggerEmailDigests = TriggerEmailDigests(
      notificationsUtils: mockNotificationsUtils,
    );

    // Trigger the function
    await triggerEmailDigests.action(MockEventContext());

    // Verify no emails were sent
    verify(() => sendEmailClient.sendEmails([])).called(1);
  });

  test('Should not send digest if user has disabled event notifications',
      () async {
    final triggerEmailDigests = TriggerEmailDigests(
      notificationsUtils: mockNotificationsUtils,
    );

    var template =
        const Template(id: templateId, title: 'All the things to discuss');

    template = await eventTestUtils.createTemplate(
      communityId: communityId,
      template: template,
      creatorId: adminUserId,
    );

    // Create test event
    final now = DateTime.now();
    final event = Event(
      id: '12341234',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [],
      scheduledTime: now.add(const Duration(days: 7)),
      isPublic: true,
    );

    await eventTestUtils.createEvent(
      event: event,
      userId: adminUserId,
    );

    // Set user notification preferences to none
    await firestore
        .document(
          '/privateUserData/$memberId/communityUserSettings/$communityId',
        )
        .setData(
          admin_interop.DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              CommunityUserSettings(
                notifyEvents: NotificationEmailType.none,
              ).toJson(),
            ),
          ),
        );
    await firestore
        .document(
          '/privateUserData/$adminUserId/communityUserSettings/$communityId',
        )
        .setData(
          admin_interop.DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              CommunityUserSettings(
                notifyEvents: NotificationEmailType.immediate,
              ).toJson(),
            ),
          ),
        );

    when(
      () => mockSendEmailClient.sendEmails(any()),
    ).thenAnswer((_) async => {});
    when(() => mockNotificationsUtils.getUnsubscribeUrl(userId: adminUserId))
        .thenReturn('https://example.com/unsubscribe');

    // Mock user record
    final userRecord = MockUserRecord();
    when(() => userRecord.uid).thenReturn(memberId);
    when(() => userRecord.email).thenReturn('member@example.com');

    when(() => mockFirebaseAuthUtils.getUsers([memberId]))
        .thenAnswer((_) async => [userRecord]);

    final adminRecord = MockUserRecord();
    when(() => adminRecord.uid).thenReturn(adminUserId);
    when(() => adminRecord.email).thenReturn('admin@example.com');

    when(() => mockFirebaseAuthUtils.getUsers([adminUserId]))
        .thenAnswer((_) async => [adminRecord]);

    // Trigger the function
    await triggerEmailDigests.action(MockEventContext());

    // Verify only one email sent (to admin user)
    verify(() => sendEmailClient.sendEmails(any(that: hasLength(1)))).called(1);
  });

  test('Should not send digest if one was recently sent', () async {
    final triggerEmailDigests = TriggerEmailDigests(
      notificationsUtils: mockNotificationsUtils,
    );

    final now = DateTime.now();

    // Create recent digest record
    await firestore
        .collection('/privateUserData/$memberId/emailDigests')
        .document()
        .setData(
          admin_interop.DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              EmailDigestRecord(
                userId: memberId,
                communityId: communityId,
                type: DigestType.weekly,
                sentAt: now.subtract(const Duration(days: 2)),
              ).toJson(),
            ),
          ),
        );
    await firestore
        .collection('/privateUserData/$adminUserId/emailDigests')
        .document()
        .setData(
          admin_interop.DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              EmailDigestRecord(
                userId: memberId,
                communityId: communityId,
                type: DigestType.weekly,
                sentAt: now.subtract(const Duration(days: 2)),
              ).toJson(),
            ),
          ),
        );
    var template =
        const Template(id: templateId, title: 'All the things to discuss');

    template = await eventTestUtils.createTemplate(
      communityId: communityId,
      template: template,
      creatorId: adminUserId,
    );
    // Create test event
    final event = Event(
      id: '12341234',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [],
      scheduledTime: now.add(const Duration(days: 7)),
      isPublic: true,
    );

    await eventTestUtils.createEvent(
      event: event,
      userId: adminUserId,
    );
    when(
      () => mockSendEmailClient.sendEmails(any()),
    ).thenAnswer((_) async => {});
    when(() => mockNotificationsUtils.getUnsubscribeUrl(userId: adminUserId))
        .thenReturn('https://example.com/unsubscribe');
    when(() => mockNotificationsUtils.getUnsubscribeUrl(userId: memberId))
        .thenReturn('https://example.com/unsubscribe');
    // Mock user record
    final userRecord = MockUserRecord();
    when(() => userRecord.uid).thenReturn(memberId);
    when(() => userRecord.email).thenReturn('member@example.com');

    when(() => mockFirebaseAuthUtils.getUsers([memberId]))
        .thenAnswer((_) async => [userRecord]);

    final adminRecord = MockUserRecord();
    when(() => adminRecord.uid).thenReturn(adminUserId);
    when(() => adminRecord.email).thenReturn('admin@example.com');

    when(() => mockFirebaseAuthUtils.getUsers([adminUserId]))
        .thenAnswer((_) async => [adminRecord]);

    // Trigger the function
    await triggerEmailDigests.action(MockEventContext());

    // Verify no emails were sent
    verify(() => sendEmailClient.sendEmails([])).called(1);
  });
}

class MockEventContext extends Mock implements EventContext {}
