import 'package:data_models/admin/plan_capability_list.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:functions/utils/infra/firestore_utils.dart';

class SubscriptionTestUtils {
  static final unrestrictedPlan = PlanCapabilityList(
    type: 'unrestricted',
    adminCount: 1000000,
    facilitatorCount: 1000000,
    hasAdvancedBranding: true,
    hasBasicAnalytics: true,
    hasCustomAnalytics: true,
    hasCustomUrls: true,
    hasIntegrations: true,
    hasLivestreams: true,
    hasPrePost: true,
    hasSmartMatching: true,
    userHours: 1000000,
  );
  static final unrestrictedPlanWithQuotas =
      unrestrictedPlan.copyWith(adminCount: 1, facilitatorCount: 1);

  Future<void> addUnrestrictedPlanCapabilities({
    required PlanCapabilityList planCapabilities,
  }) async {
    final planCollection = firestore.collection('/plan-capability-lists/');
    final planDocRef = planCollection.document();
    await firestore.runTransaction((transaction) async {
      transaction.set(
        planDocRef,
        DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(planCapabilities.toJson()),
        ),
      );
    });
  }

  Future<void> removeUnrestrictedPlanCapabilities() async {
    final matchingCapabilities = await firestore
        .collection('plan-capability-lists')
        .where(
          PlanCapabilityList.kFieldType,
          isEqualTo: 'unrestricted',
        )
        .limit(1)
        .get();

    if (matchingCapabilities.documents.isNotEmpty) {
      await matchingCapabilities.documents.first.reference.delete();
    }
  }
}
