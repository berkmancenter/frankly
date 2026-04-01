import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:uuid/uuid.dart';
import 'agora_api.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/recording/recording_session.dart';
import 'package:data_models/utils/utils.dart';

const _uuid = Uuid();

class LiveMeetingUtils {
  bool _shouldRecord(Event event) => event.eventSettings?.alwaysRecord ?? false;
  AgoraUtils agoraUtils;

  LiveMeetingUtils({AgoraUtils? agoraUtils})
      : agoraUtils = agoraUtils ?? AgoraUtils();

  Future<GetMeetingJoinInfoResponse> getMeetingJoinInfo({
    required Transaction transaction,
    required String communityId,
    required String liveMeetingCollectionPath,
    required String meetingId,
    required String userId,
    required Event event,
  }) async {
    final fieldsToUpdate = <String>[];

    final liveMeetingSnapshot = await transaction.get(
      firestore.document('$liveMeetingCollectionPath/$meetingId'),
    );
    var liveMeeting = LiveMeeting.fromJson(
      firestoreUtils.fromFirestoreJson(liveMeetingSnapshot.data.toMap()),
    );
    if (isNullOrEmpty(liveMeeting.meetingId)) {
      fieldsToUpdate.add(LiveMeeting.kFieldMeetingId);
    }
    liveMeeting = liveMeeting.copyWith(
      meetingId: liveMeeting.meetingId ?? meetingId,
    );

    final shouldRecord = _shouldRecord(event) || liveMeeting.record;
    String? newSessionId;
    if (shouldRecord && liveMeeting.recordingSessionId == null) {
      newSessionId = _uuid.v4();
      fieldsToUpdate.add(LiveMeeting.kFieldRecordingSessionId);
      liveMeeting = liveMeeting.copyWith(recordingSessionId: newSessionId);
    }

    if (liveMeetingSnapshot.exists && fieldsToUpdate.isNotEmpty) {
      transaction.update(
        liveMeetingSnapshot.reference,
        UpdateData.fromMap(
          jsonSubset(
            fieldsToUpdate,
            firestoreUtils.toFirestoreJson(liveMeeting.toJson()),
          ),
        ),
      );
    } else if (!liveMeetingSnapshot.exists) {
      transaction.set(
        liveMeetingSnapshot.reference,
        DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(liveMeeting.toJson()),
        ),
      );
    }

    if (newSessionId != null) {
      final chatPath =
          '$liveMeetingCollectionPath/$meetingId/chats/community_chat/messages';
      final participantIds = liveMeeting.participants
          .map((p) => p.communityId)
          .whereType<String>()
          .toList();
      await agoraUtils.recordRoom(
        roomId: meetingId,
        sessionId: newSessionId,
        eventId: event.id,
        communityId: communityId,
        roomType: RecordingRoomType.main,
        chatPath: chatPath,
        participantIds: participantIds,
      );
    }

    final token =
        agoraUtils.createToken(uid: uidToInt(userId), roomId: meetingId);

    return GetMeetingJoinInfoResponse(
      identity: userId,
      meetingToken: token,
      meetingId: meetingId,
    );
  }

  Future<GetMeetingJoinInfoResponse> getBreakoutRoomJoinInfo({
    required String communityId,
    required String eventId,
    required String breakoutSessionId,
    required String breakoutRoomPath,
    required String meetingId,
    required String userId,
    required bool record,
    required String? existingRecordingSessionId,
    required List<String> participantIds,
  }) async {
    final token =
        agoraUtils.createToken(uid: uidToInt(userId), roomId: meetingId);

    if (record && existingRecordingSessionId == null) {
      final newSessionId = _uuid.v4();

      // Write recordingSessionId to the BreakoutRoom document before starting Agora.
      await firestore.document(breakoutRoomPath).updateData(
            UpdateData.fromMap(
                {BreakoutRoom.kFieldRecordingSessionId: newSessionId}),
          );

      final chatPath = '$breakoutRoomPath/chats/community_chat/messages';
      await agoraUtils.recordRoom(
        roomId: meetingId,
        sessionId: newSessionId,
        eventId: eventId,
        communityId: communityId,
        roomType: RecordingRoomType.breakout,
        breakoutSessionId: breakoutSessionId,
        chatPath: chatPath,
        participantIds: participantIds,
      );
    }

    return GetMeetingJoinInfoResponse(
      identity: userId,
      meetingToken: token,
      meetingId: meetingId,
    );
  }
}
