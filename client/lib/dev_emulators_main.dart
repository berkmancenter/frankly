import 'package:firebase_core/firebase_core.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/cloud_functions_service.dart';
import 'package:junto/services/firestore/firestore_database.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';

void main() async {
  isDev = true;
  loggingService.log('Running in dev emulator mode');

  const emulatorArg = String.fromEnvironment('EMULATORS', defaultValue: 'functions,firestore,auth');
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
      default:
        loggingService.log('Unsupported emulator type $emulator. Ignoring.',
            logType: LogType.warning);
    }
  }

  await runJunto(
      //Use to connect to "dev" environment
      firebaseOptions: FirebaseOptions(
    apiKey: 'AIzaSyByhTE9Z2AbE3uNpo171ffS-f1TI3M25mU',
    appId: '1:12851330326:web:585837588dbf7a0f5da437',
    messagingSenderId: '12851330326',
    projectId: 'gen-hls-bkc-7627',
    authDomain: 'gen-hls-bkc-7627.firebaseapp.com',
    databaseURL: 'https://gen-hls-bkc-7627-default-rtdb.firebaseio.com',
    storageBucket: 'gen-hls-bkc-7627.appspot.com',
    measurementId: 'G-185Y8008N8',
  ));
}
