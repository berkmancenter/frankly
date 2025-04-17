import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/utils/infra/firebase_auth_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/events/event.dart';
import 'package:functions/community/get_members_data.dart';
import '../util/community_test_utils.dart';
import '../util/event_test_utils.dart';
import '../util/function_test_fixture.dart';

void main() {
  const regularUserId = 'regularUser';
  late String communityId;
  final mockFirebaseAuthUtils = MockFirebaseAuthUtils();
  firebaseAuthUtils = mockFirebaseAuthUtils;
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  setupTestFixture();

  setUp(() async {
    // Create test community
    communityId = await communityTestUtils.createTestCommunity();

    // Add regular member
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: regularUserId,
      status: MembershipStatus.member,
    );
  });

  test('Should return member details for admin request', () async {
    final membersDataGetter = GetMembersData();
    final req = GetMembersDataRequest(
      communityId: communityId,
      userIds: [adminUserId, regularUserId],
    );

    final adminUserRecord = MockUserRecord();
    final regularUserRecord = MockUserRecord();

    when(
      () => mockFirebaseAuthUtils.getUser(adminUserId),
    ).thenAnswer((_) async {
      return adminUserRecord;
    });

    when(() => adminUserRecord.displayName).thenReturn('Admin');
    when(() => adminUserRecord.email).thenReturn('admin@admin.com');
    when(() => regularUserRecord.displayName).thenReturn('Joe User');
    when(() => regularUserRecord.email).thenReturn('user@joe.com');

    when(
      () => mockFirebaseAuthUtils.getUser(regularUserId),
    ).thenAnswer((_) async {
      return regularUserRecord;
    });

    final result = await membersDataGetter.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    /** Have to deal with returned Map instead of using GetMembersDataResponse.fromJson because SERVER_TIMESTAMP
    placeholder used for Membership.firstJoined does not resolve to an actual date. */
    expect(result['membersDetailsList'], hasLength(2));

    // Verify admin member details
    final adminMember = result['membersDetailsList']
        .firstWhere((member) => member['id'] == adminUserId);

    expect(
      adminMember,
      equals(
        {
          'id': adminUserId,
          'email': 'admin@admin.com',
          'displayName': 'Admin',
          'membership': {
            'userId': adminUserId,
            'communityId': communityId,
            'status': 'owner',
            'firstJoined': 'SERVER_TIMESTAMP',
            'invisible': false,
          },
          'memberEvent': null,
        },
      ),
    );

    // Verify regular member details
    final regularMember = result['membersDetailsList']
        .firstWhere((member) => member['id'] == regularUserId);
    expect(
      regularMember,
      equals(
        {
          'id': regularUserId,
          'email': 'user@joe.com',
          'displayName': 'Joe User',
          'membership': {
            'userId': regularUserId,
            'communityId': communityId,
            'status': 'member',
            'firstJoined': 'SERVER_TIMESTAMP',
            'invisible': false,
          },
          'memberEvent': null,
        },
      ),
    );
  });

  test('Error thrown when non-admin requests member data', () async {
    final membersDataGetter = GetMembersData();
    final req = GetMembersDataRequest(
      communityId: communityId,
      userIds: [adminUserId, regularUserId],
    );

    expect(
      () async {
        await membersDataGetter.action(
          req,
          CallableContext(regularUserId, null, 'fakeInstanceId'),
        );
      },
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.failedPrecondition &&
              e.message == 'Unauthorized',
        ),
      ),
    );
  });

  test('Should include event participation data when event path provided',
      () async {
    // Add event participation data
    final event = Event(
      id: '12341daaaåff2ddd837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: '902342',
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

    Event createdEvent = await eventTestUtils.createEvent(
      event: event,
      userId: adminUserId,
    );

    final membersDataGetter = GetMembersData();
    final req = GetMembersDataRequest(
      communityId: communityId,
      userIds: [adminUserId],
      eventPath: createdEvent.fullPath,
    );

    final result = await membersDataGetter.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    final memberDetails = result['membersDetailsList'].first;

    expect(memberDetails['memberEvent'], isNotNull);
    expect(memberDetails['memberEvent']['eventId'], equals(createdEvent.id));
    expect(
      memberDetails['memberEvent']['participant']['status'],
      equals('active'),
    );
  });

  test('Should handle non-existent users gracefully', () async {
    final membersDataGetter = GetMembersData();
    final req = GetMembersDataRequest(
      communityId: communityId,
      userIds: ['non-existent-user'],
    );

    final result = await membersDataGetter.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    final memberDetails = result['membersDetailsList'].first;

    expect(memberDetails['email'], equals('Unknown'));
    expect(
      memberDetails['membership']['status'],
      equals('nonmember'),
    );
  });
}
