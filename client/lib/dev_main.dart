import 'package:firebase_core/firebase_core.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/services.dart';

void main() {
  isDev = true;
  loggingService.log('main: Running in dev mode');
  runJunto(
    firebaseOptions: FirebaseOptions(
      apiKey: 'AIzaSyByhTE9Z2AbE3uNpo171ffS-f1TI3M25mU',
      appId: '1:12851330326:web:585837588dbf7a0f5da437',
      messagingSenderId: '12851330326',
      projectId: 'gen-hls-bkc-7627',
      authDomain: 'gen-hls-bkc-7627.web.app',
      databaseURL: 'https://gen-hls-bkc-7627-default-rtdb.firebaseio.com',
      storageBucket: 'gen-hls-bkc-7627.appspot.com',
      measurementId: 'G-185Y8008N8',
    )
  );
}
