import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto_user_settings.dart';
import 'package:junto_models/utils.dart';

import 'firestore_utils.dart';

class FirestorePrivateUserDataService {
  static const String privateUserData = 'privateUserData';
  static const String juntoUserSettings = 'juntoUserSettings';

  DocumentReference<Map<String, dynamic>> _juntoUserSettingsReference({
    required String userId,
    required String juntoId,
  }) =>
      firestoreDatabase.firestore.doc('$privateUserData/$userId/$juntoUserSettings/$juntoId');

  Stream<JuntoUserSettings> getJuntoUserSettings({
    required String userId,
    required String juntoId,
  }) {
    final docRef = _juntoUserSettingsReference(userId: userId, juntoId: juntoId);
    return docRef.snapshots().asyncMap((snapshot) async {
      if (snapshot.exists) {
        return _convertJuntoUserSettingsWithDefaultsAsync(snapshot);
      } else {
        return userService.getDefaultJuntoUserSettings(juntoId: juntoId);
      }
    });
  }

  Future<JuntoUserSettings> getOrCreateJuntoUserSettings({
    required JuntoUserSettings defaultJuntoUserSettings,
  }) async {
    final docRef = _juntoUserSettingsReference(
      userId: defaultJuntoUserSettings.userId!,
      juntoId: defaultJuntoUserSettings.juntoId!,
    );

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return _convertJuntoUserSettingsWithDefaultsAsync(snapshot);
    } else {
      await docRef.set(toFirestoreJson(defaultJuntoUserSettings.toJson()));
      return defaultJuntoUserSettings;
    }
  }

  Future<void> updateJuntoUserSettings({
    required JuntoUserSettings juntoUserSettings,
    Iterable<String>? keys,
  }) async {
    final docRef = _juntoUserSettingsReference(
      userId: juntoUserSettings.userId!,
      juntoId: juntoUserSettings.juntoId!,
    );
    await docRef.set(
      jsonSubset(keys ?? {}, toFirestoreJson(juntoUserSettings.toJson())),
      SetOptions(merge: true),
    );
  }

  static Future<JuntoUserSettings> _convertJuntoUserSettingsWithDefaultsAsync(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    var privateUserSettings = await _convertJuntoUserSettingsAsync(doc);
    if (privateUserSettings.notifyAnnouncements == null) {
      privateUserSettings =
          privateUserSettings.copyWith(notifyAnnouncements: NotificationEmailType.immediate);
    }
    if (privateUserSettings.notifyEvents == null) {
      privateUserSettings =
          privateUserSettings.copyWith(notifyEvents: NotificationEmailType.immediate);
    }
    return privateUserSettings;
  }

  static Future<JuntoUserSettings> _convertJuntoUserSettingsAsync(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final privateUserSettings = await compute<Map<String, dynamic>, JuntoUserSettings>(
      _convertJuntoUserSettings,
      doc.data()!,
    );
    return privateUserSettings;
  }

  static JuntoUserSettings _convertJuntoUserSettings(Map<String, dynamic> data) {
    return JuntoUserSettings.fromJson(fromFirestoreJson(data));
  }
}
