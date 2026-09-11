import 'package:client/core/localization/app_localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:client/config/environment.dart';
import 'package:client/core/data/services/analytics_service.dart';
import 'package:client/features/events/data/services/cloud_functions_event_service.dart';
import 'package:client/features/events/data/services/firestore_event_service.dart';
import 'package:client/features/events/features/create_event/data/providers/create_event_dialog_model.dart';
import 'package:client/features/events/features/event_page/data/providers/template_provider.dart';
import 'package:client/services.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../mocked_classes.mocks.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBuildContext = MockBuildContext();
  final mockCommunityProvider = MockCommunityProvider();
  final mockFirestoreEventService = MockFirestoreEventService();
  final mockCloudFunctionsEventService = MockCloudFunctionsEventService();
  final mockAnalyticsService = MockAnalyticsService();

  setUp(() async {
    await GetIt.instance.reset();
    final localization = AppLocalizationService();
    localization.setLocalization(
        await AppLocalizations.delegate.load(const Locale('en')));
    services.registerSingleton<AppLocalizationService>(localization);

    services
        .registerSingleton<FirestoreEventService>(mockFirestoreEventService);
    services.registerSingleton<CloudFunctionsEventService>(
      mockCloudFunctionsEventService,
    );
    services.registerSingleton<AnalyticsService>(mockAnalyticsService);
  });

  tearDown(() async {
    reset(mockBuildContext);
    reset(mockCommunityProvider);
    reset(mockFirestoreEventService);
    reset(mockCloudFunctionsEventService);
    reset(mockAnalyticsService);
    await GetIt.instance.reset();
  });

  test('default create flow keeps Dembrane link and forces recording on submit',
      () async {
    const communityId = 'community-id';
    const dembraneProjectId = 'project-123';
    final scheduledTime = DateTime(2026, 5, 22, 12);
    final initialEvent = Event(
      id: 'event-id',
      status: EventStatus.active,
      collectionPath: 'communities/$communityId/templates/default/events',
      communityId: communityId,
      templateId: defaultTemplateId,
      creatorId: 'creator-id',
      scheduledTime: scheduledTime,
      nullableEventType: EventType.hosted,
      isPublic: false,
      eventSettings: EventSettings.defaultSettings,
    );
    final community = Community(id: communityId);

    when(mockCommunityProvider.communityId).thenReturn(communityId);
    when(mockCommunityProvider.community).thenReturn(community);
    when(mockCommunityProvider.eventSettings)
        .thenReturn(EventSettings.defaultSettings);
    when(
      mockFirestoreEventService.createEventIfNotExists(
        event: anyNamed('event'),
        privateLiveStreamInfo: anyNamed('privateLiveStreamInfo'),
      ),
    ).thenAnswer((invocation) async {
      return invocation.namedArguments[#event]! as Event;
    });
    when(
      mockCloudFunctionsEventService.createEvent(any),
    ).thenAnswer((_) async {});

    final model = CreateEventDialogModel(
      communityProvider: mockCommunityProvider,
    );
    model.setEvent(initialEvent);

    expect(model.allPages, [
      CurrentPage.selectTemplate,
      CurrentPage.selectVisibility,
      CurrentPage.selectDate,
      CurrentPage.selectTime,
    ]);

    model.updateDembraneProjectId('  $dembraneProjectId  ');

    final createdEvent = await model.submit(mockBuildContext);

    expect(createdEvent, isNotNull);
    expect(createdEvent!.dembraneProjectId,
        Environment.dembraneEnabled ? dembraneProjectId : null);
    expect(
        createdEvent.eventSettings?.alwaysRecord, Environment.dembraneEnabled);

    final capturedEvent = verify(
      mockFirestoreEventService.createEventIfNotExists(
        event: captureAnyNamed('event'),
        privateLiveStreamInfo: captureAnyNamed('privateLiveStreamInfo'),
      ),
    ).captured.first as Event;
    expect(capturedEvent.dembraneProjectId,
        Environment.dembraneEnabled ? dembraneProjectId : null);
    expect(
        capturedEvent.eventSettings?.alwaysRecord, Environment.dembraneEnabled);
    verify(mockCloudFunctionsEventService.createEvent(createdEvent)).called(1);
  });
}
