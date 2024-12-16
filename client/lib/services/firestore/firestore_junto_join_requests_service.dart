import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/membership_request.dart';

class FirestoreJuntoJoinRequestsService {
  BehaviorSubjectWrapper<List<MembershipRequest>> getRequestsForJuntoId({required String juntoId}) {
    return wrapInBehaviorSubject(firestoreDatabase.firestore
        .collection('/junto/$juntoId/join-requests')
        .where('status', isEqualTo: EnumToString.convertToString(MembershipRequestStatus.requested))
        .snapshots()
        .map((s) => s.docs)
        .asyncMap(_convertRequestsListAsync));
  }

  BehaviorSubjectWrapper<MembershipRequest?> getUserRequestForJuntoId({
    required String juntoId,
    required String userId,
  }) {
    return wrapInBehaviorSubject(firestoreDatabase.firestore
        .collection('junto')
        .doc(juntoId)
        .collection('join-requests')
        .doc(userId)
        .snapshots()
        .asyncMap((s) {
      if (s.exists && s.data() != null) {
        return MembershipRequest.fromJson(fromFirestoreJson(s.data() as Map<String, dynamic>));
      } else {
        return null;
      }
    }));
  }

  Future<void> createOrUpdateRequest({required MembershipRequest request}) async {
    await firestoreDatabase.firestore
        .collection('junto')
        .doc(request.juntoId)
        .collection('join-requests')
        .doc(request.userId)
        .set(toFirestoreJson(request.toJson()), SetOptions(merge: true));
  }

  static Future<List<MembershipRequest>> _convertRequestsListAsync(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final requests = await compute(_convertRequestList, docs.map((doc) => doc.data()).toList());

    return requests;
  }

  static List<MembershipRequest> _convertRequestList(List<Map<String, dynamic>> data) {
    return data.map((d) => MembershipRequest.fromJson(fromFirestoreJson(d))).toList();
  }
}
