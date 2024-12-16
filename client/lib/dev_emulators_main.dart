import 'package:client/environment.dart';
import 'package:client/app.dart';
import 'package:client/services/cloud_functions_service.dart';
import 'package:client/services/firestore/firestore_database.dart';
import 'package:client/services/logging_service.dart';
import 'package:client/services/services.dart';
import 'package:client/services/user_data_service.dart';
import 'package:client/services/user_service.dart';

void main() async {
  loggingService.log('Running in dev emulator mode');

  const emulatorArg = Environment.enableEmulators;
  List<String> emulators = emulatorArg.split(',');
  for (var emulator in emulators) {
    switch (emulator) {
      case ('functions'):
        loggingService.log('Enabling functions emulator');
        CloudFunctionsService.usingEmulator = true;
        break;
      case ('firestore'):
        loggingService.log('Enabling firestore emulator');
        FirestoreDatabase.usingEmulator = true;
        break;
      case ('auth'):
        loggingService.log('Enabling auth emulator');
        UserService.usingEmulator = true;
        break;
      case ('database'):
        loggingService.log('Enabling Realtime Database emulator');
        UserDataService.usingEmulator = true;
        break;
      default:
        loggingService.log(
          'Unsupported emulator type $emulator. Ignoring.',
          logType: LogType.warning,
        );
    }
  }

  await runClient();
}
