import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/media_item.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/firestore/pre_post_card.dart';
import 'package:junto_models/firestore/utils.dart';
import 'package:uuid/uuid.dart';

part 'discussion.freezed.dart';
part 'discussion.g.dart';

enum DiscussionStatus {
  active,
  canceled,
}

enum DiscussionEmailType {
  initialSignUp,
  oneDayReminder,
  oneHourReminder,
  updated,
  canceled,
  ended
}

enum DiscussionType {
  hosted,
  hostless,
  livestream,
}

// TODO: Make required fields required here (and throughout app)
@Freezed(makeCollectionsUnmodifiable: false)
class Discussion with _$Discussion implements SerializeableRequest {
  static const String kFieldAgendaItems = 'agendaItems';
  static const String kFieldPreEventCardData = 'preEventCardData';
  static const String kFieldPostEventCardData = 'postEventCardData';
  static const String kFieldWaitingRoomInfo = 'waitingRoomInfo';
  static const String fieldPrerequisiteTopic = 'prerequisiteTopicId';
  static const String kFieldExternalPlatform = 'externalPlatform';
  static const String kFieldDiscussionType = 'discussionType';
  static const String kFieldPresentParticipantCountEstimate = 'presentParticipantCountEstimate';
  static const String kFieldParticipantCountEstimate = 'participantCountEstimate';
  static const String kFieldScheduledTime = 'scheduledTime';
  static const String kFieldIsPublic = 'isPublic';
  static const String kFieldTitle = 'title';
  static const String kFieldDescription = 'description';
  static const String kFieldMinParticipants = 'minParticipants';
  static const String kFieldMaxParticipants = 'maxParticipants';
  static const String kFieldLiveStreamInfo = 'liveStreamInfo';
  static const String kFieldBreakoutRoomDefinition = 'breakoutRoomDefinition';
  static const String kFieldStatus = 'status';
  static const String kFieldIsLocked = 'isLocked';
  static const String kFieldImage = 'image';
  static const String kDurationInMinutes = 'durationInMinutes';
  static const String kFieldDiscussionSettings = 'discussionSettings';
  static const String kFieldJuntoId = 'juntoId';

  static const int defaultMinParticipants = 0;
  static const int defaultMaxParticipants = 8;
  static const int defaultMaxParticipantsInHostlessEvent = 10000;

  Discussion._();

