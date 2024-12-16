// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'junto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Junto _$$_JuntoFromJson(Map<String, dynamic> json) => _$_Junto(
      id: json['id'] as String,
      displayIds: (json['displayIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      name: json['name'] as String?,
      contactEmail: json['contactEmail'] as String?,
      creatorId: json['creatorId'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      bannerImageUrl: json['bannerImageUrl'] as String?,
      createdDate: dateTimeFromTimestamp(json['createdDate']),
      isPublic: json['isPublic'] as bool?,
      description: json['description'] as String?,
      tagLine: json['tagLine'] as String?,
      enabledFeatureFlags: json['enabledFeatureFlags'] == null
          ? const []
          : juntoFeatureFlagsFromJson(json['enabledFeatureFlags']),
      communitySettings: json['communitySettings'] == null
          ? null
          : CommunitySettings.fromJson(
              json['communitySettings'] as Map<String, dynamic>),
      discussionSettings: json['discussionSettings'] == null
          ? null
          : DiscussionSettings.fromJson(
              json['discussionSettings'] as Map<String, dynamic>),
      donationDialogText: json['donationDialogText'] as String?,
      ratingSurveyUrl: json['ratingSurveyUrl'] as String?,
      themeLightColor: json['themeLightColor'] as String?,
      themeDarkColor: json['themeDarkColor'] as String?,
      onboardingSteps: (json['onboardingSteps'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$OnboardingStepEnumMap, e))
              .toList() ??
          const [],
      isOnboardingOverviewEnabled:
          json['isOnboardingOverviewEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$$_JuntoToJson(_$_Junto instance) => <String, dynamic>{
      'id': instance.id,
      'displayIds': instance.displayIds,
      'name': instance.name,
      'contactEmail': instance.contactEmail,
      'creatorId': instance.creatorId,
      'profileImageUrl': instance.profileImageUrl,
      'bannerImageUrl': instance.bannerImageUrl,
      'createdDate': serverTimestamp(instance.createdDate),
      'isPublic': instance.isPublic,
      'description': instance.description,
      'tagLine': instance.tagLine,
      'enabledFeatureFlags': instance.enabledFeatureFlags
          .map((e) => _$JuntoFeatureFlagsEnumMap[e]!)
          .toList(),
      'communitySettings': instance.communitySettings?.toJson(),
      'discussionSettings': instance.discussionSettings?.toJson(),
      'donationDialogText': instance.donationDialogText,
      'ratingSurveyUrl': instance.ratingSurveyUrl,
      'themeLightColor': instance.themeLightColor,
      'themeDarkColor': instance.themeDarkColor,
      'onboardingSteps': instance.onboardingSteps
          .map((e) => _$OnboardingStepEnumMap[e]!)
          .toList(),
      'isOnboardingOverviewEnabled': instance.isOnboardingOverviewEnabled,
    };

const _$OnboardingStepEnumMap = {
  OnboardingStep.brandSpace: 'brandSpace',
  OnboardingStep.createGuide: 'createGuide',
  OnboardingStep.hostConversation: 'hostConversation',
  OnboardingStep.inviteSomeone: 'inviteSomeone',
  OnboardingStep.createStripeAccount: 'createStripeAccount',
};

const _$JuntoFeatureFlagsEnumMap = {
  JuntoFeatureFlags.allowDonations: 'allowDonations',
  JuntoFeatureFlags.alwaysRecord: 'alwaysRecord',
  JuntoFeatureFlags.allowUnofficialTopics: 'allowUnofficialTopics',
  JuntoFeatureFlags.allowPredefineBreakoutsOnHosted:
      'allowPredefineBreakoutsOnHosted',
  JuntoFeatureFlags.chat: 'chat',
  JuntoFeatureFlags.defaultStageView: 'defaultStageView',
  JuntoFeatureFlags.disableScreenShare: 'disableScreenShare',
  JuntoFeatureFlags.disableEmailDigests: 'disableEmailDigests',
  JuntoFeatureFlags.dontAllowMembersToCreateMeetings:
      'dontAllowMembersToCreateMeetings',
  JuntoFeatureFlags.enableBreakoutsByCategory: 'enableBreakoutsByCategory',
  JuntoFeatureFlags.enableDiscussionThreads: 'enableDiscussionThreads',
  JuntoFeatureFlags.enablePrerequisites: 'enablePrerequisites',
  JuntoFeatureFlags.enableHostless: 'enableHostless',
  JuntoFeatureFlags.enablePlatformSelection: 'enablePlatformSelection',
  JuntoFeatureFlags.liveMeetingMobile: 'liveMeetingMobile',
  JuntoFeatureFlags.multiplePeopleOnStage: 'multiplePeopleOnStage',
  JuntoFeatureFlags.multipleVideoTypes: 'multipleVideoTypes',
  JuntoFeatureFlags.requireApprovalToJoin: 'requireApprovalToJoin',
  JuntoFeatureFlags.showSmartMatchingForBreakouts:
      'showSmartMatchingForBreakouts',
  JuntoFeatureFlags.suppressJoinDiscussionEmails:
      'suppressJoinDiscussionEmails',
};

_$_Featured _$$_FeaturedFromJson(Map<String, dynamic> json) => _$_Featured(
      documentPath: json['documentPath'] as String?,
      featuredType:
          $enumDecodeNullable(_$FeaturedTypeEnumMap, json['featuredType']),
    );

Map<String, dynamic> _$$_FeaturedToJson(_$_Featured instance) =>
    <String, dynamic>{
      'documentPath': instance.documentPath,
      'featuredType': _$FeaturedTypeEnumMap[instance.featuredType],
    };

const _$FeaturedTypeEnumMap = {
  FeaturedType.topic: 'topic',
  FeaturedType.conversation: 'conversation',
};

_$_CommunitySettings _$$_CommunitySettingsFromJson(Map<String, dynamic> json) =>
    _$_CommunitySettings(
      allowDonations: json['allowDonations'] as bool? ?? true,
      allowUnofficialTopics: json['allowUnofficialTopics'] as bool? ?? false,
      disableEmailDigests: json['disableEmailDigests'] as bool? ?? false,
      dontAllowMembersToCreateMeetings:
          json['dontAllowMembersToCreateMeetings'] as bool? ?? true,
      enableDiscussionThreads: json['enableDiscussionThreads'] as bool? ?? true,
      enableHostless: json['enableHostless'] as bool? ?? false,
      featureOnKazmHome: json['featureOnKazmHome'] as bool? ?? false,
      featuredOrder: json['featuredOrder'] as int?,
      multiplePeopleOnStage: json['multiplePeopleOnStage'] as bool? ?? false,
      multipleVideoTypes: json['multipleVideoTypes'] as bool? ?? false,
      requireApprovalToJoin: json['requireApprovalToJoin'] as bool? ?? false,
      enablePlatformSelection: json['enablePlatformSelection'] as bool? ?? true,
      enableUpdatedLiveMeetingMobile:
          json['enableUpdatedLiveMeetingMobile'] as bool? ?? false,
      enableAVCheck: json['enableAVCheck'] as bool? ?? true,
    );

Map<String, dynamic> _$$_CommunitySettingsToJson(
        _$_CommunitySettings instance) =>
    <String, dynamic>{
      'allowDonations': instance.allowDonations,
      'allowUnofficialTopics': instance.allowUnofficialTopics,
      'disableEmailDigests': instance.disableEmailDigests,
      'dontAllowMembersToCreateMeetings':
          instance.dontAllowMembersToCreateMeetings,
      'enableDiscussionThreads': instance.enableDiscussionThreads,
      'enableHostless': instance.enableHostless,
      'featureOnKazmHome': instance.featureOnKazmHome,
      'featuredOrder': instance.featuredOrder,
      'multiplePeopleOnStage': instance.multiplePeopleOnStage,
      'multipleVideoTypes': instance.multipleVideoTypes,
      'requireApprovalToJoin': instance.requireApprovalToJoin,
      'enablePlatformSelection': instance.enablePlatformSelection,
      'enableUpdatedLiveMeetingMobile': instance.enableUpdatedLiveMeetingMobile,
      'enableAVCheck': instance.enableAVCheck,
    };
