import 'dart:math';

import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/discussion_threads/data/models/manipulate_discussion_thread_model.dart';
import 'package:client/features/discussion_threads/presentation/manipulate_discussion_thread_presenter.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBuildContext = MockBuildContext();
  final mockView = MockManipulateDiscussionThreadView();
  final mockDiscussionThreadsHelper = MockDiscussionThreadsHelper();
  final mockFirestoreDiscussionThreadsService =
      MockFirestoreDiscussionThreadsService();
  final mockMediaHelperService = MockMediaHelperService();
  final mockResponsiveLayoutService = MockResponsiveLayoutService();
  final mockUserService = MockUserService();
  final mockCommunityProvider = MockCommunityProvider();
  final mockDiscussionThread = MockDiscussionThread();

  late ManipulateDiscussionThreadModel model;
  late ManipulateDiscussionThreadPresenter presenter;

  void reinitialisePresenter(ManipulateDiscussionThreadModel manipulateModel) {
    model = manipulateModel;
    presenter = ManipulateDiscussionThreadPresenter(
      mockBuildContext,
      mockView,
      model,
      discussionThreadsHelper: mockDiscussionThreadsHelper,
      firestoreDiscussionThreadsService: mockFirestoreDiscussionThreadsService,
      mediaHelperService: mockMediaHelperService,
      responsiveLayoutService: mockResponsiveLayoutService,
      userService: mockUserService,
    );
  }

  setUp(() {
    reinitialisePresenter(
      ManipulateDiscussionThreadModel(mockCommunityProvider, null),
    );
  });

  tearDown(() {
    reset(mockBuildContext);
    reset(mockView);
    reset(mockDiscussionThreadsHelper);
    reset(mockFirestoreDiscussionThreadsService);
    reset(mockMediaHelperService);
    reset(mockResponsiveLayoutService);
    reset(mockUserService);
    reset(mockCommunityProvider);
    reset(mockDiscussionThread);
  });

  group('init', () {
    test('existingDiscussionThread is null', () {
      reinitialisePresenter(
        ManipulateDiscussionThreadModel(mockCommunityProvider, null),
      );

      presenter.init();

      expect(model.content.isEmpty, isTrue);
    });

    test('existingDiscussionThread is not null', () {
      reinitialisePresenter(
        ManipulateDiscussionThreadModel(
          mockCommunityProvider,
          DiscussionThread(
            id: 'id',
            creatorId: 'creatorId',
            content: 'content',
          ),
        ),
      );

      presenter.init();

      expect(model.content, 'content');
    });
  });

  test('getUserId', () {
    when(mockUserService.currentUserId).thenReturn('userId');

    final result = presenter.getUserId();

    expect(result, 'userId');
  });

  group('getPositiveButtonText', () {
    test('existingDiscussionThread is not null', () {
      reinitialisePresenter(
        ManipulateDiscussionThreadModel(mockCommunityProvider, null),
      );

      final result = presenter.getPositiveButtonText();

      expect(result, 'Post');
    });

    test('existingDiscussionThread is not null', () {
      reinitialisePresenter(
        ManipulateDiscussionThreadModel(
          mockCommunityProvider,
          mockDiscussionThread,
        ),
      );

      final result = presenter.getPositiveButtonText();

      expect(result, 'Update');
    });
  });

  group('addNewDiscussionThread', () {
    test('discussionThread is null', () async {
      reinitialisePresenter(
        ManipulateDiscussionThreadModel(
          mockCommunityProvider,
          DiscussionThread(id: 'id', creatorId: 'creatorId', content: ''),
        ),
      );
      model.content = 'content';
      model.pickedImageUrl = 'pickedImageUrl';
      when(mockCommunityProvider.communityId).thenReturn('communityId');
      when(mockUserService.currentUserId).thenReturn('userId');
      when(
        mockFirestoreDiscussionThreadsService.getNewDocumentId('communityId'),
      ).thenReturn('docId');
      when(
        mockDiscussionThreadsHelper.addNewDiscussionThread(
          discussionThreadContent: 'content',
          userId: 'userId',
          pickedImageUrl: 'pickedImageUrl',
          documentId: 'docId',
          mediaHelperService: mockMediaHelperService,
          onError: anyNamed('onError'),
        ),
      ).thenAnswer((_) async => await null);

      final result = await presenter.addNewDiscussionThread();

      expect(result, isFalse);
      verifyNever(mockView.showMessage(any, toastType: anyNamed('toastType')));
      verifyNever(
        mockFirestoreDiscussionThreadsService.addNewDiscussionThread(
          any,
          any,
        ),
      );
    });

    test('discussionThread is not null', () async {
      reinitialisePresenter(
        ManipulateDiscussionThreadModel(
          mockCommunityProvider,
          DiscussionThread(id: 'id', creatorId: 'creatorId', content: ''),
        ),
      );
      model.content = 'content';
      model.pickedImageUrl = 'pickedImageUrl';
      when(mockCommunityProvider.communityId).thenReturn('communityId');
      when(mockUserService.currentUserId).thenReturn('userId');
      when(
        mockFirestoreDiscussionThreadsService.getNewDocumentId('communityId'),
      ).thenReturn('docId');
      when(
        mockDiscussionThreadsHelper.addNewDiscussionThread(
          discussionThreadContent: 'content',
          userId: 'userId',
          pickedImageUrl: 'pickedImageUrl',
          documentId: 'docId',
          mediaHelperService: mockMediaHelperService,
          onError: anyNamed('onError'),
        ),
      ).thenAnswer((_) async => mockDiscussionThread);

      final result = await presenter.addNewDiscussionThread();

      expect(result, isTrue);
      verify(
        mockView.showMessage(
          'Post has been created',
          toastType: ToastType.success,
        ),
      ).called(1);
      verify(
        mockFirestoreDiscussionThreadsService.addNewDiscussionThread(
          'communityId',
          mockDiscussionThread,
        ),
      ).called(1);
    });
  });

  group('updateDiscussionThread', () {
    test('discussionThread is null', () async {
      reinitialisePresenter(
        ManipulateDiscussionThreadModel(
          mockCommunityProvider,
          DiscussionThread(id: 'id', creatorId: 'creatorId', content: ''),
        ),
      );
      model.content = 'content';
      model.pickedImageUrl = 'pickedImageUrl';
      when(mockCommunityProvider.communityId).thenReturn('communityId');
      when(mockUserService.currentUserId).thenReturn('userId');
      when(
        mockDiscussionThreadsHelper.updateDiscussionThread(
          existingDiscussionThread: model.existingDiscussionThread,
          discussionThreadContent: 'content',
          pickedImageUrl: 'pickedImageUrl',
          generalHelperService: mockMediaHelperService,
          onError: anyNamed('onError'),
        ),
      ).thenAnswer((_) async => await null);

      final result = await presenter.updateDiscussionThread();

      expect(result, isFalse);
      verifyNever(mockView.showMessage(any, toastType: anyNamed('toastType')));
      verifyNever(
        mockFirestoreDiscussionThreadsService.updateDiscussionThread(
          any,
          any,
        ),
      );
    });

    test('discussionThread is not null', () async {
      reinitialisePresenter(
        ManipulateDiscussionThreadModel(
          mockCommunityProvider,
          mockDiscussionThread,
        ),
      );
      model.content = 'content';
      model.pickedImageUrl = 'pickedImageUrl';
      when(mockCommunityProvider.communityId).thenReturn('communityId');
      when(mockUserService.currentUserId).thenReturn('userId');
      when(
        mockDiscussionThreadsHelper.updateDiscussionThread(
          existingDiscussionThread: model.existingDiscussionThread,
          discussionThreadContent: 'content',
          pickedImageUrl: 'pickedImageUrl',
          generalHelperService: mockMediaHelperService,
          onError: anyNamed('onError'),
        ),
      ).thenAnswer((_) async => mockDiscussionThread);

      final result = await presenter.updateDiscussionThread();

      expect(result, isTrue);
      verify(
        mockView.showMessage(
          'Post has been updated',
          toastType: ToastType.success,
        ),
      ).called(1);
      verify(
        mockFirestoreDiscussionThreadsService.updateDiscussionThread(
          'communityId',
          mockDiscussionThread,
        ),
      ).called(1);
    });
  });

  test('updateContent', () {
    expect(model.content, '');

    presenter.updateContent(' content ');

    expect(model.content, ' content ');
  });

  test('getCommunityDisplayId', () {
    when(mockCommunityProvider.displayId).thenReturn('displayId');

    final result = presenter.getCommunityDisplayId();

    expect(result, 'displayId');
  });

  group('addEmojiToContent', () {
    const text = 'bitcoin to the moon';
    //b i t c o i n   t o    t  h  e     m  o  o  n
    //0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18

    test('before first char', () {
      model.content = text;
      presenter.addEmojiToContent(EmotionType.heart, -100);
      expect(model.content, '❤️bitcoin to the moon');
    });

    test('very first char', () {
      model.content = text;
      presenter.addEmojiToContent(EmotionType.heart, 0);
      expect(model.content, '❤️bitcoin to the moon');
    });

    test('middle of the text', () {
      model.content = text;
      presenter.addEmojiToContent(EmotionType.heartEyes, 10);
      expect(model.content, 'bitcoin to😍 the moon');
    });

    test('last char', () {
      model.content = text;
      presenter.addEmojiToContent(EmotionType.hundred, 19);
      expect(model.content, 'bitcoin to the moon💯');
    });

    test('after last char', () {
      model.content = text;
      presenter.addEmojiToContent(EmotionType.hundred, 100);
      expect(model.content, 'bitcoin to the moon💯');
    });
  });

  test('isMobile', () {
    final value = Random().nextBool();
    when(mockResponsiveLayoutService.isMobile(mockBuildContext))
        .thenReturn(value);

    final result = presenter.isMobile(mockBuildContext);

    expect(result, value);
  });
}
