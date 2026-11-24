import 'package:client/features/events/features/event_page/presentation/views/event_settings_drawer.dart';
import 'package:client/features/external_integrations/data/models/event_integration_change.dart';
import 'package:data_models/events/event.dart';

class EventSettingsModel {
  final EventSettingsDrawerType eventSettingsDrawerType;
  late final String title;
  late final EventSettings initialEventSettings;
  late EventSettings eventSettings;
  late final EventSettings defaultSettings;

  /// Unsaved external integration changes for this event, keyed by
  /// integration id. Written together with [eventSettings] on save.
  final Map<String, EventIntegrationChange> integrationChanges = {};

  EventSettingsModel(this.eventSettingsDrawerType);
}
