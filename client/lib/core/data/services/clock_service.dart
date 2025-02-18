import 'package:client/core/utils/error_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:pedantic/pedantic.dart';

class ClockService {
  static const Duration _systemClockAllowedOffset = Duration(seconds: 30);
  static const Duration _maxAllowedFlightTime = Duration(seconds: 15);

  DateTime? _serverTime;
  Stopwatch? _elapsedStopwatch;

  Future<void> initialize() async {
    unawaited(swallowErrors(() => _loadTime()));
  }

  Future<void> _loadTime() async {
    final deviceAppStartTime = DateTime.now().toUtc();
    final stopwatch = Stopwatch()..start();

    final serverTimestamp = await getServerTimestamp();

    /// In cloud functions there may have been some cold start so the server time might have some
    /// offset from our initial call in addition to latency.
    ///
    /// Two methods of adjusting for that latency are subtracting the entire flightTime or
    /// sutracting half of the flight time to offset for latency.
    ///
    /// Subtracting the entire flight time makes sense when there is a lot of cold start.
    final flightTime = stopwatch.elapsed.inMilliseconds;
    final serverAppStartTimeMidpoint = serverTimestamp.subtract(
      Duration(
        milliseconds: (flightTime / 2).round(),
      ),
    );

    loggingService.log('DeviceStartTime: $deviceAppStartTime');
    loggingService.log('ServerTimestamp: $serverTimestamp');
    loggingService
        .log('ServerAppStartTimeMidpoint: $serverAppStartTimeMidpoint');

    final offsetFromServer =
        serverAppStartTimeMidpoint.difference(deviceAppStartTime);

    final useServerTime = flightTime < _maxAllowedFlightTime.inMilliseconds &&
        offsetFromServer.abs() > _systemClockAllowedOffset;
    if (useServerTime) {
      loggingService
          .log('Replacing device time with time retrieved from server');
      _serverTime = serverTimestamp;
      _elapsedStopwatch = stopwatch;
    } else {
      stopwatch.stop();
    }
  }

  Future<DateTime> getServerTimestamp() async {
    final result = await cloudFunctions.callFunction(
      'GetServerTimestamp',
      GetServerTimestampRequest().toJson(),
    );

    return GetServerTimestampResponse.fromJson(result).serverTimestamp;
  }

  DateTime now() {
    final localServerTime = _serverTime;
    final localStopwatch = _elapsedStopwatch;
    if (localServerTime != null && localStopwatch != null) {
      final localTime = localServerTime.add(localStopwatch.elapsed).toLocal();
      return localTime;
    }

    return DateTime.now();
  }
}
