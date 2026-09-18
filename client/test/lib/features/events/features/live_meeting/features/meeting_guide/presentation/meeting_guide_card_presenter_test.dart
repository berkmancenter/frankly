import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/models/meeting_guide_card_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/meeting_guide_card_presenter.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../mocked_classes.mocks.dart';

void main() {
  final mockBuildContext = MockBuildContext();
  final mockView = MockMeetingGuideCardView();
  final mockAgendaProvider = MockAgendaProvider();
  final mockEventTabsControllerState = MockEventTabsControllerState();
  final mockUserDataService = MockUserDataService();
  final mockCommunityProvider = MockCommunityProvider();
  final mockLiveMeetingProvider = MockLiveMeetingProvider();
  final mockMeetingGuideCardStore = MockMeetingGuideCardStore();
  final mockResponsiveLayoutService = MockResponsiveLayoutService();
  final mockUserService = MockUserService();
  final mockEventProvider = MockEventProvider();
  late MeetingGuideCardModel model;
  late MeetingGuideCardPresenter presenter;

  setUp(() {
    model = MeetingGuideCardModel();
    presenter = MeetingGuideCardPresenter(
      mockBuildContext,
      mockView,
      model,
      agendaProvider: mockAgendaProvider,
      eventTabsModel: mockEventTabsControllerState,
      userDataService: mockUserDataService,
      communityProvider: mockCommunityProvider,
      liveMeetingProvider: mockLiveMeetingProvider,
      meetingGuideCardStore: mockMeetingGuideCardStore,
      testResponsiveLayoutService: mockResponsiveLayoutService,
      userService: mockUserService,
      eventProvider: mockEventProvider,
    );
  });

  tearDown(() {
    reset(mockBuildContext);
    reset(mockView);
    reset(mockAgendaProvider);
    reset(mockEventTabsControllerState);
    reset(mockUserDataService);
    reset(mockCommunityProvider);
    reset(mockLiveMeetingProvider);
    reset(mockMeetingGuideCardStore);
    reset(mockResponsiveLayoutService);
    reset(mockUserService);
    reset(mockEventProvider);
  });

  group('isPendingAdvance', () {
    test('pending agenda item matches the current agenda item', () {
      when(mockAgendaProvider.pendingAdvanceAgendaItemId)
          .thenReturn('agendaItemId1');
      when(mockMeetingGuideCardStore.isHoldingPendingAdvanceTransition)
          .thenReturn(false);

      final result = presenter.isPendingAdvance('agendaItemId1');

      expect(result, isTrue);
    });

    test(
        'pending agenda item is for a different agenda item and no transition is held',
        () {
      when(mockAgendaProvider.pendingAdvanceAgendaItemId)
          .thenReturn('agendaItemId2');
      when(mockMeetingGuideCardStore.isHoldingPendingAdvanceTransition)
          .thenReturn(false);

      final result = presenter.isPendingAdvance('agendaItemId1');

      expect(result, isFalse);
    });

    test(
        'pending agenda item is for a different agenda item but a transition is held',
        () {
      when(mockAgendaProvider.pendingAdvanceAgendaItemId)
          .thenReturn('agendaItemId2');
      when(mockMeetingGuideCardStore.isHoldingPendingAdvanceTransition)
          .thenReturn(true);

      final result = presenter.isPendingAdvance('agendaItemId1');

      expect(result, isTrue);
    });

    test('there is no pending agenda item and no transition is held', () {
      when(mockAgendaProvider.pendingAdvanceAgendaItemId).thenReturn(null);
      when(mockMeetingGuideCardStore.isHoldingPendingAdvanceTransition)
          .thenReturn(false);

      final result = presenter.isPendingAdvance('agendaItemId1');

      expect(result, isFalse);
    });

    test('there is no pending agenda item but a transition is held', () {
      when(mockAgendaProvider.pendingAdvanceAgendaItemId).thenReturn(null);
      when(mockMeetingGuideCardStore.isHoldingPendingAdvanceTransition)
          .thenReturn(true);

      final result = presenter.isPendingAdvance('agendaItemId1');

      expect(result, isTrue);
    });
  });

  group('isPendingAdvanceOptimistic (countdown display gate)', () {
    const presentIds = {'a', 'b', 'c'}; // threshold = 3 ~/ 2 + 1 = 2

    setUp(() {
      when(mockUserService.currentUserId).thenReturn('a');
      when(mockMeetingGuideCardStore.isHoldingPendingAdvanceTransition)
          .thenReturn(false);
      // Empty agenda -> isLastAgendaItem is always false
      when(mockAgendaProvider.resolvedAgendaItems).thenReturn(const []);
    });

    test('shows when the server pending id matches the current poll item', () {
      when(mockAgendaProvider.pendingAdvanceAgendaItemId).thenReturn('poll1');

      final result = presenter.isPendingAdvanceOptimistic(
        currentAgendaItemId: 'poll1',
        itemDetails: const [],
        presentParticipantIds: presentIds,
      );

      expect(result, isTrue);
    });

    test('shows once the optimistic ready count reaches the threshold', () {
      when(mockAgendaProvider.pendingAdvanceAgendaItemId).thenReturn(null);
      when(
        mockMeetingGuideCardStore.optimisticReadyCount(
          agendaItemId: 'poll1',
          currentUserId: 'a',
          details: const [],
          presentParticipantIds: presentIds,
        ),
      ).thenReturn(2);

      final result = presenter.isPendingAdvanceOptimistic(
        currentAgendaItemId: 'poll1',
        itemDetails: const [],
        presentParticipantIds: presentIds,
      );

      expect(result, isTrue);
    });

    test('hidden while below threshold and no server pending', () {
      when(mockAgendaProvider.pendingAdvanceAgendaItemId).thenReturn(null);
      when(
        mockMeetingGuideCardStore.optimisticReadyCount(
          agendaItemId: 'poll1',
          currentUserId: 'a',
          details: const [],
          presentParticipantIds: presentIds,
        ),
      ).thenReturn(1);

      final result = presenter.isPendingAdvanceOptimistic(
        currentAgendaItemId: 'poll1',
        itemDetails: const [],
        presentParticipantIds: presentIds,
      );

      expect(result, isFalse);
    });

    // Root cause of the mobile "countdown never appears" case: the bottom nav
    // passes getCurrentAgendaItem()?.id, which is null whenever the displayed
    // item object hasn't resolved, so a genuinely-active server advance for the
    // current item is not recognized and the ring is suppressed.
    test(
        'suppressed when the current id is null even though the server advance '
        'is active for that item', () {
      when(mockAgendaProvider.pendingAdvanceAgendaItemId).thenReturn('poll1');

      final withNullId = presenter.isPendingAdvanceOptimistic(
        currentAgendaItemId: null,
        itemDetails: const [],
        presentParticipantIds: presentIds,
      );
      final withResolvedId = presenter.isPendingAdvanceOptimistic(
        currentAgendaItemId: 'poll1',
        itemDetails: const [],
        presentParticipantIds: presentIds,
      );

      expect(
        withNullId,
        isFalse,
        reason: 'passing a null id drops the active advance',
      );
      expect(
        withResolvedId,
        isTrue,
        reason: 'the fallback-safe id recognizes the same active advance',
      );
    });
  });

  group('current agenda item id resolution', () {
    test(
        'getCurrentAgendaItem()?.id is null while getCurrentAgendaItemId() '
        'still resolves the pending item', () {
      when(mockMeetingGuideCardStore.meetingGuideCardAgendaItem)
          .thenReturn(null);
      when(mockMeetingGuideCardStore.currentAgendaModelItemId)
          .thenReturn('poll1');

      // The mobile bottom nav uses the former; the desktop bottom section uses
      // the latter. Only the latter is safe to gate the countdown on.
      expect(presenter.getCurrentAgendaItem()?.id, isNull);
      expect(presenter.getCurrentAgendaItemId(), 'poll1');
    });
  });
}
