import 'package:collection/src/iterable_extensions.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'community.freezed.dart';
part 'community.g.dart';

List<CommunityFeatureFlags> communityFeatureFlagsFromJson(dynamic enumList) {
  final isStringList = enumList is List<dynamic>;
  if (!isStringList) {
    return [];
  }
  final List<String> nonNullEnumList =
      (enumList as List<dynamic>).whereNotNull().whereType<String>().toList();
  final featureFlags =
      EnumToString.fromList(CommunityFeatureFlags.values, nonNullEnumList);
  return featureFlags.whereNotNull().toList();
}

enum CommunityFeatureFlags {
  allowDonations,
  alwaysRecord,
  allowUnofficialTemplates,
  allowPredefineBreakoutsOnHosted,
  chat,
  defaultStageView,
  disableScreenShare,
  disableEmailDigests,
  dontAllowMembersToCreateMeetings,
  enableBreakoutsByCategory,
  enableDiscussionThreads,
  enablePrerequisites,
  enableHostless,
  enablePlatformSelection,
  liveMeetingMobile,
  multiplePeopleOnStage,
  multipleVideoTypes,
  requireApprovalToJoin,
  showSmartMatchingForBreakouts,
  suppressJoinEventEmails,
}

enum OnboardingStep {
  brandSpace,
  createGuide,
  hostEvent,
  inviteSomeone,
  createStripeAccount,
}

@Freezed(makeCollectionsUnmodifiable: false)
class Community with _$Community implements SerializeableRequest {
  Community._();

  static const String kFieldCreatorId = 'creatorId';
  static const String kFieldCreatedDate = 'createdDate';
  static const String kFieldDisplayIds = 'displayIds';
  static const String kFieldName = 'name';
  static const String kFieldContactEmail = 'contactEmail';
  static const String kFieldTagLine = 'tagLine';
  static const String kFieldDescription = 'description';
  static const String kFieldIsPublic = 'isPublic';
  static const String kFieldBannerImageUrl = 'bannerImageUrl';
  static const String kFieldProfileImageUrl = 'profileImageUrl';
  static const String kFieldCommunitySettings = 'communitySettings';
  static const String kFieldEventSettings = 'eventSettings';
  static const String kFieldDonationDialogText = 'donationDialogText';
  static const String kFieldRatingSurveyUrl = 'ratingSurveyUrl';
  static const String kFieldThemeLightColor = 'themeLightColor';
  static const String kFieldThemeDarkColor = 'themeDarkColor';
  static const String kFieldOnboardingSteps = 'onboardingSteps';

