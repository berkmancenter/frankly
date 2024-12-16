import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/subscription_plan_util.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/utils.dart';

final baseAllowedUpdateFields = {
  Junto.kFieldName,
  Junto.kFieldContactEmail,
  Junto.kFieldProfileImageUrl,
  Junto.kFieldBannerImageUrl,
  Junto.kFieldIsPublic,
  Junto.kFieldDescription,
  Junto.kFieldTagLine,
  Junto.kFieldCommunitySettings,
  Junto.kFieldDiscussionSettings,
  Junto.kFieldDonationDialogText,
  Junto.kFieldRatingSurveyUrl,
  Junto.kFieldThemeLightColor,
  Junto.kFieldThemeDarkColor,
  Junto.kFieldOnboardingSteps,
};

class UpdateJunto extends OnCallMethod<UpdateJuntoRequest> {
  UpdateJunto() : super('UpdateJunto', (json) => UpdateJuntoRequest.fromJson(json));

  @override
  Future<String> action(UpdateJuntoRequest request, CallableContext context) async {
    orElseUnauthorized(context?.authUid != null);

    Junto junto = request.junto;

    final juntoMembershipDoc = await firestore
        .document('memberships/${context?.authUid}/junto-membership/${junto.id}')
        .get();
    final membership = Membership.fromJson(firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));
    if (!membership.isAdmin) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    if (junto.name != null && (junto.name?.trim() ?? '').isEmpty) {
      throw HttpsError(HttpsError.failedPrecondition, 'Name is required.', null);
    }

    if (!junto.displayIds.contains(junto.id)) {
      junto = junto.copyWith(
        displayIds: [
          ...junto.displayIds,
          junto.id,
          junto.id.toLowerCase(),
        ],
      );
    }

    final juntoCollection = firestore.collection('/junto/');

    for (final displayId in junto.displayIds) {
      final juntosWithMatchingId =
          await juntoCollection.where(Junto.kFieldDisplayIds, arrayContains: displayId).get();
      if (juntosWithMatchingId.isNotEmpty &&
          juntosWithMatchingId.documents.any((doc) => doc.documentID != junto.id)) {
        final alreadyUsedMessage = 'The URL display name $displayId is already taken.';
        throw HttpsError(HttpsError.failedPrecondition, alreadyUsedMessage, null);
      }
    }

    final juntoDocRef = juntoCollection.document(junto.id);

    final capabilities = await subscriptionPlanUtil.calculateCapabilities(junto.id);
    final hasCustomUrls = capabilities.hasCustomUrls;
    final allowedUpdateFields = [
      ...baseAllowedUpdateFields,
      if (hasCustomUrls != null && hasCustomUrls) Junto.kFieldDisplayIds
    ];

    final juntoJson = junto.toJson();
    final updateFields = request.keys.where((key) => allowedUpdateFields.contains(key));
    if (updateFields.isEmpty) {
      throw HttpsError(HttpsError.failedPrecondition, 'No fields to update', null);
    }

    try {
      final finalisedUpdateMap = jsonSubset(updateFields, juntoJson);
      print('Update data: $finalisedUpdateMap');
      await juntoDocRef.updateData(UpdateData.fromMap(firestoreUtils.toFirestoreJson(finalisedUpdateMap)));
      return '';
    } catch (e, s) {
      print('Exception: $e, Stack: $s');
      throw HttpsError(HttpsError.unknown, 'Failed to update document', null);
    }
  }
}
