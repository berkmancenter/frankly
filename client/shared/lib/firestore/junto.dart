import 'package:collection/src/iterable_extensions.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/utils.dart';

part 'junto.freezed.dart';
part 'junto.g.dart';

List<JuntoFeatureFlags> juntoFeatureFlagsFromJson(dynamic enumList) {
  final isStringList = enumList is List<dynamic>;
  if (!isStringList) {
    return [];
  }
  final List<String> nonNullEnumList =
      (enumList as List<dynamic>).whereNotNull().whereType<String>().toList();
  final featureFlags = EnumToString.fromList(JuntoFeatureFlags.values, nonNullEnumList);
  return featureFlags.whereNotNull().toList();
}

enum JuntoFeatureFlags {
  allowDonations,
  alwaysRecord,
  allowUnofficialTopics,
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
  suppressJoinDiscussionEmails,
}

enum OnboardingStep {
  brandSpace,
  createGuide,
  hostConversation,
  inviteSomeone,
  createStripeAccount,
}

@Freezed(makeCollectionsUnmodifiable: false)
class Junto with _$Junto implements SerializeableRequest {
  Junto._();

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
  static const String kFieldDiscussionSettings = 'discussionSettings';
  static const String kFieldDonationDialogText = 'donationDialogText';
  static const String kFieldRatingSurveyUrl = 'ratingSurveyUrl';
  static const String kFieldThemeLightColor = 'themeLightColor';
  static const String kFieldThemeDarkColor = 'themeDarkColor';
  static const String kFieldOnboardingSteps = 'onboardingSteps';

  factory Junto({
    required String id,

    /// List of IDs that correlate to this Junto in the URL bar.
    @Default([]) List<String> displayIds,
    String? name,
    String? contactEmail,
    String? creatorId,
    String? profileImageUrl,
    String? bannerImageUrl,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp) DateTime? createdDate,
    bool? isPublic,
    String? description,
    String? tagLine,
    @Default([])
    @JsonKey(fromJson: juntoFeatureFlagsFromJson)
    List<JuntoFeatureFlags> enabledFeatureFlags,
    CommunitySettings? communitySettings,
    DiscussionSettings? discussionSettings,
    String? donationDialogText,
    String? ratingSurveyUrl,
    String? themeLightColor,
    String? themeDarkColor,
    @Default([]) List<OnboardingStep> onboardingSteps,
    @Default(false) bool isOnboardingOverviewEnabled,
  }) = _Junto;

  factory Junto.fromJson(Map<String, dynamic> json) => _$JuntoFromJson(json);

  static Map<String, dynamic> toJsonForCloudFunction(Junto? junto) {
    if (junto == null) return {};

    return junto.toJson()..remove(Junto.kFieldCreatedDate);
  }

  String get displayId => displayIds.firstOrNull ?? id;

  CommunitySettings get settingsMigration {
    final localSettings = communitySettings;
    if (localSettings == null) {
      final flags = enabledFeatureFlags;
      return CommunitySettings(
        allowDonations: flags.contains(JuntoFeatureFlags.allowDonations),
        allowUnofficialTopics: flags.contains(JuntoFeatureFlags.allowUnofficialTopics),
        enableHostless: flags.contains(JuntoFeatureFlags.enableHostless),
        disableEmailDigests: flags.contains(JuntoFeatureFlags.disableEmailDigests),
        dontAllowMembersToCreateMeetings:
            flags.contains(JuntoFeatureFlags.dontAllowMembersToCreateMeetings),
        enableDiscussionThreads: flags.contains(JuntoFeatureFlags.enableDiscussionThreads),
        enablePlatformSelection: flags.contains(JuntoFeatureFlags.enablePlatformSelection),
        multiplePeopleOnStage: flags.contains(JuntoFeatureFlags.multiplePeopleOnStage),
        multipleVideoTypes: flags.contains(JuntoFeatureFlags.multipleVideoTypes),
        requireApprovalToJoin: flags.contains(JuntoFeatureFlags.requireApprovalToJoin),
      );
    } else {
      return localSettings;
    }
  }

  DiscussionSettings get discussionSettingsMigration {
    final localSettings = discussionSettings;
    if (localSettings == null) {
      final flags = enabledFeatureFlags;
      return DiscussionSettings(
        alwaysRecord: flags.contains(JuntoFeatureFlags.alwaysRecord),
        allowPredefineBreakoutsOnHosted:
            flags.contains(JuntoFeatureFlags.allowPredefineBreakoutsOnHosted),
        chat: flags.contains(JuntoFeatureFlags.chat),
        defaultStageView: flags.contains(JuntoFeatureFlags.defaultStageView),
        enableBreakoutsByCategory: flags.contains(JuntoFeatureFlags.enableBreakoutsByCategory),
        enablePrerequisites: flags.contains(JuntoFeatureFlags.enablePrerequisites),
        showSmartMatchingForBreakouts:
            flags.contains(JuntoFeatureFlags.showSmartMatchingForBreakouts),
        reminderEmails: !flags.contains(JuntoFeatureFlags.suppressJoinDiscussionEmails),
        showChatMessagesInRealTime: DiscussionSettings.defaultSettings.showChatMessagesInRealTime,
        talkingTimer: DiscussionSettings.defaultSettings.talkingTimer,
        allowMultiplePeopleOnStage: DiscussionSettings.defaultSettings.allowMultiplePeopleOnStage,
        agendaPreview: DiscussionSettings.defaultSettings.agendaPreview,
      );
    } else {
      return localSettings;
    }
  }
}

enum FeaturedType {
  topic,
  conversation,
}

@Freezed(makeCollectionsUnmodifiable: false)
class Featured with _$Featured {
  factory Featured({
    String? documentPath,
    @JsonKey(unknownEnumValue: null) FeaturedType? featuredType,
  }) = _Featured;

  factory Featured.fromJson(Map<String, dynamic> json) => _$FeaturedFromJson(json);
}

CommunitySettings communitySettingsFromJson(Map<String, dynamic> json) =>
    CommunitySettings.fromJson(json);

@Freezed(makeCollectionsUnmodifiable: false)
class CommunitySettings with _$CommunitySettings {
  static const kFieldAllowDonations = 'allowDonations';
  static const kFieldAllowUnofficialTopics = 'allowUnofficialTopics';
  static const kFieldDisableEmailDigests = 'disableEmailDigests';
  static const kFieldDontAllowMembersToCreateMeetings = 'dontAllowMembersToCreateMeetings';
  static const kFieldEnableDiscussionThreads = 'enableDiscussionThreads';
  static const kFieldEnableHostless = 'enableHostless';
  static const kFieldFeatureOnKazmHome = 'featureOnKazmHome';
  static const kFieldFeaturedOrder = 'featuredOrder';
  static const kFieldEnablePlatformSelection = 'enablePlatformSelection';
  static const kFieldMultiplePeopleOnStage = 'multiplePeopleOnStage';
  static const kFieldRequireApprovalToJoin = 'requireApprovalToJoin';

  const factory CommunitySettings({
    @Default(true) bool allowDonations,
    @Default(false) bool allowUnofficialTopics,
    @Default(false) bool disableEmailDigests,
    @Default(true) bool dontAllowMembersToCreateMeetings,
    @Default(true) bool enableDiscussionThreads,
    @Default(true) bool enableHostless,
    @Default(false) bool featureOnKazmHome,
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
