import 'package:client/core/localization/app_localization_service.dart';
import 'package:client/core/data/services/firestore_database.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/views/event_settings_drawer.dart';
import 'package:data_models/events/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAppDrawerProvider mockAppDrawerProvider;
  late MockCommunityProvider mockCommunityProvider;
  late MockEventProvider mockEventProvider;
  late MockFirestoreDatabase mockFirestoreDatabase;
  late MockEvent mockEvent;
  late MockTemplate mockTemplate;

  const settingsWithAutoEnd = EventSettings(
    autoEndMeeting: true,
    autoEndGracePeriodMinutes: 15,
    chat: true,
    showChatMessagesInRealTime: true,
    talkingTimer: true,
    agendaPreview: true,
  );

  setUpAll(() async {
    GetIt.instance.registerSingleton(AppLocalizationService());
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    GetIt.instance<AppLocalizationService>().setLocalization(l10n);
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  setUp(() {
    mockAppDrawerProvider = MockAppDrawerProvider();
    mockCommunityProvider = MockCommunityProvider();
    mockEventProvider = MockEventProvider();
    mockFirestoreDatabase = MockFirestoreDatabase();
    mockEvent = MockEvent();
    mockTemplate = MockTemplate();

    GetIt.instance.registerSingleton<FirestoreDatabase>(mockFirestoreDatabase);

    when(mockCommunityProvider.eventSettings)
        .thenReturn(EventSettings.defaultSettings);
    when(mockEventProvider.event).thenReturn(mockEvent);
    when(mockEvent.eventSettings).thenReturn(settingsWithAutoEnd);
    when(mockEvent.templateId).thenReturn('misc');
    when(mockEventProvider.template).thenReturn(mockTemplate);
    when(mockTemplate.eventSettings)
        .thenReturn(EventSettings.defaultSettings);
  });

  tearDown(() {
    GetIt.instance.unregister<FirestoreDatabase>();
    reset(mockAppDrawerProvider);
    reset(mockCommunityProvider);
    reset(mockEventProvider);
    reset(mockFirestoreDatabase);
    reset(mockEvent);
    reset(mockTemplate);
  });

  Widget buildDrawer() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppDrawerProvider>.value(
          value: mockAppDrawerProvider,
        ),
        ChangeNotifierProvider<CommunityProvider>.value(
          value: mockCommunityProvider,
        ),
        ChangeNotifierProvider<EventProvider>.value(
          value: mockEventProvider,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: EventSettingsDrawer(
            eventSettingsDrawerType: EventSettingsDrawerType.event,
          ),
        ),
      ),
    );
  }

  Finder findGracePeriodField() {
    return find.byType(TextFormField);
  }

  Finder findGracePeriodTextField() {
    return find.byType(TextField);
  }

  void setLargeScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Suppress pre-existing RenderFlex overflow errors in the drawer layout.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);
  }

  group('grace period input', () {
    testWidgets('shows initial value from event settings', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildDrawer());
      await tester.pumpAndSettle();

      expect(findGracePeriodField(), findsOneWidget);
      final textField = tester.widget<TextField>(findGracePeriodTextField());
      expect(textField.controller!.text, equals('15'));
    });

    testWidgets('retains focus while typing valid values', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildDrawer());
      await tester.pumpAndSettle();

      final field = findGracePeriodField();
      await tester.tap(field);
      await tester.pump();

      // Clear and type a new value.
      await tester.enterText(field, '30');
      await tester.pump();

      // The field should still have focus.
      final textField = tester.widget<TextField>(findGracePeriodTextField());
      expect(textField.focusNode!.hasFocus, isTrue);
    });

    testWidgets('shows error styling for out-of-range input', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildDrawer());
      await tester.pumpAndSettle();

      final field = findGracePeriodField();
      await tester.tap(field);
      await tester.pump();

      await tester.enterText(field, '999');
      await tester.pump();

      // The error path sets enabledBorder explicitly.
      final textField = tester.widget<TextField>(findGracePeriodTextField());
      expect(textField.decoration!.enabledBorder, isA<OutlineInputBorder>());
    });

    testWidgets('auto-corrects after debounce timeout', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildDrawer());
      await tester.pumpAndSettle();

      final field = findGracePeriodField();
      await tester.tap(field);
      await tester.pump();

      await tester.enterText(field, '999');
      await tester.pump();

      // Wait for the 1-second debounce.
      await tester.pump(const Duration(seconds: 1));

      final textField = tester.widget<TextField>(findGracePeriodTextField());
      expect(textField.controller!.text, equals('120'));
    });

    testWidgets('auto-corrects negative value to 0', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildDrawer());
      await tester.pumpAndSettle();

      final field = findGracePeriodField();
      await tester.tap(field);
      await tester.pump();

      await tester.enterText(field, '-5');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final textField = tester.widget<TextField>(findGracePeriodTextField());
      expect(textField.controller!.text, equals('0'));
    });

    testWidgets('auto-corrects on focus loss', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildDrawer());
      await tester.pumpAndSettle();

      final field = findGracePeriodField();
      await tester.tap(field);
      await tester.pump();

      await tester.enterText(field, '200');
      await tester.pump();

      // Tap elsewhere to lose focus.
      await tester.tapAt(Offset.zero);
      await tester.pump();

      final textField = tester.widget<TextField>(findGracePeriodTextField());
      expect(textField.controller!.text, equals('120'));
    });

    testWidgets('clears error styling after auto-correction', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildDrawer());
      await tester.pumpAndSettle();

      final field = findGracePeriodField();
      await tester.tap(field);
      await tester.pump();

      await tester.enterText(field, 'abc');
      await tester.pump();

      // Verify error state.
      var tf = tester.widget<TextField>(findGracePeriodTextField());
      expect(tf.decoration!.enabledBorder, isA<OutlineInputBorder>());

      // Wait for debounce auto-correction.
      await tester.pump(const Duration(seconds: 1));

      tf = tester.widget<TextField>(findGracePeriodTextField());
      expect(tf.decoration!.enabledBorder, isNull);
      expect(tf.controller!.text, equals('0'));
    });
  });
}
