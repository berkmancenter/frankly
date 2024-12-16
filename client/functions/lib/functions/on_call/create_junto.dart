import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/firestore/partner_agreement.dart';
import 'package:junto_models/utils.dart';

class CreateJunto extends OnCallMethod<CreateJuntoRequest> {
  CreateJunto() : super('createJunto', (json) => CreateJuntoRequest.fromJson(json));

  @override
  Future<Map<String, dynamic>> action(CreateJuntoRequest request, CallableContext context) async {
    orElseUnauthorized(context?.authUid != null);

    final Junto? requestedJunto = request.junto;
    if (requestedJunto == null) {
      throw HttpsError(HttpsError.failedPrecondition, 'Must provide junto information.', null);
    }

    Junto junto = requestedJunto;

    if ((junto.name?.trim() ?? '').isEmpty) {
      throw HttpsError(HttpsError.failedPrecondition, 'Name is required.', null);
    }

    final juntoCollection = firestore.collection('/junto/');
    final juntoDocRef = juntoCollection.document();

    final juntosWithMatchingId = await juntoCollection
        .where(Junto.kFieldDisplayIds, arrayContains: juntoDocRef.documentID)
        .get();
    final alreadyUsedMessage = 'The URL display name ${juntoDocRef.documentID} is already taken.';
    if (juntosWithMatchingId.isNotEmpty) {
      throw HttpsError(HttpsError.failedPrecondition, alreadyUsedMessage, null);
    }

    final userId = context?.authUid;

    junto = junto.copyWith(
        id: juntoDocRef.documentID,
        creatorId: userId,
        profileImageUrl: junto.profileImageUrl ??
            'https://picsum.photos/seed/${juntoDocRef.documentID}-profile/512',
        bannerImageUrl: junto.bannerImageUrl ?? '',
        communitySettings: const CommunitySettings(),
        discussionSettings: DiscussionSettings.defaultSettings,
        displayIds: [juntoDocRef.documentID]);

    final agreementChangedFields = [PartnerAgreement.kFieldJuntoId];
    DocumentReference agreementRef;
    PartnerAgreement agreementUpdated;

    if (request.agreementId != null) {
      agreementRef = firestore.document('partner-agreements/${request.agreementId}');
      final agreementDoc = await agreementRef.get();
      orElseUnauthorized(agreementDoc.exists);
      final agreement = PartnerAgreement.fromJson(firestoreUtils.fromFirestoreJson(agreementDoc.data?.toMap() ?? {}));
      agreementUpdated = agreement.copyWith(juntoId: juntoDocRef.documentID);
    } else {
      agreementRef = firestore.collection('partner-agreements').document();
      agreementUpdated = PartnerAgreement(
        id: agreementRef.documentID,
        juntoId: juntoDocRef.documentID,
        allowPayments: true,
      );
      agreementChangedFields
          .addAll([PartnerAgreement.kFieldId, PartnerAgreement.kFieldAllowPayments]);
    }

    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(juntoDocRef);

      if (doc.exists) {
        throw HttpsError(HttpsError.failedPrecondition, alreadyUsedMessage, null);
      }

      transaction.set(juntoDocRef, DocumentData.fromMap(firestoreUtils.toFirestoreJson(junto.toJson())));

      transaction.set(
          firestore.document('memberships/$userId/junto-membership/${juntoDocRef.documentID}'),
          DocumentData.fromMap(firestoreUtils.toFirestoreJson(Membership(
            juntoId: juntoDocRef.documentID,
            userId: userId!,
            status: MembershipStatus.owner,
          ).toJson())));

      transaction.set(
        agreementRef,
        DocumentData.fromMap(jsonSubset(agreementChangedFields, firestoreUtils.toFirestoreJson(agreementUpdated.toJson()))),
        merge: true,
      );
    });

    return CreateJuntoResponse(juntoId: juntoDocRef.documentID).toJson();
  }
}
