import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/member_details.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/firestore/public_user_info.dart';
import 'package:quiver/iterables.dart';

class GetMembersData extends OnCallMethod<GetMembersDataRequest> {
  GetMembersData() : super('GetMembersData', (jsonMap) => GetMembersDataRequest.fromJson(jsonMap));

  @override
  Future<Map<String, dynamic>> action(
      GetMembersDataRequest request, CallableContext context) async {
    final juntoId = request.juntoId;

    // Check if current user is admin
    final adminMembershipDocRef = 'memberships/${context?.authUid}/junto-membership/$juntoId';
    final juntoMembershipDoc = await firestore.document(adminMembershipDocRef).get();

    final membership = Membership.fromJson(firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));

    if (!membership.isAdmin) {
      throw HttpsError(HttpsError.failedPrecondition, 'Unauthorized', null);
    }

    final memberDetailsList = <MemberDetails>[];

    final discussionPath = request.discussionPath;
    Discussion? discussion;
    if (discussionPath != null) {
      final discussionDoc = await firestore.document(discussionPath).get();
      discussion = Discussion.fromJson(firestoreUtils.fromFirestoreJson(discussionDoc.data.toMap()));
    }

    for (var userIdsBatch in partition(request.userIds, 250)) {
      final List<Future<MemberDetails>> memberDetailsListFutures = [];
      for (var member in userIdsBatch) {
        memberDetailsListFutures.add(_getDataForUser(
          memberId: member,
          juntoId: juntoId,
          discussion: discussion,
        ));
      }
      memberDetailsList.addAll(await Future.wait(memberDetailsListFutures));
    }

    return GetMembersDataResponse(
      membersDetailsList: memberDetailsList,
    ).toJson();
  }

  Future<MemberDetails> _getDataForUser({
    required String memberId,
    required String juntoId,
    required Discussion? discussion,
  }) async {
    // Check memberId user membership
    final membershipDocRef = 'memberships/$memberId/junto-membership/$juntoId';
    final membershipDoc = await firestore.document(membershipDocRef).get();

    // Get memberId user membership details
    final membershipDetails = membershipDoc.exists
        ? Membership.fromJson(firestoreUtils.fromFirestoreJson(membershipDoc.data?.toMap() ?? {}))
        : Membership(userId: memberId, juntoId: juntoId, status: MembershipStatus.nonmember);

    // Get memberId user info
    final memberInfo = await firestoreUtils.getUser(memberId);

    final String memberName;
    if (isNullOrEmpty(memberInfo.displayName)) {
      final memberDoc = await firestore.document('publicUser/${memberInfo.uid}').get();
      final publicUserInfo = PublicUserInfo.fromJson(firestoreUtils.fromFirestoreJson(memberDoc.data.toMap()));
      memberName = publicUserInfo.displayName ?? '';
    } else {
      memberName = memberInfo.displayName;
    }

    // Get memberId user chats and suggestions per discussion within current junto
    MemberDiscussionData? memberDiscussionsData;

    if (discussion != null) {
      final String discussionPath = discussion.fullPath;

      final participantData =
          await firestore.document('$discussionPath/discussion-participants/$memberId').get();

      final participant = Participant.fromJson(firestoreUtils.fromFirestoreJson(participantData.data.toMap()));

      memberDiscussionsData = MemberDiscussionData(
        discussionId: discussion.id,
        topicId: discussion.topicId,
        participant: participant,
      );
    }

    return MemberDetails(
      id: memberId,
      email: memberInfo.email,
      displayName: memberName,
      membership: membershipDetails,
      memberDiscussion: memberDiscussionsData,
    );
  }
}
