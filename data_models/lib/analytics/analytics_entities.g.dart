// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsAgreeToTermsAndConditionsEvent
    _$AnalyticsAgreeToTermsAndConditionsEventFromJson(
            Map<String, dynamic> json) =>
        AnalyticsAgreeToTermsAndConditionsEvent(
          userId: json['userId'] as String,
        );

Map<String, dynamic> _$AnalyticsAgreeToTermsAndConditionsEventToJson(
        AnalyticsAgreeToTermsAndConditionsEvent instance) =>
    <String, dynamic>{
      'userId': instance.userId,
    };

AnalyticsLinkStripeAccountEvent _$AnalyticsLinkStripeAccountEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsLinkStripeAccountEvent();

Map<String, dynamic> _$AnalyticsLinkStripeAccountEventToJson(
        AnalyticsLinkStripeAccountEvent instance) =>
    <String, dynamic>{};

AnalyticsCreateCommunityEvent _$AnalyticsCreateCommunityEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsCreateCommunityEvent(
      communityId: json['communityId'] as String,
    );

Map<String, dynamic> _$AnalyticsCreateCommunityEventToJson(
        AnalyticsCreateCommunityEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

AnalyticsUpdateCommunityImageEvent _$AnalyticsUpdateCommunityImageEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsUpdateCommunityImageEvent(
      communityId: json['communityId'] as String,
    );

Map<String, dynamic> _$AnalyticsUpdateCommunityImageEventToJson(
        AnalyticsUpdateCommunityImageEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

AnalyticsUpdateCommunityMetadataEvent
    _$AnalyticsUpdateCommunityMetadataEventFromJson(
            Map<String, dynamic> json) =>
        AnalyticsUpdateCommunityMetadataEvent(
          communityId: json['communityId'] as String,
        );

Map<String, dynamic> _$AnalyticsUpdateCommunityMetadataEventToJson(
        AnalyticsUpdateCommunityMetadataEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

AnalyticsPressShareCommunityLinkEvent
    _$AnalyticsPressShareCommunityLinkEventFromJson(
            Map<String, dynamic> json) =>
        AnalyticsPressShareCommunityLinkEvent(
          communityId: json['communityId'] as String,
          shareType: $enumDecode(_$ShareTypeEnumMap, json['shareType']),
        );

Map<String, dynamic> _$AnalyticsPressShareCommunityLinkEventToJson(
        AnalyticsPressShareCommunityLinkEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'shareType': _$ShareTypeEnumMap[instance.shareType]!,
    };

const _$ShareTypeEnumMap = {
  ShareType.facebook: 'facebook',
  ShareType.twitter: 'twitter',
  ShareType.linkedin: 'linkedin',
  ShareType.email: 'email',
  ShareType.link: 'link',
};

AnalyticsJoinCommunityEvent _$AnalyticsJoinCommunityEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsJoinCommunityEvent(
      communityId: json['communityId'] as String,
    );

Map<String, dynamic> _$AnalyticsJoinCommunityEventToJson(
        AnalyticsJoinCommunityEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

AnalyticsLeaveCommunityEvent _$AnalyticsLeaveCommunityEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsLeaveCommunityEvent(
      communityId: json['communityId'] as String,
    );

Map<String, dynamic> _$AnalyticsLeaveCommunityEventToJson(
        AnalyticsLeaveCommunityEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

AnalyticsPressAddNewGuideEvent _$AnalyticsPressAddNewGuideEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsPressAddNewGuideEvent(
      communityId: json['communityId'] as String,
    );

Map<String, dynamic> _$AnalyticsPressAddNewGuideEventToJson(
        AnalyticsPressAddNewGuideEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
    };

AnalyticsCompleteNewGuideEvent _$AnalyticsCompleteNewGuideEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsCompleteNewGuideEvent(
      communityId: json['communityId'] as String,
      guideId: json['guideId'] as String,
    );

Map<String, dynamic> _$AnalyticsCompleteNewGuideEventToJson(
        AnalyticsCompleteNewGuideEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'guideId': instance.guideId,
    };

AnalyticsPressCreateEventFromGuideEvent
    _$AnalyticsPressCreateEventFromGuideEventFromJson(
            Map<String, dynamic> json) =>
        AnalyticsPressCreateEventFromGuideEvent(
          communityId: json['communityId'] as String,
          guideId: json['guideId'] as String,
        );

Map<String, dynamic> _$AnalyticsPressCreateEventFromGuideEventToJson(
        AnalyticsPressCreateEventFromGuideEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'guideId': instance.guideId,
    };

AnalyticsCreateEventEvent _$AnalyticsCreateEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsCreateEventEvent(
      communityId: json['communityId'] as String,
      eventId: json['eventId'] as String,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsCreateEventEventToJson(
        AnalyticsCreateEventEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'eventId': instance.eventId,
      'guideId': instance.guideId,
    };

AnalyticsScheduleEventEvent _$AnalyticsScheduleEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsScheduleEventEvent(
      communityId: json['communityId'] as String,
      eventId: json['eventId'] as String,
      daysFromNow: json['daysFromNow'] as int,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsScheduleEventEventToJson(
        AnalyticsScheduleEventEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'eventId': instance.eventId,
      'daysFromNow': instance.daysFromNow,
      'guideId': instance.guideId,
    };

AnalyticsEditEventEvent _$AnalyticsEditEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsEditEventEvent(
      communityId: json['communityId'] as String,
      eventId: json['eventId'] as String,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsEditEventEventToJson(
        AnalyticsEditEventEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'eventId': instance.eventId,
      'guideId': instance.guideId,
    };

AnalyticsPressShareEventEvent _$AnalyticsPressShareEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsPressShareEventEvent(
      communityId: json['communityId'] as String,
      eventId: json['eventId'] as String,
      guideId: json['guideId'] as String?,
      shareType: $enumDecode(_$ShareTypeEnumMap, json['shareType']),
    );

Map<String, dynamic> _$AnalyticsPressShareEventEventToJson(
        AnalyticsPressShareEventEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'eventId': instance.eventId,
      'guideId': instance.guideId,
      'shareType': _$ShareTypeEnumMap[instance.shareType]!,
    };

AnalyticsEnterEventEvent _$AnalyticsEnterEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsEnterEventEvent(
      communityId: json['communityId'] as String,
      eventId: json['eventId'] as String,
      asHost: json['asHost'] as bool,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsEnterEventEventToJson(
        AnalyticsEnterEventEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'eventId': instance.eventId,
      'asHost': instance.asHost,
      'guideId': instance.guideId,
    };

AnalyticsCompleteEventEvent _$AnalyticsCompleteEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsCompleteEventEvent(
      communityId: json['communityId'] as String,
      eventId: json['eventId'] as String,
      asHost: json['asHost'] as bool,
      duration: json['duration'] as int,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsCompleteEventEventToJson(
        AnalyticsCompleteEventEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'eventId': instance.eventId,
      'asHost': instance.asHost,
      'duration': instance.duration,
      'guideId': instance.guideId,
    };

AnalyticsPressEventHelpEvent _$AnalyticsPressEventHelpEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsPressEventHelpEvent(
      communityId: json['communityId'] as String,
      eventId: json['eventId'] as String,
      asHost: json['asHost'] as bool,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsPressEventHelpEventToJson(
        AnalyticsPressEventHelpEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'eventId': instance.eventId,
      'asHost': instance.asHost,
      'guideId': instance.guideId,
    };

AnalyticsRsvpEventEvent _$AnalyticsRsvpEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsRsvpEventEvent(
      communityId: json['communityId'] as String,
      eventId: json['eventId'] as String,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsRsvpEventEventToJson(
        AnalyticsRsvpEventEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'eventId': instance.eventId,
      'guideId': instance.guideId,
    };

AnalyticsDonateEvent _$AnalyticsDonateEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsDonateEvent(
      communityId: json['communityId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$AnalyticsDonateEventToJson(
        AnalyticsDonateEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'amount': instance.amount,
    };

AnalyticsUpdateCommunitySubscriptionEvent
    _$AnalyticsUpdateCommunitySubscriptionEventFromJson(
            Map<String, dynamic> json) =>
        AnalyticsUpdateCommunitySubscriptionEvent(
          communityId: json['communityId'] as String?,
          planType: json['planType'] as String,
          subscriptionId: json['subscriptionId'] as String,
          isCanceled: json['isCanceled'] as bool,
        );

Map<String, dynamic> _$AnalyticsUpdateCommunitySubscriptionEventToJson(
        AnalyticsUpdateCommunitySubscriptionEvent instance) =>
    <String, dynamic>{
      'communityId': instance.communityId,
      'planType': instance.planType,
      'subscriptionId': instance.subscriptionId,
      'isCanceled': instance.isCanceled,
    };
