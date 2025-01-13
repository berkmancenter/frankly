import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../utils/infra/firestore_event_function.dart';
import '../../utils/infra/on_firestore_helper.dart';
import '../../on_firestore_function.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/admin/partner_agreement.dart';

import '../../utils/infra/firestore_utils.dart';

class OnPartnerAgreements extends OnFirestoreFunction<PartnerAgreement> {
  OnPartnerAgreements()
      : super(
          [
            AppFirestoreFunctionData(
              'PartnerAgreementOnCreate',
              FirestoreEventType.onCreate,
            ),
            AppFirestoreFunctionData(
              'PartnerAgreementOnUpdate',
              FirestoreEventType.onUpdate,
            ),
          ],
          (snapshot) {
            return PartnerAgreement.fromJson(
              firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
            ).copyWith(id: snapshot.documentID);
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
      final String? communityId = after.communityId;
      if (communityId != null) {
        await onboardingStepsHelper.updateOnboardingSteps(
          communityId,
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
    print(
      'Partner Agreement (${documentSnapshot.documentID}) has been created',
    );

    final String communityId =
        documentSnapshot.data.getString(FirestoreHelper.kCommunityId);

    await onboardingStepsHelper.updateOnboardingSteps(
      communityId,
      documentSnapshot,
      firestoreHelper,
      OnboardingStep.createStripeAccount,
    );
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
