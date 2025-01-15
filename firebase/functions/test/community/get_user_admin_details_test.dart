import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership_request.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/utils/infra/firebase_auth_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/events/event.dart';
import 'package:functions/community/get_user_admin_details.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop hide EventType;
import 'package:functions/utils/infra/firestore_utils.dart';

import '../util/community_test_utils.dart';
import '../util/event_test_utils.dart';

void main() {
  const adminUserId = 'adminUser';
  const regularUserId = 'regularUser';
  const requesterUserId = 'requesterUser';
  const nonMemberUserId = 'nonMemberUser';
  String communityId = '';
  final mockFirebaseAuthUtils = MockFirebaseAuthUtils();
  firebaseAuthUtils = mockFirebaseAuthUtils;
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();

  setUp(() async {
    setFirebaseAppFactory(
      () => admin_interop.FirebaseAdmin.instance.initializeApp()!,
    );

    // Create test community
    final communityResult = await communityTestUtils.createCommunity(
      community: Community(
        id: '1992123911',
        name: 'Testing Community',
        isPublic: true,
      ),
      userId: adminUserId,
    );
    communityId = communityResult['communityId'];

    // Add regular member
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: regularUserId,
      status: MembershipStatus.member,
    );
  });

  tearDown(() async {
    resetMocktailState();
  });

  test('Should allow user to request their own admin details', () async {
    final getUserAdminDetails = GetUserAdminDetails();
    final req = GetUserAdminDetailsRequest(
      userIds: [regularUserId],
    );

    final userRecord = MockUserRecord();
    when(() => userRecord.uid).thenReturn(regularUserId);
    when(() => userRecord.email).thenReturn('user@example.com');

    when(
      () => mockFirebaseAuthUtils.getUsers([regularUserId]),
    ).thenAnswer((_) async => [userRecord]);

    final result = await getUserAdminDetails.action(
      req,
      CallableContext(regularUserId, null, 'fakeInstanceId'),
    );

    expect(result['userAdminDetails'], hasLength(1));
    final response = UserAdminDetails.fromJson(
      firestoreUtils.fromFirestoreJson(result['userAdminDetails'].first),
    );
    expect(
      response,
      equals(
        UserAdminDetails(
          userId: regularUserId,
          email: 'user@example.com',
        ),
      ),
    );
  });

  test('Should allow admin to request member admin details', () async {
    final getUserAdminDetails = GetUserAdminDetails();
    final req = GetUserAdminDetailsRequest(
      userIds: [regularUserId],
      communityId: communityId,
    );

    final userRecord = MockUserRecord();
    when(() => userRecord.uid).thenReturn(regularUserId);
    when(() => userRecord.email).thenReturn('user@example.com');

    when(
      () => mockFirebaseAuthUtils.getUsers([regularUserId]),
    ).thenAnswer((_) async => [userRecord]);

    final result = await getUserAdminDetails.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    expect(result['userAdminDetails'], hasLength(1));
    final response = UserAdminDetails.fromJson(
      firestoreUtils.fromFirestoreJson(result['userAdminDetails'].first),
    );
    expect(
      response,
      equals(
        UserAdminDetails(
          userId: regularUserId,
          email: 'user@example.com',
        ),
      ),
    );
  });

  test('Should allow admin to request details for event participants',
      () async {
    const templateId = '902342';
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
    );

    Event createdEvent = await eventTestUtils.createEvent(
      event: event,
      userId: adminUserId,
    );

    // Add participant to event
    await eventTestUtils.joinEvent(
      communityId: communityId,
      eventId: createdEvent.id,
      templateId: '902342',
      uid: nonMemberUserId,
    );

    final getUserAdminDetails = GetUserAdminDetails();
    final req = GetUserAdminDetailsRequest(
      userIds: [nonMemberUserId],
      communityId: communityId,
      eventPath: createdEvent.fullPath,
    );

    final userRecord = MockUserRecord();
    when(() => userRecord.uid).thenReturn(nonMemberUserId);
    when(() => userRecord.email).thenReturn('user@example2.com');

    when(
      () => mockFirebaseAuthUtils.getUsers([nonMemberUserId]),
    ).thenAnswer((_) async => [userRecord]);

    final result = await getUserAdminDetails.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    expect(result['userAdminDetails'], hasLength(1));
    final response = UserAdminDetails.fromJson(
      firestoreUtils.fromFirestoreJson(result['userAdminDetails'].first),
    );
    expect(
      response,
      equals(
        UserAdminDetails(
          userId: nonMemberUserId,
          email: 'user@example2.com',
        ),
      ),
    );
  });

  test('Should throw error when non-admin requests other user details',
      () async {
    final getUserAdminDetails = GetUserAdminDetails();
    final req = GetUserAdminDetailsRequest(
      userIds: [adminUserId],
      communityId: communityId,
    );

    expect(
      () async {
        await getUserAdminDetails.action(
          req,
          CallableContext(regularUserId, null, 'fakeInstanceId'),
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

  test('Should allow admin to request details for membership requesters',
      () async {
    // Add membership request
    await communityTestUtils.addJoinRequest(
      request: MembershipRequest(
        communityId: communityId,
        userId: requesterUserId,
      ),
    );

    final getUserAdminDetails = GetUserAdminDetails();
    final req = GetUserAdminDetailsRequest(
      userIds: [requesterUserId],
      communityId: communityId,
    );

    final userRecord = MockUserRecord();
    when(() => userRecord.uid).thenReturn(requesterUserId);
    when(() => userRecord.email).thenReturn('requester@example.com');

    when(
      () => mockFirebaseAuthUtils.getUsers([requesterUserId]),
    ).thenAnswer((_) async => [userRecord]);

    final result = await getUserAdminDetails.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    expect(result['userAdminDetails'], hasLength(1));
    final response = UserAdminDetails.fromJson(
      firestoreUtils.fromFirestoreJson(result['userAdminDetails'].first),
    );
    expect(
      response,
      equals(
        UserAdminDetails(
          userId: requesterUserId,
          email: 'requester@example.com',
        ),
      ),
    );
  });
}
