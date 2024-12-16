import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/subscription_plan_util.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/partner_agreement.dart';

class GetJuntoDonationsEnabled extends OnCallMethod<GetJuntoDonationsEnabledRequest> {
  GetJuntoDonationsEnabled()
      : super(
          'GetJuntoDonationsEnabled',
          (jsonMap) => GetJuntoDonationsEnabledRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
      GetJuntoDonationsEnabledRequest request, CallableContext context) async {
    return GetJuntoDonationsEnabledResponse(
            donationsEnabled: await _isEnabled(juntoId: request.juntoId))
        .toJson();
  }

  Future<bool> _isEnabled({required String juntoId}) async {
    final juntoSnapshot = await firestore.document('/junto/$juntoId').get();
    orElseNotFound(juntoSnapshot.exists);
    final junto = Junto.fromJson(firestoreUtils.fromFirestoreJson(juntoSnapshot.data.toMap()));

    if (!kShowStripeFeatures) {
      return false;
    }
    
    if (!junto.settingsMigration.allowDonations) {
      return false;
    }

    final agreementDocs = await firestore
        .collection('partner-agreements')
        .where(
          PartnerAgreement.kFieldJuntoId,
          isEqualTo: juntoId,
        )
        .get();
    if (agreementDocs.documents.isNotEmpty) {
      final agreement = PartnerAgreement.fromJson(firestoreUtils.fromFirestoreJson(agreementDocs.documents.first.data.toMap()));
      return agreement.stripeConnectedAccountActive;
    }

    return false;
  }
}
