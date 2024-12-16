// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Community _$$_CommunityFromJson(Map<String, dynamic> json) => _$_Community(
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
          : communityFeatureFlagsFromJson(json['enabledFeatureFlags']),
      communitySettings: json['communitySettings'] == null
          ? null
          : CommunitySettings.fromJson(
              json['communitySettings'] as Map<String, dynamic>),
      eventSettings: json['eventSettings'] == null
          ? null
          : EventSettings.fromJson(
              json['eventSettings'] as Map<String, dynamic>),
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

Map<String, dynamic> _$$_CommunityToJson(_$_Community instance) =>
    <String, dynamic>{
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
          .map((e) => _$CommunityFeatureFlagsEnumMap[e]!)
          .toList(),
      'communitySettings': instance.communitySettings?.toJson(),
      'eventSettings': instance.eventSettings?.toJson(),
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
  OnboardingStep.hostEvent: 'hostEvent',
  OnboardingStep.inviteSomeone: 'inviteSomeone',
  OnboardingStep.createStripeAccount: 'createStripeAccount',
};

const _$CommunityFeatureFlagsEnumMap = {
  CommunityFeatureFlags.allowDonations: 'allowDonations',
  CommunityFeatureFlags.alwaysRecord: 'alwaysRecord',
  CommunityFeatureFlags.allowUnofficialTemplates: 'allowUnofficialTemplates',
  CommunityFeatureFlags.allowPredefineBreakoutsOnHosted:
      'allowPredefineBreakoutsOnHosted',
  CommunityFeatureFlags.chat: 'chat',
  CommunityFeatureFlags.defaultStageView: 'defaultStageView',
  CommunityFeatureFlags.disableScreenShare: 'disableScreenShare',
  CommunityFeatureFlags.disableEmailDigests: 'disableEmailDigests',
  CommunityFeatureFlags.dontAllowMembersToCreateMeetings:
      'dontAllowMembersToCreateMeetings',
  CommunityFeatureFlags.enableBreakoutsByCategory: 'enableBreakoutsByCategory',
  CommunityFeatureFlags.enableDiscussionThreads: 'enableDiscussionThreads',
  CommunityFeatureFlags.enablePrerequisites: 'enablePrerequisites',
  CommunityFeatureFlags.enableHostless: 'enableHostless',
  CommunityFeatureFlags.enablePlatformSelection: 'enablePlatformSelection',
  CommunityFeatureFlags.liveMeetingMobile: 'liveMeetingMobile',
  CommunityFeatureFlags.multiplePeopleOnStage: 'multiplePeopleOnStage',
  CommunityFeatureFlags.multipleVideoTypes: 'multipleVideoTypes',
  CommunityFeatureFlags.requireApprovalToJoin: 'requireApprovalToJoin',
  CommunityFeatureFlags.showSmartMatchingForBreakouts:
      'showSmartMatchingForBreakouts',
  CommunityFeatureFlags.suppressJoinEventEmails: 'suppressJoinEventEmails',
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
  FeaturedType.template: 'template',
  FeaturedType.event: 'event',
};

_$_CommunitySettings _$$_CommunitySettingsFromJson(Map<String, dynamic> json) =>
    _$_CommunitySettings(
      allowDonations: json['allowDonations'] as bool? ?? true,
      allowUnofficialTemplates:
          json['allowUnofficialTemplates'] as bool? ?? false,
      disableEmailDigests: json['disableEmailDigests'] as bool? ?? false,
      dontAllowMembersToCreateMeetings:
          json['dontAllowMembersToCreateMeetings'] as bool? ?? true,
      enableDiscussionThreads: json['enableDiscussionThreads'] as bool? ?? true,
      enableHostless: json['enableHostless'] as bool? ?? true,
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
      'allowUnofficialTemplates': instance.allowUnofficialTemplates,
      'disableEmailDigests': instance.disableEmailDigests,
      'dontAllowMembersToCreateMeetings':
          instance.dontAllowMembersToCreateMeetings,
      'enableDiscussionThreads': instance.enableDiscussionThreads,
      'enableHostless': instance.enableHostless,
      'featuredOrder': instance.featuredOrder,
      'multiplePeopleOnStage': instance.multiplePeopleOnStage,
      'multipleVideoTypes': instance.multipleVideoTypes,
      'requireApprovalToJoin': instance.requireApprovalToJoin,
      'enablePlatformSelection': instance.enablePlatformSelection,
      'enableUpdatedLiveMeetingMobile': instance.enableUpdatedLiveMeetingMobile,
      'enableAVCheck': instance.enableAVCheck,
    };
