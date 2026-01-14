import 'dart:io';
import 'dart:ui';

import 'package:client/core/data/services/clock_service.dart';
import 'package:client/core/localization/app_localization_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/features/events/data/services/firestore_event_service.dart';
import 'package:client/core/data/services/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:client/features/admin/presentation/views/data_tab.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';

import 'data_tab_test.mocks.dart';

@GenerateMocks([
  // AppLocalizationService,
  BehaviorSubjectWrapper,
  ClockService,
  CommunityProvider,
  Event,
  FirestoreDatabase,
  FirestoreEventService,
])

// class MockAppLocalizationService extends Mock implements AppLocalizationService {}


void main() {

  // I don't want this test to run right now;
  // So I set this to true to skip all tests in this file,
  // but wanted to keep the code for future use
  const disabled =  true;

  // late MockAppLocalizationService mockAppLocalizationService;
  late MockClockService mockClockService;
  late MockCommunityProvider mockCommunityProvider;
  late MockFirestoreDatabase mockFirestoreDatabase;
  late MockFirestoreEventService mockFirestoreEventService;
  late List<Event> mockAllEvents;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });
  setUp(() {
    // Reset GetIt before each test
    GetIt.instance.reset();
    
    // Create fresh mocks for each test
    // mockAppLocalizationService = MockAppLocalizationService();
    mockClockService = MockClockService();
    mockCommunityProvider = MockCommunityProvider();
    mockFirestoreDatabase = MockFirestoreDatabase();
    mockFirestoreEventService = MockFirestoreEventService();
    mockCommunityProvider = MockCommunityProvider();
    mockFirestoreDatabase = MockFirestoreDatabase();
    mockFirestoreEventService = MockFirestoreEventService();

    // Set up mock behaviors
    when(mockClockService.now()).thenReturn(DateTime.now());
    when(mockClockService.now()).thenReturn(DateTime.now());
    when(mockCommunityProvider.communityId).thenReturn('fake-community-id');
    when(
      mockFirestoreEventService.communityEvents(
        communityId: 'fake-community-id',
      ),).thenAnswer((_) => BehaviorSubjectWrapper(Stream.value(mockAllEvents)));
    
    // Register services
    // GetIt.instance.registerSingleton<AppLocalizationService>(mockAppLocalizationService);
    GetIt.instance.registerSingleton<ClockService>(mockClockService);
    GetIt.instance.registerSingleton<FirestoreDatabase>(mockFirestoreDatabase);
    GetIt.instance.registerSingleton<FirestoreEventService>(mockFirestoreEventService);
    GetIt.instance.registerSingleton<CommunityProvider>(mockCommunityProvider);
    

    mockAllEvents = List.generate(
      80,
      (i) => Event(
        id: 'test-event-${i + 1}',
        title: 'Test Event ${i + 1}',
        scheduledTime: mockClockService.now().add(Duration(days: i)),
        communityId: mockCommunityProvider.communityId,
        status: EventStatus.active,
        isPublic: true,
        nullableEventType: [
          EventType.livestream,
          EventType.hosted,
          EventType.hostless,
        ][i % 3],
        collectionPath: '',
        templateId: 'test-template-id',
        creatorId: 'test-creator-id',
        eventSettings: EventSettings(),
      ),
    );
    // Mock the events to be returned by the service
    when(mockFirestoreEventService.getEventsFromPaths('fake-community-id', <String>['path1', 'path2'])).thenAnswer((_) async => mockAllEvents);
  });

  tearDown(() {
    // Clean up GetIt after each test
    GetIt.instance.reset();
  });
  
  Widget createWidgetUnderTest() {
    return MaterialApp(
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<CommunityProvider>(
        create: (_) => mockCommunityProvider,
        child: Scaffold(
          body: DataTab(),
        ),
      ),
    );
  }

  group('DataTab', () {
  testWidgets('should display empty page when no events',
        (WidgetTester tester) async {
      mockAllEvents = [];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(EmptyPageContent), findsOneWidget);
    }, skip: disabled,);

    testWidgets('should display events list when events exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.pumpAndSettle();

      expect(find.text('Test Event 1'), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);
      expect(find.text('Hosted'), findsOneWidget);
    }, skip: disabled,);

    testWidgets('should display pagination controls',
        (WidgetTester tester) async {
      // mockAllEvents is already set up in setUp() with 80 events

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(find.text('1 - 5 of 80'), findsOneWidget);
    }, skip: disabled,);

    testWidgets('should navigate to next page when forward button pressed',
        (WidgetTester tester) async {
      // mockAllEvents is already set up in setUp() with 80 events

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pump();

      expect(find.text('6 - 10 of 80'), findsOneWidget);
    }, skip: disabled,);
    testWidgets('should display correct livestream status icons',
        (WidgetTester tester) async {
      // Create a livestream event
      final livestreamEvent = Event(
        id: 'livestream-event-1',
        title: 'Livestream Event 1',
        scheduledTime: mockClockService.now(),
        communityId: mockCommunityProvider.communityId,
        status: EventStatus.active,
        isPublic: true,
        nullableEventType: EventType.livestream,
        collectionPath: '',
        templateId: 'test-template-id',
        creatorId: 'test-creator-id',
        eventSettings: EventSettings(),
      );
      mockAllEvents = [livestreamEvent];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.live_tv_outlined), findsOneWidget);
      expect(find.text('Livestream'), findsOneWidget);
    }, skip: disabled,);

    testWidgets('should show private event correctly',
        (WidgetTester tester) async {
      // Create a private event
      final privateEvent = Event(
        id: 'private-event-1',
        title: 'Private Event 1',
        scheduledTime: mockClockService.now(),
        communityId: mockCommunityProvider.communityId,
        status: EventStatus.active,
        isPublic: false,
        nullableEventType: EventType.hosted,
        collectionPath: '',
        templateId: 'test-template-id',
        creatorId: 'test-creator-id',
        eventSettings: EventSettings(),
      );
      mockAllEvents = [privateEvent];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Private'), findsOneWidget);
    }, skip: disabled,);
  });
}