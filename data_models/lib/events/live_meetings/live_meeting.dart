import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'live_meeting.freezed.dart';
part 'live_meeting.g.dart';

enum BreakoutRoomStatus {
  /// Currently asking users if theyd like to participate
  pending,

  /// Actively assigning users to breakout rooms
  processingAssignments,

  /// Breakout rooms have been assigned and are active
  active,
  inactive,
}

@Freezed(makeCollectionsUnmodifiable: false)
class LiveMeeting with _$LiveMeeting implements SerializeableRequest {
  static const String kFieldCurrentBreakoutSession = 'currentBreakoutSession';
  static const String kFieldPinnedUserIds = 'pinnedUserIds';
  static const String kFieldEvents = 'events';
  static const String kFieldRecord = 'record';
  static const String kFieldMeetingId = 'meetingId';
  static const String kFieldIsMeetingCardMinimized = 'isMeetingCardMinimized';

  factory LiveMeeting({
    // TODO(null-safety): There are places that we set various fields on the live meeting possibly
    // before the meeting is created with a meeting ID. We should make it required but need to be
    // careful since live meeting is updated from many places and if any of them do a non-merge
    // it will overwrite this.
    String? meetingId,
    @Default([]) List<LiveMeetingParticipant> participants,
    @Default([]) List<LiveMeetingEvent> events,

    /// This is a copy of the breakout session object
    ///
    /// We could later on not copy but have the client look up the data from the breakout doc.
    BreakoutRoomSession? currentBreakoutSession,
    @Default(false) bool record,
    @Default(false) bool isMeetingCardMinimized,
    @Default([]) List<String> pinnedUserIds,
  }) = _LiveMeeting;

  factory LiveMeeting.fromJson(Map<String, dynamic> json) =>
      _$LiveMeetingFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class LiveMeetingParticipant with _$LiveMeetingParticipant {
  factory LiveMeetingParticipant({
    String? communityId,
    String? meetingId,
    // Temporary ID to store external community user ID mappings
    // This should no longer be necessary when/if we switch to Twilio in Flutter
    String? externalCommunityId,
  }) = _LiveMeetingParticipant;

  factory LiveMeetingParticipant.fromJson(Map<String, dynamic> json) =>
      _$LiveMeetingParticipantFromJson(json);
}

enum LiveMeetingEventType {
  @Deprecated('Use agendaItemStarted instead')
  startMeeting,
  @Deprecated('Use agendaItemStarted or finishMeeting instead')
  agendaItemCompleted,

  agendaItemStarted,
  finishMeeting,
  @Deprecated('Videos always start automatically now')
  startVideo,
}

@Freezed(makeCollectionsUnmodifiable: false)
class LiveMeetingEvent with _$LiveMeetingEvent {
  factory LiveMeetingEvent({
    @JsonKey(unknownEnumValue: null) LiveMeetingEventType? event,
    DateTime? timestamp,
    String? agendaItem,
    @Default(false) bool? hostless,
  }) = _LiveMeetingEvent;

  factory LiveMeetingEvent.fromJson(Map<String, dynamic> json) =>
      _$LiveMeetingEventFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class LiveMeetingRating
    with _$LiveMeetingRating
    implements SerializeableRequest {
  factory LiveMeetingRating({
    String? ratingId,
    double? rating,
  }) = _LiveMeetingRating;

  factory LiveMeetingRating.fromJson(Map<String, dynamic> json) =>
      _$LiveMeetingRatingFromJson(json);
}

enum BreakoutRoomFlagStatus {
  unflagged,
  needsHelp,
}

const breakoutsWaitingRoomId = 'waiting-room';
const reassignNewRoomId = 'new-room';

@Freezed(makeCollectionsUnmodifiable: false)
class BreakoutRoom with _$BreakoutRoom implements SerializeableRequest {
  static const String kFieldParticipantIds = 'participantIds';
  static const String kFieldFlagStatus = 'flagStatus';
  static const String kFieldRoomName = 'roomName';
  static const String kFieldRoomId = 'roomId';

  factory BreakoutRoom({
    required String roomId,
    required String roomName,

    /// This field is used in pagination to show earlier rooms first.
    /// We don't use alphabetical because waiting room needs to come first.
    required int orderingPriority,
    required String creatorId,
    @Default([]) List<String> participantIds,
    @Default([]) List<String> originalParticipantIdsAssignment,
    @Default(BreakoutRoomFlagStatus.unflagged)
    @JsonKey(
        defaultValue: BreakoutRoomFlagStatus.unflagged,
        unknownEnumValue: BreakoutRoomFlagStatus.unflagged)
    BreakoutRoomFlagStatus flagStatus,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? createdDate,
    @Default(false) bool record,
  }) = _BreakoutRoom;

  factory BreakoutRoom.fromJson(Map<String, dynamic> json) =>
      _$BreakoutRoomFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class BreakoutRoomSession with _$BreakoutRoomSession {
  static const String kFieldBreakoutRoomSessionId = 'breakoutRoomSessionId';
  static const String kFieldBreakoutRoomStatus = 'breakoutRoomStatus';
  static const String kFieldProcessingId = 'processingId';

  factory BreakoutRoomSession({
    required String breakoutRoomSessionId,
    @JsonKey(unknownEnumValue: null) BreakoutRoomStatus? breakoutRoomStatus,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? statusUpdatedTime,
    required BreakoutAssignmentMethod assignmentMethod,
    required int targetParticipantsPerRoom,
    required bool hasWaitingRoom,
    int? maxRoomNumber,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? createdDate,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
    DateTime? scheduledTime,

    /// Generated ID that lets callers know who is currently processing assignments.
    String? processingId,
  }) = _BreakoutRoomSession;

  factory BreakoutRoomSession.fromJson(Map<String, dynamic> json) =>
      _$BreakoutRoomSessionFromJson(json);
}
