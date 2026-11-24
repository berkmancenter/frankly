import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:functions/events/external_integration_defaults.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:test/test.dart';
import '../util/function_test_fixture.dart';

void main() {
  // Each test uses its own community: the fixture only clears top-level
  // collections, not these subcollections.
  late String communityId;
  late String eventPath;
  var testIndex = 0;
  setupTestFixture();

  setUp(() {
    testIndex++;
    communityId = 'external-integration-community-$testIndex-'
        '${DateTime.now().microsecondsSinceEpoch}';
    eventPath = 'community/$communityId/templates/template1/events/event1';
  });

  Future<void> addIntegration(
    String id, {
    required bool isActive,
    required bool enabledForNewEvents,
  }) async {
    await firestore
        .document('community/$communityId/external-integrations/$id')
        .setData(
          DocumentData.fromMap({
            'id': id,
            'communityId': communityId,
            'displayName': 'Receiver $id',
            'isActive': isActive,
            'enabledForNewEvents': enabledForNewEvents,
            'events': ['recording.ready'],
          }),
        );
  }

  Future<DocumentSnapshot> settings(String id) => firestore
      .document('$eventPath/external-integration-settings/$id')
      .get();

  test('does nothing when no integration is configured', () async {
    final enabled = await ExternalIntegrationDefaults()
        .applyToNewEvent(communityId: communityId, eventPath: eventPath);
    expect(enabled, isEmpty);
  });

  test('enables only active integrations marked on for new events', () async {
    await addIntegration('on', isActive: true, enabledForNewEvents: true);
    await addIntegration('off', isActive: true, enabledForNewEvents: false);
    await addIntegration('inactive', isActive: false, enabledForNewEvents: true);

    final enabled = await ExternalIntegrationDefaults()
        .applyToNewEvent(communityId: communityId, eventPath: eventPath);

    expect(enabled, equals(['on']));
    final on = await settings('on');
    expect(on.exists, isTrue);
    expect(on.data.getBool('enabled'), isTrue);
    expect(on.data.getString('integrationId'), equals('on'));
    expect((await settings('off')).exists, isFalse);
    expect((await settings('inactive')).exists, isFalse);
  });

  test('keeps a choice the host already made', () async {
    await addIntegration('on', isActive: true, enabledForNewEvents: true);
    await firestore
        .document('$eventPath/external-integration-settings/on')
        .setData(
          DocumentData.fromMap({'integrationId': 'on', 'enabled': false}),
        );

    final enabled = await ExternalIntegrationDefaults()
        .applyToNewEvent(communityId: communityId, eventPath: eventPath);

    expect(enabled, isEmpty);
    expect((await settings('on')).data.getBool('enabled'), isFalse);
  });
}
