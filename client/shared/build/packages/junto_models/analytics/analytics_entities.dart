import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/analytics/share_type.dart';
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
  Map<String, dynamic> toJson() => _$AnalyticsAgreeToTermsAndConditionsEventToJson(this);
}

@JsonSerializable()
class AnalyticsLinkStripeAccountEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'link_stripe_account';
  }

  AnalyticsLinkStripeAccountEvent();

  @override
  Map<String, dynamic> toJson() => _$AnalyticsLinkStripeAccountEventToJson(this);
}

@JsonSerializable()
class AnalyticsCreateJuntoEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'create_junto';
  }

  final String juntoId;

  AnalyticsCreateJuntoEvent({
    required this.juntoId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsCreateJuntoEventToJson(this);
}

@JsonSerializable()
class AnalyticsUpdateJuntoImageEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'update_junto_image';
  }

  final String juntoId;

  AnalyticsUpdateJuntoImageEvent({
    required this.juntoId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsUpdateJuntoImageEventToJson(this);
}

@JsonSerializable()
class AnalyticsUpdateJuntoMetadataEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'update_junto_metadata';
  }

  final String juntoId;

  AnalyticsUpdateJuntoMetadataEvent({
    required this.juntoId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsUpdateJuntoMetadataEventToJson(this);
}

@JsonSerializable()
class AnalyticsPressShareJuntoLinkEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_share_junto_link';
  }

  final String juntoId;
  final ShareType shareType;

  AnalyticsPressShareJuntoLinkEvent({
    required this.juntoId,
    required this.shareType,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsPressShareJuntoLinkEventToJson(this);
}

@JsonSerializable()
class AnalyticsPressAddNewGuideEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_add_new_guide';
  }

  final String juntoId;

  AnalyticsPressAddNewGuideEvent({
    required this.juntoId,
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

  final String juntoId;
  final String guideId;

  AnalyticsCompleteNewGuideEvent({
    required this.juntoId,
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

  final String juntoId;
  final String guideId;

  AnalyticsPressCreateEventFromGuideEvent({
    required this.juntoId,
    required this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsPressCreateEventFromGuideEventToJson(this);
}

@JsonSerializable()
class AnalyticsCreateEventEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'create_event';
  }

  final String juntoId;
  final String discussionId;
  final String? guideId;

  AnalyticsCreateEventEvent({
    required this.juntoId,
    required this.discussionId,
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

  final String juntoId;
  final String discussionId;
  final int daysFromNow;
  final String? guideId;

  AnalyticsScheduleEventEvent({
    required this.juntoId,
    required this.discussionId,
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

  final String juntoId;
  final String discussionId;
  final String? guideId;

  AnalyticsEditEventEvent({
    required this.juntoId,
    required this.discussionId,
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

  final String juntoId;
  final String discussionId;
  final String? guideId;
  final ShareType shareType;

  AnalyticsPressShareEventEvent({
    required this.juntoId,
    required this.discussionId,
    this.guideId,
    required this.shareType,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsPressShareEventEventToJson(this);
}

@JsonSerializable()
class AnalyticsEnterDiscussionEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'enter_discussion';
  }

  final String juntoId;
  final String discussionId;
  final bool asHost;
  final String? guideId;

  AnalyticsEnterDiscussionEvent({
    required this.juntoId,
    required this.discussionId,
    required this.asHost,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsEnterDiscussionEventToJson(this);
}

@JsonSerializable()
class AnalyticsCompleteDiscussionEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'complete_discussion';
  }

  final String juntoId;
  final String discussionId;
  final bool asHost;
  final String? guideId;

  AnalyticsCompleteDiscussionEvent({
    required this.juntoId,
    required this.discussionId,
    required this.asHost,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsCompleteDiscussionEventToJson(this);
}

@JsonSerializable()
class AnalyticsPressDiscussionHelpEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'press_discussion_help';
  }

  final String juntoId;
  final String discussionId;
  final bool asHost;
  final String? guideId;

  AnalyticsPressDiscussionHelpEvent({
    required this.juntoId,
    required this.discussionId,
    required this.asHost,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsPressDiscussionHelpEventToJson(this);
}

@JsonSerializable()
class AnalyticsRsvpDiscussionEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'rsvp_discussion';
  }

  final String juntoId;
  final String discussionId;
  final String? guideId;

  AnalyticsRsvpDiscussionEvent({
    required this.juntoId,
    required this.discussionId,
    this.guideId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsRsvpDiscussionEventToJson(this);
}

@JsonSerializable()
class AnalyticsJoinJuntoEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'join_junto';
  }

  final String juntoId;

  AnalyticsJoinJuntoEvent({
    required this.juntoId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsJoinJuntoEventToJson(this);
}

@JsonSerializable()
class AnalyticsLeaveJuntoEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'leave_junto';
  }

  final String juntoId;

  AnalyticsLeaveJuntoEvent({
    required this.juntoId,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsLeaveJuntoEventToJson(this);
}

@JsonSerializable()
class AnalyticsDonateEvent implements AnalyticsEvent {
  @override
  String getEventType() {
    return 'donate';
  }

  final String juntoId;
  final double amount;

  AnalyticsDonateEvent({
    required this.juntoId,
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

  final String? juntoId;
  final String planType;
  final String subscriptionId;
  final bool isCanceled;

  AnalyticsUpdateCommunitySubscriptionEvent({
    required this.juntoId,
    required this.planType,
    required this.subscriptionId,
    required this.isCanceled,
  });

  @override
  Map<String, dynamic> toJson() => _$AnalyticsUpdateCommunitySubscriptionEventToJson(this);
}
