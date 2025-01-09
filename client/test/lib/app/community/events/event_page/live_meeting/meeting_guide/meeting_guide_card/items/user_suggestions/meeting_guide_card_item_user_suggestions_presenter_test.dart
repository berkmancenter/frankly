import 'dart:math';

import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/models/meeting_guide_card_item_user_suggestions_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/meeting_guide_card_item_user_suggestions_presenter.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:mockito/mockito.dart';
import '../../../../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBuildContext = MockBuildContext();
  final mockView = MockMeetingGuideCardItemUserSuggestionsView();
  final mockAgendaProvider = MockAgendaProvider();
  final mockFirestoreMeetingGuideService = MockFirestoreMeetingGuideService();
  final mockMeetingGuideCardStore = MockMeetingGuideCardStore();
  final mockResponsiveLayoutService = MockResponsiveLayoutService();
  final mockUserService = MockUserService();
  final mockMeetingUserSuggestion = MockMeetingUserSuggestion();
  final mockEventPermissions = MockEventPermissionsProvider();
  late MeetingGuideCardItemUserSuggestionsModel model;
  late MeetingGuideCardItemUserSuggestionsPresenter presenter;

  setUp(() {
    model = MeetingGuideCardItemUserSuggestionsModel();
    presenter = MeetingGuideCardItemUserSuggestionsPresenter(
      mockBuildContext,
      mockView,
      model,
      agendaProvider: mockAgendaProvider,
      testFirestoreMeetingGuideService: mockFirestoreMeetingGuideService,
      meetingGuideCardStore: mockMeetingGuideCardStore,
      testResponsiveLayoutService: mockResponsiveLayoutService,
      userService: mockUserService,
      eventPermissions: mockEventPermissions,
    );
  });

  tearDown(() {
    reset(mockBuildContext);
    reset(mockView);
    reset(mockAgendaProvider);
    reset(mockFirestoreMeetingGuideService);
    reset(mockMeetingGuideCardStore);
    reset(mockResponsiveLayoutService);
    reset(mockUserService);
    reset(mockMeetingUserSuggestion);
  });

  test('isMobile', () {
    final value = Random().nextBool();
    when(mockResponsiveLayoutService.isMobile(mockBuildContext))
        .thenReturn(value);

    final result = presenter.isMobile(mockBuildContext);

    expect(result, value);
  });

  test('inLiveMeeting', () {
    final value = Random().nextBool();
    when(mockAgendaProvider.inLiveMeeting).thenReturn(value);

    final result = presenter.inLiveMeeting();

    expect(result, value);
  });

  test('getParticipantAgendaItemDetailsStream', () {
    final stream = Stream.fromIterable(<List<ParticipantAgendaItemDetails>>[]);
    when(mockMeetingGuideCardStore.participantAgendaItemDetailsStream)
        .thenAnswer((_) => stream);

    final result = presenter.getParticipantAgendaItemDetailsStream();

    expect(result, stream);
  });

  group('addSuggestion', () {
    test('suggestion is empty', () async {
      await presenter.addSuggestion('');

      verify(
        mockView.showMessage(
          'Suggestion cannot be empty',
          toastType: ToastType.failed,
        ),
      ).called(1);
      verifyZeroInteractions(mockFirestoreMeetingGuideService);
    });

    test('success', () async {
      final agendaItem = AgendaItem(id: 'agendaItemId');
      when(mockMeetingGuideCardStore.meetingGuideCardAgendaItem)
          .thenReturn(agendaItem);
      when(mockUserService.currentUserId).thenReturn('userId');
      when(mockAgendaProvider.liveMeetingPath).thenReturn('path');

      await presenter.addSuggestion('suggestion');

      verify(
        mockFirestoreMeetingGuideService.addUserSuggestion(
          agendaItemId: 'agendaItemId',
          userId: 'userId',
          liveMeetingPath: 'path',
          suggestion: 'suggestion',
        ),
      ).called(1);
      verifyNever(mockView.showMessage(any, toastType: anyNamed('toastType')));
    });
  });

  test('removeSuggestion', () async {
    final agendaItem = AgendaItem(id: 'agendaItemId');
    final meetingUserSuggestion =
        MeetingUserSuggestion(id: 'id', suggestion: 'suggestion');
    when(mockMeetingGuideCardStore.meetingGuideCardAgendaItem)
        .thenReturn(agendaItem);
    when(mockUserService.currentUserId).thenReturn('userId');
    when(mockAgendaProvider.liveMeetingPath).thenReturn('path');

    await presenter.removeSuggestion(meetingUserSuggestion, 'userId');

    verify(
      mockFirestoreMeetingGuideService.removeUserSuggestion(
        agendaItemId: 'agendaItemId',
        userId: 'userId',
        liveMeetingPath: 'path',
        meetingUserSuggestion: meetingUserSuggestion,
      ),
    ).called(1);
    verifyNever(mockView.showMessage(any, toastType: anyNamed('toastType')));
  });

  group('getFormattedDetails', () {
    test('list is null', () {
      final result = presenter.getFormattedDetails(null);

      expect(result, []);
    });

    test('list is empty', () {
      final result = presenter.getFormattedDetails([]);

      expect(result, []);
    });

    test('success', () {
      final user1Item1 = MeetingUserSuggestion(
        id: 'id1',
        suggestion: 'suggestion1',
        likedByIds: ['', '', ''],
      );
      final user1Item2 =
          MeetingUserSuggestion(id: 'id2', suggestion: 'suggestion2');
      final user1Item3 = MeetingUserSuggestion(
        id: 'id3',
        suggestion: 'suggestion3',
        likedByIds: ['', '', ''],
        dislikedByIds: ['', '', ''],
      );
      final user3Item1 = MeetingUserSuggestion(
        id: 'id31',
        suggestion: 'suggestion31',
        likedByIds: ['', ''],
      );
      final participantItemDetails = <ParticipantAgendaItemDetails>[
        ParticipantAgendaItemDetails(
          userId: 'userId2',
          suggestions: [user1Item1, user1Item2, user1Item3],
        ),
        ParticipantAgendaItemDetails(userId: 'userId2', suggestions: []),
        ParticipantAgendaItemDetails(
          userId: 'userId3',
          suggestions: [user3Item1],
        ),
      ];

      final result = presenter.getFormattedDetails(participantItemDetails);

      expect(
        result,
        [
          ParticipantAgendaItemDetails(
            userId: 'userId2',
            suggestions: [user1Item1],
          ),
          ParticipantAgendaItemDetails(
            userId: 'userId3',
            suggestions: [user3Item1],
          ),
          ParticipantAgendaItemDetails(
            userId: 'userId2',
            suggestions: [user1Item2],
          ),
          ParticipantAgendaItemDetails(
            userId: 'userId2',
            suggestions: [user1Item3],
          ),
        ],
      );
    });
  });

  group('isMySuggestion', () {
    final participantAgendaItemDetails =
        ParticipantAgendaItemDetails(userId: 'userId');

    test('true', () {
      when(mockUserService.currentUserId).thenReturn('userId');

      final result = presenter.isMySuggestion(participantAgendaItemDetails);

      expect(result, isTrue);
    });

    test('false', () {
      when(mockUserService.currentUserId).thenReturn('userId2');

      final result = presenter.isMySuggestion(participantAgendaItemDetails);

      expect(result, isFalse);
    });
  });

  group('getLikeImagePath', () {
    test('true', () {
      when(mockMeetingUserSuggestion.isLiked('userId')).thenReturn(true);
      when(mockUserService.currentUserId).thenReturn('userId');

      final result = presenter.getLikeImagePath(mockMeetingUserSuggestion);

      expect(result, AppAsset.kLikeSelectedPng);
    });

    test('false', () {
      when(mockMeetingUserSuggestion.isLiked('userId')).thenReturn(false);
      when(mockUserService.currentUserId).thenReturn('userId');

      final result = presenter.getLikeImagePath(mockMeetingUserSuggestion);

      expect(result, AppAsset.kLikeNotSelectedPng);
    });
  });

  group('getDislikeImagePath', () {
    test('true', () {
      when(mockMeetingUserSuggestion.isDisliked('userId')).thenReturn(true);
      when(mockUserService.currentUserId).thenReturn('userId');

      final result = presenter.getDislikeImagePath(mockMeetingUserSuggestion);

      expect(result, AppAsset.kDislikeSelectedPng);
    });

    test('false', () {
      when(mockMeetingUserSuggestion.isDisliked('userId')).thenReturn(false);
      when(mockUserService.currentUserId).thenReturn('userId');

      final result = presenter.getDislikeImagePath(mockMeetingUserSuggestion);

      expect(result, AppAsset.kDislikeNotSelectedPng);
    });
  });

  test('getLikeDislikeCount', () {
    when(mockMeetingUserSuggestion.getLikeDislikeCount()).thenReturn(26);

    final result = presenter.getLikeDislikeCount(mockMeetingUserSuggestion);

    expect(result, '26');
  });

  group('toggleLikeDislike', () {
    group('like', () {
      test('is liked already', () async {
        final agendaItem = AgendaItem(id: 'agendaItemId');
        final participantItemDetails =
            ParticipantAgendaItemDetails(userId: 'userId');
        when(mockUserService.currentUserId).thenReturn('currentUserId');
        when(mockMeetingUserSuggestion.isLiked('currentUserId'))
            .thenReturn(true);
        when(mockMeetingUserSuggestion.id)
            .thenReturn('meetingUserSuggestionId');
        when(mockMeetingGuideCardStore.meetingGuideCardAgendaItem)
            .thenReturn(agendaItem);
        when(mockAgendaProvider.liveMeetingPath).thenReturn('path');

        await presenter.toggleLikeDislike(
          LikeType.like,
          participantItemDetails,
          mockMeetingUserSuggestion,
        );

        verify(
          mockFirestoreMeetingGuideService.toggleLikeInMeetingSuggestion(
            LikeType.neutral,
            agendaItemId: 'agendaItemId',
            voterId: 'currentUserId',
            creatorId: 'userId',
            liveMeetingPath: 'path',
            meetingUserSuggestionId: 'meetingUserSuggestionId',
          ),
        ).called(1);
      });

      test('is not liked already', () async {
        final agendaItem = AgendaItem(id: 'agendaItemId');
        final participantItemDetails =
            ParticipantAgendaItemDetails(userId: 'userId');
        when(mockUserService.currentUserId).thenReturn('currentUserId');
        when(mockMeetingUserSuggestion.isLiked('currentUserId'))
            .thenReturn(false);
        when(mockMeetingUserSuggestion.id)
            .thenReturn('meetingUserSuggestionId');
        when(mockMeetingGuideCardStore.meetingGuideCardAgendaItem)
            .thenReturn(agendaItem);
        when(mockAgendaProvider.liveMeetingPath).thenReturn('path');

        await presenter.toggleLikeDislike(
          LikeType.like,
          participantItemDetails,
          mockMeetingUserSuggestion,
        );

        verify(
          mockFirestoreMeetingGuideService.toggleLikeInMeetingSuggestion(
            LikeType.like,
            agendaItemId: 'agendaItemId',
            voterId: 'currentUserId',
            creatorId: 'userId',
            liveMeetingPath: 'path',
            meetingUserSuggestionId: 'meetingUserSuggestionId',
          ),
        ).called(1);
      });
    });

    test('neutral', () async {
      final agendaItem = AgendaItem(id: 'agendaItemId');
      final participantItemDetails =
          ParticipantAgendaItemDetails(userId: 'userId');
      when(mockUserService.currentUserId).thenReturn('currentUserId');
      when(mockMeetingUserSuggestion.id).thenReturn('meetingUserSuggestionId');
      when(mockMeetingGuideCardStore.meetingGuideCardAgendaItem)
          .thenReturn(agendaItem);
      when(mockAgendaProvider.liveMeetingPath).thenReturn('path');

      await presenter.toggleLikeDislike(
        LikeType.neutral,
        participantItemDetails,
        mockMeetingUserSuggestion,
      );

      verify(
        mockFirestoreMeetingGuideService.toggleLikeInMeetingSuggestion(
          LikeType.neutral,
          agendaItemId: 'agendaItemId',
          voterId: 'currentUserId',
          creatorId: 'userId',
          liveMeetingPath: 'path',
          meetingUserSuggestionId: 'meetingUserSuggestionId',
        ),
      ).called(1);
    });

    group('dislike', () {
      test('is disliked already', () async {
        final agendaItem = AgendaItem(id: 'agendaItemId');
        final participantItemDetails =
            ParticipantAgendaItemDetails(userId: 'userId');
        when(mockUserService.currentUserId).thenReturn('currentUserId');
        when(mockMeetingUserSuggestion.isDisliked('currentUserId'))
            .thenReturn(true);
        when(mockMeetingUserSuggestion.id)
            .thenReturn('meetingUserSuggestionId');
        when(mockMeetingGuideCardStore.meetingGuideCardAgendaItem)
            .thenReturn(agendaItem);
        when(mockAgendaProvider.liveMeetingPath).thenReturn('path');

        await presenter.toggleLikeDislike(
          LikeType.dislike,
          participantItemDetails,
          mockMeetingUserSuggestion,
        );

        verify(
          mockFirestoreMeetingGuideService.toggleLikeInMeetingSuggestion(
            LikeType.neutral,
            agendaItemId: 'agendaItemId',
            voterId: 'currentUserId',
            creatorId: 'userId',
            liveMeetingPath: 'path',
            meetingUserSuggestionId: 'meetingUserSuggestionId',
          ),
        ).called(1);
      });

      test('is not disliked already', () async {
        final agendaItem = AgendaItem(id: 'agendaItemId');
        final participantItemDetails =
            ParticipantAgendaItemDetails(userId: 'userId');
        when(mockUserService.currentUserId).thenReturn('currentUserId');
        when(mockMeetingUserSuggestion.isDisliked('currentUserId'))
            .thenReturn(false);
        when(mockMeetingUserSuggestion.id)
            .thenReturn('meetingUserSuggestionId');
        when(mockMeetingGuideCardStore.meetingGuideCardAgendaItem)
            .thenReturn(agendaItem);
        when(mockAgendaProvider.liveMeetingPath).thenReturn('path');

        await presenter.toggleLikeDislike(
          LikeType.dislike,
          participantItemDetails,
          mockMeetingUserSuggestion,
        );

        verify(
          mockFirestoreMeetingGuideService.toggleLikeInMeetingSuggestion(
            LikeType.dislike,
            agendaItemId: 'agendaItemId',
            voterId: 'currentUserId',
            creatorId: 'userId',
            liveMeetingPath: 'path',
            meetingUserSuggestionId: 'meetingUserSuggestionId',
          ),
        ).called(1);
      });
    });
  });
}
