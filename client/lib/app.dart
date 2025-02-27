import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/config/environment.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/transitions.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:uuid/uuid.dart';

import 'config/firebase_options.dart';

bool kShowStripeFeatures = false;
bool useBotControls = false;
Map<String, String>? botJoinParameters;

// If a SENTRY_RELEASE is supplied via `--dart-define=SENTRY_RELEASE=whatever` on build, then
// we do Sentry reporting
const String sentryRelease =
    String.fromEnvironment('SENTRY_RELEASE', defaultValue: '');
bool enableSentry = sentryRelease != '';

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

Future<void> runClient({FirebaseOptions? firebaseOptions}) async {
  setURLPathStrategy();

  await Firebase.initializeApp(
    options: firebaseOptions ?? DefaultFirebaseOptions.currentPlatform,
  );

  if (enableSentry) {
    await Sentry.init(
      (options) => options
        ..dsn = Environment.sentryDSN
        ..environment = Environment.sentryEnvironment,
    );
  }

  FlutterError.onError = (details) {
    reportError(details.exception, details.stack);
  };

  runZonedGuarded(
    () => runApp(App()),
    (error, stackTrace) {
      reportError(error, stackTrace);
    },
  );
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
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
        ChangeNotifierProvider.value(value: userDataService),
        ChangeNotifierProvider.value(value: dialogProvider),
        Provider.value(value: firestoreDatabase),
        ChangeNotifierProvider(create: (_) => NavBarProvider()),
      ],
      child: Portal(
        child: MaterialApp.router(
          shortcuts: {
            ...WidgetsApp.defaultShortcuts,
            LogicalKeySet(LogicalKeyboardKey.space): ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
                DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.shift): DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowUp): DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowDown): DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowLeft): DoNothingIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowRight): DoNothingIntent(),
          },
          routerDelegate: routerDelegate,
          backButtonDispatcher:
              BeamerBackButtonDispatcher(delegate: routerDelegate),
          routeInformationParser: BeamerParser(),
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: AppColor.black,
            brightness: Brightness.light,
            colorScheme: ColorScheme(
              brightness: Brightness.light,
              primary: AppColor.black,
              onPrimary: AppColor.white,
              secondary: AppColor.white,
              primaryContainer: AppColor.gray900,
              onPrimaryContainer: AppColor.white,
              secondaryContainer: AppColor.gray600,
              onSecondaryContainer: AppColor.white,
              errorContainer: AppColor.red200,
              onErrorContainer: AppColor.red500,
              onSecondary: AppColor.black,
              error: AppColor.red200,
              onError: AppColor.white,
              surface: AppColor.gray50,
              surfaceDim: AppColor.gray400,
              onSurface: AppColor.black,
            ),
            pageTransitionsTheme: NoTransitionsOnWeb(),
          ),
          builder: (_, child) => UIMigration(
            child: child!,
          ),
        ),
      ),
    );
  }
}