  factory Discussion({
    required String id,
    @JsonKey(unknownEnumValue: DiscussionStatus.active, defaultValue: DiscussionStatus.active) required DiscussionStatus status,

    /// Describes the type of discussion this is such as hosted or livestream.
    ///
    /// Some legacy conversations do not have this field so it is nullable. Use the [discussionType]
    /// getter below to determine which discussion type it is.
    @JsonKey(unknownEnumValue: null, name: 'discussionType') DiscussionType? nullableDiscussionType,
    required String collectionPath,
    required String juntoId,
    required String topicId,
    required String creatorId,
    String? prerequisiteTopicId,
    String? creatorDisplayName,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp) DateTime? createdDate,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
        DateTime? scheduledTime,
    String? scheduledTimeZone,
    String? title,
    String? description,
    String? image,
    @Default(false) bool isPublic,
    int? minParticipants,
    int? maxParticipants,
    @Default([]) List<AgendaItem> agendaItems,
    WaitingRoomInfo? waitingRoomInfo,
    @JsonKey(fromJson: BreakoutRoomDefinition.fromJsonMigration)
        BreakoutRoomDefinition? breakoutRoomDefinition,
    @Default(false) bool isLocked,
    LiveStreamInfo? liveStreamInfo,
    PrePostCard? preEventCardData,
    PrePostCard? postEventCardData,
    PlatformItem? externalPlatform,
    DiscussionSettings? discussionSettings,
    @Default(60) int durationInMinutes,

    /// ID used to tie meetings back to external communities
    String? externalCommunityId,

    /// Status that is only means something on a per-community basis.
    /// Ex: For Unify America determines if the meeting is cancelled due to
    /// no-show or not.
    /// Leaving as a string, not enum, to allow more flexibility for each
    /// community.
    String? externalCommunityStatus,

    /// For large events we compute the number of participants every x number
    /// of seconds and update this field due to large numbers of people
    int? participantCountEstimate,
    int? presentParticipantCountEstimate,

    /// Temporary hacky solution to allow us to specify that some breakout rooms that were matched
    /// using match IDs should be recorded.
    @Default([]) breakoutMatchIdsToRecord,
  }) = _Discussion;

  factory Discussion.fromJson(Map<String, dynamic> json) => _$DiscussionFromJson(json);

  /// Describes the type of this discussion such as Hosted or Livestream.
  ///
  /// Some legacy data has null discussion type because they existed before this field was
  /// introduced. This function falls back to the previous logic on determining the discussion type.
  DiscussionType get discussionType {
    final localNullableDiscussionType = nullableDiscussionType;
    if (localNullableDiscussionType != null) return localNullableDiscussionType;

    // In the event that discussion type is null, the discussion type is determined by the
    // presence of the liveStreamInfo field. If it is non-null then this event is a livestream.
    if (liveStreamInfo != null) return DiscussionType.livestream;

    // If the discussion type is null, and there is no liveStreamInfo, then this discussion is a
    // hosted discussion.
    return DiscussionType.hosted;
  }

  bool get useParticipantCountEstimate {
    return discussionType != DiscussionType.hosted;
  }

  /// Override to remove any milliseconds value from the scheduled time.
  ///
  /// This can lead to mismatches between our server event handling with milliseconds causing extra
  /// problems.
  @override
  DateTime? get scheduledTime {
    final localScheduledTime = super.scheduledTime;
    if (localScheduledTime == null) return null;

    return localScheduledTime.subtract(Duration(milliseconds: localScheduledTime.millisecond));
  }

  bool get isLiveStream => discussionType == DiscussionType.livestream;

  bool get isHosted => discussionType == DiscussionType.hosted;

  bool get hasPreEventData => preEventCardData?.hasData ?? false;

  bool get hasPostEventData => postEventCardData?.hasData ?? false;

  String get fullPath => '$collectionPath/$id';

  Duration timeUntilScheduledStart(DateTime now) {
    final bufferedScheduledTime =
        scheduledTime?.add(Duration(seconds: waitingRoomInfo?.waitingMediaBufferSeconds ?? 0));
    return bufferedScheduledTime?.difference(now) ?? Duration.zero;
  }

  Duration timeUntilWaitingRoomFinished(DateTime now) {
    var startTime = timeUntilScheduledStart(now);
    final durationSeconds = waitingRoomInfo?.durationSeconds;
    if (durationSeconds != null) {
      final durationAfterStart = Duration(seconds: durationSeconds);
      startTime = startTime + durationAfterStart;
    }
    return startTime;
  }
}

@Freezed(makeCollectionsUnmodifiable: false)
class DiscussionSettings with _$DiscussionSettings {
  static const kFieldTalkingTimer = 'talkingTimer';
  static const kFieldAlwaysRecord = 'alwaysRecord';
  static const kFieldAllowPredefineBreakoutsOnHosted = 'allowPredefineBreakoutsOnHosted';
  static const kFieldDefaultStageView = 'defaultStageView';
  static const kFieldAllowScreenShare = 'allowScreenshare';
  static const kFieldShowSmartMatchingForBreakouts = 'showSmartMatchingForBreakouts';
  static const kFieldEnableBreakoutsByCategory = 'enableBreakoutsByCategory';
  static const kFieldReminderEmails = 'reminderEmails';
  static const kFieldChat = 'chat';
  static const kFieldShowChatMessagesInRealTime = 'showChatMessagesInRealTime';
  static const kFieldAgendaPreview = 'agendaPreview';

  static const DiscussionSettings defaultSettings = DiscussionSettings(
    reminderEmails: true,
    chat: true,
    showChatMessagesInRealTime: true,
    talkingTimer: true,
    allowScreenshare: true,
    allowPredefineBreakoutsOnHosted: false,
    defaultStageView: false,
    enableBreakoutsByCategory: false,
    allowMultiplePeopleOnStage: false,
    showSmartMatchingForBreakouts: false,
    alwaysRecord: false,
    enablePrerequisites: false,
    agendaPreview: true,
  );

