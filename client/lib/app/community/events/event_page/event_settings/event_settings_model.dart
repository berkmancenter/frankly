import 'package:client/app/community/events/event_page/event_settings/event_settings_drawer.dart';
import 'package:data_models/events/event.dart';

class EventSettingsModel {
  final EventSettingsDrawerType eventSettingsDrawerType;
  late final String title;
  late final EventSettings initialEventSettings;
  late EventSettings eventSettings;
  late final EventSettings defaultSettings;

  EventSettingsModel(this.eventSettingsDrawerType);
}
