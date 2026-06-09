import 'package:client/core/data/services/clock_service.dart';
import 'package:client/core/localization/app_localization_service.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/waiting_room.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/services.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/media_item.dart';
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

  final mockClockService = MockClockService();
  final mockCommunityProvider = MockCommunityProvider();
  final mockEventProvider = MockEventProvider();
  final mockLiveMeetingProvider = MockLiveMeetingProvider();

  late Event event;
  late Widget capturedVideoWidget;
  late String capturedVideoUrl;
  late Duration? capturedStartOffset;
  late VoidCallback? capturedOnEnded;

  setUpAll(() async {
    if (!services.isRegistered<ClockService>()) {
      services.registerSingleton<ClockService>(mockClockService);
    }
    if (!services.isRegistered<AppLocalizationService>()) {
      services.registerSingleton(AppLocalizationService());
    }
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    appLocalizationService.setLocalization(l10n);
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  setUp(() {
    event = Event(
      id: 'event-id',
      status: EventStatus.active,
      collectionPath: 'communities/community-id/events',
      communityId: 'community-id',
      templateId: 'template-id',
      creatorId: 'creator-id',
      scheduledTime: DateTime.utc(2026, 6, 8, 12, 0, 10),
      waitingRoomInfo: WaitingRoomInfo(
        waitingMediaItem: MediaItem(
          type: MediaType.video,
          url: 'https://example.com/waiting.mp4',
        ),
        introMediaItem: MediaItem(
          type: MediaType.video,
          url: 'https://example.com/intro.mp4',
        ),
      ),
    );

    when(mockClockService.now()).thenReturn(
      DateTime.utc(2026, 6, 8, 12, 0, 0),
    );
    when(mockCommunityProvider.community).thenReturn(
      Community(
        id: 'community-id',
        profileImageUrl: 'https://example.com/community.png',
      ),
    );
    when(mockEventProvider.event).thenReturn(event);
    when(mockEventProvider.eventParticipants).thenReturn([]);
    when(mockLiveMeetingProvider.breakoutsActive).thenReturn(false);

    capturedVideoUrl = '';
    capturedStartOffset = null;
    capturedOnEnded = null;
    capturedVideoWidget = const SizedBox.shrink();
  });

  tearDown(() {
    reset(mockClockService);
    reset(mockCommunityProvider);
    reset(mockEventProvider);
    reset(mockLiveMeetingProvider);
  });

  testWidgets(
    'waiting room keeps waiting-phase callback captured and still starts intro after the waiting video ends',
    (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CommunityProvider>(
              create: (_) => mockCommunityProvider,
            ),
            ChangeNotifierProvider<EventProvider>(
              create: (_) => mockEventProvider,
            ),
            ChangeNotifierProvider<LiveMeetingProvider>(
              create: (_) => mockLiveMeetingProvider,
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
            home: WaitingRoom(
              videoPlayerBuilder: ({
                required String url,
                required bool isIntroMedia,
                required bool loop,
                required Duration? videoStartOffset,
                required VoidCallback? onReady,
                required VoidCallback? onEnded,
              }) {
                capturedVideoUrl = url;
                capturedStartOffset = videoStartOffset;
                capturedOnEnded = onEnded;
                capturedVideoWidget = Container(
                  key: ValueKey(url),
                  child: Text(url),
                );
                return capturedVideoWidget;
              },
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('https://example.com/waiting.mp4')),
        findsOneWidget,
      );
      expect(capturedVideoUrl, 'https://example.com/waiting.mp4');
      expect(capturedStartOffset, isNull);
      expect(capturedOnEnded, isNotNull);

      when(mockClockService.now()).thenReturn(
        DateTime.utc(2026, 6, 8, 12, 0, 15),
      );
      capturedOnEnded!();
      await tester.pump();

      expect(
        find.byKey(const ValueKey('https://example.com/intro.mp4')),
        findsOneWidget,
      );
      expect(capturedVideoUrl, 'https://example.com/intro.mp4');
      expect(capturedStartOffset, const Duration(seconds: 5));
      expect(
        find.byKey(const ValueKey('https://example.com/community.png')),
        findsNothing,
      );
    },
  );
}