  const factory DiscussionSettings({
    bool? reminderEmails,
    bool? chat,
    bool? showChatMessagesInRealTime,
    bool? talkingTimer,
    bool? allowScreenshare,
    bool? allowPredefineBreakoutsOnHosted,
    bool? defaultStageView,
    bool? enableBreakoutsByCategory,
    bool? allowMultiplePeopleOnStage,
    bool? showSmartMatchingForBreakouts,
    bool? alwaysRecord,
    bool? enablePrerequisites,
    bool? agendaPreview,
  }) = _DiscussionSettings;

  factory DiscussionSettings.fromJson(Map<String, dynamic> json) =>
      _$DiscussionSettingsFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class LiveStreamInfo with _$LiveStreamInfo {
  static const String kFieldMuxId = 'muxId';

  factory LiveStreamInfo({
    String? muxId,
    String? muxPlaybackId,
    String? muxStatus,
    String? latestAssetPlaybackId,
    String? liveStreamWaitingTextOverride,
    bool? resetStream,
  }) = _LiveStreamInfo;

  factory LiveStreamInfo.fromJson(Map<String, dynamic> json) => _$LiveStreamInfoFromJson(json);
}

enum ParticipantStatus {
  active,
  canceled,
  banned,
}

@Freezed(makeCollectionsUnmodifiable: false)
class Participant with _$Participant implements SerializeableRequest {
  static const String kFieldId = 'id';
  static const String kFieldIsPresent = 'isPresent';
  static const String kFieldMembershipStatus = 'membershipStatus';
  static const String kFieldCurrentBreakoutRoomId = 'currentBreakoutRoomId';
  static const String kFieldLastUpdatedTime = 'lastUpdatedTime';
  static const String kFieldMostRecentPresentTime = 'mostRecentPresentTime';
  static const String kFieldBreakoutRoomSurveyQuestions = 'breakoutRoomSurveyQuestions';
  static const String kFieldOptInAmericaTalks = 'optInToAmericaTalks';
  static const String kFieldZipCode = 'zipCode';
  static const String kAvailableForBreakoutSessionId = 'availableForBreakoutSessionId';
  static const String kFieldMuteOverride = 'muteOverride';
  static const String kFieldStatus = 'status';
  static const String kFieldCreatedDate = 'createdDate';

  factory Participant({
    required String id,
    String? juntoId,
    String? externalCommunityId,
    String? topicId,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp) DateTime? lastUpdatedTime,
    @JsonKey(fromJson: dateTimeFromTimestamp) DateTime? createdDate,
    // TODO(Danny): See if there is a way to do this without duplicating this information on the participant
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp) DateTime? scheduledTime,
    @JsonKey(unknownEnumValue: null) ParticipantStatus? status,
    @Default(false) bool isPresent,
    String? availableForBreakoutSessionId,

    /// This cannot be trusted for any auth operations. Should be enforced through
    /// firestore security rules.
    @JsonKey(unknownEnumValue: null) MembershipStatus? membershipStatus,
    String? currentBreakoutRoomId,

    /// Host can set to true to mute this user during a meeting
    @Default(false) bool muteOverride,
    Map<String, String>? joinParameters,
    @Default([]) List<BreakoutQuestion> breakoutRoomSurveyQuestions,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
        DateTime? mostRecentPresentTime,
    String? zipCode,
    @Default(false) bool? optInToAmericaTalks,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class PrivateLiveStreamInfo with _$PrivateLiveStreamInfo {
  factory PrivateLiveStreamInfo({
    String? streamServerUrl,
    String? streamKey,
  }) = _PrivateLiveStreamInfo;

  factory PrivateLiveStreamInfo.fromJson(Map<String, dynamic> json) =>
      _$PrivateLiveStreamInfoFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class DiscussionEmailLog with _$DiscussionEmailLog {
  factory DiscussionEmailLog({
    String? userId,
    @JsonKey(unknownEnumValue: null) DiscussionEmailType? discussionEmailType,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime) DateTime? createdDate,

    /// ID used to identify a group of emails that were sent. This is used to
    /// ensure that the same email is not sent multiple times to a group.
    String? sendId,
  }) = _DiscussionEmailLog;

  factory DiscussionEmailLog.fromJson(Map<String, dynamic> json) =>
      _$DiscussionEmailLogFromJson(json);
}

enum AgendaItemType {
  text,
  video,
  image,
  poll,
  wordCloud,
  userSuggestions,
}

extension AgendaItemTypeExtension on AgendaItemType {
  String get text {
    switch (this) {
      case AgendaItemType.text:
        return 'Text';
      case AgendaItemType.video:
        return 'Video';
      case AgendaItemType.image:
        return 'Image';
      case AgendaItemType.poll:
        return 'Poll';
      case AgendaItemType.wordCloud:
        return 'Word Cloud';
      case AgendaItemType.userSuggestions:
        return 'Suggestions';
    }
  }
}

enum AgendaItemVideoType {
  youtube,
  vimeo,
  url,
}

@Freezed(makeCollectionsUnmodifiable: false)
class AgendaItem with _$AgendaItem {
  static const kDefaultTimeInSeconds = 5 * 60;
  static const userSuggestionsId = 'user-submitted';

