import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/firestore/membership_request.dart';

class GetUserAdminDetails extends OnCallMethod<GetUserAdminDetailsRequest> {
  GetUserAdminDetails()
      : super('GetUserAdminDetails', (jsonMap) => GetUserAdminDetailsRequest.fromJson(jsonMap));

  @override
  Future<Map<String, dynamic>> action(
      GetUserAdminDetailsRequest request, CallableContext context) async {
    // Verify user can get these details
    final onlyRequestingSelf =
        request.userIds.length == 1 && request.userIds.single == context?.authUid;

    bool authorized = onlyRequestingSelf;

    if (!authorized && request.juntoId != null) {
      final juntoMembershipDoc = await firestore
          .document('memberships/${context?.authUid}/junto-membership/${request.juntoId}')
          .get();

      final membership = Membership.fromJson(
          firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));

      if (!authorized && request.discussionPath != null) {
        final discussionParticipantDocs = await firestore.getAll(request.userIds
            .map(
                (id) => firestore.document('${request.discussionPath}/discussion-participants/$id'))
            .toList());

        final allUsersAreParticipants = discussionParticipantDocs
            .map((doc) =>
                Participant.fromJson(firestoreUtils.fromFirestoreJson(doc.data?.toMap() ?? {})))
            .every((participant) => participant.status == ParticipantStatus.active);
        authorized = membership.isAdmin && allUsersAreParticipants;
      }

      if (!authorized) {
        print('caller membership');
        print(membership);

        // All requested IDs must be members or requesters of this space.
        final memberDocuments = await firestore.getAll(request.userIds
            .map((id) => firestore.document('memberships/$id/junto-membership/${request.juntoId}'))
            .toList());
        final requestDocuments = await firestore.getAll(request.userIds
            .map((id) => firestore.document('junto/${request.juntoId}/join-requests/$id'))
            .toList());
        final memberships = memberDocuments
            .where((doc) => doc.exists)
            .map((doc) =>
                Membership.fromJson(firestoreUtils.fromFirestoreJson(doc.data?.toMap() ?? {})))
            .where((membership) => membership.isMember || membership.isAttendee)
            .map((membership) => membership.userId);
        print('Requests');
        print(requestDocuments.map((doc) => doc.data?.toMap()));
        final requests = requestDocuments
            .where((doc) => doc.exists)
            .where((d) => d.data?.toMap()['userId'] != null)
            .map((doc) => MembershipRequest.fromJson(
                firestoreUtils.fromFirestoreJson(doc.data?.toMap() ?? {})))
            .map((request) => request.userId);
        final joinedSet = {...memberships, ...requests};
        final allUsersAreMembersOrRequesters = joinedSet.containsAll(request.userIds);

        print('user memberships and requests');
        print(joinedSet);
        authorized = membership.isAdmin && allUsersAreMembersOrRequesters;
      }
    }

    if (!authorized) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final userRecords = await firestoreUtils.getUsers(request.userIds);

    return GetUserAdminDetailsResponse(
      userAdminDetails: userRecords
          .map((record) => UserAdminDetails(
                userId: record.uid,
                email: record.email,
              ))
          .toList(),
    ).toJson();
  }
}
