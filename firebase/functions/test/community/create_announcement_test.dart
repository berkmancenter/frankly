import 'package:data_models/announcements/announcement.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/community/create_announcement.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import '../util/community_test_utils.dart';
import '../util/email_test_utils.dart';
import '../util/function_test_fixture.dart';

void main() {
  const nonAdminUserId = 'nonAdminUser';
  late String communityId;
  final communityTestUtils = CommunityTestUtils();
  setupTestFixture();

  setUp(() async {
    // Create test community
    communityId = await communityTestUtils.createTestCommunity();
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: nonAdminUserId,
      status: MembershipStatus.member,
    );
  });

  test('Should allow admin to create an announcement', () async {
    final notificationsUtils = MockNotificationsUtils();
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
    when(
      () => notificationsUtils.sendCommunityNotifications(
        filterUsersBy: any(named: 'filterUsersBy'),
        communityId: communityId,
        generateMessage: any(named: 'generateMessage'),
      ),
    ).thenAnswer((_) async {
      return;
    });

    final createAnnouncement =
        CreateAnnouncement(notificationsUtils: notificationsUtils);
    final announcement = Announcement(
      title: 'Test Announcement',
      message: 'This is a test announcement.',
    );
    final req = CreateAnnouncementRequest(
      communityId: communityId,
      announcement: announcement,
    );

    await createAnnouncement.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    final announcementRef = await firestore
        .collection('/community/$communityId/announcements')
        .where('title', isEqualTo: 'Test Announcement')
        .get();
    final createdAnnouncement = Announcement.fromJson(
      firestoreUtils
          .fromFirestoreJson(announcementRef.documents[0].data.toMap()),
    );
    final expectedAnnouncement =
        announcement.copyWith(createdDate: createdAnnouncement.createdDate);
    expect(createdAnnouncement, equals(expectedAnnouncement));

    verify(
      () => notificationsUtils.sendCommunityNotifications(
        filterUsersBy: any(named: 'filterUsersBy'),
        communityId: communityId,
        generateMessage: any(named: 'generateMessage'),
      ),
    );
  });

  test('Should prevent non-admin user from creating an announcement', () async {
    final createAnnouncement = CreateAnnouncement();
    final announcement = Announcement(
      title: 'Unauthorized Announcement',
      message: 'This should not be allowed.',
    );
    final req = CreateAnnouncementRequest(
      communityId: communityId,
      announcement: announcement,
    );

    expect(
      () async => await createAnnouncement.action(
        req,
        CallableContext(nonAdminUserId, null, 'fakeInstanceId'),
      ),
      throwsA(isA<HttpsError>()),
    );
  });
}

class MockCommunity extends Mock implements Community {}
