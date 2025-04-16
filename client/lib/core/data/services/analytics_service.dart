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
        dispatchSettings: const DispatchSettings.persistent(),
      );
    }
  }

  /// Call to track a user event
  void logEvent(AnalyticsEvent event) {
    if (!enableMatomo) return;

    final eventProps = event.toJson();
    final communityId = eventProps['communityId'];

    final dimensions = {
      if (communityId != null) 'dimension1': communityId.toString(),
      if (userService.currentUserId != null)
        'dimension3': userService.currentUserId!,
    };

    MatomoTracker.instance.trackEvent(
      eventInfo: EventInfo(
        category: event.getEventCategory(),
        action: event.getEventType(),
        name: event.getEventName(),
        value: event.getMetricValue(),
      ),
      dimensions: dimensions,
    );
  }
}
