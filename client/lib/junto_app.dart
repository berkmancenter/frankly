import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_transitions.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

bool isDev = false;
bool kShowStripeFeatures = false;
bool useBotControls = false;
Map<String, String>? botJoinParameters;

// If a SENTRY_RELEASE is supplied via `--dart-define=SENTRY_RELEASE=whatever` on build, then
// we do Sentry reporting
const String sentryRelease = String.fromEnvironment('SENTRY_RELEASE', defaultValue: '');
bool enableSentry = sentryRelease != '';

NavigatorState get navigatorState => routerDelegate.navigatorKey.currentState!;

final uuid = Uuid();

Future<void> reportError(dynamic error, dynamic stackTrace) async {
  loggingService.log(
    'reportError: error',
    logType: LogType.error,
    error: error,
    stackTrace: stackTrace,
  );

  if (enableSentry) {
    // Send the Exception and Stacktrace to the indicated Sentry dsn
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
    );
  }
}

Future<void> runJunto({FirebaseOptions? firebaseOptions}) async {
  setURLPathStrategy();

  await Firebase.initializeApp(
    options: firebaseOptions ?? DefaultFirebaseOptions.currentPlatform,
  );

  if (enableSentry) {
    await Sentry.init((options) => options
      ..dsn =
          'https://c658d2850c821c3f1988de6c82754037@o4507534547156992.ingest.us.sentry.io/4507765645574144'
      ..environment = isDev ? 'staging' : 'production');
  }

  FlutterError.onError = (details) {
    reportError(details.exception, details.stack);
  };

  runZonedGuarded(
    () => runApp(JuntoApp()),
    (error, stackTrace) {
      reportError(error, stackTrace);
    },
  );
}

class JuntoApp extends StatefulWidget {
  @override
  _JuntoAppState createState() => _JuntoAppState();
}

class _JuntoAppState extends State<JuntoApp> {
  @override
  void initState() {
    super.initState();

    initializeTimezones();

    createServices();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userService),
        ChangeNotifierProvider.value(value: juntoUserDataService),
        ChangeNotifierProvider.value(value: dialogProvider),
        Provider.value(value: firestoreDatabase),
        ChangeNotifierProvider(create: (_) => NavBarProvider()),
      ],
      child: Portal(
        child: MaterialApp.router(
          shortcuts: {
            ...WidgetsApp.defaultShortcuts,
            LogicalKeySet(LogicalKeyboardKey.space): ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.shift): DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowUp): DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowDown): DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowLeft): DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowRight): DoNothingIntent(),
          },
          routerDelegate: routerDelegate,
          backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
          routeInformationParser: BeamerParser(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColor.darkBlue,
              secondary: AppColor.brightGreen,
            ),
            pageTransitionsTheme: NoTransitionsOnWeb(),
          ),
          builder: (_, child) => JuntoUiMigration(
            whiteBackground: true,
            child: child!,
          ),
        ),
      ),
    );
  }
}
