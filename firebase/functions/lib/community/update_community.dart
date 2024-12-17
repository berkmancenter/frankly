import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/firestore_utils.dart';
import '../utils/subscription_plan_util.dart';
import '../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/utils/utils.dart';

final baseAllowedUpdateFields = {
  Community.kFieldName,
  Community.kFieldContactEmail,
  Community.kFieldProfileImageUrl,
  Community.kFieldBannerImageUrl,
  Community.kFieldIsPublic,
  Community.kFieldDescription,
  Community.kFieldTagLine,
  Community.kFieldCommunitySettings,
  Community.kFieldEventSettings,
  Community.kFieldDonationDialogText,
  Community.kFieldRatingSurveyUrl,
  Community.kFieldThemeLightColor,
  Community.kFieldThemeDarkColor,
  Community.kFieldOnboardingSteps,
};

class UpdateCommunity extends OnCallMethod<UpdateCommunityRequest> {
  UpdateCommunity()
      : super(
          'UpdateCommunity',
          (json) => UpdateCommunityRequest.fromJson(json),
        );

  @override
  Future<String> action(
    UpdateCommunityRequest request,
    CallableContext context,
  ) async {
    orElseUnauthorized(context.authUid != null);

    Community community = request.community;

    final communityMembershipDoc = await firestore
        .document(
          'memberships/${context.authUid}/community-membership/${community.id}',
        )
        .get();
    final membership = Membership.fromJson(
      firestoreUtils
          .fromFirestoreJson(communityMembershipDoc.data.toMap() ?? {}),
    );
    if (!membership.isAdmin) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    if (community.name != null && (community.name?.trim() ?? '').isEmpty) {
      throw HttpsError(
        HttpsError.failedPrecondition,
        'Name is required.',
        null,
      );
    }

    if (!community.displayIds.contains(community.id)) {
      community = community.copyWith(
        displayIds: [
          ...community.displayIds,
          community.id,
          community.id.toLowerCase(),
        ],
      );
    }

    final communityCollection = firestore.collection('/community/');

    for (final displayId in community.displayIds) {
      final communitiesWithMatchingId = await communityCollection
          .where(Community.kFieldDisplayIds, arrayContains: displayId)
          .get();
      if (communitiesWithMatchingId.isNotEmpty &&
          communitiesWithMatchingId.documents
              .any((doc) => doc.documentID != community.id)) {
        final alreadyUsedMessage =
            'The URL display name $displayId is already taken.';
        throw HttpsError(
          HttpsError.failedPrecondition,
          alreadyUsedMessage,
          null,
        );
      }
    }

    final communityDocRef = communityCollection.document(community.id);

    final capabilities =
        await subscriptionPlanUtil.calculateCapabilities(community.id);
    final hasCustomUrls = capabilities.hasCustomUrls;
    final allowedUpdateFields = [
      ...baseAllowedUpdateFields,
      if (hasCustomUrls != null && hasCustomUrls) Community.kFieldDisplayIds,
    ];

    final communityJson = community.toJson();
    final updateFields =
        request.keys.where((key) => allowedUpdateFields.contains(key));
    if (updateFields.isEmpty) {
      throw HttpsError(
        HttpsError.failedPrecondition,
        'No fields to update',
        null,
      );
    }

    try {
      final finalisedUpdateMap = jsonSubset(updateFields, communityJson);
      print('Update data: $finalisedUpdateMap');
      await communityDocRef.updateData(
        UpdateData.fromMap(
          firestoreUtils.toFirestoreJson(finalisedUpdateMap),
        ),
      );
      return '';
    } catch (e, s) {
      print('Exception: $e, Stack: $s');
      throw HttpsError(HttpsError.unknown, 'Failed to update document', null);
    }
  }
}
