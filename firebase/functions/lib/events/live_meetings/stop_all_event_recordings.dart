import 'package:data_models/events/live_meetings/live_meeting.dart';
import '../../utils/infra/firestore_utils.dart';
import 'agora_api.dart';

/// Stops all active recordings for an event (main room + breakout rooms).
Future<void> stopAllEventRecordings({
  required String liveMeetingPath,
  required AgoraUtils agoraUtils,
}) async {
  // Stop main room recording if one is active.
  try {
    final liveMeeting = await firestoreUtils.getFirestoreObject(
      path: liveMeetingPath,
      constructor: (map) => LiveMeeting.fromJson(map),
    );
    if (liveMeeting.recordingSessionId != null) {
      await agoraUtils.stopRoom(sessionId: liveMeeting.recordingSessionId!);
    }
  } catch (e) {
    print('Error stopping main room recording on event end: $e');
  }

  // Stop all breakout room recordings in parallel.
  try {
    final breakoutSessionDocs = await firestore
        .collection('$liveMeetingPath/breakout-room-sessions')
        .get();
    final stopFutures = <Future<void>>[];
    for (final sessionDoc in breakoutSessionDocs.documents) {
      final breakoutRoomDocs = await firestore
          .collection('${sessionDoc.reference.path}/breakout-rooms')
          .get();
      for (final roomDoc in breakoutRoomDocs.documents) {
        final breakoutRoom = BreakoutRoom.fromJson(
          firestoreUtils.fromFirestoreJson(roomDoc.data.toMap()),
        );
        if (breakoutRoom.recordingSessionId != null) {
          stopFutures.add(
            agoraUtils
                .stopRoom(sessionId: breakoutRoom.recordingSessionId!)
                .catchError((e) {
              print(
                  'Error stopping breakout recording ${breakoutRoom.recordingSessionId}: $e',);
            }),
          );
        }
      }
    }
    await Future.wait(stopFutures);
  } catch (e) {
    print('Error stopping breakout room recordings on event end: $e');
  }
}
