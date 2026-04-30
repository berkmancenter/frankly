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

  // Stop all breakout room recordings.
  try {
    final breakoutSessionDocs = await firestore
        .collection('$liveMeetingPath/breakout-room-sessions')
        .get();
    for (final sessionDoc in breakoutSessionDocs.documents) {
      final breakoutRoomDocs = await firestore
          .collection('${sessionDoc.reference.path}/breakout-rooms')
          .get();
      for (final roomDoc in breakoutRoomDocs.documents) {
        final breakoutRoom = BreakoutRoom.fromJson(
          firestoreUtils.fromFirestoreJson(roomDoc.data.toMap()),
        );
        if (breakoutRoom.recordingSessionId != null) {
          try {
            await agoraUtils.stopRoom(
                sessionId: breakoutRoom.recordingSessionId!,);
          } catch (e) {
            print(
                'Error stopping breakout recording ${breakoutRoom.recordingSessionId}: $e',);
          }
        }
      }
    }
  } catch (e) {
    print('Error stopping breakout room recordings on event end: $e');
  }
}
