import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:data_models/external_integrations/external_integration.dart';
import '../utils/infra/firestore_utils.dart';

/// Switches on, for a newly created event, every active external integration
/// of its community that is marked "on for new events". Hosts can turn them
/// off again in the event settings.
class ExternalIntegrationDefaults {
  Future<List<String>> applyToNewEvent({
    required String communityId,
    required String eventPath,
  }) async {
    final integrations = await firestore
        .collection('community/$communityId/${ExternalIntegration.kCollection}')
        .where(ExternalIntegration.kFieldIsActive, isEqualTo: true)
        .get();
    if (integrations.documents.isEmpty) return [];

    final enabledIds = <String>[];
    for (final doc in integrations.documents) {
      if (doc.data.getBool('enabledForNewEvents') != true) continue;

      final settingsRef = firestore.document(
        '$eventPath/${EventExternalIntegrationSettings.kCollection}/${doc.documentID}',
      );
      // Respect a choice the host already made. Read and write in one
      // transaction so a host saving the settings at the same moment is not
      // overwritten.
      final applied = await firestore.runTransaction<bool>((transaction) async {
        final existing = await transaction.get(settingsRef);
        if (existing.exists) return false;
        transaction.set(
          settingsRef,
          DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              EventExternalIntegrationSettings(
                integrationId: doc.documentID,
                enabled: true,
              ).toJson(),
            ),
          ),
        );
        return true;
      });
      if (!applied) continue;
      enabledIds.add(doc.documentID);
    }
    return enabledIds;
  }
}
