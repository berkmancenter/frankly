import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:data_models/utils/utils.dart';

import '../../../../core/utils/firestore_utils.dart';

class FirestoreUserService {
  static const String publicUser = 'publicUser';

  DocumentReference<Map<String, dynamic>> publicUserReference({
    required String userId,
  }) =>
      firestoreDatabase.firestore.doc('$publicUser/$userId');

  Future<PublicUserInfo> getPublicUser({required String userId}) async {
    final docRef = publicUserReference(userId: userId);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return _convertPublicUserInfoAsync(snapshot);
    } else {
      // If creation of the user failed during sign up this can happen. It
      // should be rare.
      return PublicUserInfo(
        id: userId,
        agoraId: uidToInt(userId),
        displayName: 'User-${userId.substring(0, 4)}',
        imageUrl: 'https://picsum.photos/seed/$userId/160',
      );
    }
  }

  Future<PublicUserInfo?> getPublicUserByAgoraId({required int agoraId}) async {
    final querySnapshot = await firestoreDatabase.firestore
        .collection(publicUser)
        .where('agoraId', isEqualTo: agoraId)
        .get();
    final data = querySnapshot.docs.firstOrNull;
    if (data == null) {
      return null;
    }
    return await _convertPublicUserInfoAsync(data);
  }

  Future<PublicUserInfo> getOrCreatePublicUserInfo({
    required PublicUserInfo defaultUserInfo,
  }) async {
    final docRef = publicUserReference(userId: defaultUserInfo.id);

    return await firestoreDatabase.firestore
        .runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        return _convertPublicUserInfoAsync(snapshot);
      } else {
        transaction.set(docRef, toFirestoreJson(defaultUserInfo.toJson()));
        // New user signed up
        analytics.logEvent(
          AnalyticsUserRegistrationEvent(userId: defaultUserInfo.id),
        );
        return defaultUserInfo;
      }
    });
  }

  Future<void> updatePublicUser({
    required PublicUserInfo userInfo,
    required Iterable<String> keys,
  }) async {
    final docRef = publicUserReference(userId: userInfo.id);
    print('Updating public user');
    await docRef.set(
      jsonSubset(keys, toFirestoreJson(userInfo.toJson())),
      SetOptions(merge: true),
    );
  }

  static Future<PublicUserInfo> _convertPublicUserInfoAsync(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final publicUser = await compute<Map<String, dynamic>, PublicUserInfo>(
      _convertPublicUserInfo,
      doc.data()!,
    );
    return publicUser;
  }

  static PublicUserInfo _convertPublicUserInfo(Map<String, dynamic> data) {
    if (data['agoraId'] == null) {
      data['agoraId'] = uidToInt(data['id']);
    }
    return PublicUserInfo.fromJson(fromFirestoreJson(data));
  }
}
