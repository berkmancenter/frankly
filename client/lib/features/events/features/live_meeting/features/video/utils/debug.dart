import 'package:client/services.dart';

class Debug {
  static final Debug _debug = Debug._internal();

  factory Debug() {
    return _debug;
  }

  Debug._internal();

  static var enabled = false;

  static void log(dynamic message) {
    if (enabled) {
      loggingService.log('[ APPDEBUG ] $message');
    }
    if (message is Error) {
      loggingService.log(
        'Error during conference',
        error: message,
        stackTrace: message.stackTrace,
      );
    }
  }
}
