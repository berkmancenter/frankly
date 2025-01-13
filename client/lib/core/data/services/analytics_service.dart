import 'package:data_models/analytics/analytics_entities.dart';

/// Trait names in Segment; avoid modifying existing names as it will break data continuity
enum UserAnalyticsProperty {
  email,
  displayName,
}

/// Manages our Segment integration
class AnalyticsService {
  /// Call to track a user event
  void logEvent(AnalyticsEvent event) {
    // Disabling segment by not sending events here rather than removing the log events
    // everywhere that we log them.
  }
}
