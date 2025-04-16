import 'package:client/features/events/features/event_page/presentation/views/event_settings_drawer.dart';
import 'package:data_models/events/event.dart';

class EventSettingsModel {
  final EventSettingsDrawerType eventSettingsDrawerType;
  late final String title;
  late final EventSettings initialEventSettings;
  late EventSettings eventSettings;
  late final EventSettings defaultSettings;

  EventSettingsModel(this.eventSettingsDrawerType);
}
