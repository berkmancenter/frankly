import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:matomo_tracker/matomo_tracker.dart';

class AnalyticsService {
  bool enableMatomo = Environment.matomoURL != '';

  Future<void> initialize() async {
    if (enableMatomo && !MatomoTracker.instance.initialized) {
      await MatomoTracker.instance.initialize(
        siteId: Environment.matomoSiteId,
        url: Environment.matomoURL,
        cookieless: true,
      );
    }
  }

  /// Call to track a user event
  void logEvent(AnalyticsEvent event) {
    if (!enableMatomo) return;

    final eventProps = event.toJson();
    final communityId = eventProps['communityId'];
    final eventId = eventProps['eventId'];
    final templateId = eventProps['guideId'];

    // TODO unclear if any reason to make event a dimension but community and user def
    final dimensions = {
      if (eventId != null) 'dimension2': eventId.toString(),
      if (communityId != null) 'dimension1': communityId.toString(),
      if (userService.currentUserId != null)
        'dimension3': userService.currentUserId!,
    };

    MatomoTracker.instance.trackEvent(
      eventInfo: EventInfo(
        category: event.getEventCategory(),
        action: event.getEventType(),
        name: eventProps['name'] ?? eventId ?? templateId ?? communityId,
        value: eventProps['value'],
      ),
      dimensions: dimensions,
    );
  }
}
