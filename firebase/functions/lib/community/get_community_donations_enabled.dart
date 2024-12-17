import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/firestore_utils.dart';
import '../utils/subscription_plan_util.dart';
import '../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/community.dart';
import 'package:data_models/firestore/partner_agreement.dart';

class GetCommunityDonationsEnabled
    extends OnCallMethod<GetCommunityDonationsEnabledRequest> {
  GetCommunityDonationsEnabled()
      : super(
          'GetCommunityDonationsEnabled',
          (jsonMap) => GetCommunityDonationsEnabledRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetCommunityDonationsEnabledRequest request,
    CallableContext context,
  ) async {
    return GetCommunityDonationsEnabledResponse(
      donationsEnabled: await _isEnabled(communityId: request.communityId),
    ).toJson();
  }

  Future<bool> _isEnabled({required String communityId}) async {
    final communitySnapshot =
        await firestore.document('/community/$communityId').get();
    orElseNotFound(communitySnapshot.exists);
    final community = Community.fromJson(
      firestoreUtils.fromFirestoreJson(communitySnapshot.data.toMap()),
    );

    if (!kShowStripeFeatures) {
      return false;
    }

    if (!community.settingsMigration.allowDonations) {
      return false;
    }

    final agreementDocs = await firestore
        .collection('partner-agreements')
        .where(
          PartnerAgreement.kFieldCommunityId,
          isEqualTo: communityId,
        )
        .get();
    if (agreementDocs.documents.isNotEmpty) {
      final agreement = PartnerAgreement.fromJson(
        firestoreUtils
            .fromFirestoreJson(agreementDocs.documents.first.data.toMap()),
      );
      return agreement.stripeConnectedAccountActive;
    }

    return false;
  }
}
