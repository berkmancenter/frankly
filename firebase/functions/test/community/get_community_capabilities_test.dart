import 'package:data_models/admin/plan_capability_list.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/community/get_community_capabilities.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:functions/utils/infra/firestore_utils.dart';

import '../util/community_test_utils.dart';
import '../util/subscription_test_utils.dart';

void main() {
  const userId = 'fakeAuthId';
  const memberId = 'memberFooId';
  String communityId = '';
  final communityTestUtils = CommunityTestUtils();
  final subscriptionTestUtils = SubscriptionTestUtils();

  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);
    await subscriptionTestUtils.addUnrestrictedPlanCapabilities(
      planCapabilities: SubscriptionTestUtils.unrestrictedPlan,
    );
    final communityResult = await communityTestUtils.createCommunity(
      community: Community(
        id: '1999',
        name: 'Testing Community',
        isPublic: true,
      ),
      userId: userId,
    );
    communityId = communityResult['communityId'];
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: memberId,
      status: MembershipStatus.member,
    );
  });

  tearDown(() async {
    await subscriptionTestUtils.removeUnrestrictedPlanCapabilities();
  });

  test('Should return unrestricted capabilities since Stripe is disabled',
      () async {
    final capabilitiesGetter = GetCommunityCapabilities();
    final req = GetCommunityCapabilitiesRequest(
      communityId: communityId,
    );

    final result = await capabilitiesGetter.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );

    final capabilitiesResult = PlanCapabilityList.fromJson(
      firestoreUtils.fromFirestoreJson(result),
    );
    expect(capabilitiesResult, equals(SubscriptionTestUtils.unrestrictedPlan));
  });

  test('Error thrown when user is not authenticated', () async {
    final capabilitiesGetter = GetCommunityCapabilities();
    final req = GetCommunityCapabilitiesRequest(
      communityId: communityId,
    );

    expect(
      () async {
        await capabilitiesGetter.action(
          req,
          CallableContext(null, null, 'fakeInstanceId'),
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
  test(
      'Error thrown when requester does not have moderator or above permission',
      () async {
    final capabilitiesGetter = GetCommunityCapabilities();
    final req = GetCommunityCapabilitiesRequest(
      communityId: communityId,
    );

    expect(
      () async {
        await capabilitiesGetter.action(
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
}
