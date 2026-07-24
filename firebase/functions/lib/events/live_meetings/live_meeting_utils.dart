import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'agora_api.dart';
import 'agora_stt_api.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/recording/recording_session.dart';
import 'package:data_models/utils/utils.dart';

class PendingRecording {
  final String roomId;
  final String sessionId;
  final String eventId;
  final String communityId;
  final RecordingRoomType roomType;
  final String chatPath;
  final List<String> participantIds;

  PendingRecording({
    required this.roomId,
    required this.sessionId,
    required this.eventId,
    required this.communityId,
    required this.roomType,
    required this.chatPath,
    required this.participantIds,
  });
}

class MeetingJoinResult {
  final GetMeetingJoinInfoResponse response;
  final PendingRecording? pendingRecording;

  MeetingJoinResult({required this.response, this.pendingRecording});
}

class LiveMeetingUtils {
  bool _shouldRecord(Event event) => event.eventSettings?.alwaysRecord ?? false;
  AgoraUtils agoraUtils;
  AgoraSttApi sttApi;

  LiveMeetingUtils({AgoraUtils? agoraUtils, AgoraSttApi? sttApi})
      : agoraUtils = agoraUtils ?? AgoraUtils(),
        sttApi = sttApi ?? AgoraSttApi();

  Future<MeetingJoinResult> getMeetingJoinInfo({
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
      newSessionId = firestore
          .collection(RecordingSession.kCollection)
          .document()
          .documentID;
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

    PendingRecording? pendingRecording;
    if (newSessionId != null) {
      final chatPath =
          '$liveMeetingCollectionPath/$meetingId/chats/community_chat/messages';
      final participantIds = liveMeeting.participants
          .map((p) => p.communityId)
          .whereType<String>()
          .toList();
      pendingRecording = PendingRecording(
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

    return MeetingJoinResult(
      response: GetMeetingJoinInfoResponse(
        identity: userId,
        meetingToken: token,
        meetingId: meetingId,
      ),
      pendingRecording: pendingRecording,
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
      await _startBreakoutRecording(
        communityId: communityId,
        eventId: eventId,
        breakoutSessionId: breakoutSessionId,
        breakoutRoomPath: breakoutRoomPath,
        meetingId: meetingId,
        participantIds: participantIds,
      );
    } else if (record && existingRecordingSessionId != null) {
      // If the session exists but has reached a terminal state (Agora idled out
      // while the room was empty), clear recordingSessionId and start fresh so
      // re-entry gets its own recording.
      final sessionSnap = await firestore
          .collection(RecordingSession.kCollection)
          .document(existingRecordingSessionId)
          .get();
      if (sessionSnap.exists) {
        final session = RecordingSession.fromJson(
          firestoreUtils.fromFirestoreJson(sessionSnap.data.toMap()),
        );
        final isTerminal = session.status == RecordingSessionStatus.stopped ||
            session.status == RecordingSessionStatus.failed;
        if (isTerminal) {
          await _startBreakoutRecording(
            communityId: communityId,
            eventId: eventId,
            breakoutSessionId: breakoutSessionId,
            breakoutRoomPath: breakoutRoomPath,
            meetingId: meetingId,
            participantIds: participantIds,
          );
        }
      }
    }

    return GetMeetingJoinInfoResponse(
      identity: userId,
      meetingToken: token,
      meetingId: meetingId,
    );
  }

  Future<void> _startBreakoutRecording({
    required String communityId,
    required String eventId,
    required String breakoutSessionId,
    required String breakoutRoomPath,
    required String meetingId,
    required List<String> participantIds,
  }) async {
    final newSessionId = firestore
        .collection(RecordingSession.kCollection)
        .document()
        .documentID;

    await firestore.document(breakoutRoomPath).updateData(
          UpdateData.fromMap(
              {BreakoutRoom.kFieldRecordingSessionId: newSessionId},),
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

    // Fire-and-forget: STT start is an external network call and handles its
    // own errors internally, so no need to block the join path on it.
    unawaited(startTranscription(
      roomId: meetingId,
      sessionId: newSessionId,
    ),);
  }

  Future<void> startTranscription({
    required String roomId,
    required String sessionId,
  }) async {
    const language = 'en-US';
    try {
      final agentId = await sttApi.startTranscription(
        channelName: roomId,
        language: language,
      );
      await firestore
          .collection(RecordingSession.kCollection)
          .document(sessionId)
          .updateData(UpdateData.fromMap({
        'agoraRttAgentId': agentId,
        'rttLanguage': language,
      }),);
    } catch (e) {
      print('Failed to start transcription for room $roomId: $e');
    }
  }

  Future<void> recordUidMapping({
    required String sessionId,
    required int agoraUid,
    required String userId,
  }) async {
    try {
      await firestore
          .collection(RecordingSession.kCollection)
          .document(sessionId)
          .updateData(UpdateData.fromMap({
        'uidToDisplayName.$agoraUid': userId,
      }),);
    } catch (e) {
      print('Failed to record UID mapping for $userId: $e');
    }
  }
}
