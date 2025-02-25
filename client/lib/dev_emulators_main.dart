import 'package:client/config/environment.dart';
import 'package:client/app.dart';
import 'package:client/core/data/services/cloud_functions.dart';
import 'package:client/core/data/services/firestore_database.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
//import 'package:logging/logging.dart' as lg;
//import 'package:super_editor/super_editor.dart';

void main() async {
  loggingService.log('Running in dev emulator mode');

  const emulatorArg = Environment.enableEmulators;
  List<String> emulators = emulatorArg.split(',');
  for (var emulator in emulators) {
    switch (emulator) {
      case ('functions'):
        loggingService.log('Enabling functions emulator');
        CloudFunctions.usingEmulator = true;
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

  /** TODO remove this - just showing you to configure SuperEditor loggers if you need them */
  /** 
  initLoggers(lg.Level.FINEST, {
    editorGesturesLog,
    // editorImeLog,
    // editorKeyLog,
    // editorOpsLog,
    // editorLayoutLog,
    editorPoliciesLog,
    editorDocLog,
    // editorStyleLog,
    // textFieldLog,
  });
*/
  await runClient();
}