  factory Community({
    required String id,

    /// List of IDs that correlate to this Community in the URL bar.
    @Default([]) List<String> displayIds,
    String? name,
    String? contactEmail,
    String? creatorId,
    String? profileImageUrl,
    String? bannerImageUrl,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? createdDate,
    bool? isPublic,
    String? description,
    String? tagLine,
    @Default([])
    @JsonKey(fromJson: communityFeatureFlagsFromJson)
    List<CommunityFeatureFlags> enabledFeatureFlags,
    CommunitySettings? communitySettings,
    EventSettings? eventSettings,
    String? donationDialogText,
    String? ratingSurveyUrl,
    String? themeLightColor,
    String? themeDarkColor,
    @Default([]) List<OnboardingStep> onboardingSteps,
    @Default(false) bool isOnboardingOverviewEnabled,
  }) = _Community;

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);

  static Map<String, dynamic> toJsonForCloudFunction(Community? community) {
    if (community == null) return {};

    return community.toJson()..remove(Community.kFieldCreatedDate);
  }

  String get displayId => displayIds.firstOrNull ?? id;

  CommunitySettings get settingsMigration {
    final localSettings = communitySettings;
    if (localSettings == null) {
      final flags = enabledFeatureFlags;
      return CommunitySettings(
        allowDonations: flags.contains(CommunityFeatureFlags.allowDonations),
        allowUnofficialTemplates:
            flags.contains(CommunityFeatureFlags.allowUnofficialTemplates),
        enableHostless: flags.contains(CommunityFeatureFlags.enableHostless),
        disableEmailDigests:
            flags.contains(CommunityFeatureFlags.disableEmailDigests),
        dontAllowMembersToCreateMeetings: flags
            .contains(CommunityFeatureFlags.dontAllowMembersToCreateMeetings),
        enableDiscussionThreads:
            flags.contains(CommunityFeatureFlags.enableDiscussionThreads),
        enablePlatformSelection:
            flags.contains(CommunityFeatureFlags.enablePlatformSelection),
        multiplePeopleOnStage:
            flags.contains(CommunityFeatureFlags.multiplePeopleOnStage),
        multipleVideoTypes:
            flags.contains(CommunityFeatureFlags.multipleVideoTypes),
        requireApprovalToJoin:
            flags.contains(CommunityFeatureFlags.requireApprovalToJoin),
      );
    } else {
      return localSettings;
    }
  }

  EventSettings get eventSettingsMigration {
    final localSettings = eventSettings;
    if (localSettings == null) {
      final flags = enabledFeatureFlags;
      return EventSettings(
        alwaysRecord: flags.contains(CommunityFeatureFlags.alwaysRecord),
        allowPredefineBreakoutsOnHosted: flags
            .contains(CommunityFeatureFlags.allowPredefineBreakoutsOnHosted),
        chat: flags.contains(CommunityFeatureFlags.chat),
        defaultStageView:
            flags.contains(CommunityFeatureFlags.defaultStageView),
        enableBreakoutsByCategory:
            flags.contains(CommunityFeatureFlags.enableBreakoutsByCategory),
        enablePrerequisites:
            flags.contains(CommunityFeatureFlags.enablePrerequisites),
        showSmartMatchingForBreakouts:
            flags.contains(CommunityFeatureFlags.showSmartMatchingForBreakouts),
        reminderEmails:
            !flags.contains(CommunityFeatureFlags.suppressJoinEventEmails),
        showChatMessagesInRealTime:
            EventSettings.defaultSettings.showChatMessagesInRealTime,
        talkingTimer: EventSettings.defaultSettings.talkingTimer,
        allowMultiplePeopleOnStage:
            EventSettings.defaultSettings.allowMultiplePeopleOnStage,
        agendaPreview: EventSettings.defaultSettings.agendaPreview,
      );
    } else {
      return localSettings;
    }
  }
}

enum FeaturedType {
  template,
  event,
}

@Freezed(makeCollectionsUnmodifiable: false)
class Featured with _$Featured {
  factory Featured({
    String? documentPath,
    @JsonKey(unknownEnumValue: null) FeaturedType? featuredType,
  }) = _Featured;

  factory Featured.fromJson(Map<String, dynamic> json) =>
      _$FeaturedFromJson(json);
}

CommunitySettings communitySettingsFromJson(Map<String, dynamic> json) =>
    CommunitySettings.fromJson(json);

@Freezed(makeCollectionsUnmodifiable: false)
class CommunitySettings with _$CommunitySettings {
  static const kFieldAllowDonations = 'allowDonations';
  static const kFieldAllowUnofficialTemplates = 'allowUnofficialTemplates';
  static const kFieldDisableEmailDigests = 'disableEmailDigests';
  static const kFieldDontAllowMembersToCreateMeetings =
      'dontAllowMembersToCreateMeetings';
  static const kFieldEnableDiscussionThreads = 'enableDiscussionThreads';
  static const kFieldEnableHostless = 'enableHostless';
  static const kFieldFeaturedOrder = 'featuredOrder';
  static const kFieldEnablePlatformSelection = 'enablePlatformSelection';
  static const kFieldMultiplePeopleOnStage = 'multiplePeopleOnStage';
  static const kFieldRequireApprovalToJoin = 'requireApprovalToJoin';

  const factory CommunitySettings({
    @Default(true) bool allowDonations,
    @Default(false) bool allowUnofficialTemplates,
    @Default(false) bool disableEmailDigests,
    @Default(true) bool dontAllowMembersToCreateMeetings,
    @Default(true) bool enableDiscussionThreads,
    @Default(true) bool enableHostless,
    int? featuredOrder,
    @Default(false) bool multiplePeopleOnStage,
    @Default(false) bool multipleVideoTypes,
    @Default(false) bool requireApprovalToJoin,
    @Default(true) bool enablePlatformSelection,
    @Default(false) bool enableUpdatedLiveMeetingMobile,
    @Default(true) bool enableAVCheck,
  }) = _CommunitySettings;

  factory CommunitySettings.fromJson(Map<String, dynamic> json) =>
      _$CommunitySettingsFromJson(json);
}
