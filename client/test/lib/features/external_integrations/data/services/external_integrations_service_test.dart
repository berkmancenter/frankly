import 'dart:async';

import 'package:client/features/external_integrations/data/services/external_integrations_service.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/external_integrations/external_integration.dart';
import 'package:flutter_test/flutter_test.dart';

/// Feeds enabledIntegrationsForEvent from controllers instead of Firestore.
class _StreamedExternalIntegrationsService extends ExternalIntegrationsService {
  final integrations = StreamController<List<ExternalIntegration>>();
  final settings = StreamController<
      Map<String, EventExternalIntegrationSettings>>.broadcast();
  int settingsListens = 0;

  @override
  Stream<List<ExternalIntegration>> activeIntegrations(String communityId) =>
      integrations.stream;

  @override
  Stream<Map<String, EventExternalIntegrationSettings>> eventSettings(
    Event event,
  ) {
    settingsListens++;
    return settings.stream;
  }
}

void main() {
  final event = Event(
    id: 'e1',
    status: EventStatus.active,
    collectionPath: 'community/c1/templates/t1/events',
    communityId: 'c1',
    templateId: 't1',
    creatorId: 'host',
  );

  ExternalIntegration integration(String id) => ExternalIntegration(
        id: id,
        communityId: 'c1',
        displayName: id,
        events: [ExternalIntegrationEventTypes.recordingReady],
      );

  final enabled = EventExternalIntegrationSettings(
    integrationId: 'int1',
    enabled: true,
  );

  test('follows integration changes after the settings stream has started',
      () async {
    final service = _StreamedExternalIntegrationsService();
    final emitted = <List<String>>[];
    final sub = service
        .enabledIntegrationsForEvent(event)
        .listen((list) => emitted.add(list.map((i) => i.id).toList()));

    service.integrations.add([integration('int1')]);
    await pumpEventQueue();
    service.settings.add({'int1': enabled});
    await pumpEventQueue();
    expect(emitted.last, ['int1']);

    // The integration is turned off community-wide: the notice must update
    // even though the event settings did not change.
    service.integrations.add([]);
    await pumpEventQueue();
    expect(emitted.last, isEmpty);

    await sub.cancel();
  });

  test('does not listen to event settings without integrations', () async {
    final service = _StreamedExternalIntegrationsService();
    final emitted = <List<ExternalIntegration>>[];
    final sub = service.enabledIntegrationsForEvent(event).listen(emitted.add);

    service.integrations.add([]);
    await pumpEventQueue();
    expect(emitted, [isEmpty]);
    expect(service.settingsListens, 0);

    await sub.cancel();
  });
}
