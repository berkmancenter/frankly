import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/firestore_event_function.dart';
import 'package:junto_functions/functions/firestore_helper.dart';
import 'package:junto_functions/functions/on_firestore_function.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/partner_agreement.dart';

import '../../utils/firestore_utils.dart';

class OnPartnerAgreements extends OnFirestoreFunction<PartnerAgreement> {
  OnPartnerAgreements()
      : super(
          [
            AppFirestoreFunctionData('PartnerAgreementOnCreate', FirestoreEventType.onCreate),
            AppFirestoreFunctionData('PartnerAgreementOnUpdate', FirestoreEventType.onUpdate)
          ],
          (snapshot) {
            return PartnerAgreement.fromJson(firestoreUtils.fromFirestoreJson(snapshot.data.toMap()))
                .copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath => 'partner-agreements/{partnerAgreementId}';

  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    PartnerAgreement before,
    PartnerAgreement after,
    DateTime updateTime,
    EventContext context,
  ) async {
    print('Partner Agreement (${before.id}) has been updated');

    final beforeStripeId = before.stripeConnectedAccountId;
    final afterStripeId = after.stripeConnectedAccountId;

    // Checks whether new billing account was created.
    if (beforeStripeId == null && afterStripeId != null) {
      final String? juntoId = after.juntoId;
      if (juntoId != null) {
        await onboardingStepsHelper.updateOnboardingSteps(
          juntoId,
          changes.after,
          firestoreHelper,
          OnboardingStep.createStripeAccount,
        );
      }
    }
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    PartnerAgreement parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    print('Partner Agreement (${documentSnapshot.documentID}) has been created');

    final String? juntoId = documentSnapshot.data.getString(FirestoreHelper.kJuntoId);
    if (juntoId != null) {
      final String? stripeId =
          documentSnapshot.data.getString(PartnerAgreement.kFieldStripeConnectedAccountId);
      if (stripeId != null) {
        await onboardingStepsHelper.updateOnboardingSteps(
          juntoId,
          documentSnapshot,
          firestoreHelper,
          OnboardingStep.createStripeAccount,
        );
      }
    }
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    PartnerAgreement parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    PartnerAgreement before,
    PartnerAgreement after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
