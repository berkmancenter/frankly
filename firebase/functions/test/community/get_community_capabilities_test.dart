import 'package:data_models/admin/plan_capability_list.dart';
import 'package:data_models/community/membership.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/community/get_community_capabilities.dart';
import 'package:functions/utils/infra/firestore_utils.dart';

import '../util/community_test_utils.dart';
import '../util/function_test_fixture.dart';
import '../util/subscription_test_utils.dart';

void main() {
  const memberId = 'memberFooId';
  late String communityId;
  final communityTestUtils = CommunityTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityTestUtils.createTestCommunity();
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: memberId,
      status: MembershipStatus.member,
    );
  });

  test('Should return unrestricted capabilities since Stripe is disabled',
      () async {
    final capabilitiesGetter = GetCommunityCapabilities();
    final req = GetCommunityCapabilitiesRequest(
      communityId: communityId,
    );

    final result = await capabilitiesGetter.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
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
