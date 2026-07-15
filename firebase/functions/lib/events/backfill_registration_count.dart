import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import '../cloud_function.dart';
import '../utils/infra/firestore_utils.dart';
import 'package:data_models/events/event.dart';

/// One-time callable function that populates registrationCount for all events
/// that don't already have it set. Safe to call multiple times (idempotent).
class BackfillRegistrationCount implements CloudFunction {
  @override
  final String functionName = 'backfillRegistrationCount';

  Future<dynamic> action(dynamic data, CallableContext context) async {
    print('$functionName: starting backfill');

    final eventsSnapshot =
        await firestore.collectionGroup('events').select([]).get();

    var updated = 0;
    var skipped = 0;

    for (final eventDoc in eventsSnapshot.documents) {
      // Only process documents in the events subcollection (not nested deeper).
      final pathSegments = eventDoc.reference.path.split('/');
      if (pathSegments.length != 6 ||
          pathSegments[4] != 'events') {
        continue;
      }

      final eventPath = eventDoc.reference.path;

      // Count active participants.
      final activeDocs = await firestore
          .collection('$eventPath/event-participants')
          .where(
            Participant.kFieldStatus,
            isEqualTo: ParticipantStatus.active.name,
          )
          .select([]).get();

      final count = activeDocs.documents.length;

      await firestore.document(eventPath).updateData(
            UpdateData.fromMap({Event.kFieldRegistrationCount: count}),
          );
      updated++;
    }

    print('$functionName: updated $updated events, skipped $skipped');
    return {'updated': updated, 'skipped': skipped};
  }

  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(
          RuntimeOptions(
            timeoutSeconds: 540,
            memory: '1GB',
            minInstances: 0,
          ),
        )
        .https
        .onCall((data, context) => action(data, context));
  }
}
