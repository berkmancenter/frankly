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

class LiveMeetingUtils {
  bool _shouldRecord(Event event) => event.eventSettings?.alwaysRecord ?? false;
  AgoraUtils agoraUtils;
  AgoraSttApi sttApi;

  LiveMeetingUtils({AgoraUtils? agoraUtils, AgoraSttApi? sttApi})
      : agoraUtils = agoraUtils ?? AgoraUtils(),
        sttApi = sttApi ?? AgoraSttApi();

  Future<GetMeetingJoinInfoResponse> getMeetingJoinInfo({
    required Transaction transaction,
    required String communityId,
    required String liveMeetingCollectionPath,
    required String meetingId,
    required String userId,
    required Event event,
  }) async {
    final fieldsToUpdate = <String>[];

    // Look up live meeting
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

    final shouldRecord = _shouldRecord(event) || (liveMeeting.record);
    if (shouldRecord) {
      await agoraUtils.recordRoom(roomId: meetingId);
      await _startTranscription(
        roomId: meetingId,
        eventId: event.id,
        communityId: communityId,
        roomType: RecordingRoomType.main,
      );      await _recordUidMapping(
        eventId: event.id!,
        roomId: meetingId,
        agoraUid: uidToInt(userId),
        userId: userId,
      );    }

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
    required String meetingId,
    required String userId,
    required bool record,
  }) async {
    final token =
        agoraUtils.createToken(uid: uidToInt(userId), roomId: meetingId);
    if (record) {
      await agoraUtils.recordRoom(roomId: meetingId);
      await _startTranscription(
        roomId: meetingId,
        eventId: eventId,
        communityId: communityId,
        roomType: RecordingRoomType.breakout,
      );
      await _recordUidMapping(
        eventId: eventId,
        roomId: meetingId,
        agoraUid: uidToInt(userId),
        userId: userId,
      );
    }

    final meetingInfo = GetMeetingJoinInfoResponse(
      identity: userId,
      meetingToken: token,
      meetingId: meetingId,
    );

    return meetingInfo;
  }

  Future<void> _startTranscription({
    required String roomId,
    required String eventId,
    required String communityId,
    required RecordingRoomType roomType,
  }) async {
    // Check if an active transcription session already exists for this room.
    final existing = await firestore
        .collection(RecordingSession.kCollection)
        .where(RecordingSession.kFieldRoomId, isEqualTo: roomId)
        .where(RecordingSession.kFieldEventId, isEqualTo: eventId)
        .where(RecordingSession.kFieldStatus, isEqualTo: 'recording')
        .get();

    if (existing.isNotEmpty) {
      print('Transcription already active for room $roomId, skipping');
      return;
    }

    const language = 'en-US';
    try {
      final agentId = await sttApi.startTranscription(
        channelName: roomId,
        language: language,
      );

      final sessionRef =
          firestore.collection(RecordingSession.kCollection).document();
      final session = RecordingSession(
        sessionId: sessionRef.documentID,
        communityId: communityId,
        eventId: eventId,
        roomId: roomId,
        roomType: roomType,
        status: RecordingSessionStatus.recording,
        agoraRttAgentId: agentId,
        rttLanguage: language,
        gcsPrefix: '$roomId/transcripts',
      );

      await sessionRef.setData(
        DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(session.toJson()),
        ),
      );
    } catch (e) {
      print('Failed to start transcription for room $roomId: $e');
    }
  }

  /// Records the Agora UID to Firebase user ID mapping on the active session
  /// for this room, so transcripts can resolve speaker names at export time.
  Future<void> _recordUidMapping({
    required String eventId,
    required String roomId,
    required int agoraUid,
    required String userId,
  }) async {
    try {
      final sessions = await firestore
          .collection(RecordingSession.kCollection)
          .where(RecordingSession.kFieldRoomId, isEqualTo: roomId)
          .where(RecordingSession.kFieldEventId, isEqualTo: eventId)
          .where(RecordingSession.kFieldStatus, isEqualTo: 'recording')
          .get();

      if (sessions.isEmpty) return;

      final sessionRef = sessions.first.reference;
      await sessionRef.updateData(
        UpdateData.fromMap({
          'uidToDisplayName.$agoraUid': userId,
        }),
      );
    } catch (e) {
      print('Failed to record UID mapping for $userId in room $roomId: $e');
    }
  }
}
