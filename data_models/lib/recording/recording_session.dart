import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'recording_session.freezed.dart';
part 'recording_session.g.dart';

enum RecordingSessionStatus {
  starting,
  recording,
  stopping,
  stopped,
  failed,
}

enum RecordingRoomType {
  main,
  breakout,
}

@Freezed(makeCollectionsUnmodifiable: false)
class RecordingSession with _$RecordingSession {
  static const String kCollection = 'recording-sessions';
  static const String kFieldSessionId = 'sessionId';
  static const String kFieldStatus = 'status';
  static const String kFieldRoomId = 'roomId';
  static const String kFieldEventId = 'eventId';
  static const String kFieldCommunityId = 'communityId';
  static const String kArtifactMp4 = 'complete_mp4';
  static const String kArtifactTranscript = 'transcript_json';

  factory RecordingSession({
    String? sessionId,
    required String communityId,
    required String eventId,
    required String roomId,
    @JsonKey(unknownEnumValue: RecordingRoomType.main)
    required RecordingRoomType roomType,
    @JsonKey(unknownEnumValue: RecordingSessionStatus.failed)
    required RecordingSessionStatus status,
    @Default('system') String startedBy,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? startedAt,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? stoppedAt,
    String? breakoutSessionId,
    String? agoraResourceId,
    String? agoraSid,
    String? agoraRttAgentId,
    String? rttLanguage,
    String? gcsPrefix,
    String? chatPath,
    String? errorMessage,
    @Default({}) Map<String, String> artifactPaths,
    @Default([]) List<String> participantIds,
    @Default({}) Map<String, String> uidToDisplayName,
  }) = _RecordingSession;

  factory RecordingSession.fromJson(Map<String, dynamic> json) =>
      _$RecordingSessionFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class TranscriptSegment with _$TranscriptSegment {
  static const String kSubcollection = 'transcript-segments';

  factory TranscriptSegment({
    String? segmentId,
    required String text,
    required int startMs,
    required int durationMs,
    required String speakerUid,
    required String language,
    double? confidence,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
    DateTime? receivedAt,
  }) = _TranscriptSegment;

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) =>
      _$TranscriptSegmentFromJson(json);
}
