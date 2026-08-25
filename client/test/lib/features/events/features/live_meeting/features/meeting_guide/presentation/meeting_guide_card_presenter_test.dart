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
}
