import 'package:data_models/community/membership.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:data_models/community/community.dart';
import 'package:functions/community/update_membership.dart';
import 'package:functions/utils/subscription_plan_util.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/infra/firestore_utils.dart';

import '../util/community_test_utils.dart';
import '../util/function_test_fixture.dart';
import '../util/subscription_test_utils.dart';

void main() {
  const ownerId = 'ownerUserId';
  const adminId = 'adminUserId';
  const memberId = 'memberUserId';
  const member2Id = 'memberUser2Id';
  String communityId = '';
  final communityTestUtils = CommunityTestUtils();
  final subscriptionTestUtils = SubscriptionTestUtils();
  setupTestFixture();

  setUp(() async {
    Community testCommunity = Community(
      id: '19999999',
      name: 'Testing Community',
      isPublic: true,
      creatorId: ownerId,
    );

    final communityResult = await communityTestUtils.createCommunity(
      community: testCommunity,
      userId: ownerId,
    );
    communityId = communityResult['communityId'];

    // Set up initial memberships
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: adminId,
      status: MembershipStatus.admin,
    );
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: memberId,
      status: MembershipStatus.member,
    );
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: member2Id,
      status: MembershipStatus.member,
    );
  });

  test('Owner should be able to promote member to admin', () async {
    final membershipUpdater = UpdateMembership();
    final req = UpdateMembershipRequest(
      communityId: communityId,
      userId: memberId,
      status: MembershipStatus.admin,
    );

    await membershipUpdater.action(
      req,
      CallableContext(ownerId, null, 'fakeInstanceId'),
    );

    final membershipSnapshot = await firestore
        .document('memberships/$memberId/community-membership/$communityId')
        .get();
    final updatedMembership = Membership.fromJson(
      firestoreUtils.fromFirestoreJson(membershipSnapshot.data.toMap()),
    );

    expect(updatedMembership.status, equals(MembershipStatus.admin));
  });
  test('Admin should be able to promote member to mod', () async {
    final membershipUpdater = UpdateMembership();
    final req = UpdateMembershipRequest(
      communityId: communityId,
      userId: memberId,
      status: MembershipStatus.mod,
    );

    await membershipUpdater.action(
      req,
      CallableContext(adminId, null, 'fakeInstanceId'),
    );

    final membershipSnapshot = await firestore
        .document('memberships/$memberId/community-membership/$communityId')
        .get();
    final updatedMembership = Membership.fromJson(
      firestoreUtils.fromFirestoreJson(membershipSnapshot.data.toMap()),
    );

    expect(updatedMembership.status, equals(MembershipStatus.mod));
  });

  test('Admin should not be able to modify owner status', () async {
    final membershipUpdater = UpdateMembership();
    final req = UpdateMembershipRequest(
      communityId: communityId,
      userId: ownerId,
      status: MembershipStatus.admin,
    );

    expect(
      () async {
        await membershipUpdater.action(
          req,
          CallableContext(adminId, null, 'fakeInstanceId'),
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

  test('Regular member should not be able to promote others', () async {
    final membershipUpdater = UpdateMembership();
    const newMemberId = 'newMemberId';
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: newMemberId,
      status: MembershipStatus.member,
    );

    final req = UpdateMembershipRequest(
      communityId: communityId,
      userId: newMemberId,
      status: MembershipStatus.admin,
    );

    expect(
      () async {
        await membershipUpdater.action(
          req,
          CallableContext(memberId, null, 'fakeInstanceId'),
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

  group('Quota tests', () {
    final mockSubscriptionPlanUtil = MockSubscriptionPlanUtil();
    setUpAll(() async {
      subscriptionPlanUtil = mockSubscriptionPlanUtil;
      when(
        () => mockSubscriptionPlanUtil.calculateCapabilities(any()),
      ).thenAnswer((_) async {
        return SubscriptionTestUtils.unrestrictedPlanWithQuotas;
      });
    });

    tearDownAll(() async {
      subscriptionPlanUtil = SubscriptionPlanUtil();
    });

    test('Should fail when exceeding admin quota', () async {
      // Already have owner and one admin, try to add another
      final membershipUpdater = UpdateMembership();
      final req = UpdateMembershipRequest(
        communityId: communityId,
        userId: memberId,
        status: MembershipStatus.admin,
      );

      expect(
        () async {
          await membershipUpdater.action(
            req,
            CallableContext(ownerId, null, 'fakeInstanceId'),
          );
        },
        throwsA(
          predicate(
            (e) =>
                e is HttpsError &&
                e.code == HttpsError.resourceExhausted &&
                e.message == 'Insufficient admin count quota.',
          ),
        ),
      );
    });
    test('Should fail when exceeding faciliator quota', () async {
      // Make one member a facilitator
      final membershipUpdater = UpdateMembership();
      final req = UpdateMembershipRequest(
        communityId: communityId,
        userId: memberId,
        status: MembershipStatus.facilitator,
      );
      await membershipUpdater.action(
        req,
        CallableContext(ownerId, null, 'fakeInstanceId'),
      );

      final req2 = UpdateMembershipRequest(
        communityId: communityId,
        userId: member2Id,
        status: MembershipStatus.facilitator,
      );

      expect(
        () async {
          await membershipUpdater.action(
            req2,
            CallableContext(ownerId, null, 'fakeInstanceId'),
          );
        },
        throwsA(
          predicate(
            (e) =>
                e is HttpsError &&
                e.code == HttpsError.resourceExhausted &&
                e.message == 'Insufficient facilitator count quota.',
          ),
        ),
      );
    });
  });

  test('Member should be able to leave community', () async {
    final membershipUpdater = UpdateMembership();
    final req = UpdateMembershipRequest(
      communityId: communityId,
      userId: memberId,
      status: MembershipStatus.nonmember,
    );

    await membershipUpdater.action(
      req,
      CallableContext(memberId, null, 'fakeInstanceId'),
    );

    final membershipSnapshot = await firestore
        .document('memberships/$memberId/community-membership/$communityId')
        .get();
    final updatedMembership = Membership.fromJson(
      firestoreUtils.fromFirestoreJson(membershipSnapshot.data.toMap()),
    );

    expect(updatedMembership.status, equals(MembershipStatus.nonmember));
  });
}
