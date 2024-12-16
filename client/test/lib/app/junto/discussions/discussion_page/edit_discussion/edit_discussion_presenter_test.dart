import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/edit_discussion/edit_discussion_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/edit_discussion/edit_discussion_presenter.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockContext = MockBuildContext();
  final mockView = MockEditDiscussionView();
  final mockDiscussionPageProvider = MockDiscussionPageProvider();
  final mockResponsiveLayoutService = MockResponsiveLayoutService();
  final mockFirestoreDiscussionService = MockFirestoreDiscussionService();
  final mockDiscussionProvider = MockDiscussionProvider();
  final mockFirestoreDatabase = MockFirestoreDatabase();
  final mockJuntoProvider = MockJuntoProvider();
  final mockCommunityPermissionsProvider = MockCommunityPermissionsProvider();
  final mockEditDiscussionPresenterHelper = MockEditDiscussionPresenterHelper();
  final mockAppDrawerProvider = MockAppDrawerProvider();

  late EditDiscussionModel model;
  late EditDiscussionPresenter presenter;

  setUp(() {
    model = EditDiscussionModel();
    presenter = EditDiscussionPresenter(
      mockContext,
      mockView,
      model,
      editDiscussionPresenterHelper: mockEditDiscussionPresenterHelper,
      appDrawerProvider: mockAppDrawerProvider,
      discussionPageProvider: mockDiscussionPageProvider,
      responsiveLayoutService: mockResponsiveLayoutService,
      firestoreDiscussionService: mockFirestoreDiscussionService,
      firestoreDatabase: mockFirestoreDatabase,
      juntoProvider: mockJuntoProvider,
      communityPermissionsProvider: mockCommunityPermissionsProvider,
    );
  });

  tearDown(() {
    reset(mockView);
    reset(mockEditDiscussionPresenterHelper);
    reset(mockAppDrawerProvider);
    reset(mockDiscussionPageProvider);
    reset(mockResponsiveLayoutService);
    reset(mockFirestoreDiscussionService);
    reset(mockDiscussionProvider);
    reset(mockFirestoreDatabase);
    reset(mockJuntoProvider);
  });

  Discussion getDiscussion() {
    return Discussion(
      id: 'id',
      status: DiscussionStatus.active,
      collectionPath: 'collectionPath',
      juntoId: 'juntoId',
      topicId: 'topicId',
      creatorId: 'creatorId',
    );
  }

  test('init', () {
    final discussion = getDiscussion();
    when(mockDiscussionPageProvider.discussionProvider).thenReturn(mockDiscussionProvider);
    when(mockDiscussionProvider.discussion).thenReturn(discussion);

    presenter.init();

    expect(model.discussion, discussion);
    expect(model.initialDiscussion, discussion);
    verify(mockView.updateView()).called(1);
  });

  test('updateDiscussionType', () {
    when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final discussion = getDiscussion();
    model.discussion = discussion;

    presenter.updateDiscussionType(DiscussionType.hosted);

    expect(
      discussion.copyWith(nullableDiscussionType: DiscussionType.hosted).toJson(),
      model.discussion.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  group('getDiscussionTypeTitle', () {
    void executeTest(DiscussionType discussionType) {
      test('$discussionType', () {
        final String result;
        switch (discussionType) {
          case DiscussionType.hosted:
            result = 'Hosted';
            break;
          case DiscussionType.hostless:
            result = 'Hostless';
            break;
          case DiscussionType.livestream:
            result = 'Livestream';
            break;
        }

        expect(presenter.getDiscussionTypeTitle(discussionType), result);
      });
    }

    for (var discussionType in DiscussionType.values) {
      executeTest(discussionType);
    }
  });

  test('updateTitle', () {
    when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final discussion = getDiscussion();
    model.discussion = discussion;

    presenter.updateTitle('title');

    expect(
      discussion.copyWith(title: 'title').toJson(),
      model.discussion.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateDescription', () {
    when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final discussion = getDiscussion();
    model.discussion = discussion;

    presenter.updateDescription('description');

    expect(
      discussion.copyWith(description: 'description').toJson(),
      model.discussion.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateIsPublic', () {
    when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final discussion = getDiscussion();
    model.discussion = discussion;

    presenter.updateIsPublic(true);

    expect(
      discussion.copyWith(isPublic: true).toJson(),
      model.discussion.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateDate', () {
    when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final dateTime = DateTime(2020, 1, 2, 3, 4);
    final discussion = getDiscussion().copyWith(scheduledTime: dateTime);
    model.discussion = discussion;

    presenter.updateDate(DateTime(2010, 10, 11, 12));

    expect(
      discussion.copyWith(scheduledTime: DateTime(2010, 10, 11, 3, 4)).toJson(),
      model.discussion.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateTime', () {
    when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final dateTime = DateTime(2020, 1, 2, 3, 4);
    final discussion = getDiscussion().copyWith(scheduledTime: dateTime);
    model.discussion = discussion;

    presenter.updateTime(TimeOfDay(hour: 16, minute: 20));

    expect(
      discussion.copyWith(scheduledTime: DateTime(2020, 1, 2, 16, 20)).toJson(),
      model.discussion.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateIsFeatured', () {
    when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
    model.isFeatured = false;

    presenter.updateIsFeatured(true);

    expect(model.isFeatured, isTrue);
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateMaxParticipants', () {
    when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final discussion = getDiscussion();
    model.discussion = discussion;

    presenter.updateMaxParticipants(15);

    expect(
      discussion.copyWith(maxParticipants: 15).toJson(),
      model.discussion.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('updateEventDuration', () {
    when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final discussion = getDiscussion();
    model.discussion = discussion;

    presenter.updateEventDuration(Duration(minutes: 120));

    expect(
      discussion.copyWith(durationInMinutes: 120).toJson(),
      model.discussion.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  test('isMobile', () {
    when(mockResponsiveLayoutService.isMobile(mockContext)).thenReturn(true);

    final result = presenter.isMobile(mockContext);

    expect(result, isTrue);
  });

  group('showFeatureToggle', () {
    test('true', () {
      when(mockCommunityPermissionsProvider.canFeatureItems).thenReturn(true);
      expect(presenter.showFeatureToggle, isTrue);
    });

    test('false', () {
      when(mockCommunityPermissionsProvider.canFeatureItems).thenReturn(false);
      expect(presenter.showFeatureToggle, isFalse);
    });
  });

  group('isPlatformSelectionFeatureEnabled', () {
    test('true', () {
      final settings = CommunitySettings(enablePlatformSelection: true);
      when(mockJuntoProvider.settings).thenReturn(settings);
      expect(presenter.isPlatformSelectionFeatureEnabled(), isTrue);
    });

    test('false', () {
      final settings = CommunitySettings(enablePlatformSelection: false);
      when(mockJuntoProvider.settings).thenReturn(settings);
      expect(presenter.isPlatformSelectionFeatureEnabled(), isFalse);
    });
  });

  group('saveChanges', () {
    test('validation error', () async {
      final junto = Junto(id: 'juntoId');
      when(mockJuntoProvider.junto).thenReturn(junto);
      model.discussion = getDiscussion();
      when(mockEditDiscussionPresenterHelper.areChangesValid(model.discussion)).thenReturn('error');

      await presenter.saveChanges();

      verify(mockView.showMessage('error', toastType: ToastType.failed)).called(1);
      verify(mockAppDrawerProvider.hideConfirmChangesDialogLayer()).called(1);
      verifyNoMoreInteractions(mockView);
    });

    test('success', () async {
      final junto = Junto(id: 'juntoId');
      when(mockJuntoProvider.junto).thenReturn(junto);
      final discussion = getDiscussion().copyWith(
        title: 'title',
        description: 'description',
        collectionPath: 'collectionPath',
        id: 'discussionId',
      );
      model.discussion = discussion;
      when(mockEditDiscussionPresenterHelper.areChangesValid(model.discussion)).thenReturn(null);
      when(mockCommunityPermissionsProvider.canFeatureItems).thenReturn(true);
      model.isFeatured = true;

      await presenter.saveChanges();

      verifyNever(mockView.showMessage(any, toastType: ToastType.failed));
      verify(mockFirestoreDatabase.updateFeaturedItem(
        juntoId: 'juntoId',
        documentId: 'discussionId',
        featured: anyNamed('featured'),
        isFeatured: true,
      )).called(1);

      verify(
        mockFirestoreDiscussionService.updateDiscussion(
          discussion: discussion,
          keys: [
            Discussion.kFieldDiscussionType,
            Discussion.kFieldTitle,
            Discussion.kFieldImage,
            Discussion.kFieldDescription,
            Discussion.kFieldIsPublic,
            Discussion.kFieldScheduledTime,
            Discussion.kFieldMaxParticipants,
            Discussion.kDurationInMinutes,
          ],
        ),
      ).called(1);
      verify(mockView.closeDrawer()).called(1);
    });
  });

  group('isFeatured', () {
    test('true', () {
      final featuredItems = [
        Featured(documentPath: 'docPath1'),
        Featured(documentPath: 'collectionPath/discussionId'),
        Featured(documentPath: 'docPath2'),
      ];
      final discussion = getDiscussion().copyWith(
        collectionPath: 'collectionPath',
        id: 'discussionId',
      );
      model.discussion = discussion;

      final result = presenter.isFeatured(featuredItems);

      expect(result, isTrue);
    });

    test('false with null list', () {
      final discussion = getDiscussion().copyWith(
        collectionPath: 'collectionPath',
        id: 'discussionId',
      );
      model.discussion = discussion;

      final result = presenter.isFeatured(null);

      expect(result, isFalse);
    });

    test('false, no matches', () {
      final featuredItems = [
        Featured(documentPath: 'docPath1'),
        Featured(documentPath: 'docPath2'),
        Featured(documentPath: 'docPath3'),
      ];
      final discussion = getDiscussion().copyWith(
        collectionPath: 'collectionPath',
        id: 'discussionId',
      );
      model.discussion = discussion;

      final result = presenter.isFeatured(featuredItems);

      expect(result, isFalse);
    });
  });

  test('getFeaturedStream', () {
    final BehaviorSubjectWrapper<List<Featured>> stream = BehaviorSubjectWrapper(Stream.empty());
    when(mockJuntoProvider.junto).thenReturn(Junto(id: 'id'));
    when(mockFirestoreDatabase.getJuntoFeaturedItems('id')).thenAnswer((_) => stream);

    final result = presenter.getFeaturedStream();

    expect(result, stream);
  });

  test('getDiscussionDocumentPath', () {
    final discussion = getDiscussion().copyWith(
      collectionPath: 'collectionPath',
      id: 'discussionId',
    );
    model.discussion = discussion;

    final result = presenter.getDiscussionDocumentPath();

    expect(result, 'collectionPath/discussionId');
  });

  test('updateImage', () {
    when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
    final discussion = getDiscussion();
    model.discussion = discussion;

    presenter.updateImage('url');

    expect(
      discussion.copyWith(image: 'url').toJson(),
      model.discussion.toJson(),
    );
    verify(mockAppDrawerProvider.setUnsavedChanges(true)).called(1);
    verify(mockView.updateView()).called(1);
  });

  group('cancelEvent', () {
    test('true', () async {
      when(mockDiscussionPageProvider.cancelDiscussion()).thenAnswer((_) async => true);

      await presenter.cancelEvent();

      verify(mockView.closeDrawer()).called(1);
    });

    test('false', () async {
      when(mockDiscussionPageProvider.cancelDiscussion()).thenAnswer((_) async => false);

      await presenter.cancelEvent();

      verifyNever(mockView.closeDrawer());
    });
  });

  group('wereChangesMade', () {
    test('true', () async {
      when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(true);
      expect(presenter.wereChangesMade(), isTrue);
    });

    test('false', () async {
      when(mockEditDiscussionPresenterHelper.wereChangesMade(model)).thenReturn(false);
      expect(presenter.wereChangesMade(), isFalse);
    });
  });

  test('showConfirmChangesDialog', () {
    presenter.showConfirmChangesDialog();
    verify(mockAppDrawerProvider.showConfirmChangesDialogLayer()).called(1);
  });

  group('canBuildParticipantCountSection', () {
    void executeTest(DiscussionType discussionType) {
      test('$discussionType', () {
        model.discussion = getDiscussion().copyWith(nullableDiscussionType: discussionType);
        final result = presenter.canBuildParticipantCountSection();

        switch (discussionType) {
          case DiscussionType.hosted:
            expect(result, isTrue);
            break;
          case DiscussionType.hostless:
          case DiscussionType.livestream:
            expect(result, isFalse);
            break;
        }
      });
    }

    for (var discussionType in DiscussionType.values) {
      executeTest(discussionType);
    }
  });
}
