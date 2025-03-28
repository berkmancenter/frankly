import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:test/test.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:functions/community/on_community_membership.dart';
import 'package:enum_to_string/enum_to_string.dart';

import '../util/community_test_utils.dart';
import '../util/function_test_fixture.dart';

void main() {
  const creatorId = 'creatorUser';
  const newMemberId = 'newMember';
  late String communityId;
  final communityTestUtils = CommunityTestUtils();
  late OnCommunityMembership onCommunityMembership;
  setupTestFixture();

  setUp(() async {
    onCommunityMembership = OnCommunityMembership();

    // Create test community with initial onboarding step
    final communityResult = await communityTestUtils.createCommunity(
      community: Community(
        id: '1992123911',
        name: 'Testing Community',
        isPublic: true,
        creatorId: creatorId,
        onboardingSteps: [
          OnboardingStep.brandSpace,
        ],
      ),
      userId: creatorId,
    );
    communityId = communityResult['communityId'];
    print("Created community $communityId");
  });

  test('Should not add inviteSomeone step when creator joins', () async {
    // Get the document snapshot
    final docSnapshot = await firestore
        .document('memberships/$creatorId/community-membership/$communityId')
        .get();

    // Explicitly call onCreate
    await onCommunityMembership.onCreate(
      docSnapshot,
      Membership(communityId: communityId, userId: creatorId),
      DateTime.now(),
      MockEventContext(),
    );

    // Verify community document
    final communityDoc =
        await firestore.document('community/$communityId').get();

    final onboardingSteps = communityDoc.data
        .toMap()[Community.kFieldOnboardingSteps] as List<dynamic>;

    // Should only have the initial brandSpace step
    expect(onboardingSteps, hasLength(1));
    expect(
      onboardingSteps.first,
      equals(EnumToString.convertToString(OnboardingStep.brandSpace)),
    );
  });

  test('Should add inviteSomeone step when first non-creator member joins',
      () async {
    // Create membership document
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: newMemberId,
      status: MembershipStatus.member,
    );

    // Get the document snapshot
    final docSnapshot = await firestore
        .document('memberships/$newMemberId/community-membership/$communityId')
        .get();

    // Explicitly call onCreate
    await onCommunityMembership.onCreate(
      docSnapshot,
      Membership(communityId: communityId, userId: newMemberId),
      DateTime.now(),
      MockEventContext(),
    );

    // Verify community document
    final communityDoc =
        await firestore.document('community/$communityId').get();

    final onboardingSteps = communityDoc.data
        .toMap()[Community.kFieldOnboardingSteps] as List<dynamic>;

    // Should have both brandSpace and inviteSomeone steps
    expect(onboardingSteps, hasLength(2));
    expect(
      onboardingSteps,
      contains(EnumToString.convertToString(OnboardingStep.brandSpace)),
    );
    expect(
      onboardingSteps,
      contains(EnumToString.convertToString(OnboardingStep.inviteSomeone)),
    );
  });

  test('Should not add duplicate inviteSomeone step when second member joins',
      () async {
    // Add first new member and call onCreate
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: newMemberId,
      status: MembershipStatus.member,
    );
    print("Community ID before $communityId");
    final firstDocSnapshot = await firestore
        .document('memberships/$newMemberId/community-membership/$communityId')
        .get();
    print("Community ID after $communityId");
    print("The membership doc ${firstDocSnapshot.documentID}");
    await onCommunityMembership.onCreate(
      firstDocSnapshot,
      Membership(communityId: communityId, userId: newMemberId),
      DateTime.now(),
      MockEventContext(),
    );

    // Add second member and call onCreate
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: 'anotherMember',
      status: MembershipStatus.member,
    );

    final secondDocSnapshot = await firestore
        .document('memberships/anotherMember/community-membership/$communityId')
        .get();

    await onCommunityMembership.onCreate(
      secondDocSnapshot,
      Membership(communityId: communityId, userId: 'anotherMember'),
      DateTime.now(),
      MockEventContext(),
    );

    // Verify community document
    final communityDoc =
        await firestore.document('community/$communityId').get();
    print('JEN ${communityDoc.data.toMap()}');
    final onboardingSteps = communityDoc.data
        .toMap()[Community.kFieldOnboardingSteps] as List<dynamic>;

    // Should still only have two steps
    expect(onboardingSteps, hasLength(2));
    expect(
      onboardingSteps,
      contains(EnumToString.convertToString(OnboardingStep.brandSpace)),
    );
    expect(
      onboardingSteps,
      contains(EnumToString.convertToString(OnboardingStep.inviteSomeone)),
    );
  });

  test('Should handle missing onboardingSteps field gracefully', () async {
    // Create community without onboardingSteps
    final communityWithoutSteps = await communityTestUtils.createCommunity(
      community: Community(
        id: '99999',
        name: 'No Steps Community',
        isPublic: true,
        creatorId: creatorId,
      ),
      userId: creatorId,
    );

    // Create membership and call onCreate
    await communityTestUtils.addCommunityMember(
      communityId: communityWithoutSteps['communityId'],
      userId: newMemberId,
      status: MembershipStatus.member,
    );

    final docSnapshot = await firestore
        .document(
          'memberships/$newMemberId/community-membership/${communityWithoutSteps['communityId']}',
        )
        .get();

    await onCommunityMembership.onCreate(
      docSnapshot,
      Membership(communityId: communityId, userId: newMemberId),
      DateTime.now(),
      MockEventContext(),
    );
  });

  test('Should handle non-existent community gracefully', () async {
    // Create membership for non-existent community
    await communityTestUtils.addCommunityMember(
      communityId: 'nonexistent-community',
      userId: newMemberId,
      status: MembershipStatus.member,
    );

    final docSnapshot = await firestore
        .document(
          'memberships/$newMemberId/community-membership/nonexistent-community',
        )
        .get();

    // Call onCreate and verify it doesn't throw exception
    await onCommunityMembership.onCreate(
      docSnapshot,
      Membership(communityId: 'nonexistent-community', userId: newMemberId),
      DateTime.now(),
      MockEventContext(),
    );
  });
}
