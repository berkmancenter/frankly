@TestOn('browser')
library;

import 'package:client/core/data/services/clock_service.dart';
import 'package:client/core/data/services/firestore_database.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/services/firestore_meeting_guide_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
// Web plugin registration is explicit in Flutter browser tests.
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _Database extends Fake implements FirestoreDatabase {
  @override
  final FirebaseFirestore firestore;
  _Database(this.firestore);
}

class _Clock extends Fake implements ClockService {
  DateTime time = DateTime.utc(2026, 9, 8, 12);
  @override
  DateTime now() => time;
}

void main() {
  const enabled = bool.fromEnvironment('WORD_CLOUD_EMULATOR_TEST');
  test(
    'persists entry metadata, deduplicates concurrent submits, and removes entries',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      FirebaseCoreWeb.registerWith(webPluginRegistrar);
      FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
      final app = await Firebase.initializeApp(
        name: 'word-cloud-storage',
        options: const FirebaseOptions(
          apiKey: 'local-test-key',
          appId: '1:123:web:wordcloud',
          messagingSenderId: '123',
          projectId: 'demo-frankly-443',
        ),
      );
      final db = FirebaseFirestore.instanceFor(app: app);
      db.settings = const Settings(persistenceEnabled: false);
      // This opt-in test checks storage transactions, not security rules. The
      // emulator-only owner token permits setup without touching real accounts.
      js.context.callMethod('eval', [
        r'''
      firebase_firestore.connectFirestoreEmulator(
        firebase_firestore.getFirestore(firebase_core.getApp('word-cloud-storage')),
        'localhost', 8080, {mockUserToken: 'owner'});
    '''
      ]);
      final clock = _Clock();
      GetIt.instance.registerSingleton<FirestoreDatabase>(_Database(db));
      GetIt.instance.registerSingleton<ClockService>(clock);
      addTearDown(() async {
        await GetIt.instance.reset();
        await app.delete();
      });
      const meeting =
          'community/storage/templates/template/events/event/live-meetings/event';
      final ref = db.doc(
        '$meeting/participant-agenda-item-details/cloud/participant-details/user',
      );
      await ref.set({
        'wordCloudResponses': ['Legacy'],
      });
      addTearDown(() => ref.delete());
      final service = FirestoreMeetingGuideService();
      Future<void> submit(String word) => service.addWordCloudResponse(
            agendaItemId: 'cloud',
            userId: 'user',
            liveMeetingPath: meeting,
            response: word,
            prompt: 'What matters?',
          );
      await Future.wait([submit('Trust'), submit('Trust')]);
      clock.time = clock.time.add(const Duration(minutes: 1));
      await submit('Listening');
      final saved =
          (await ref.get(const GetOptions(source: Source.server))).data()!;
      expect(saved['wordCloudResponses'], ['Legacy', 'Trust', 'Listening']);
      final entries = saved['wordCloudEntries'] as List;
      expect(entries, hasLength(2));
      expect(entries[0]['createdDate'], '2026-09-08T12:00:00.000Z');
      expect(entries[1]['createdDate'], '2026-09-08T12:01:00.000Z');
      expect(entries[0]['prompt'], 'What matters?');
      expect(entries[0]['userId'], 'user');
      await service.removeWordCloudResponse(
        agendaItemId: 'cloud',
        userId: 'user',
        liveMeetingPath: meeting,
        response: 'Trust',
      );
      final remaining =
          (await ref.get(const GetOptions(source: Source.server))).data()!;
      expect(remaining['wordCloudResponses'], ['Legacy', 'Listening']);
      expect(
        (remaining['wordCloudEntries'] as List).single['message'],
        'Listening',
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
    skip: !enabled
        ? 'Requires local Firestore emulator; enable WORD_CLOUD_EMULATOR_TEST.'
        : false,
  );
}
