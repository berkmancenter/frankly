import 'package:junto/junto_app.dart';
import 'package:logger/logger.dart';

enum LogType {
  debug,
  warning,
  error,
}

class LoggingService {
  final Logger _logger;

  LoggingService({Logger? logger})
      : _logger = logger ??
            Logger(
              filter: ProductionFilter(),
              printer: PrettyPrinter(
                printTime: true,
                methodCount: 0,
                errorMethodCount: 20,
              ),
              level: isDev ? Level.verbose : Level.error,
            );

  void log(
    Object message, {
    LogType logType = LogType.debug,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    switch (logType) {
      case LogType.debug:
        print(message);
        break;
      case LogType.warning:
        print(message);
        break;
      case LogType.error:
        _logger.e(message, error: error, stackTrace: stackTrace);
        break;
    }
  }
}
