import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import '../../cloud_function.dart';
import '../../utils/firestore_utils.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/utils.dart';

/// Follow https://firebase.google.com/docs/firestore/solutions/presence
class UpdatePresenceStatus implements CloudFunction {
  @override
  final String functionName = 'UpdatePresenceStatus';

  FutureOr<void> action(
    Change<DataSnapshot> change,
    EventContext context,
  ) async {
    try {
      final realtimeDatabasePresence =
          change.after.val() as Map<String, dynamic>;
      final afterPresenceUpdateTime = DateTime.fromMillisecondsSinceEpoch(
        realtimeDatabasePresence['last_changed'],
      );

      if (realtimeDatabasePresence['state'] != 'offline') return;

      print('change in presence: $realtimeDatabasePresence');

      // If the current timestamp for this data is newer than
      // the data that triggered this event, we exit this function.
      final currentPresenceSnapshot = await change.after.ref.once('value');
      final currentPresenceValue =
          currentPresenceSnapshot.val() as Map<String, dynamic>;
      final currentPresenceTimestamp = DateTime.fromMillisecondsSinceEpoch(
        currentPresenceValue['last_changed'],
      );
      if (currentPresenceTimestamp.isAfter(afterPresenceUpdateTime)) {
        print('presence already changed so ignoring');
        return null;
      }

      print('updating all participants to disconnected');
      await _updateEventStatusesToOffline(
        userId: context.params['uid']!,
        updateTime: afterPresenceUpdateTime,
      );
    } catch (e, stacktrace) {
      print('Error during action $functionName');
      print(e);
      print(stacktrace);
      rethrow;
    }
  }

  Future<void> _updateEventStatusesToOffline({
    required String userId,
    required DateTime updateTime,
  }) async {
    final documentsToUpdate = await firestore
        .collectionGroup('event-participants')
        .where(Participant.kFieldId, isEqualTo: userId)
        .where(Participant.kFieldIsPresent, isEqualTo: true)
        .get();

    await Future.wait(
      documentsToUpdate.documents.map(
        (doc) => firestore.runTransaction((transaction) async {
          final liveParticipantData = await transaction.get(doc.reference);
          final participant = Participant.fromJson(
            firestoreUtils.fromFirestoreJson(liveParticipantData.data.toMap()),
          );
          final lastUpdatedTime = participant.lastUpdatedTime;

          if (lastUpdatedTime != null && lastUpdatedTime.isAfter(updateTime)) {
            print('status already updated so ignoring');
            return;
          }

          transaction.update(
            doc.reference,
            UpdateData.fromMap(
              jsonSubset(
                [
                  Participant.kFieldIsPresent,
                  Participant.kFieldLastUpdatedTime,
                  Participant.kFieldCurrentBreakoutRoomId,
                ],
                firestoreUtils.toFirestoreJson(
                  participant
                      .copyWith(
                        isPresent: false,
                        currentBreakoutRoomId: '',
                      )
                      .toJson()
                    ..[Participant.kFieldLastUpdatedTime] =
                        Timestamp.fromDateTime(updateTime),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(
          RuntimeOptions(timeoutSeconds: 60, memory: '1GB', minInstances: 0),
        )
        .database
        .ref('/status/{uid}')
        .onUpdate(action);
  }
}
