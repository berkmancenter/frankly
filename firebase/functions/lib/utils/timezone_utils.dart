import 'package:timezone/data/latest_all.dart';
import 'package:timezone/standalone.dart' as tz;

TimezoneUtils get timezoneUtils => TimezoneUtils();

class TimezoneUtils {
  static TimezoneUtils? _timezoneUtils;

  factory TimezoneUtils() => _timezoneUtils ??= TimezoneUtils._();

  TimezoneUtils._() {
    initializeTimeZones();
  }

  tz.Location getLocation(String name) => tz.getLocation(name);

  tz.TZDateTime fromDateTime(DateTime datetime, tz.Location location) =>
      tz.TZDateTime.from(datetime, location);
}
