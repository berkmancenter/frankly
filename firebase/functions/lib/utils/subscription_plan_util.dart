import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'infra/firestore_utils.dart';
import 'utils.dart';
import 'package:data_models/admin/billing_subscription.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/admin/partner_agreement.dart';
import 'package:data_models/admin/plan_capability_list.dart';

const kShowStripeFeatures = false;
var subscriptionPlanUtil = SubscriptionPlanUtil();

class SubscriptionPlanUtil {
  PlanCapabilityList getDefaultCapabilities() {
    return PlanCapabilityList(
      userHours: 0,
      adminCount: 1,
      facilitatorCount: 0,
      takeRate: .3,
      hasSmartMatching: false,
      hasLivestreams: false,
      hasCustomUrls: false,
      hasAdvancedBranding: false,
      hasBasicAnalytics: false,
      hasCustomAnalytics: false,
      hasIntegrations: false,
      hasPrePost: false,
    );
  }

  /// Given a community, return its list of capabilities (governed by its owners subscription level and
  /// any overrides we have specified).
  ///
  /// If `requesterUserId` is specified, ensure that this user is allowed to view the full list of
  /// capabilities (and otherwise throw an error). If it is not specified, assume it's a system call
  /// with full permissions, and the calling code is responsible for not exposing sensitive
  /// capability values (such as `takeRate`) to any user that will see the return value.
  Future<PlanCapabilityList> calculateCapabilities(
    String communityId, {
    String? requesterUserId,
  }) async {
    bool isMod = false;
    if (requesterUserId != null) {
      final membershipDoc =
          'memberships/$requesterUserId/community-membership/$communityId';
      final communityMembershipDoc =
          await firestore.document(membershipDoc).get();

      final membership = Membership.fromJson(
        firestoreUtils.fromFirestoreJson(communityMembershipDoc.data.toMap()),
      );
      isMod = membership.isMod;
    }

    orElseUnauthorized(
      requesterUserId == null || isMod,
      logMessage: 'Only mods or above can access capabilities.',
    );

    // If Stripe is disabled, return early with unrestricted plan regardless of subscription type.
    if (!kShowStripeFeatures) {
      return _getCapabilitiesForType(type: 'unrestricted');
    }

    final overridePlan = await _getOverridePlan(communityId: communityId);

    final subscriptionPlan =
        await _getSubscriptionPlan(communityId: communityId);

    // Allow individual capability overrides with graceful fallback
    return [getDefaultCapabilities(), subscriptionPlan, overridePlan]
        .withoutNulls
        .reduce(_combineCapabilities);
  }

  /// Check if this community is covered by a partner-agreements record that specifies a plan override.
  /// If so, just return the capabilities for that plan type.
  Future<PlanCapabilityList?> _getOverridePlan({
    required String communityId,
  }) async {
    final agreementDocs = await firestore
        .collection('partner-agreements')
        .where(PartnerAgreement.kFieldCommunityId, isEqualTo: communityId)
        .limit(1)
        .get();

    if (agreementDocs.documents.isNotEmpty) {
      PartnerAgreement agreement = PartnerAgreement.fromJson(
        firestoreUtils
            .fromFirestoreJson(agreementDocs.documents.first.data.toMap()),
      );

      final planOverride = agreement.planOverride;
      if (planOverride != null) {
        return _getCapabilitiesForType(type: planOverride);
      }
    }

    return null;
  }

  Future<PlanCapabilityList?> _getSubscriptionPlan({
    required String communityId,
  }) async {
    // Get active subscriptions for communityId
    final subscriptionCollection = firestore.collectionGroup('subscriptions');
    final activeSubscriptions = await subscriptionCollection
        .where(
          BillingSubscription.kFieldActiveUntil,
          isGreaterThan: (DateTime.now().toUtc()),
        )
        .where(
          BillingSubscription.kFieldAppliedCommunityId,
          isEqualTo: communityId,
        )
        .get();

    if (activeSubscriptions.isNotEmpty) {
      // Return combined capability list
      final subscriptions = activeSubscriptions.documents.map(
        (doc) => BillingSubscription.fromJson(
          firestoreUtils.fromFirestoreJson(doc.data.toMap()),
        ),
      );
      final types =
          subscriptions.map((subscription) => subscription.type).toSet();
      final planFutures = types.map((e) => _getCapabilitiesForType(type: e));
      final plans = await Future.wait(planFutures);
      return plans.reduce(_combineCapabilities);
    }

    return null;
  }

