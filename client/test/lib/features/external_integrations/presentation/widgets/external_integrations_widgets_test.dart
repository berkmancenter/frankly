import 'package:client/core/localization/app_localization_service.dart';
import 'package:client/features/external_integrations/data/services/external_integrations_service.dart';
import 'package:client/features/external_integrations/presentation/widgets/event_external_integrations_section.dart';
import 'package:client/features/external_integrations/presentation/widgets/recording_destination_notice.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/external_integrations/external_integration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakeExternalIntegrationsService extends ExternalIntegrationsService {
  List<ExternalIntegration> active = [];
  Map<String, EventExternalIntegrationSettings> settings = {};

  @override
  Stream<List<ExternalIntegration>> activeIntegrations(String communityId) =>
      Stream.value(active);

  @override
  Stream<Map<String, EventExternalIntegrationSettings>> eventSettings(
    Event event,
  ) =>
      Stream.value(settings);

  @override
  Stream<List<ExternalIntegration>> enabledIntegrationsForEvent(Event event) =>
      Stream.value(
        active.where((i) => settings[i.id]?.enabled ?? false).toList(),
      );
}

void main() {
  late AppLocalizations l10n;
  late _FakeExternalIntegrationsService service;

  final event = Event(
    id: 'e1',
    status: EventStatus.active,
    collectionPath: 'community/c1/templates/t1/events',
    communityId: 'c1',
    templateId: 't1',
    creatorId: 'host',
  );

  final integration = ExternalIntegration(
    id: 'int1',
    communityId: 'c1',
    displayName: 'Example Receiver',
    events: [ExternalIntegrationEventTypes.recordingReady],
  );

  setUpAll(() async {
    GetIt.instance.registerSingleton(AppLocalizationService());
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
    GetIt.instance<AppLocalizationService>().setLocalization(l10n);
  });

  setUp(() {
    service = _FakeExternalIntegrationsService();
    if (GetIt.instance.isRegistered<ExternalIntegrationsService>()) {
      GetIt.instance.unregister<ExternalIntegrationsService>();
    }
    GetIt.instance.registerSingleton<ExternalIntegrationsService>(service);
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
    await tester.pump();
  }

  group('RecordingDestinationNotice', () {
    testWidgets('shows nothing when no integration is configured',
        (tester) async {
      await pump(tester, RecordingDestinationNotice(event: event));
      expect(find.text(l10n.recordingsAreSentTo), findsNothing);
    });

    testWidgets('shows nothing when the integration is off for the event',
        (tester) async {
      service.active = [integration];
      await pump(tester, RecordingDestinationNotice(event: event));
      expect(find.text(l10n.recordingsAreSentTo), findsNothing);
    });

    testWidgets('names the integration when it is on for the event',
        (tester) async {
      service.active = [integration];
      service.settings = {
        'int1': EventExternalIntegrationSettings(
          integrationId: 'int1',
          enabled: true,
        ),
      };
      await pump(tester, RecordingDestinationNotice(event: event));
      expect(find.text(l10n.recordingsAreSentTo), findsOneWidget);
      expect(find.text('Example Receiver'), findsOneWidget);
    });
  });

  group('EventExternalIntegrationsSection', () {
    testWidgets('is hidden when the community has no active integration',
        (tester) async {
      await pump(tester, EventExternalIntegrationsSection(event: event));
      expect(find.text(l10n.eventIntegrationsTitle), findsNothing);
    });

    testWidgets('shows a toggle per integration and the reference field',
        (tester) async {
      service.active = [
        integration.copyWith(externalReferenceLabel: 'Project ID'),
      ];
      service.settings = {
        'int1': EventExternalIntegrationSettings(
          integrationId: 'int1',
          enabled: true,
          externalReference: 'p-42',
        ),
      };
      await pump(tester, EventExternalIntegrationsSection(event: event));
      expect(find.text(l10n.eventIntegrationsTitle), findsOneWidget);
      expect(find.text('Example Receiver'), findsOneWidget);
      expect(find.text('Project ID'), findsOneWidget);
      expect(find.text('p-42'), findsOneWidget);
    });
  });
}
