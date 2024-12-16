import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:junto_models/firestore/membership.dart';

class ResetParticipantAgendaItems extends OnCallMethod<ResetParticipantAgendaItemsRequest> {
  ResetParticipantAgendaItems()
      : super('ResetParticipantAgendaItems',
            (json) => ResetParticipantAgendaItemsRequest.fromJson(json));

  @override
  Future<void> action(ResetParticipantAgendaItemsRequest request, CallableContext context) async {
    final liveMeetingPath = request.liveMeetingPath;
    final juntoIdMatch = RegExp('/?junto/([^/]+)').matchAsPrefix(liveMeetingPath);
    if (juntoIdMatch == null) {
      throw HttpsError(HttpsError.invalidArgument, 'LiveMeetingPath malformed.', null);
    }

    final juntoId = juntoIdMatch.group(1);
    final liveMeetingDoc = await firestore.document(liveMeetingPath).get();
    if (!liveMeetingDoc.exists) {
      throw HttpsError(HttpsError.failedPrecondition, 'Incorrect meeting path', null);
    }

    final discussionMatch =
        RegExp('/?junto/([^/]+)/topics/([^/]+)/discussions/([^/]+)').matchAsPrefix(liveMeetingPath);
    final discussion = await firestoreUtils.getFirestoreObject(
      path: discussionMatch!.group(0)!,
      constructor: (map) => Discussion.fromJson(map),
    );

    final membershipDoc = 'memberships/${context?.authUid}/junto-membership/$juntoId';
    final juntoMembershipDoc = await firestore.document(membershipDoc).get();

    final membership = Membership.fromJson(firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));

    if (!membership.isAdmin && discussion.creatorId != context?.authUid) {
      throw HttpsError(HttpsError.failedPrecondition, 'Unauthorized', null);
    }

    final participantDetails = await firestore
        .collectionGroup('participant-details')
        .where(ParticipantAgendaItemDetails.kFieldMeetingId, isEqualTo: liveMeetingDoc.documentID)
        .get();

    // Verification that all documents match our live meeting
    final docs = participantDetails.documents;
    final matchingPathDocs = docs.where((d) => d.reference.path.startsWith(liveMeetingPath));

    if (docs.length != matchingPathDocs.length) {
      print(
          'Some docs with meetingId: ${liveMeetingDoc.documentID} do not match the requested live meeting path: $liveMeetingPath');
    }

    await Future.wait([
      for (final document in matchingPathDocs) document.reference.delete(),
    ]);
  }
}
