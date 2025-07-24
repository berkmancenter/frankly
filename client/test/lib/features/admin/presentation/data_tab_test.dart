import 'package:client/core/widgets/empty_page_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:client/features/admin/presentation/views/data_tab.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';

import '../../../../mocked_classes.mocks.dart';

@GenerateMocks([
  BehaviorSubjectWrapper,
  CommunityProvider,
])
void main() {
  late List<MockEvent> mockAllEvents;
  late MockCommunityProvider mockCommunityProvider;

  setUp(() {
    mockAllEvents = List.generate(
          80,
          (i) => Event(
            id: 'test-event-${i + 1}',
            title: 'Test Event ${i + 1}',
            scheduledTime: clockService.now().add(Duration(days: i)),
            communityId: mockCommunityProvider.communityId,
            status: EventStatus.active,
            isPublic: true,
            nullableEventType: [EventType.livestream, EventType.hosted, EventType.hostless][i % 3],
            collectionPath: '',
            templateId: 'test-template-id',
            creatorId: 'test-creator-id',
            eventSettings: EventSettings(),
          ) as MockEvent,
        );

    mockCommunityProvider = MockCommunityProvider();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: DataTab(),
      ),
    );
  }

  group('EventsTab', () {
    testWidgets('should display empty page when no events', (WidgetTester tester) async {
      when(mockAllEvents).thenAnswer((_) => <MockEvent>[]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(EmptyPageContent), findsOneWidget);
    });

    testWidgets('should display events list when events exist', (WidgetTester tester) async {
      when(mockAllEvents).thenAnswer((_) => [mockAllEvents[0]]);
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Test Event 1'), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);
      expect(find.text('Hosted'), findsOneWidget);
    });

    testWidgets('should display pagination controls', (WidgetTester tester) async {
      when(mockAllEvents).thenAnswer((_) => mockAllEvents);
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(find.text('1 - 5 of 80'), findsOneWidget);
    });

    testWidgets('should navigate to next page when forward button pressed', (WidgetTester tester) async {
      when(mockAllEvents).thenAnswer((_) => mockAllEvents);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pump();

      expect(find.text('6 - 10 of 80'), findsOneWidget);
    });
    testWidgets('should display correct livestream status icons', (WidgetTester tester) async {
      when(mockAllEvents.where((event) => event.nullableEventType == EventType.livestream))
          .thenReturn([mockAllEvents[0]]);
 
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.live_tv_outlined), findsOneWidget);
      expect(find.text('Livestream'), findsOneWidget);
    });

    testWidgets('should show private event correctly', (WidgetTester tester) async {
      when(mockAllEvents.where((event) => !event.isPublic)).thenReturn([mockAllEvents[0]]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Private'), findsOneWidget);
    });
  });
}