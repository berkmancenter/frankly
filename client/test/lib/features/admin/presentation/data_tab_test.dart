import 'package:client/core/data/services/clock_service.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/features/events/data/services/firestore_event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:client/features/admin/presentation/views/data_tab.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';

import '../../../../mocked_classes.mocks.dart';

@GenerateMocks([
  // BehaviorSubjectWrapper,
  CommunityProvider,
  Event,
])
void main() {
  final mockClockService = MockClockService();
  final mockCommunityProvider = MockCommunityProvider();
  final mockFirestoreEventService = FirestoreEventService();
   when(mockClockService.now()).thenReturn(DateTime.now());
  GetIt.instance.registerSingleton<ClockService>(mockClockService);
  GetIt.instance.registerSingleton<CommunityProvider>(mockCommunityProvider);
  GetIt.instance.registerSingleton<FirestoreEventService>(mockFirestoreEventService);

  late List<Event> mockAllEvents;
  
  setUp(() {
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
  });
  Widget createWidgetUnderTest() {
    return MaterialApp(
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
      await tester.pump();

      expect(find.byType(EmptyPageContent), findsOneWidget);
    });

    testWidgets('should display events list when events exist', (WidgetTester tester) async {

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Test Event 1'), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);
      expect(find.text('Hosted'), findsOneWidget);
    });

    testWidgets('should display pagination controls', (WidgetTester tester) async {
      // mockAllEvents is already set up in setUp() with 80 events

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(find.text('1 - 5 of 80'), findsOneWidget);
    });

    testWidgets('should navigate to next page when forward button pressed', (WidgetTester tester) async {
      // mockAllEvents is already set up in setUp() with 80 events

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pump();

      expect(find.text('6 - 10 of 80'), findsOneWidget);
    });
    testWidgets('should display correct livestream status icons', (WidgetTester tester) async {
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
    });

    testWidgets('should show private event correctly', (WidgetTester tester) async {
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
      await tester.pump();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Private'), findsOneWidget);
    });
  });
}