  /// Return the designated capabilities for a subscription of a given type. These are set manually
  /// by us in the plan-capability-lists collection.
  Future<PlanCapabilityList> _getCapabilitiesForType({
    required String type,
  }) async {
    final matchingCapabilities = await firestore
        .collection('plan-capability-lists')
        .where(PlanCapabilityList.kFieldType, isEqualTo: type)
        .limit(1)
        .get();

    if (matchingCapabilities.documents.isNotEmpty) {
      return PlanCapabilityList.fromJson(
        firestoreUtils.fromFirestoreJson(
          matchingCapabilities.documents.first.data.toMap(),
        ),
      );
    } else {
      print('Using default capabilities');
      return getDefaultCapabilities();
    }
  }

  /// Combine two capability lists into one; for each individual capability field, choose the better
  /// of the two from among the inputs (from the perspective of the customer)
  PlanCapabilityList _combineCapabilities(
    PlanCapabilityList a,
    PlanCapabilityList b,
  ) {
    return PlanCapabilityList(
      type: applyReducerWithNullable(_getOverridingType, a.type, b.type),
      userHours: applyReducerWithNullable(max, a.userHours, b.userHours),
      adminCount: applyReducerWithNullable(max, a.adminCount, b.adminCount),
      facilitatorCount:
          applyReducerWithNullable(max, a.facilitatorCount, b.facilitatorCount),
      takeRate: applyReducerWithNullable(min, a.takeRate, b.takeRate),
      hasSmartMatching: applyReducerWithNullable(
        orOperator,
        a.hasSmartMatching,
        b.hasSmartMatching,
      ),
      hasLivestreams: applyReducerWithNullable(
        orOperator,
        a.hasLivestreams,
        b.hasLivestreams,
      ),
      hasCustomUrls: applyReducerWithNullable(
        orOperator,
        a.hasCustomUrls,
        b.hasCustomUrls,
      ),
      hasAdvancedBranding: applyReducerWithNullable(
        orOperator,
        a.hasAdvancedBranding,
        b.hasAdvancedBranding,
      ),
      hasBasicAnalytics: applyReducerWithNullable(
        orOperator,
        a.hasBasicAnalytics,
        b.hasBasicAnalytics,
      ),
      hasCustomAnalytics: applyReducerWithNullable(
        orOperator,
        a.hasCustomAnalytics,
        b.hasCustomAnalytics,
      ),
      hasIntegrations: applyReducerWithNullable(
        orOperator,
        a.hasIntegrations,
        b.hasIntegrations,
      ),
      hasPrePost:
          applyReducerWithNullable(orOperator, a.hasPrePost, b.hasPrePost),
    );
  }

  bool orOperator(bool a, bool b) => a || b;

  /// Apply a reducing function that expects non-null args -- if one of the inputs is null, choose
  /// the other (without applying the reducer function).
  T? applyReducerWithNullable<T>(T Function(T, T) f, T? a, T? b) {
    if (a == null) {
      return b;
    } else if (b == null) {
      return a;
    } else {
      return f(a, b);
    }
  }

  /// Return what we consider to be the more capable plan type; useful for display purposes
  String _getOverridingType(String a, String b) {
    final ordering = [
      EnumToString.convertToString(PlanType.unrestricted),
      EnumToString.convertToString(PlanType.pro),
      EnumToString.convertToString(PlanType.club),
      EnumToString.convertToString(PlanType.individual),
    ];
    if (ordering.indexOf(a) < ordering.indexOf(b)) {
      return a;
    } else {
      return b;
    }
  }
}
