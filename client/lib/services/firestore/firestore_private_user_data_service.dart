import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services/services.dart';
import 'package:data_models/community/community_user_settings.dart';
import 'package:data_models/utils/utils.dart';

import 'firestore_utils.dart';

class FirestorePrivateUserDataService {
  static const String privateUserData = 'privateUserData';
  static const String communityUserSettings = 'communityUserSettings';

  DocumentReference<Map<String, dynamic>> _communityUserSettingsReference({
    required String userId,
    required String communityId,
  }) =>
      firestoreDatabase.firestore
          .doc('$privateUserData/$userId/$communityUserSettings/$communityId');

  Stream<CommunityUserSettings> getCommunityUserSettings({
    required String userId,
    required String communityId,
  }) {
    final docRef = _communityUserSettingsReference(
      userId: userId,
      communityId: communityId,
    );
    return docRef.snapshots().asyncMap((snapshot) async {
      if (snapshot.exists) {
        return _convertCommunityUserSettingsWithDefaultsAsync(snapshot);
      } else {
        return userService.getDefaultCommunityUserSettings(
          communityId: communityId,
        );
      }
    });
  }

  Future<CommunityUserSettings> getOrCreateCommunityUserSettings({
    required CommunityUserSettings defaultCommunityUserSettings,
  }) async {
    final docRef = _communityUserSettingsReference(
      userId: defaultCommunityUserSettings.userId!,
      communityId: defaultCommunityUserSettings.communityId!,
    );

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return _convertCommunityUserSettingsWithDefaultsAsync(snapshot);
    } else {
      await docRef.set(toFirestoreJson(defaultCommunityUserSettings.toJson()));
      return defaultCommunityUserSettings;
    }
  }

  Future<void> updateCommunityUserSettings({
    required CommunityUserSettings communityUserSettings,
    Iterable<String>? keys,
  }) async {
    final docRef = _communityUserSettingsReference(
      userId: communityUserSettings.userId!,
      communityId: communityUserSettings.communityId!,
    );
    await docRef.set(
      jsonSubset(keys ?? {}, toFirestoreJson(communityUserSettings.toJson())),
      SetOptions(merge: true),
    );
  }

  static Future<CommunityUserSettings>
      _convertCommunityUserSettingsWithDefaultsAsync(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    var privateUserSettings = await _convertCommunityUserSettingsAsync(doc);
    if (privateUserSettings.notifyAnnouncements == null) {
      privateUserSettings = privateUserSettings.copyWith(
        notifyAnnouncements: NotificationEmailType.immediate,
      );
    }
    if (privateUserSettings.notifyEvents == null) {
      privateUserSettings = privateUserSettings.copyWith(
        notifyEvents: NotificationEmailType.immediate,
      );
    }
    return privateUserSettings;
  }

  static Future<CommunityUserSettings> _convertCommunityUserSettingsAsync(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final privateUserSettings =
        await compute<Map<String, dynamic>, CommunityUserSettings>(
      _convertCommunityUserSettings,
      doc.data()!,
    );
    return privateUserSettings;
  }

  static CommunityUserSettings _convertCommunityUserSettings(
    Map<String, dynamic> data,
  ) {
    return CommunityUserSettings.fromJson(fromFirestoreJson(data));
  }
}
