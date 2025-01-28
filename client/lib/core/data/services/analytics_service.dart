import 'package:data_models/analytics/analytics_entities.dart';
import 'package:client/services.dart';
import 'dart:js_interop';

/// Trait names in Segment; avoid modifying existing names as it will break data continuity
enum UserAnalyticsProperty {
  email,
  displayName,
}

@JS('plausible')
external void _plausible(String eventName, [JSAny? eventData]);

/// Manages our Segment integration
class AnalyticsService {
  /// Call to track a user event
  void logEvent(AnalyticsEvent event) {
    _trackEvent(
      event.getEventType(),
      props: event.toJson(),
    );
  }

  void _trackEvent(String eventName, {Map<String, dynamic>? props}) {
    try {
      if (props != null) {
        loggingService.log('Analytics Event $eventName with some props $props');
        _plausible(eventName, props.jsify());
      } else {
        loggingService.log('Analytics Event $eventName');
        _plausible(eventName);
      }
    } catch (e) {
      loggingService.log('Failed to track event: $e');
    }
  }
}
