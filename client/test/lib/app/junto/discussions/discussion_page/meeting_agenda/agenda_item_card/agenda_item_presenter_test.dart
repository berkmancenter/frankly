import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/agenda_item_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/agenda_item_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_data.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/poll/agenda_item_poll_data.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/text/agenda_item_text_data.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/user_suggestions/agenda_item_user_suggestions_data.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_data.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/word_cloud/agenda_item_word_cloud_data.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/visible_exception.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBuildContext = MockBuildContext();
  final mockView = MockAgendaItemView();
  final mockAgendaItemHelper = MockAgendaItemHelper();
  final mockAgendaProvider = MockAgendaProvider();
  final mockDiscussionPermissionsProvider = MockDiscussionPermissionsProvider();
  final mockAgendaItem = MockAgendaItem();
  final mockDiscussion = MockDiscussion();
  final mockTopic = MockTopic();
  final mockMeetingGuideCardStore = MockMeetingGuideCardStore();
  final mockLiveMeetingProvider = MockLiveMeetingProvider();
  final mockCommunityPermissionsProvider = MockCommunityPermissionsProvider();
  final mockAgendaProviderParams = MockAgendaProviderParams();
  final agendaItem = AgendaItem(id: 'someId');
  late AgendaItemModel model;
  late AgendaItemPresenter presenter;

  setUp(() {
    model = AgendaItemModel(agendaItem);
    presenter = AgendaItemPresenter(
      mockBuildContext,
      mockView,
      model,
      agendaItemPresenterHelper: mockAgendaItemHelper,
      agendaProvider: mockAgendaProvider,
      meetingGuideCardStore: mockMeetingGuideCardStore,
      discussionPermissionsProvider: mockDiscussionPermissionsProvider,
      liveMeetingProvider: mockLiveMeetingProvider,
      communityPermissionsProvider: mockCommunityPermissionsProvider,
    );
  });

  tearDown(() {
    reset(mockView);
    reset(mockAgendaItemHelper);
    reset(mockAgendaItem);
    reset(mockAgendaProviderParams);
    reset(mockTopic);
    reset(mockAgendaProvider);
    reset(mockMeetingGuideCardStore);
    reset(mockDiscussionPermissionsProvider);
    reset(mockDiscussion);
    reset(mockLiveMeetingProvider);
    reset(mockCommunityPermissionsProvider);
  });

  test('init', () {
    presenter.init();

    verify(mockAgendaItemHelper.initialiseFields(model)).called(1);
    verify(mockView.updateView()).called(1);
  });

  group('isCardActive', () {
    test('true', () {
      when(mockAgendaProvider.isCurrentAgendaItem(agendaItem.id)).thenReturn(true);
      expect(presenter.isCardActive(), isTrue);
    });

    test('false', () {
      when(mockAgendaProvider.isCurrentAgendaItem(agendaItem.id)).thenReturn(false);
      expect(presenter.isCardActive(), isFalse);
    });
  });

  group('isCompleted', () {
    test('true', () {
      when(mockAgendaProvider.isCompleted('someId')).thenReturn(true);
      expect(presenter.isCompleted(), isTrue);
    });

    test('false', () {
      when(mockAgendaProvider.isCompleted('someId')).thenReturn(false);
      expect(presenter.isCompleted(), isFalse);
    });
  });

  group('isCollapsed', () {
    test('true', () {
      when(mockAgendaProvider.collapsedAgendaItemIds).thenReturn({'otherId', 'someId'});
      expect(presenter.isCollapsed(), isTrue);
    });

    test('false', () {
      when(mockAgendaProvider.collapsedAgendaItemIds).thenReturn({'otherId', 'someOtherId'});
      expect(presenter.isCollapsed(), isFalse);
    });
  });

  group('switchType', () {
    void executeTest(AgendaItemType type) {
      test('$type', () {
        presenter.changeAgendaType(type);

        expect(model.agendaItem.type, type);
        verify(mockView.updateView()).called(1);
      });
    }

    for (var type in AgendaItemType.values) {
      executeTest(type);
    }
  });

  group('hasBeenEdited', () {
    test('true', () {
      when(mockAgendaItemHelper.hasBeenEdited(model)).thenReturn(true);
      expect(presenter.hasBeenEdited(), isTrue);
    });
    test('false', () {
      when(mockAgendaItemHelper.hasBeenEdited(model)).thenReturn(false);
      expect(presenter.hasBeenEdited(), isFalse);
    });
  });

  test('getFormattedDuration', () {
    expect(presenter.getFormattedDuration(Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
    expect(presenter.getFormattedDuration(Duration(minutes: 1, seconds: 2)), '1:02');
    expect(presenter.getFormattedDuration(Duration(seconds: 1)), '0:01');
  });

  group('saveContent', () {
    test('!areRequiredFieldsInput', () async {
      model.agendaItem = model.agendaItem.copyWith(nullableType: AgendaItemType.text);
      when(mockAgendaItemHelper.areRequiredFieldsInput(model)).thenReturn('error message');

      await presenter.saveContent();

      verify(mockView.showMessage('error message', toastType: ToastType.failed)).called(1);
      verifyNever(mockAgendaProvider.upsertAgendaItem(updatedItem: anyNamed('updatedItem')));
      verifyNever(mockView.updateView());
    });

    group('areRequiredFieldsInput', () {
      test('!wasEdited', () async {
        model.agendaItem = model.agendaItem.copyWith(nullableType: AgendaItemType.text);
        model.isEditMode = true;

        when(mockAgendaItemHelper.areRequiredFieldsInput(model)).thenReturn(null);
        when(mockAgendaItemHelper.hasBeenEdited(model)).thenReturn(false);
        when(mockAgendaProvider.unsavedItems).thenReturn([]);

        await presenter.saveContent();

        expect(model.isEditMode, isFalse);
        verify(mockView.updateView()).called(1);
      });

      group('wasEdited', () {
        test('contains duplicates', () async {
          model.agendaItem = model.agendaItem.copyWith(nullableType: AgendaItemType.poll);
          model.agendaItemPollData = AgendaItemPollData('question', ['duplicate', 'duplicate']);

          when(mockAgendaItemHelper.areRequiredFieldsInput(model)).thenReturn(null);
          when(mockAgendaItemHelper.hasBeenEdited(model)).thenReturn(true);
          when(mockAgendaProvider.unsavedItems).thenReturn([]);

          expect(() async => await presenter.saveContent(), throwsA(isA<VisibleException>()));
        });

        test('regular', () async {
          model.agendaItemTextData = AgendaItemTextData('someTitle', 'textContent');
          model.agendaItemVideoData =
              AgendaItemVideoData('someTitle', AgendaItemVideoType.url, 'videoUrl');
          model.agendaItemImageData = AgendaItemImageData('someTitle', 'imageUrl');
          model.agendaItemPollData = AgendaItemPollData('question', ['answer1', 'answer2']);
          model.agendaItemWordCloudData = AgendaItemWordCloudData('prompt');

          when(mockAgendaItemHelper.areRequiredFieldsInput(model)).thenReturn(null);
          when(mockAgendaItemHelper.hasBeenEdited(model)).thenReturn(true);

          await presenter.saveContent();
          // verify(mockAgendaProvider.upsertAgendaItem(updatedItem: ...)).called(1);
          expect(model.isEditMode, isFalse);
          verify(mockView.updateView()).called(1);
        },
            skip:
                'Fix once all code has been migrated to null safety. Currently experiencing issue with not many leads, since it is WEB. Error: ReachabilityError: `null` encountered as case in a switch expression with a non-nullable enum type.');
      });
    });
  });

  test('finishEditingItem', () async {
    await presenter.finishEditingItem();
    verify(mockAgendaProvider.finishAgendaItem('someId')).called(1);
  });

  test('toggleEditMode', () {
    presenter.toggleEditMode();

    expect(model.isEditMode, isTrue);
    verify(mockView.updateView()).called(1);
  });

  group('doesAllow', () {
    test('trueNotOnDiscussionPage', () {
      when(mockAgendaProvider.params).thenReturn(mockAgendaProviderParams);
      when(mockAgendaProviderParams.isNotOnDiscussionPage).thenReturn(true);
      when(mockAgendaProviderParams.topic).thenReturn(mockTopic);
      when(mockCommunityPermissionsProvider.canEditTopic(mockTopic)).thenReturn(true);
      expect(presenter.doesAllowEdit(), isTrue);
    });
    test('falseNotOnDiscussionPage', () {
      when(mockAgendaProvider.params).thenReturn(mockAgendaProviderParams);
      when(mockAgendaProviderParams.isNotOnDiscussionPage).thenReturn(true);
      when(mockAgendaProviderParams.topic).thenReturn(mockTopic);
      when(mockCommunityPermissionsProvider.canEditTopic(mockTopic)).thenReturn(false);
      expect(presenter.doesAllowEdit(), isFalse);
    });

    test('trueOnDiscussionPage', () {
      when(mockAgendaProvider.params).thenReturn(mockAgendaProviderParams);
      when(mockAgendaProviderParams.isNotOnDiscussionPage).thenReturn(false);
      when(mockDiscussionPermissionsProvider.canEditDiscussion).thenReturn(true);
      when(mockLiveMeetingProvider.isInBreakout).thenReturn(false);
      expect(presenter.doesAllowEdit(), isTrue);
    });

    test('falseOnDiscussionPage', () {
      when(mockAgendaProvider.params).thenReturn(mockAgendaProviderParams);
      when(mockAgendaProviderParams.isNotOnDiscussionPage).thenReturn(false);
      when(mockDiscussionPermissionsProvider.canEditDiscussion).thenReturn(false);
      when(mockLiveMeetingProvider.isInBreakout).thenReturn(false);
      expect(presenter.doesAllowEdit(), isFalse);
    });

    test('falseInBreakouts', () {
      when(mockAgendaProvider.params).thenReturn(mockAgendaProviderParams);
      when(mockAgendaProviderParams.isNotOnDiscussionPage).thenReturn(false);
      when(mockDiscussionPermissionsProvider.canEditDiscussion).thenReturn(true);
      when(mockLiveMeetingProvider.isInBreakout).thenReturn(true);
      expect(presenter.doesAllowEdit(), isFalse);
    });
  });

  group('tapOnCard', () {
    test('isEditMode', () {
      model.isEditMode = true;

      presenter.toggleCardExpansion();

      verifyNever(mockView.updateView());
    });
    group('!isEditMode', () {
      test('remove', () {
        Set<String> items = {'one', 'someId', 'three'};
        model.isEditMode = false;

        when(mockAgendaProvider.collapsedAgendaItemIds).thenReturn(items);

        presenter.toggleCardExpansion();

        expect(items.length, 2);
        expect(items.contains('one'), isTrue);
        expect(items.contains('someId'), isFalse);
        expect(items.contains('three'), isTrue);
        verify(mockView.updateView()).called(1);
      });
      test('add', () {
        Set<String> items = {'one', 'three'};
        model.isEditMode = false;

        when(mockAgendaProvider.collapsedAgendaItemIds).thenReturn(items);

        presenter.toggleCardExpansion();

        expect(items.length, 3);
        expect(items.contains('one'), isTrue);
        expect(items.contains('someId'), isTrue);
        expect(items.contains('three'), isTrue);
        verify(mockView.updateView()).called(1);
      });
    });
  });

  test('reorder', () {
    presenter.reorder();
    verify(mockAgendaProvider.startReorder()).called(1);
  });

  group('isInLiveMeeting', () {
    test('true', () {
      when(mockAgendaProvider.inLiveMeeting).thenReturn(true);
      expect(presenter.isInLiveMeeting(), isTrue);
    });
    test('false', () {
      when(mockAgendaProvider.inLiveMeeting).thenReturn(false);
      expect(presenter.isInLiveMeeting(), isFalse);
    });
  });

  group('isBrandNew', () {
    test('true', () {
      when(mockAgendaItemHelper.isBrandNew(model)).thenReturn(true);
      expect(presenter.isBrandNew(), isTrue);
    });
    test('false', () {
      when(mockAgendaItemHelper.isBrandNew(model)).thenReturn(false);
      expect(presenter.isBrandNew(), isFalse);
    });
  });

  test('discard', () {}, skip: 'Logic is not implemented yet in the method. Wait until it is.');

  test('deleteAgendaItem', () async {
    await presenter.deleteAgendaItem();
    verify(mockAgendaProvider.deleteAgendaItem(any)).called(1);
  });

  group('canExpand', () {
    void executeTest(bool inLiveMeeting, bool isCompleted, bool isCardActive) {
      test('inLiveMeeting: $inLiveMeeting, isCompleted: $isCompleted, isCardActive: $isCardActive',
          () {
        final result = presenter.canExpand(inLiveMeeting, isCompleted, isCardActive);

        if (!inLiveMeeting || (!isCompleted && !isCardActive)) {
          expect(result, isTrue);
        } else {
          expect(result, isFalse);
        }
      });
    }

    executeTest(true, true, true);
    executeTest(false, true, true);
    executeTest(true, false, true);
    executeTest(true, true, false);
    executeTest(false, false, true);
    executeTest(false, true, false);
    executeTest(true, false, false);
    executeTest(false, false, false);
  });

  group('canReorder', () {
    void executeTest(bool allowEdit, bool isEditMode, bool isCompleted, bool isCardActive) {
      test(
          'allowEdit: $allowEdit, isEditMode: $isEditMode, isCompleted: $isCompleted, isCardActive: $isCardActive',
          () {
        final result = presenter.canReorder(allowEdit, isEditMode, isCompleted, isCardActive);

        if (allowEdit && !isEditMode && !isCompleted && !isCardActive) {
          expect(result, isTrue);
        } else {
          expect(result, isFalse);
        }
      });
    }

    executeTest(true, true, true, true);
    executeTest(false, true, true, true);
    executeTest(true, false, true, true);
    executeTest(true, true, false, true);
    executeTest(true, true, true, false);
    executeTest(false, false, true, true);
    executeTest(false, true, false, true);
    executeTest(false, true, true, false);
    executeTest(true, false, false, true);
    executeTest(true, false, true, false);
    executeTest(true, true, false, false);
    executeTest(false, false, false, true);
    executeTest(false, false, true, false);
    executeTest(false, true, false, false);
    executeTest(true, false, false, false);
    executeTest(false, false, false, false);
  });

  test('updateAgendaItemTextData', () {
    final data = AgendaItemTextData('title', 'content');
    presenter.updateAgendaItemTextData(data);

    expect(model.agendaItemTextData, data);
    verify(mockView.updateView()).called(1);
  });

  test('updateAgendaItemImageData', () {
    final data = AgendaItemImageData('title', 'url');
    presenter.updateAgendaItemImageData(data);

    expect(model.agendaItemImageData, data);
    verify(mockView.updateView()).called(1);
  });

  test('updateAgendaItemVideoData', () {
    final data = AgendaItemVideoData('title', AgendaItemVideoType.url, 'url');
    presenter.updateAgendaItemVideoData(data);

    expect(model.agendaItemVideoData, data);
    verify(mockView.updateView()).called(1);
  });

  test('updateAgendaItemPollData', () {
    final data = AgendaItemPollData('question', ['one', 'two']);
    presenter.updateAgendaItemPollData(data);

    expect(model.agendaItemPollData, data);
    verify(mockView.updateView()).called(1);
  });

  test('updateAgendaItemWCData', () {
    final data = AgendaItemWordCloudData('prompt');
    presenter.updateAgendaItemWordCloudData(data);

    expect(model.agendaItemWordCloudData, data);
    verify(mockView.updateView()).called(1);
  });

  group('getTitle', () {
    group('title is set', () {
      void executeTest(AgendaItemType agendaItemType) {
        test('$agendaItemType', () {
          model.agendaItem = model.agendaItem.copyWith(nullableType: agendaItemType);
          model.agendaItemTextData = AgendaItemTextData('text title', '');
          model.agendaItemVideoData =
              AgendaItemVideoData('video title', AgendaItemVideoType.url, '');
          model.agendaItemImageData = AgendaItemImageData('image title', '');
          model.agendaItemPollData = AgendaItemPollData('question', []);
          model.agendaItemWordCloudData = AgendaItemWordCloudData('wc prompt');
          model.agendaItemUserSuggestionsData = AgendaItemUserSuggestionsData('suggestions title');

          final result = presenter.getTitle();

          switch (agendaItemType) {
            case AgendaItemType.text:
              expect(result, 'text title');
              break;
            case AgendaItemType.video:
              expect(result, 'video title');
              break;
            case AgendaItemType.image:
              expect(result, 'image title');
              break;
            case AgendaItemType.poll:
              expect(result, 'question');
              break;
            case AgendaItemType.wordCloud:
              expect(result, 'wc prompt');
              break;
            case AgendaItemType.userSuggestions:
              expect(result, 'suggestions title');
              break;
          }
        });
      }

      for (var agendaItemType in AgendaItemType.values) {
        executeTest(agendaItemType);
      }
    });

    group('title is not set', () {
      void executeTest(AgendaItemType agendaItemType) {
        test('$agendaItemType', () {
          model.agendaItem = model.agendaItem.copyWith(nullableType: agendaItemType);
          model.agendaItemTextData = AgendaItemTextData('', '');
          model.agendaItemVideoData = AgendaItemVideoData('', AgendaItemVideoType.url, '');
          model.agendaItemImageData = AgendaItemImageData('', '');
          model.agendaItemPollData = AgendaItemPollData('', []);
          model.agendaItemWordCloudData = AgendaItemWordCloudData('');
          model.agendaItemUserSuggestionsData = AgendaItemUserSuggestionsData('');

          final result = presenter.getTitle();

          switch (agendaItemType) {
            case AgendaItemType.text:
              expect(result, 'Text Title');
              break;
            case AgendaItemType.video:
              expect(result, 'Video');
              break;
            case AgendaItemType.image:
              expect(result, 'Image');
              break;
            case AgendaItemType.poll:
              expect(result, 'Question');
              break;
            case AgendaItemType.wordCloud:
              expect(result, 'Word Cloud');
              break;
            case AgendaItemType.userSuggestions:
              expect(result, 'Suggestions');
              break;
          }
        });
      }

      for (var agendaItemType in AgendaItemType.values) {
        executeTest(agendaItemType);
      }
    });
  });

  test('cancelChanges', () {
    model.agendaItem = AgendaItem(id: 'id');
    model.isEditMode = true;

    presenter.cancelChanges();

    verify(mockAgendaProvider.deleteUnsavedItem('id')).called(1);
    verify(mockAgendaItemHelper.initialiseFields(model)).called(1);
    expect(model.isEditMode, isFalse);
    verify(mockView.updateView()).called(1);
  });

  test('updateTime', () {
    model.timeInSeconds = 1;

    presenter.updateTime(Duration(minutes: 2, seconds: 30));

    expect(model.timeInSeconds, 150);
    verify(mockView.updateView()).called(1);
  });
}
