import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/infra/firestore_utils.dart';
import '../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/admin/partner_agreement.dart';
import 'package:data_models/utils/utils.dart';

class CreateCommunity extends OnCallMethod<CreateCommunityRequest> {
  CreateCommunity()
      : super(
          'createCommunity',
          (json) => CreateCommunityRequest.fromJson(json),
        );

  @override
  Future<Map<String, dynamic>> action(
    CreateCommunityRequest request,
    CallableContext context,
  ) async {
    orElseUnauthorized(context.authUid != null);

    final Community? requestedCommunity = request.community;
    if (requestedCommunity == null) {
      throw HttpsError(
        HttpsError.failedPrecondition,
        'Must provide community information.',
        null,
      );
    }

    Community community = requestedCommunity;

    if ((community.name?.trim() ?? '').isEmpty) {
      throw HttpsError(
        HttpsError.failedPrecondition,
        'Name is required.',
        null,
      );
    }

    final communityCollection = firestore.collection('/community/');
    final communityDocRef = communityCollection.document();

    final communitiesWithMatchingId = await communityCollection
        .where(
          Community.kFieldDisplayIds,
          arrayContains: communityDocRef.documentID,
        )
        .get();
    final alreadyUsedMessage =
        'The URL display name ${communityDocRef.documentID} is already taken.';
    if (communitiesWithMatchingId.isNotEmpty) {
      throw HttpsError(HttpsError.failedPrecondition, alreadyUsedMessage, null);
    }

    final userId = context.authUid;

    community = community.copyWith(
      id: communityDocRef.documentID,
      creatorId: userId,
      profileImageUrl: community.profileImageUrl ??
          'https://picsum.photos/seed/${communityDocRef.documentID}-profile/512',
      bannerImageUrl: community.bannerImageUrl ?? '',
      communitySettings: const CommunitySettings(),
      eventSettings: EventSettings.defaultSettings,
      // Ensure displayIds is not empty
      // If displayIds is empty, use the document ID as the first displayId
      displayIds: [
        community.displayIds.isNotEmpty
            ? community.displayIds[0]
            : communityDocRef.documentID,
    ],);

    final agreementChangedFields = [PartnerAgreement.kFieldCommunityId];
    DocumentReference agreementRef;
    PartnerAgreement agreementUpdated;

    if (request.agreementId != null) {
      agreementRef =
          firestore.document('partner-agreements/${request.agreementId}');
      final agreementDoc = await agreementRef.get();
      orElseUnauthorized(agreementDoc.exists);
      final agreement = PartnerAgreement.fromJson(
        firestoreUtils.fromFirestoreJson(agreementDoc.data.toMap()),
      );
      agreementUpdated =
          agreement.copyWith(communityId: communityDocRef.documentID);
    } else {
      agreementRef = firestore.collection('partner-agreements').document();
      agreementUpdated = PartnerAgreement(
        id: agreementRef.documentID,
        communityId: communityDocRef.documentID,
        allowPayments: true,
      );
      agreementChangedFields.addAll(
        [PartnerAgreement.kFieldId, PartnerAgreement.kFieldAllowPayments],
      );
    }

    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(communityDocRef);

      if (doc.exists) {
        throw HttpsError(
          HttpsError.failedPrecondition,
          alreadyUsedMessage,
          null,
        );
      }

      transaction.set(
        communityDocRef,
        DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(community.toJson()),
        ),
      );

      transaction.set(
        firestore.document(
          'memberships/$userId/community-membership/${communityDocRef.documentID}',
        ),
        DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(
            Membership(
              communityId: communityDocRef.documentID,
              userId: userId!,
              status: MembershipStatus.owner,
            ).toJson(),
          ),
        ),
      );

      transaction.set(
        agreementRef,
        DocumentData.fromMap(
          jsonSubset(
            agreementChangedFields,
            firestoreUtils.toFirestoreJson(agreementUpdated.toJson()),
          ),
        ),
        merge: true,
      );
    });

    return CreateCommunityResponse(communityId: communityDocRef.documentID)
        .toJson();
  }
}