  AgendaItem._();

  factory AgendaItem({
    required String id,
    int? priority,
    String? creatorId,
    String? title,
    String? content,
    @Default(AgendaItemVideoType.url) AgendaItemVideoType videoType,
    // TODO: Remove this system of giving a default to nullable items
    @JsonKey(unknownEnumValue: null, name: 'type') AgendaItemType? nullableType,
    String? videoUrl,
    String? imageUrl,
    List<String>? pollAnswers,
    @Default(AgendaItem.kDefaultTimeInSeconds) int? timeInSeconds,
    String? suggestionsButtonText,
  }) = _AgendaItem;

  factory AgendaItem.fromJson(Map<String, dynamic> json) => _$AgendaItemFromJson(json);

  AgendaItemType get type {
    if (id == userSuggestionsId) return AgendaItemType.userSuggestions;
    final localNullableType = nullableType;
    if (localNullableType == null) return AgendaItemType.text;

    return localNullableType;
  }
}

@Freezed(makeCollectionsUnmodifiable: false)
class SuggestedAgendaItem with _$SuggestedAgendaItem {
  static const String kFieldUpvotedUserIds = 'upvotedUserIds';
  static const String kFieldDownvotedUserIds = 'downvotedUserIds';
  static const String kFieldCreatedDate = 'createdDate';

  factory SuggestedAgendaItem({
    String? id,
    String? creatorId,
    String? content,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp) DateTime? createdDate,
    @Default([]) List<String> upvotedUserIds,
    @Default([]) List<String> downvotedUserIds,
  }) = _SuggestedAgendaItem;

  factory SuggestedAgendaItem.fromJson(Map<String, dynamic> json) =>
      _$SuggestedAgendaItemFromJson(json);
}

enum BreakoutAssignmentMethod {
  /// Distributed throughout target participants size based on membership status
  targetPerRoom,

  /// Algorithm for matching by answers to survey questions
  smartMatch,

  /// Assign Participants based on category
  category
}

/// Defines the breakout room size and matching strategy to be used during this meeting.
@Freezed(makeCollectionsUnmodifiable: false)
class BreakoutRoomDefinition with _$BreakoutRoomDefinition {
  factory BreakoutRoomDefinition({
    String? creatorId,
    int? targetParticipants,
    @Deprecated('use breakoutQuestions instead') @Default([]) List<SurveyQuestion> questions,
    @Default([]) List<BreakoutQuestion> breakoutQuestions,
    @Default([]) List<BreakoutCategory> categories,
    @Default(BreakoutAssignmentMethod.targetPerRoom)
    @JsonKey(defaultValue: BreakoutAssignmentMethod.targetPerRoom, unknownEnumValue: BreakoutAssignmentMethod.targetPerRoom)
        BreakoutAssignmentMethod assignmentMethod,
  }) = _BreakoutRoomDefinition;

  @Deprecated('Use fromJsonMigration instead')
  factory BreakoutRoomDefinition.fromJson(Map<String, dynamic> json) =>
      _$BreakoutRoomDefinitionFromJson(json);

