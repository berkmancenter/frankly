import 'package:client/core/data/services/clock_service.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/features/events/data/services/cloud_functions_event_service.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../mocked_classes.mocks.dart';

void main() {
  final now = DateTime(2026, 1, 1, 12);
  final mockClockService = MockClockService();
  final mockEventService = MockCloudFunctionsEventService();
  final mockEventProvider = MockEventProvider();

  setUpAll(() {
    GetIt.instance
      ..registerSingleton<ClockService>(mockClockService)
      ..registerSingleton<CloudFunctionsEventService>(mockEventService);
  });

  tearDownAll(() async {
    await GetIt.instance.unregister<ClockService>();
    await GetIt.instance.unregister<CloudFunctionsEventService>();
  });

  setUp(() {
    reset(mockEventService);
    reset(mockEventProvider);
    when(mockClockService.now()).thenReturn(now);
  });

  LiveMeetingProvider buildProvider(Event event) {
    when(mockEventProvider.event).thenReturn(event);
    return LiveMeetingProvider(
      communityProvider: MockCommunityProvider(),
      eventProvider: mockEventProvider,
      navBarProvider: NavBarProvider(),
      showToast: (_, {hideOnMobile}) {},
    );
  }

  Event event({required DateTime scheduledTime, bool alwaysRecord = false}) =>
      Event(
        id: 'e1',
        collectionPath: 'community/c1/templates/t1/events',
        communityId: 'c1',
        templateId: 't1',
        creatorId: 'u1',
        status: EventStatus.active,
        scheduledTime: scheduledTime,
        eventSettings: EventSettings(alwaysRecord: alwaysRecord),
      );

  group('sendPostEventEmailIfDue', () {
    test('calls eventEnded once past the email threshold', () {
      final e = event(scheduledTime: now.subtract(Duration(minutes: 30)));
      buildProvider(e).sendPostEventEmailIfDue();

      final captured =
          verify(mockEventService.eventEnded(captureAny)).captured.single;
      expect(
        (captured as EventEndedRequest).eventPath,
        equals(e.fullPath),
      );
    });

    test('does not call eventEnded before threshold even when recording', () {
      // Leaving a recorded event must not trigger eventEnded.
      buildProvider(
        event(
          scheduledTime: now.subtract(Duration(minutes: 1)),
          alwaysRecord: true,
        ),
      ).sendPostEventEmailIfDue();

      verifyNever(mockEventService.eventEnded(any));
    });
  });
}
