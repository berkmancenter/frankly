import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart' as admin;
import '../on_call_function.dart';
import '../utils/firestore_utils.dart';
import '../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/member_details.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:quiver/iterables.dart';

class GetMembersData extends OnCallMethod<GetMembersDataRequest> {
  GetMembersData()
      : super(
          'GetMembersData',
          (jsonMap) => GetMembersDataRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetMembersDataRequest request,
    CallableContext context,
  ) async {
    final communityId = request.communityId;

    // Check if current user is admin
    final adminMembershipDocRef =
        'memberships/${context.authUid}/community-membership/$communityId';
    final communityMembershipDoc =
        await firestore.document(adminMembershipDocRef).get();

    final membership = Membership.fromJson(
      firestoreUtils
          .fromFirestoreJson(communityMembershipDoc.data.toMap() ?? {}),
    );

    if (!membership.isAdmin) {
      throw HttpsError(HttpsError.failedPrecondition, 'Unauthorized', null);
    }

    final memberDetailsList = <MemberDetails>[];

    final eventPath = request.eventPath;
    Event? event;
    if (eventPath != null) {
      final eventDoc = await firestore.document(eventPath).get();
      event = Event.fromJson(
        firestoreUtils.fromFirestoreJson(eventDoc.data.toMap()),
      );
    }

    for (var userIdsBatch in partition(request.userIds, 250)) {
      final List<Future<MemberDetails>> memberDetailsListFutures = [];
      for (var member in userIdsBatch) {
        memberDetailsListFutures.add(
          _getDataForUser(
            memberId: member,
            communityId: communityId,
            event: event,
          ),
        );
      }
      memberDetailsList.addAll(await Future.wait(memberDetailsListFutures));
    }

    return GetMembersDataResponse(
      membersDetailsList: memberDetailsList,
    ).toJson();
  }

  Future<MemberDetails> _getDataForUser({
    required String memberId,
    required String communityId,
    required Event? event,
  }) async {
    // Check memberId user membership
    final membershipDocRef =
        'memberships/$memberId/community-membership/$communityId';
    final membershipDoc = await firestore.document(membershipDocRef).get();

    // Get memberId user membership details
    final membershipDetails = membershipDoc.exists
        ? Membership.fromJson(
            firestoreUtils.fromFirestoreJson(membershipDoc.data.toMap() ?? {}),
          )
        : Membership(
            userId: memberId,
            communityId: communityId,
            status: MembershipStatus.nonmember,
          );

    admin.UserRecord? memberInfo;
    try {
      // Get memberId user info
      memberInfo = await firestoreUtils.getUser(memberId);
    } catch (e) {
      print('Error getting user info for $memberId: $e');
    }

    final String memberName;
    if (isNullOrEmpty(memberInfo?.displayName)) {
      final memberDoc = await firestore.document('publicUser/$memberId').get();
      memberName = memberDoc.data.toMap()['displayName'] ?? '';
    } else {
      memberName = memberInfo!.displayName;
    }

    // Get memberId user chats and suggestions per event within current community
    MemberEventData? memberEventsData;

    if (event != null) {
      final String eventPath = event.fullPath;

      final participantData = await firestore
          .document('$eventPath/event-participants/$memberId')
          .get();

      final participant = Participant.fromJson(
        firestoreUtils.fromFirestoreJson(participantData.data.toMap()),
      );

      memberEventsData = MemberEventData(
        eventId: event.id,
        templateId: event.templateId,
        participant: participant,
      );
    }

    return MemberDetails(
      id: memberId,
      email: memberInfo?.email ?? "Unknown",
      displayName: memberName,
      membership: membershipDetails,
      memberEvent: memberEventsData,
    );
  }
}
