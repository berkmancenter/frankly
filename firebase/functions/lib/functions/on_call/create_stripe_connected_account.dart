import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/functions/on_call_function.dart';
import 'package:functions/utils/firestore_utils.dart';
import 'package:functions/utils/stripe_util.dart';
import 'package:functions/utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/partner_agreement.dart';

class CreateStripeConnectedAccount
    extends OnCallMethod<CreateStripeConnectedAccountRequest> {
  CreateStripeConnectedAccount()
      : super(
          'createStripeConnectedAccount',
          (jsonMap) => CreateStripeConnectedAccountRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    CreateStripeConnectedAccountRequest request,
    CallableContext context,
  ) async {
    orElseUnauthorized(context.authUid != null);

    final agreementRef =
        firestore.document('partner-agreements/${request.agreementId}');
    final agreementDoc = await agreementRef.get();

    orElseUnauthorized(agreementDoc.exists);

    final agreement =
        PartnerAgreement.fromJson(agreementDoc.data.toMap() ?? {});
    orElseUnauthorized(agreement.allowPayments);
    orElseUnauthorized(agreement.stripeConnectedAccountId == null);
    orElseUnauthorized(agreement.initialUserId == null);

    final Map<String, String> params = {
      'type': 'express',
      'metadata[agreementId]': request.agreementId,
      'metadata[userId]': context.authUid!,
    };

    final jsonResponse =
        await stripeUtil.post(path: '/accounts', params: params);
    final String accountId = jsonResponse['id'];

    final agreementUpdated = agreement.copyWith(
      stripeConnectedAccountId: accountId,
      initialUserId: context.authUid,
    );
    await agreementRef.setData(
      DocumentData.fromMap(
        firestoreUtils.toFirestoreJson(agreementUpdated.toJson()),
      ),
      SetOptions(merge: true),
    );
  }

  // Sets minimum instances to 0
  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(
          runWithOptions ??
              RuntimeOptions(
                timeoutSeconds: 60,
                memory: '1GB',
                minInstances: 0,
              ),
        )
        .https
        .onCall(callAction);
  }
}
