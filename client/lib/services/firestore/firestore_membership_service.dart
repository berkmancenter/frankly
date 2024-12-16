import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/membership.dart';

class FirestoreMembershipService {
  CollectionReference<Map<String, dynamic>> _userMembershipsCollection(String userId) =>
      firestoreDatabase.firestore.collection('memberships/$userId/junto-membership');

  DocumentReference<Map<String, dynamic>> membershipsReference({
    required String userId,
    required String juntoId,
  }) =>
      firestoreDatabase.firestore.doc('memberships/$userId/junto-membership/$juntoId');

  BehaviorSubjectWrapper<List<Membership>> userMembershipsStream(String userId) =>
      wrapInBehaviorSubject(_userMembershipsCollection(userId)
          .snapshots()
          .map((s) => s.docs)
          .asyncMap(_convertMembershipListAsync));

  BehaviorSubjectWrapper<List<Membership>> juntoMembershipsStream({required String juntoId}) {
    return wrapInBehaviorSubject(firestoreDatabase.firestore
        .collectionGroup('junto-membership')
        .where(Membership.kFieldJuntoId, isEqualTo: juntoId)
        .orderBy(Membership.kFieldFirstJoined)
        .snapshots()
        .map((s) => s.docs)
        .asyncMap(_convertMembershipListAsync));
  }

  Stream<Membership?> getMembershipForUser({required String juntoId, required String userId}) {
    return membershipsReference(userId: userId, juntoId: juntoId)
        .snapshots()
        .map((s) => s)
        .asyncMap(_convertMembershipAsync);
  }

  Future<Membership> getMembership({required String juntoId}) async {
    final doc =
        await membershipsReference(userId: userService.currentUserId!, juntoId: juntoId).get();

    return _convertMembership(doc.data() ?? {});
  }

  static Future<List<Membership>> _convertMembershipListAsync(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final memberships =
        await Future.wait(docs.map((doc) => compute(_convertMembership, doc.data())));

    return memberships;
  }

  static Future<Membership?> _convertMembershipAsync(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final docData = doc.data();
    if (docData == null) return null;

    final membership = await compute<Map<String, dynamic>, Membership>(
      _convertMembership,
      docData,
    );
    return membership;
  }

  static Membership _convertMembership(Map<String, dynamic> data) {
    return Membership.fromJson(fromFirestoreJson(data));
  }
}
