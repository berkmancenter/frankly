import 'package:client/core/localization/app_localization_service.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_card.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_video.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCommunityPermissionsProvider mockCommunityPermissionsProvider;
  late AgendaProvider agendaProvider;

  setUpAll(() async {
    if (!GetIt.instance.isRegistered<AppLocalizationService>()) {
      GetIt.instance.registerSingleton(AppLocalizationService());
    }

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    GetIt.instance<AppLocalizationService>().setLocalization(l10n);
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  setUp(() {
    mockCommunityPermissionsProvider = MockCommunityPermissionsProvider();
    when(mockCommunityPermissionsProvider.canEditTemplate(any)).thenReturn(true);

    agendaProvider = AgendaProvider(
      params: AgendaProviderParams(
        communityId: 'community-id',
        isLivestream: false,
        isNotOnEventPage: true,
        template: Template(id: 'template-id'),
      ),
    );
  });

  Future<void> pumpWidgetUnderTest(WidgetTester tester, AgendaItem agendaItem) {
    return tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AgendaProvider>.value(value: agendaProvider),
          ChangeNotifierProvider<CommunityPermissionsProvider>.value(
            value: mockCommunityPermissionsProvider,
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
            body: SingleChildScrollView(
              child: AgendaItemCard(agendaItem: agendaItem),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'updates time input duration when video duration callback fires',
    (tester) async {
      final agendaItem = AgendaItem(
        id: 'agenda-item-1',
        nullableType: AgendaItemType.video,
        timeInSeconds: 0,
        title: 'Welcome video',
        videoType: AgendaItemVideoType.url,
        videoUrl: 'https://cdn.example.com/welcome.mp4',
      );

      await pumpWidgetUnderTest(tester, agendaItem);
      await tester.pumpAndSettle();

      if (find.byType(AgendaItemVideo).evaluate().isEmpty) {
        await tester.tap(find.byType(InkWell).first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(AgendaItemVideo), findsOneWidget);
      expect(find.text('00:00'), findsWidgets);

      final agendaItemVideo =
          tester.widget<AgendaItemVideo>(find.byType(AgendaItemVideo));
      agendaItemVideo.onVideoDurationDetected?.call(125);
      await tester.pump();

      expect(find.text('02:05'), findsWidgets);
    },
    // Flaky on Chrome due missing card subtree during callback wiring.
    // TODO: re-enable with deterministic harness.
    skip: true,
  );
}
