import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership_request.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/utils/infra/firebase_auth_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/membership.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:functions/utils/send_email_client.dart';
import 'package:functions/community/resolve_join_request.dart';

import '../util/community_test_utils.dart';
import '../util/email_test_utils.dart';

void main() {
  const adminUserId = 'adminUser';
  const regularUserId = 'regularUser';
  const requesterUserId = 'requesterUser';
  String communityId = '';
  final mockFirebaseAuthUtils = MockFirebaseAuthUtils();
  final mockSendEmailClient = MockSendEmailClient();
  firebaseAuthUtils = mockFirebaseAuthUtils;
  sendEmailClient = mockSendEmailClient;
  final communityTestUtils = CommunityTestUtils();

  setUpAll(() {
    // Register fallback values for SendGridEmail and its dependencies
    registerFallbackValue(MockSendGridEmail());
    registerFallbackValue(MockSendGridEmailMessage());
  });

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

  test('Should allow admin to approve join request', () async {
    // Add join request
    await communityTestUtils.addJoinRequest(
      request: MembershipRequest(
        communityId: communityId,
        userId: requesterUserId,
        status: MembershipRequestStatus.requested,
      ),
    );

    final resolveJoinRequest = ResolveJoinRequest();
    final req = ResolveJoinRequestRequest(
      communityId: communityId,
      userId: requesterUserId,
      approve: true,
    );

    final userRecord = MockUserRecord();
    when(() => userRecord.uid).thenReturn(requesterUserId);
    when(() => userRecord.email).thenReturn('requester@example.com');

    when(
      () => mockFirebaseAuthUtils.getUsers([requesterUserId]),
    ).thenAnswer((_) async => [userRecord]);

    when(
      () => mockSendEmailClient.sendEmail(
        any(),
        transaction: any(named: 'transaction'),
      ),
    ).thenAnswer((_) async => {});

    await resolveJoinRequest.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    // Verify membership was updated
    final membershipDoc = await firestore
        .document(
          'memberships/$requesterUserId/community-membership/$communityId',
        )
        .get();

    final membership = Membership.fromJson(
      firestoreUtils.fromFirestoreJson(membershipDoc.data.toMap()),
    );
    expect(membership.status, equals(MembershipStatus.member));

    // Verify request was marked as approved
    final requestDoc = await firestore
        .document(
          'community/$communityId/join-requests/$requesterUserId',
        )
        .get();

    final request = MembershipRequest.fromJson(
      firestoreUtils.fromFirestoreJson(requestDoc.data.toMap()),
    );
    expect(request.status, equals(MembershipRequestStatus.approved));

    // Verify email was sent
    verify(
      () => mockSendEmailClient.sendEmail(
        any(),
        transaction: any(named: 'transaction'),
      ),
    ).called(1);
  });

  test('Should allow admin to deny join request', () async {
    // Add join request
    await communityTestUtils.addJoinRequest(
      request: MembershipRequest(
        communityId: communityId,
        userId: requesterUserId,
        status: MembershipRequestStatus.requested,
      ),
    );

    final resolveJoinRequest = ResolveJoinRequest();
    final req = ResolveJoinRequestRequest(
      communityId: communityId,
      userId: requesterUserId,
      approve: false,
    );

    await resolveJoinRequest.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    // Verify request was marked as denied
    final requestDoc = await firestore
        .document(
          'community/$communityId/join-requests/$requesterUserId',
        )
        .get();

    final request = MembershipRequest.fromJson(
      firestoreUtils.fromFirestoreJson(requestDoc.data.toMap()),
    );
    expect(request.status, equals(MembershipRequestStatus.denied));

    // Verify no email was sent for denial
    verifyNever(
      () => mockSendEmailClient.sendEmail(
        any(),
        transaction: any(named: 'transaction'),
      ),
    );
  });

  test('Should throw error when trying to approve already approved request',
      () async {
    // Add already approved request
    await communityTestUtils.addJoinRequest(
      request: MembershipRequest(
        communityId: communityId,
        userId: requesterUserId,
        status: MembershipRequestStatus.approved,
      ),
    );

    final resolveJoinRequest = ResolveJoinRequest();
    final req = ResolveJoinRequestRequest(
      communityId: communityId,
      userId: requesterUserId,
      approve: true,
    );

    expect(
      () async {
        await resolveJoinRequest.action(
          req,
          CallableContext(adminUserId, null, 'fakeInstanceId'),
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

  test('Should throw error when non-admin tries to resolve request', () async {
    // Add join request
    await communityTestUtils.addJoinRequest(
      request: MembershipRequest(
        communityId: communityId,
        userId: requesterUserId,
        status: MembershipRequestStatus.requested,
      ),
    );

    final resolveJoinRequest = ResolveJoinRequest();
    final req = ResolveJoinRequestRequest(
      communityId: communityId,
      userId: requesterUserId,
      approve: true,
    );

    expect(
      () async {
        await resolveJoinRequest.action(
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
}
