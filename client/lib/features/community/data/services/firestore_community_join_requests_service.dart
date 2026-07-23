import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/community/membership_request.dart';

class FirestoreCommunityJoinRequestsService {
  BehaviorSubjectWrapper<List<MembershipRequest>> getRequestsForCommunityId({
    required String communityId,
  }) {
    return wrapInBehaviorSubject(
      firestoreDatabase.firestore
          .collection('/community/$communityId/join-requests')
          .where(
            'status',
            isEqualTo:
                EnumToString.convertToString(MembershipRequestStatus.requested),
          )
          .snapshots()
          .map((s) => s.docs)
          .asyncMap(_convertRequestsListAsync),
    );
  }

  BehaviorSubjectWrapper<MembershipRequest?> getUserRequestForCommunityId({
    required String communityId,
    required String userId,
  }) {
    return wrapInBehaviorSubject(
      firestoreDatabase.firestore
          .collection('community')
          .doc(communityId)
          .collection('join-requests')
          .doc(userId)
          .snapshots()
          .asyncMap((s) {
        if (s.exists && s.data() != null) {
          return MembershipRequest.fromJson(
            fromFirestoreJson(s.data() as Map<String, dynamic>),
          );
        } else {
          return null;
        }
      }),
    );
  }

  Future<void> createOrUpdateRequest({
    required MembershipRequest request,
  }) async {
    await firestoreDatabase.firestore
        .collection('community')
        .doc(request.communityId)
        .collection('join-requests')
        .doc(request.userId)
        .set(toFirestoreJson(request.toJson()), SetOptions(merge: true));
  }

  /// Deletes a membership request for a given community and user.
  /// [communityId] is the ID of the community.
  /// [userId] is the ID of the user whose request is to be deleted.
  /// Returns a Future that completes when the deletion is done.
  Future<void> deleteRequest({
    required String communityId,
    required String userId,
  }) async {
    await firestoreDatabase.firestore
        .collection('community')
        .doc(communityId)
        .collection('join-requests')
        .doc(userId)
        .delete();
  }

  static Future<List<MembershipRequest>> _convertRequestsListAsync(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final requests = await compute(
      _convertRequestList,
      docs.map((doc) => doc.data()).toList(),
    );

    return requests;
  }

  static List<MembershipRequest> _convertRequestList(
    List<Map<String, dynamic>> data,
  ) {
    return data
        .map((d) => MembershipRequest.fromJson(fromFirestoreJson(d)))
        .toList();
  }
}