  /// Parses [BreakoutRoomDefinition].
  ///
  /// Since we have deprecated [SurveyQuestion], it is being replaced with [BreakoutQuestion], thus
  /// handle conversion in real-time.
  static BreakoutRoomDefinition? fromJsonMigration(Map<String, dynamic>? json) {
    if (json == null) return null;

    final breakoutRoomDefinition = BreakoutRoomDefinition.fromJson(json);
    const uuid = Uuid();
    final deprecatedQuestions = breakoutRoomDefinition.questions;
    if (breakoutRoomDefinition.breakoutQuestions.isEmpty && deprecatedQuestions.isNotEmpty) {
      for (var question in deprecatedQuestions) {
        final questionId = question.id ?? uuid.v4();

        // If questionId exists, question was already added before - skip
        if (breakoutRoomDefinition.breakoutQuestions.any((element) => element.id == questionId)) {
          continue;
        }

        final newAnswerOptions = [
          for (final answerOption in question.answerOptions ?? [])
            BreakoutAnswer(
              id: uuid.v4(),
              options: [BreakoutAnswerOption(id: uuid.v4(), title: answerOption)],
            )
        ];

        final String answerOptionId;
        final answerIndex = question.answerIndex ?? 0;
        if (answerIndex >= newAnswerOptions.length) {
          continue;
        }

        // We are guaranteed only 1 answer option due to how it was constructed above.
        answerOptionId = newAnswerOptions[answerIndex].options.first.id;

        breakoutRoomDefinition.breakoutQuestions.add(
          BreakoutQuestion(
            id: questionId,
            title: question.question ?? '',
            answerOptionId: answerOptionId,
            answers: newAnswerOptions,
          ),
        );
      }
    }

    return breakoutRoomDefinition;
  }
}

@Deprecated('use [BreakoutQuestion] instead.')
@Freezed(makeCollectionsUnmodifiable: false)
class SurveyQuestion with _$SurveyQuestion {
  factory SurveyQuestion({
    /// The answer options as they were saved.
    List<String>? answerOptions,

    /// Indicates which of the answer options was selected.
    int? answerIndex,
    String? id,
    String? question,
  }) = _SurveyQuestion;

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) => _$SurveyQuestionFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class BreakoutQuestion with _$BreakoutQuestion {
  factory BreakoutQuestion({
    required String id,
    required String title,

    /// ID of selected answer from Finish RSVP page
    required String answerOptionId,
    required List<BreakoutAnswer> answers,
  }) = _BreakoutQuestion;

  factory BreakoutQuestion.fromJson(Map<String, dynamic> json) => _$BreakoutQuestionFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class BreakoutAnswer with _$BreakoutAnswer {
  factory BreakoutAnswer({
    required String id,
    required List<BreakoutAnswerOption> options,
  }) = _BreakoutAnswer;

  factory BreakoutAnswer.fromJson(Map<String, dynamic> json) => _$BreakoutAnswerFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class BreakoutAnswerOption with _$BreakoutAnswerOption {
  factory BreakoutAnswerOption({
    required String id,
    required String title,
  }) = _BreakoutAnswerOption;

  factory BreakoutAnswerOption.fromJson(Map<String, dynamic> json) =>
      _$BreakoutAnswerOptionFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class BreakoutCategory with _$BreakoutCategory {
  factory BreakoutCategory({
    required String id,
    required String category,
  }) = _BreakoutCategory;

  factory BreakoutCategory.fromJson(Map<String, dynamic> json) => _$BreakoutCategoryFromJson(json);
}

enum PlatformKey { junto, googleMeet, maps, microsoftTeam, zoom }

@Freezed(makeCollectionsUnmodifiable: false)
class PlatformItem with _$PlatformItem {
  factory PlatformItem({
    String? url,
    @Default(PlatformKey.junto)
    @JsonKey(defaultValue: PlatformKey.junto, unknownEnumValue: null)
        PlatformKey platformKey,
  }) = _PlatformItem;

  factory PlatformItem.fromJson(Map<String, dynamic> json) => _$PlatformItemFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class WaitingRoomInfo with _$WaitingRoomInfo {
  const WaitingRoomInfo._();

  const factory WaitingRoomInfo({
    @Default(0) int durationSeconds,
    @Default(0) int waitingMediaBufferSeconds,
    String? content,
    MediaItem? waitingMediaItem,
    MediaItem? introMediaItem,
    @Default(false) bool enableChat,
    @Default(false) bool loopWaitingVideo,
  }) = _WaitingRoomInfo;

  factory WaitingRoomInfo.fromJson(Map<String, dynamic> json) => _$WaitingRoomInfoFromJson(json);
}
