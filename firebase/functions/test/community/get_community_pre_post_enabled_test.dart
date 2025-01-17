import 'package:data_models/community/community.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/community/get_community_pre_post_enabled.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/infra/firestore_utils.dart';

import '../util/community_test_utils.dart';
import '../util/function_test_fixture.dart';

void main() {
  const userId = 'fakeAuthId';
  String communityId = '';
  final communityTestUtils = CommunityTestUtils();
  setupTestFixture();

  setUp(() async {
    final communityResult = await communityTestUtils.createCommunity(
      community: Community(
        id: '19954439',
        name: 'Testing Community',
        isPublic: true,
      ),
      userId: userId,
    );
    communityId = communityResult['communityId'];
  });

  test('Should return true since Stripe is disabled', () async {
    final enabledGetter = GetCommunityPrePostEnabled();
    final req = GetCommunityPrePostEnabledRequest(
      communityId: communityId,
    );

    final result = await enabledGetter.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );

    final prePostResult = GetCommunityPrePostEnabledResponse.fromJson(
      firestoreUtils.fromFirestoreJson(result),
    );
    expect(
      prePostResult,
      equals(GetCommunityPrePostEnabledResponse(prePostEnabled: true)),
    );
  });
}
