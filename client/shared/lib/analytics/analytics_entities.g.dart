// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsAgreeToTermsAndConditionsEvent
    _$AnalyticsAgreeToTermsAndConditionsEventFromJson(
            Map<String, dynamic> json) =>
        AnalyticsAgreeToTermsAndConditionsEvent();

Map<String, dynamic> _$AnalyticsAgreeToTermsAndConditionsEventToJson(
        AnalyticsAgreeToTermsAndConditionsEvent instance) =>
    <String, dynamic>{};

AnalyticsLinkStripeAccountEvent _$AnalyticsLinkStripeAccountEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsLinkStripeAccountEvent();

Map<String, dynamic> _$AnalyticsLinkStripeAccountEventToJson(
        AnalyticsLinkStripeAccountEvent instance) =>
    <String, dynamic>{};

AnalyticsCreateJuntoEvent _$AnalyticsCreateJuntoEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsCreateJuntoEvent(
      juntoId: json['juntoId'] as String,
    );

Map<String, dynamic> _$AnalyticsCreateJuntoEventToJson(
        AnalyticsCreateJuntoEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
    };

AnalyticsUpdateJuntoImageEvent _$AnalyticsUpdateJuntoImageEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsUpdateJuntoImageEvent(
      juntoId: json['juntoId'] as String,
    );

Map<String, dynamic> _$AnalyticsUpdateJuntoImageEventToJson(
        AnalyticsUpdateJuntoImageEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
    };

AnalyticsUpdateJuntoMetadataEvent _$AnalyticsUpdateJuntoMetadataEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsUpdateJuntoMetadataEvent(
      juntoId: json['juntoId'] as String,
    );

Map<String, dynamic> _$AnalyticsUpdateJuntoMetadataEventToJson(
        AnalyticsUpdateJuntoMetadataEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
    };

AnalyticsPressShareJuntoLinkEvent _$AnalyticsPressShareJuntoLinkEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsPressShareJuntoLinkEvent(
      juntoId: json['juntoId'] as String,
      shareType: $enumDecode(_$ShareTypeEnumMap, json['shareType']),
    );

Map<String, dynamic> _$AnalyticsPressShareJuntoLinkEventToJson(
        AnalyticsPressShareJuntoLinkEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'shareType': _$ShareTypeEnumMap[instance.shareType]!,
    };

const _$ShareTypeEnumMap = {
  ShareType.facebook: 'facebook',
  ShareType.twitter: 'twitter',
  ShareType.linkedin: 'linkedin',
  ShareType.email: 'email',
  ShareType.link: 'link',
};

AnalyticsPressAddNewGuideEvent _$AnalyticsPressAddNewGuideEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsPressAddNewGuideEvent(
      juntoId: json['juntoId'] as String,
    );

Map<String, dynamic> _$AnalyticsPressAddNewGuideEventToJson(
        AnalyticsPressAddNewGuideEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
    };

AnalyticsCompleteNewGuideEvent _$AnalyticsCompleteNewGuideEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsCompleteNewGuideEvent(
      juntoId: json['juntoId'] as String,
      guideId: json['guideId'] as String,
    );

Map<String, dynamic> _$AnalyticsCompleteNewGuideEventToJson(
        AnalyticsCompleteNewGuideEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'guideId': instance.guideId,
    };

AnalyticsPressCreateEventFromGuideEvent
    _$AnalyticsPressCreateEventFromGuideEventFromJson(
            Map<String, dynamic> json) =>
        AnalyticsPressCreateEventFromGuideEvent(
          juntoId: json['juntoId'] as String,
          guideId: json['guideId'] as String,
        );

Map<String, dynamic> _$AnalyticsPressCreateEventFromGuideEventToJson(
        AnalyticsPressCreateEventFromGuideEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'guideId': instance.guideId,
    };

