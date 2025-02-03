import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/utils/share_type.dart';
part 'analytics_entities.g.dart';

abstract class AnalyticsEvent {
  String getEventType();
  String getEventCategory();
  String? getEventName();
  num? getMetricValue();
  Map<String, dynamic> toJson();
  static const String userCategory = 'user';
  static const String communityCategory = 'community';
  static const String eventCategory = 'event';
  static const String templateCategory = 'template';
}

@JsonSerializable()
class AnalyticsAgreeToTermsAndConditionsEvent implements AnalyticsEvent {
  final String userId;

  @override
  String getEventType() {
    return 'agree_to_tac';
  }

  AnalyticsAgreeToTermsAndConditionsEvent({required this.userId});

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsAgreeToTermsAndConditionsEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.userCategory;
  }

  @override
  String getEventName() {
    return userId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsLinkStripeAccountEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'link_stripe_account';
  }

  AnalyticsLinkStripeAccountEvent();

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsLinkStripeAccountEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.userCategory;
  }

  @override
  String? getEventName() {
    return null;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsCreateCommunityEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'create_community';
  }

  final String communityId;

  AnalyticsCreateCommunityEvent({
    required this.communityId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsCreateCommunityEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.communityCategory;
  }

  @override
  String? getEventName() {
    return communityId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsUpdateCommunityImageEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'update_community_image';
  }

  final String communityId;

  AnalyticsUpdateCommunityImageEvent({
    required this.communityId,
  });

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsUpdateCommunityImageEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.communityCategory;
  }

  @override
  String? getEventName() {
    return communityId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsUpdateCommunityMetadataEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'update_community_metadata';
  }

  final String communityId;

  AnalyticsUpdateCommunityMetadataEvent({
    required this.communityId,
  });

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsUpdateCommunityMetadataEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.communityCategory;
  }

  @override
  String? getEventName() {
    return communityId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsPressShareCommunityLinkEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_share_community_link';
  }

  final String communityId;
  final ShareType shareType;

  AnalyticsPressShareCommunityLinkEvent({
    required this.communityId,
    required this.shareType,
  });

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsPressShareCommunityLinkEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.communityCategory;
  }

  @override
  String? getEventName() {
    return communityId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsJoinCommunityEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'join_community';
  }

  final String communityId;

  AnalyticsJoinCommunityEvent({
    required this.communityId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsJoinCommunityEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.communityCategory;
  }

  @override
  String? getEventName() {
    return communityId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsLeaveCommunityEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'leave_community';
  }

  final String communityId;

  AnalyticsLeaveCommunityEvent({
    required this.communityId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsLeaveCommunityEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.communityCategory;
  }

  @override
  String? getEventName() {
    return communityId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsPressAddNewTemplateEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_add_new_template';
  }

  final String communityId;

  AnalyticsPressAddNewTemplateEvent({
    required this.communityId,
  });

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsPressAddNewTemplateEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.templateCategory;
  }

  @override
  String? getEventName() {
    return communityId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsCompleteNewTemplateEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'complete_new_template';
  }

  final String communityId;
  final String templateId;

  AnalyticsCompleteNewTemplateEvent({
    required this.communityId,
    required this.templateId,
  });

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsCompleteNewTemplateEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.templateCategory;
  }

  @override
  String? getEventName() {
    return templateId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsPressCreateEventFromTemplateEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_create_event_from_template';
  }

  final String communityId;
  final String templateId;

  AnalyticsPressCreateEventFromTemplateEvent({
    required this.communityId,
    required this.templateId,
  });

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsPressCreateEventFromTemplateEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.eventCategory;
  }

  @override
  String? getEventName() {
    return templateId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsCreateEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'create_event';
  }

  final String communityId;
  final String eventId;
  final String? templateId;

  AnalyticsCreateEventEvent({
    required this.communityId,
    required this.eventId,
    this.templateId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsCreateEventEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.eventCategory;
  }

  @override
  String? getEventName() {
    return eventId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsScheduleEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'schedule_event';
  }

  final String communityId;
  final String eventId;
  final int daysFromNow;
  final String? templateId;

  AnalyticsScheduleEventEvent({
    required this.communityId,
    required this.eventId,
    required this.daysFromNow,
    this.templateId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsScheduleEventEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.eventCategory;
  }

  @override
  String? getEventName() {
    return eventId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsEditEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'edit_event';
  }

  final String communityId;
  final String eventId;
  final String? templateId;

  AnalyticsEditEventEvent({
    required this.communityId,
    required this.eventId,
    this.templateId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsEditEventEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.eventCategory;
  }

  @override
  String? getEventName() {
    return eventId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsPressShareEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_share_event';
  }

  final String communityId;
  final String eventId;
  final String? templateId;
  final ShareType shareType;

  AnalyticsPressShareEventEvent({
    required this.communityId,
    required this.eventId,
    this.templateId,
    required this.shareType,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsPressShareEventEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.eventCategory;
  }

  @override
  String? getEventName() {
    return eventId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsEnterEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'enter_event';
  }

  final String communityId;
  final String eventId;
  final bool asHost;
  final String? templateId;

  AnalyticsEnterEventEvent({
    required this.communityId,
    required this.eventId,
    required this.asHost,
    this.templateId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsEnterEventEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.eventCategory;
  }

  @override
  String? getEventName() {
    return eventId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsCompleteEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'complete_event';
  }

  final String communityId;
  final String eventId;
  final bool asHost;
  final int duration;
  final String? templateId;

  AnalyticsCompleteEventEvent({
    required this.communityId,
    required this.eventId,
    required this.asHost,
    required this.duration,
    this.templateId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsCompleteEventEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.eventCategory;
  }

  @override
  String? getEventName() {
    return eventId;
  }

  @override
  num? getMetricValue() {
    return duration;
  }
}

@JsonSerializable()
class AnalyticsPressEventHelpEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_event_help';
  }

  final String communityId;
  final String eventId;
  final bool asHost;
  final String? templateId;

  AnalyticsPressEventHelpEvent({
    required this.communityId,
    required this.eventId,
    required this.asHost,
    this.templateId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsPressEventHelpEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.eventCategory;
  }

  @override
  String? getEventName() {
    return eventId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsRsvpEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'rsvp_event';
  }

  final String communityId;
  final String eventId;
  final String? templateId;

  AnalyticsRsvpEventEvent({
    required this.communityId,
    required this.eventId,
    this.templateId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsRsvpEventEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.eventCategory;
  }

  @override
  String? getEventName() {
    return eventId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsDonateEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'donate';
  }

  final String communityId;
  final double amount;

  AnalyticsDonateEvent({
    required this.communityId,
    required this.amount,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsDonateEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.communityCategory;
  }

  @override
  String? getEventName() {
    return communityId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}

@JsonSerializable()
class AnalyticsUpdateCommunitySubscriptionEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'update_community_subscription';
  }

  final String? communityId;
  final String planType;
  final String subscriptionId;
  final bool isCanceled;

  AnalyticsUpdateCommunitySubscriptionEvent({
    required this.communityId,
    required this.planType,
    required this.subscriptionId,
    required this.isCanceled,
  });

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsUpdateCommunitySubscriptionEventToJson(this);

  @override
  String getEventCategory() {
    return AnalyticsEvent.communityCategory;
  }

  @override
  String? getEventName() {
    return communityId;
  }

  @override
  num? getMetricValue() {
    return null;
  }
}
