import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../../mocked_classes.mocks.dart';

void main() {
  group('MeetingGuideCardStore.detailsForAgendaItem', () {
    final itemA = ParticipantAgendaItemDetails(
      userId: 'u1',
      agendaItemId: 'A',
      readyToAdvance: true,
    );
    final itemB = ParticipantAgendaItemDetails(
      userId: 'u1',
      agendaItemId: 'B',
      readyToAdvance: false,
    );

    test('keeps only entries for the given agenda item', () {
      final result =
          MeetingGuideCardStore.detailsForAgendaItem([itemA, itemB], 'B');
      expect(result, [itemB]);
    });

    test('excludes a stale previous-item snapshot (anti-flash)', () {
      // Simulates the card handoff where the stream still holds the previous
      // item A snapshot (user ready) while the current item is now B.
      final result = MeetingGuideCardStore.detailsForAgendaItem([itemA], 'B');
      expect(result, isEmpty);
    });

    test('returns empty for null details or null agenda item', () {
      expect(MeetingGuideCardStore.detailsForAgendaItem(null, 'A'), isEmpty);
      expect(
        MeetingGuideCardStore.detailsForAgendaItem([itemA], null),
        isEmpty,
      );
    });
  });

  group('MeetingGuideCardStore.setDesiredReady', () {
    MeetingGuideCardStore buildStore(MockAgendaProvider agendaProvider) {
      return MeetingGuideCardStore(
        communityProvider: MockCommunityProvider(),
        liveMeetingProvider: MockLiveMeetingProvider(),
        agendaProvider: agendaProvider,
        showToast: (_) {},
      );
    }

    test('desiredReadyFor is null for untouched items', () {
      final store = buildStore(MockAgendaProvider());
      expect(store.desiredReadyFor('A'), isNull);
      expect(store.desiredReadyFor(null), isNull);
    });

    test('flips desiredReadyFor immediately and sends when confirmed',
        () async {
      final agendaProvider = MockAgendaProvider();
      when(
        agendaProvider.confirmReadyToMoveOn(
          currentAgendaItemId: anyNamed('currentAgendaItemId'),
          userIsReady: anyNamed('userIsReady'),
        ),
      ).thenAnswer((_) async => true);
      final store = buildStore(agendaProvider);

      // Do not await: the optimistic flip must happen synchronously, before the
      // backend round-trip resolves.
      final future = store.setDesiredReady(agendaItemId: 'A', ready: true);
      expect(store.desiredReadyFor('A'), isTrue);

      final result = await future;
      expect(result, isTrue);
      expect(store.desiredReadyFor('A'), isTrue);
      verify(
        agendaProvider.checkReadyToAdvance(agendaItemId: 'A', ready: true),
      ).called(1);
    });

    test('reverts the optimistic flip when the confirmation is cancelled',
        () async {
      final agendaProvider = MockAgendaProvider();
      when(
        agendaProvider.confirmReadyToMoveOn(
          currentAgendaItemId: anyNamed('currentAgendaItemId'),
          userIsReady: anyNamed('userIsReady'),
        ),
      ).thenAnswer((_) async => false);
      final store = buildStore(agendaProvider);

      final future = store.setDesiredReady(agendaItemId: 'A', ready: true);
      expect(store.desiredReadyFor('A'), isTrue); // optimistic

      final result = await future;
      expect(result, isFalse);
      expect(store.desiredReadyFor('A'), isNull); // reverted
      verifyNever(
        agendaProvider.checkReadyToAdvance(
          agendaItemId: anyNamed('agendaItemId'),
          ready: anyNamed('ready'),
        ),
      );
    });

    test('reverts the optimistic flip when the backend write throws', () async {
      final agendaProvider = MockAgendaProvider();
      when(
        agendaProvider.confirmReadyToMoveOn(
          currentAgendaItemId: anyNamed('currentAgendaItemId'),
          userIsReady: anyNamed('userIsReady'),
        ),
      ).thenAnswer((_) async => true);
      when(
        agendaProvider.checkReadyToAdvance(
          agendaItemId: anyNamed('agendaItemId'),
          ready: anyNamed('ready'),
        ),
      ).thenThrow(Exception('write failed'));
      final store = buildStore(agendaProvider);

      final future = store.setDesiredReady(agendaItemId: 'A', ready: true);
      expect(store.desiredReadyFor('A'), isTrue); // optimistic

      await expectLater(future, throwsException);
      expect(store.desiredReadyFor('A'), isNull); // reverted
    });
  });

  group('MeetingGuideCardStore.optimisticReadyCount', () {
    MeetingGuideCardStore buildStore(MockAgendaProvider agendaProvider) {
      return MeetingGuideCardStore(
        communityProvider: MockCommunityProvider(),
        liveMeetingProvider: MockLiveMeetingProvider(),
        agendaProvider: agendaProvider,
        showToast: (_) {},
      );
    }

    ParticipantAgendaItemDetails ready(String userId) =>
        ParticipantAgendaItemDetails(
          userId: userId,
          agendaItemId: 'A',
          readyToAdvance: true,
        );

    Future<MeetingGuideCardStore> buildStoreWithDesiredReady({
      required bool ready,
    }) async {
      final agendaProvider = MockAgendaProvider();
      when(
        agendaProvider.confirmReadyToMoveOn(
          currentAgendaItemId: anyNamed('currentAgendaItemId'),
          userIsReady: anyNamed('userIsReady'),
        ),
      ).thenAnswer((_) async => true);
      final store = buildStore(agendaProvider);
      await store.setDesiredReady(agendaItemId: 'A', ready: ready);
      return store;
    }

    test('counts present ready participants from the stream', () {
      final store = buildStore(MockAgendaProvider());
      final count = store.optimisticReadyCount(
        agendaItemId: 'A',
        currentUserId: 'u1',
        details: [ready('u2'), ready('u3')],
        presentParticipantIds: {'u1', 'u2', 'u3'},
      );
      expect(count, 2);
    });

    test('excludes ready participants who are not present', () {
      final store = buildStore(MockAgendaProvider());
      final count = store.optimisticReadyCount(
        agendaItemId: 'A',
        currentUserId: 'u1',
        details: [ready('u2'), ready('u3')],
        presentParticipantIds: {'u1', 'u2'},
      );
      expect(count, 1);
    });

    test(
        'adds the current user optimistic ready vote before the stream '
        'catches up', () async {
      final store = await buildStoreWithDesiredReady(ready: true);

      final count = store.optimisticReadyCount(
        agendaItemId: 'A',
        currentUserId: 'u1',
        details: [ready('u2')],
        presentParticipantIds: {'u1', 'u2'},
      );
      expect(count, 2);
    });

    test('removes the current user when they optimistically unready', () async {
      final store = await buildStoreWithDesiredReady(ready: false);

      final count = store.optimisticReadyCount(
        agendaItemId: 'A',
        currentUserId: 'u1',
        details: [ready('u1'), ready('u2')],
        presentParticipantIds: {'u1', 'u2'},
      );
      expect(count, 1);
    });
  });
}
