import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:functions/events/notifications/event_emails.dart';
import 'package:functions/utils/infra/firebase_auth_utils.dart';
import 'package:functions/utils/send_email_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../util/community_test_utils.dart';
import '../../util/email_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';

void main() {
  setupTestFixture();
  setUpAll(() => registerFallbackValue(MockSendGridEmail()));

  test('event notifications skip users without an email address', () async {
    final auth = MockFirebaseAuthUtils();
    final sender = MockSendEmailClient();
    firebaseAuthUtils = auth;
    sendEmailClient = sender;
    final communityId = await CommunityTestUtils().createTestCommunity();
    final event = await EventTestUtils().createEvent(
      event: Event(
        id: 'anonymous-event',
        status: EventStatus.active,
        communityId: communityId,
        templateId: 'default',
        creatorId: adminUserId,
        collectionPath: '',
      ),
      userId: adminUserId,
    );
    final user = MockUserRecord();
    when(() => user.email).thenReturn('');
    when(() => auth.getUsers([adminUserId])).thenAnswer((_) async => [user]);

    await EventEmails().sendEmailsToUsers(
      eventPath: event.fullPath,
      emailType: EventEmailType.initialSignUp,
      userIds: [adminUserId],
    );

    verifyNever(
        () => sender.sendEmail(any(), transaction: any(named: 'transaction')));
  });
}
