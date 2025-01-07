import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/admin/billing_subscription.dart';

class FirestoreBillingSubscriptionsService {
  _subscriptionDocReference({
    required String userId,
    required String subscriptionId,
  }) =>
      _subscriptionsCollectionReference(userId: userId)
          .doc('subscriptions/$subscriptionId');

  CollectionReference<Map<String, dynamic>> _subscriptionsCollectionReference({
    required String userId,
  }) =>
      firestoreDatabase.firestore
          .collection('stripeUserData/$userId/subscriptions');

  BehaviorSubjectWrapper<BillingSubscription?> getSubscription({
    required String userId,
    required String subscriptionId,
  }) {
    return wrapInBehaviorSubject(
      _subscriptionDocReference(
        userId: userId,
        subscriptionId: subscriptionId,
      ).snapshots().asyncMap(_convertBillingSubscriptionAsync),
    );
  }

  BehaviorSubjectWrapper<List<BillingSubscription>> getActiveSubscriptions({
    required String userId,
  }) {
    return wrapInBehaviorSubject(
      _subscriptionsCollectionReference(userId: userId)
          .where(
            BillingSubscription.kFieldActiveUntil,
            isGreaterThan: clockService.now().toUtc(),
          )
          .orderBy(BillingSubscription.kFieldActiveUntil)
          .snapshots()
          .map((s) => s.docs)
          .asyncMap(_convertBillingSubscriptionListAsync),
    );
  }

  Stream<BillingSubscription?> getActiveSubscription({
    required String userId,
    required String communityId,
  }) {
    return _subscriptionsCollectionReference(userId: userId)
        .where(
          BillingSubscription.kFieldActiveUntil,
          isGreaterThan: clockService.now().toUtc(),
        )
        .where(BillingSubscription.kFieldCanceled, isEqualTo: false)
        .where(
          BillingSubscription.kFieldAppliedCommunityId,
          isEqualTo: communityId,
        )
        .orderBy(BillingSubscription.kFieldActiveUntil)
        .snapshots()
        .map((s) => s.docs)
        .asyncMap(_convertBillingSubscriptionListAsync)
        .map((s) => s.firstOrNull);
  }

  Future<bool> userHasResumableSubscriptionForCommunity({
    required String userId,
    required String communityId,
  }) async {
    final subscriptionRefs =
        await _subscriptionsCollectionReference(userId: userId)
            .where(BillingSubscription.kFieldCanceled, isEqualTo: false)
            .where(
              BillingSubscription.kFieldAppliedCommunityId,
              isEqualTo: communityId,
            )
            .get();
    return subscriptionRefs.docs
        .map((e) => BillingSubscription.fromJson(fromFirestoreJson(e.data())))
        .isNotEmpty;
  }

  static Future<List<BillingSubscription>> _convertBillingSubscriptionListAsync(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final memberships = await Future.wait(
      docs.map((doc) => compute(_convertBillingSubscription, doc.data())),
    );

    return memberships;
  }

  static Future<BillingSubscription?> _convertBillingSubscriptionAsync(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    if (!doc.exists) {
      return null;
    }
    final billingSubscription =
        await compute(_convertBillingSubscription, doc.data()!);
    return billingSubscription;
  }

  static BillingSubscription _convertBillingSubscription(
    Map<String, dynamic> data,
  ) {
    return BillingSubscription.fromJson(fromFirestoreJson(data));
  }
}
