import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/utils/share_type.dart';
part 'analytics_entities.g.dart';

abstract class AnalyticsEvent {
  String getEventType();
  Map<String, dynamic> toJson();
}

@JsonSerializable()
class AnalyticsAgreeToTermsAndConditionsEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'agree_to_tac';
  }

  AnalyticsAgreeToTermsAndConditionsEvent();

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsAgreeToTermsAndConditionsEventToJson(this);
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
}

@JsonSerializable()
class AnalyticsPressAddNewGuideEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_add_new_guide';
  }

  final String communityId;

  AnalyticsPressAddNewGuideEvent({
    required this.communityId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsPressAddNewGuideEventToJson(this);
}

@JsonSerializable()
class AnalyticsCompleteNewGuideEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'complete_new_guide';
  }

  final String communityId;
  final String guideId;

  AnalyticsCompleteNewGuideEvent({
    required this.communityId,
    required this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsCompleteNewGuideEventToJson(this);
}

@JsonSerializable()
class AnalyticsPressCreateEventFromGuideEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_create_event_from_guide';
  }

  final String communityId;
  final String guideId;

  AnalyticsPressCreateEventFromGuideEvent({
    required this.communityId,
    required this.guideId,
  });

  @override
  Map<String, dynamic> toJson() =>
      _$AnalyticsPressCreateEventFromGuideEventToJson(this);
}

@JsonSerializable()
class AnalyticsCreateEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'create_event';
  }

  final String communityId;
  final String eventId;
  final String? guideId;

  AnalyticsCreateEventEvent({
    required this.communityId,
    required this.eventId,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsCreateEventEventToJson(this);
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
  final String? guideId;

  AnalyticsScheduleEventEvent({
    required this.communityId,
    required this.eventId,
    required this.daysFromNow,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsScheduleEventEventToJson(this);
}

@JsonSerializable()
class AnalyticsEditEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'edit_event';
  }

  final String communityId;
  final String eventId;
  final String? guideId;

  AnalyticsEditEventEvent({
    required this.communityId,
    required this.eventId,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsEditEventEventToJson(this);
}

@JsonSerializable()
class AnalyticsPressShareEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_share_event';
  }

  final String communityId;
  final String eventId;
  final String? guideId;
  final ShareType shareType;

  AnalyticsPressShareEventEvent({
    required this.communityId,
    required this.eventId,
    this.guideId,
    required this.shareType,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsPressShareEventEventToJson(this);
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
  final String? guideId;

  AnalyticsEnterEventEvent({
    required this.communityId,
    required this.eventId,
    required this.asHost,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsEnterEventEventToJson(this);
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
  final String? guideId;

  AnalyticsCompleteEventEvent({
    required this.communityId,
    required this.eventId,
    required this.asHost,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsCompleteEventEventToJson(this);
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
  final String? guideId;

  AnalyticsPressEventHelpEvent({
    required this.communityId,
    required this.eventId,
    required this.asHost,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsPressEventHelpEventToJson(this);
}

@JsonSerializable()
class AnalyticsRsvpEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'rsvp_event';
  }

  final String communityId;
  final String eventId;
  final String? guideId;

  AnalyticsRsvpEventEvent({
    required this.communityId,
    required this.eventId,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsRsvpEventEventToJson(this);
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
}