AnalyticsCreateEventEvent _$AnalyticsCreateEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsCreateEventEvent(
      juntoId: json['juntoId'] as String,
      discussionId: json['discussionId'] as String,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsCreateEventEventToJson(
        AnalyticsCreateEventEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'discussionId': instance.discussionId,
      'guideId': instance.guideId,
    };

AnalyticsScheduleEventEvent _$AnalyticsScheduleEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsScheduleEventEvent(
      juntoId: json['juntoId'] as String,
      discussionId: json['discussionId'] as String,
      daysFromNow: json['daysFromNow'] as int,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsScheduleEventEventToJson(
        AnalyticsScheduleEventEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'discussionId': instance.discussionId,
      'daysFromNow': instance.daysFromNow,
      'guideId': instance.guideId,
    };

AnalyticsEditEventEvent _$AnalyticsEditEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsEditEventEvent(
      juntoId: json['juntoId'] as String,
      discussionId: json['discussionId'] as String,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsEditEventEventToJson(
        AnalyticsEditEventEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'discussionId': instance.discussionId,
      'guideId': instance.guideId,
    };

AnalyticsPressShareEventEvent _$AnalyticsPressShareEventEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsPressShareEventEvent(
      juntoId: json['juntoId'] as String,
      discussionId: json['discussionId'] as String,
      guideId: json['guideId'] as String?,
      shareType: $enumDecode(_$ShareTypeEnumMap, json['shareType']),
    );

Map<String, dynamic> _$AnalyticsPressShareEventEventToJson(
        AnalyticsPressShareEventEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'discussionId': instance.discussionId,
      'guideId': instance.guideId,
      'shareType': _$ShareTypeEnumMap[instance.shareType]!,
    };

AnalyticsEnterDiscussionEvent _$AnalyticsEnterDiscussionEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsEnterDiscussionEvent(
      juntoId: json['juntoId'] as String,
      discussionId: json['discussionId'] as String,
      asHost: json['asHost'] as bool,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsEnterDiscussionEventToJson(
        AnalyticsEnterDiscussionEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'discussionId': instance.discussionId,
      'asHost': instance.asHost,
      'guideId': instance.guideId,
    };

AnalyticsCompleteDiscussionEvent _$AnalyticsCompleteDiscussionEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsCompleteDiscussionEvent(
      juntoId: json['juntoId'] as String,
      discussionId: json['discussionId'] as String,
      asHost: json['asHost'] as bool,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsCompleteDiscussionEventToJson(
        AnalyticsCompleteDiscussionEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'discussionId': instance.discussionId,
      'asHost': instance.asHost,
      'guideId': instance.guideId,
    };

AnalyticsPressDiscussionHelpEvent _$AnalyticsPressDiscussionHelpEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsPressDiscussionHelpEvent(
      juntoId: json['juntoId'] as String,
      discussionId: json['discussionId'] as String,
      asHost: json['asHost'] as bool,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsPressDiscussionHelpEventToJson(
        AnalyticsPressDiscussionHelpEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'discussionId': instance.discussionId,
      'asHost': instance.asHost,
      'guideId': instance.guideId,
    };

AnalyticsRsvpDiscussionEvent _$AnalyticsRsvpDiscussionEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsRsvpDiscussionEvent(
      juntoId: json['juntoId'] as String,
      discussionId: json['discussionId'] as String,
      guideId: json['guideId'] as String?,
    );

Map<String, dynamic> _$AnalyticsRsvpDiscussionEventToJson(
        AnalyticsRsvpDiscussionEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'discussionId': instance.discussionId,
      'guideId': instance.guideId,
    };

AnalyticsJoinJuntoEvent _$AnalyticsJoinJuntoEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsJoinJuntoEvent(
      juntoId: json['juntoId'] as String,
    );

Map<String, dynamic> _$AnalyticsJoinJuntoEventToJson(
        AnalyticsJoinJuntoEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
    };

AnalyticsLeaveJuntoEvent _$AnalyticsLeaveJuntoEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsLeaveJuntoEvent(
      juntoId: json['juntoId'] as String,
    );

Map<String, dynamic> _$AnalyticsLeaveJuntoEventToJson(
        AnalyticsLeaveJuntoEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
    };

AnalyticsDonateEvent _$AnalyticsDonateEventFromJson(
        Map<String, dynamic> json) =>
    AnalyticsDonateEvent(
      juntoId: json['juntoId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$AnalyticsDonateEventToJson(
        AnalyticsDonateEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'amount': instance.amount,
    };

AnalyticsUpdateCommunitySubscriptionEvent
    _$AnalyticsUpdateCommunitySubscriptionEventFromJson(
            Map<String, dynamic> json) =>
        AnalyticsUpdateCommunitySubscriptionEvent(
          juntoId: json['juntoId'] as String?,
          planType: json['planType'] as String,
          subscriptionId: json['subscriptionId'] as String,
          isCanceled: json['isCanceled'] as bool,
        );

Map<String, dynamic> _$AnalyticsUpdateCommunitySubscriptionEventToJson(
        AnalyticsUpdateCommunitySubscriptionEvent instance) =>
    <String, dynamic>{
      'juntoId': instance.juntoId,
      'planType': instance.planType,
      'subscriptionId': instance.subscriptionId,
      'isCanceled': instance.isCanceled,
    };
