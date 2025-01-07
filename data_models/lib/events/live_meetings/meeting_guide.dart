import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'meeting_guide.freezed.dart';
part 'meeting_guide.g.dart';

const startMeetingAgendaItemId = 'start';
const startMeetingWaitingPeriod = Duration(minutes: 5);

@Freezed(makeCollectionsUnmodifiable: false)
class ParticipantAgendaItemDetails
    with _$ParticipantAgendaItemDetails
    implements SerializeableRequest {
  static const String kFieldUserId = 'userId';
  static const String kFieldAgendaItemId = 'agendaItemId';
  static const String kFieldMeetingId = 'meetingId';
  static const String kFieldReadyToAdvance = 'readyToAdvance';
  static const String kFieldWordCloudResponses = 'wordCloudResponses';
  static const String kFieldVideoCurrentTime = 'videoCurrentTime';
  static const String kFieldVideoDuration = 'videoDuration';
  static const String kFieldPollResponse = 'pollResponse';
  static const String kFieldSuggestions = 'suggestions';
  static const String kFieldHandRaisedTime = 'handRaisedTime';

  factory ParticipantAgendaItemDetails({
    String? userId,
    String? agendaItemId,
    String? meetingId,
    bool? readyToAdvance,

    /// Indicates if a user has raised their hand during the video call.
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
    DateTime? handRaisedTime,

    /// This users response to a poll for this agenda item.
    String? pollResponse,
    @Default([]) List<String> wordCloudResponses,
    @Default([]) List<MeetingUserSuggestion> suggestions,
    // Participant's position within a video
    double? videoCurrentTime,
    double? videoDuration,
  }) = _ParticipantAgendaItemDetails;

  factory ParticipantAgendaItemDetails.fromJson(Map<String, dynamic> json) =>
      _$ParticipantAgendaItemDetailsFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class MeetingUserSuggestion
    with _$MeetingUserSuggestion
    implements SerializeableRequest {
  static const String kFieldId = 'id';
  static const String kFieldLikedByIds = 'likedByIds';
  static const String kFieldDislikedByIds = 'dislikedByIds';
  static const String kFieldLikeType = 'likeType';
  static const String kFieldSuggestion = 'suggestion';

  MeetingUserSuggestion._();

  factory MeetingUserSuggestion({
    required String id,
    required String suggestion,
    @Default([]) List<String> likedByIds,
    @Default([]) List<String> dislikedByIds,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
    DateTime? createdDate,
  }) = _MeetingUserSuggestion;

  factory MeetingUserSuggestion.fromJson(Map<String, dynamic> json) =>
      _$MeetingUserSuggestionFromJson(json);

  int getLikeDislikeCount() {
    final likeCount = likedByIds.length;
    final dislikeCount = dislikedByIds.length;
    final count = likeCount - dislikeCount;

    return count;
  }

  bool isLiked(String? userId) {
    if (userId == null) {
      return false;
    }

    return likedByIds.any((element) => element == userId);
  }

  bool isDisliked(String? userId) {
    if (userId == null) {
      return false;
    }

    return dislikedByIds.any((element) => element == userId);
  }
}

@Freezed(makeCollectionsUnmodifiable: false)
class ParticipantAgendaItemDetailsMeta
    with _$ParticipantAgendaItemDetailsMeta
    implements SerializeableRequest {
  static const String kFieldDocumentPath = 'documentPath';
  static const String kFieldVoterId = 'voterId';
  static const String kFieldLikeType = 'likeType';
  static const String kFieldUserSuggestionId = 'userSuggestionId';

  factory ParticipantAgendaItemDetailsMeta({
    required String documentPath,
    required String voterId,
    required LikeType likeType,
    required String userSuggestionId,
  }) = _ParticipantAgendaItemDetailsMeta;

  factory ParticipantAgendaItemDetailsMeta.fromJson(
          Map<String, dynamic> json) =>
      _$ParticipantAgendaItemDetailsMetaFromJson(json);
}
