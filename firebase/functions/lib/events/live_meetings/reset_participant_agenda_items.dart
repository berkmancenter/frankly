import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import '../../utils/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/community/membership.dart';

class ResetParticipantAgendaItems
    extends OnCallMethod<ResetParticipantAgendaItemsRequest> {
  ResetParticipantAgendaItems()
      : super(
          'ResetParticipantAgendaItems',
          (json) => ResetParticipantAgendaItemsRequest.fromJson(json),
        );

  @override
  Future<void> action(
    ResetParticipantAgendaItemsRequest request,
    CallableContext context,
  ) async {
    final liveMeetingPath = request.liveMeetingPath;
    final communityIdMatch =
        RegExp('/?community/([^/]+)').matchAsPrefix(liveMeetingPath);
    if (communityIdMatch == null) {
      throw HttpsError(
        HttpsError.invalidArgument,
        'LiveMeetingPath malformed.',
        null,
      );
    }

    final communityId = communityIdMatch.group(1);
    final liveMeetingDoc = await firestore.document(liveMeetingPath).get();
    if (!liveMeetingDoc.exists) {
      throw HttpsError(
        HttpsError.failedPrecondition,
        'Incorrect meeting path',
        null,
      );
    }

    final eventMatch =
        RegExp('/?community/([^/]+)/templates/([^/]+)/events/([^/]+)')
            .matchAsPrefix(liveMeetingPath);
    final event = await firestoreUtils.getFirestoreObject(
      path: eventMatch!.group(0)!,
      constructor: (map) => Event.fromJson(map),
    );

    final membershipDoc =
        'memberships/${context.authUid}/community-membership/$communityId';
    final communityMembershipDoc =
        await firestore.document(membershipDoc).get();

    final membership = Membership.fromJson(
      firestoreUtils
          .fromFirestoreJson(communityMembershipDoc.data.toMap() ?? {}),
    );

    if (!membership.isAdmin && event.creatorId != context.authUid) {
      throw HttpsError(HttpsError.failedPrecondition, 'Unauthorized', null);
    }

    final participantDetails = await firestore
        .collectionGroup('participant-details')
        .where(
          ParticipantAgendaItemDetails.kFieldMeetingId,
          isEqualTo: liveMeetingDoc.documentID,
        )
        .get();

    // Verification that all documents match our live meeting
    final docs = participantDetails.documents;
    final matchingPathDocs =
        docs.where((d) => d.reference.path.startsWith(liveMeetingPath));

    if (docs.length != matchingPathDocs.length) {
      print(
        'Some docs with meetingId: ${liveMeetingDoc.documentID} do not match the requested live meeting path: $liveMeetingPath',
      );
    }

    await Future.wait([
      for (final document in matchingPathDocs) document.reference.delete(),
    ]);
  }
}
