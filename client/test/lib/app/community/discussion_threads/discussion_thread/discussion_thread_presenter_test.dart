import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:client/app/community/discussion_threads/discussion_thread/discussion_thread_comment_ui.dart';
import 'package:client/app/community/discussion_threads/discussion_thread/discussion_thread_model.dart';
import 'package:client/app/community/discussion_threads/discussion_thread/discussion_thread_presenter.dart';
import 'package:client/app/community/utils.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/discussion_threads/discussion_thread_comment.dart';
import 'package:data_models/chat/emotion.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBuildContext = MockBuildContext();
  final mockView = MockDiscussionThreadView();
  final mockResponsiveLayoutService = MockResponsiveLayoutService();
  final mockFirestoreDiscussionThreadCommentsService =
      MockFirestoreDiscussionThreadCommentsService();
  final mockFirestoreDiscussionThreadsService =
      MockFirestoreDiscussionThreadsService();
  final mockUserService = MockUserService();
  final mockCommunityProvider = MockCommunityProvider();
  final mockEmotionHelper = MockEmotionHelper();
  final mockDiscussionThread = MockDiscussionThread();
  final mockEmotion = MockEmotion();
  final mockDiscussionThreadComment = MockDiscussionThreadComment();

  late DiscussionThreadModel model;
  late DiscussionThreadPresenter presenter;

  void reinitialisePresenter(DiscussionThreadModel discussionThreadModel) {
    model = discussionThreadModel;
    presenter = DiscussionThreadPresenter(
      mockBuildContext,
      mockView,
      model,
      testResponsiveLayoutService: mockResponsiveLayoutService,
      firestoreDiscussionThreadCommentsService:
          mockFirestoreDiscussionThreadCommentsService,
      firestoreDiscussionThreadsService: mockFirestoreDiscussionThreadsService,
      userService: mockUserService,
      communityProvider: mockCommunityProvider,
      emotionHelper: mockEmotionHelper,
    );
  }

  setUp(() {
    reinitialisePresenter(DiscussionThreadModel('id', true));
  });

  tearDown(() {
    reset(mockBuildContext);
    reset(mockView);
    reset(mockResponsiveLayoutService);
    reset(mockFirestoreDiscussionThreadCommentsService);
    reset(mockFirestoreDiscussionThreadsService);
    reset(mockUserService);
    reset(mockCommunityProvider);
    reset(mockCommunityProvider);
    reset(mockEmotionHelper);
    reset(mockDiscussionThread);
    reset(mockEmotion);
    reset(mockDiscussionThreadComment);
  });

  test('isMobile', () {
    final value = Random().nextBool();
    when(mockResponsiveLayoutService.isMobile(mockBuildContext))
        .thenReturn(value);

    final result = presenter.isMobile(mockBuildContext);

    expect(result, value);
  });

  group('toggleLikeDislike', () {
    void executeTest(LikeType likeType) {
      test('$likeType', () async {
        when(mockCommunityProvider.communityId).thenReturn('communityId');
        when(mockUserService.currentUserId).thenReturn('userId');

        await presenter.toggleLikeDislike(likeType, mockDiscussionThread);

        verify(
          mockFirestoreDiscussionThreadsService.toggleLike(
            likeType,
            'userId',
            communityId: 'communityId',
            discussionThread: mockDiscussionThread,
          ),
        ).called(1);
      });
    }

    for (var likeType in LikeType.values) {
      executeTest(likeType);
    }
  });

  group('getComments', () {
    test('only top level comments', () {
      final comment1 = DiscussionThreadComment(
        id: '1',
        creatorId: 'creatorId',
        comment: 'comment1',
        replyToCommentId: null,
      );
      final comment2 = DiscussionThreadComment(
        id: '2',
        creatorId: 'creatorId',
        comment: 'comment2',
        replyToCommentId: null,
      );
      final comment3 = DiscussionThreadComment(
        id: '3',
        creatorId: 'creatorId1',
        comment: 'comment3',
        replyToCommentId: null,
      );
      final comment4 = DiscussionThreadComment(
        id: '4',
        creatorId: 'creatorId1',
        comment: 'comment4',
        replyToCommentId: null,
      );
      final comment5 = DiscussionThreadComment(
        id: '5',
        creatorId: 'creatorId1',
        comment: 'comment5',
        replyToCommentId: '-1',
      );
      final discussionThreadComments = <DiscussionThreadComment>[
        comment1,
        comment2,
        comment3,
        comment4,
        comment5,
      ];

      final result = presenter.getComments(discussionThreadComments);

      expect(result.length, 4);
      expect(
        result[0].toJson(),
        DiscussionThreadCommentUI(comment1, []).toJson(),
      );
      expect(
        result[1].toJson(),
        DiscussionThreadCommentUI(comment2, []).toJson(),
      );
      expect(
        result[2].toJson(),
        DiscussionThreadCommentUI(comment3, []).toJson(),
      );
      expect(
        result[3].toJson(),
        DiscussionThreadCommentUI(comment4, []).toJson(),
      );
    });

    test('top level with nested comments', () {
      final comment1 = DiscussionThreadComment(
        id: '1',
        creatorId: 'creatorId',
        comment: 'comment1',
        replyToCommentId: null,
      );
      final comment2 = DiscussionThreadComment(
        id: '2',
        creatorId: 'creatorId',
        comment: 'comment2',
        replyToCommentId: null,
      );
      final comment3 = DiscussionThreadComment(
        id: '3',
        creatorId: 'creatorId1',
        comment: 'comment3',
        replyToCommentId: null,
      );
      final comment4 = DiscussionThreadComment(
        id: '4',
        creatorId: 'creatorId1',
        comment: 'comment4',
        replyToCommentId: null,
      );
      final comment5 = DiscussionThreadComment(
        id: '5',
        creatorId: 'creatorId1',
        comment: 'comment5',
        replyToCommentId: '1',
      );
      final comment6 = DiscussionThreadComment(
        id: '6',
        creatorId: 'creatorId2',
        comment: 'comment6',
        replyToCommentId: '1',
      );
      final comment7 = DiscussionThreadComment(
        id: '7',
        creatorId: 'creatorId2',
        comment: 'comment7',
        replyToCommentId: '4',
      );
      final comment8 = DiscussionThreadComment(
        id: '8',
        creatorId: 'creatorId3',
        comment: 'comment8',
        replyToCommentId: '4',
      );
      final discussionThreadComments = <DiscussionThreadComment>[
        comment1,
        comment2,
        comment3,
        comment4,
        comment5,
        comment6,
        comment7,
        comment8,
      ];

      final result = presenter.getComments(discussionThreadComments);

      expect(result.length, 4);
      expect(
        result[0].toJson(),
        DiscussionThreadCommentUI(comment1, [
          comment5,
          comment6,
        ]).toJson(),
      );
      expect(
        result[1].toJson(),
        DiscussionThreadCommentUI(comment2, []).toJson(),
      );
      expect(
        result[2].toJson(),
        DiscussionThreadCommentUI(comment3, []).toJson(),
      );
      expect(
        result[3].toJson(),
        DiscussionThreadCommentUI(comment4, [
          comment7,
          comment8,
        ]).toJson(),
      );
    });
  });

  test('updateDiscussionEmotion', () async {
    final emotions = [mockEmotion];
    final existingEmotion =
        Emotion(creatorId: 'creatorId', emotionType: EmotionType.heart);
    final isSignedIn = Random().nextBool();
    when(mockCommunityProvider.communityId).thenReturn('communityId');
    when(mockUserService.currentUserId).thenReturn('userId');
    when(mockUserService.isSignedIn).thenReturn(isSignedIn);
    when(mockDiscussionThread.emotions).thenReturn(emotions);
    when(mockEmotionHelper.getMyEmotion(emotions, isSignedIn, 'userId'))
        .thenReturn(existingEmotion);

    await presenter.updateDiscussionEmotion(
      EmotionType.exclamation,
      mockDiscussionThread,
    );

    verify(
      mockFirestoreDiscussionThreadsService.updateEmotion(
        Emotion(creatorId: 'userId', emotionType: EmotionType.exclamation),
        existingEmotion: existingEmotion,
        communityId: 'communityId',
        discussionThread: mockDiscussionThread,
        emotionHelper: mockEmotionHelper,
      ),
    ).called(1);
  });

  test('updateDiscussionCommentEmotion', () async {
    final emotions = [mockEmotion];
    final existingEmotion =
        Emotion(creatorId: 'creatorId', emotionType: EmotionType.heart);
    final isSignedIn = Random().nextBool();
    when(mockCommunityProvider.communityId).thenReturn('communityId');
    when(mockUserService.currentUserId).thenReturn('userId');
    when(mockUserService.isSignedIn).thenReturn(isSignedIn);
    when(mockDiscussionThreadComment.emotions).thenReturn(emotions);
    when(mockEmotionHelper.getMyEmotion(emotions, isSignedIn, 'userId'))
        .thenReturn(existingEmotion);

    await presenter.updateDiscussionCommentEmotion(
      emotionType: EmotionType.exclamation,
      discussionThreadComment: mockDiscussionThreadComment,
      discussionThreadId: 'discussionThreadId',
    );

    verify(
      mockFirestoreDiscussionThreadCommentsService.updateEmotion(
        Emotion(creatorId: 'userId', emotionType: EmotionType.exclamation),
        existingEmotion: existingEmotion,
        communityId: 'communityId',
        discussionThreadId: 'discussionThreadId',
        discussionThreadComment: mockDiscussionThreadComment,
        emotionHelper: mockEmotionHelper,
      ),
    ).called(1);
  });

  test('getDiscussionThreadStream', () {
    final stream = MockStream<DiscussionThread>();
    when(mockCommunityProvider.communityId).thenReturn('communityId');
    when(
      mockFirestoreDiscussionThreadsService.getDiscussionThreadStream(
        communityId: 'communityId',
        discussionThreadId: 'id',
      ),
    ).thenAnswer((_) => stream);

    final result = presenter.getDiscussionThreadStream();

    expect(result, stream);
  });

  group('isCreator', () {
    test('true', () {
      when(mockUserService.currentUserId).thenReturn('userId');

      final result = presenter.isCreator(
        DiscussionThread(
          id: 'id',
          creatorId: 'userId',
          content: 'content',
        ),
      );

      expect(result, isTrue);
    });

    test('false', () {
      when(mockUserService.currentUserId).thenReturn('userId');

      final result = presenter.isCreator(
        DiscussionThread(
          id: 'id',
          creatorId: 'userId2',
          content: 'content',
        ),
      );

      expect(result, isFalse);
    });
  });

  test('deleteThread', () async {
    when(mockCommunityProvider.communityId).thenReturn('communityId');

    await presenter.deleteThread();

    verify(
      mockFirestoreDiscussionThreadsService.deleteDiscussionThread(
        communityId: 'communityId',
        discussionThreadId: 'id',
      ),
    ).called(1);
    verify(
      mockView.showMessage(
        'Post was deleted',
        toastType: ToastType.success,
      ),
    ).called(1);
  });

  test('getUserId', () {
    when(mockUserService.currentUserId).thenReturn('userId');

    final result = presenter.getUserId();

    expect(result, 'userId');
  });

  test('addNewComment', () async {
    when(mockCommunityProvider.communityId).thenReturn('communityId');
    when(mockUserService.currentUserId).thenReturn('userId');
    when(
      mockFirestoreDiscussionThreadCommentsService.getNewDocumentId(
        communityId: 'communityId',
        discussionThreadId: 'id',
      ),
    ).thenReturn('docId');

    await presenter.addNewComment(
      comment: 'comment',
      discussionThreadId: 'id',
      replyToCommentId: 'replyToCommentId',
    );

    verify(
      mockFirestoreDiscussionThreadCommentsService
          .addNewDiscussionThreadComment(
        communityId: 'communityId',
        discussionThreadId: 'id',
        discussionThreadComment: DiscussionThreadComment(
          id: 'docId',
          creatorId: 'userId',
          comment: 'comment',
          replyToCommentId: 'replyToCommentId',
        ),
      ),
    ).called(1);
  });

  test('getDiscussionThreadCommentsStream', () {
    final stream = MockStream<List<DiscussionThreadComment>>();
    when(mockCommunityProvider.communityId).thenReturn('communityId');
    when(
      mockFirestoreDiscussionThreadCommentsService
          .getDiscussionThreadCommentsStream(
        communityId: 'communityId',
        discussionThreadId: 'id',
      ),
    ).thenAnswer((_) => stream);

    final result = presenter.getDiscussionThreadCommentsStream();

    expect(result, stream);
  });

  test('getCommunityDisplayId', () {
    when(mockCommunityProvider.displayId).thenReturn('displayId');

    final result = presenter.getCommunityDisplayId();

    expect(result, 'displayId');
  });

  group('scrollToComments', () {
    test('scrollToComments is true and was not scrolled before', () {
      reinitialisePresenter(DiscussionThreadModel('id', true));
      model.wasScrolledToComments = false;

      presenter.scrollToComments();

      expect(model.wasScrolledToComments, isTrue);
      verify(mockView.scrollToComments()).called(1);
    });

    test('scrollToComments is true and was scrolled before', () {
      reinitialisePresenter(DiscussionThreadModel('id', true));
      model.wasScrolledToComments = true;

      presenter.scrollToComments();

      expect(model.wasScrolledToComments, true);
      verifyNever(mockView.scrollToComments());
    });

    test('scrollToComments is false and was not scrolled before', () {
      reinitialisePresenter(DiscussionThreadModel('id', false));
      model.wasScrolledToComments = false;

      presenter.scrollToComments();

      expect(model.wasScrolledToComments, isFalse);
      verifyNever(mockView.scrollToComments());
    });

    test('scrollToComments is false and was scrolled before', () {
      reinitialisePresenter(DiscussionThreadModel('id', false));
      model.wasScrolledToComments = true;

      presenter.scrollToComments();

      expect(model.wasScrolledToComments, true);
      verifyNever(mockView.scrollToComments());
    });
  });

  test('isSignedIn', () {
    final value = Random().nextBool();
    when(mockUserService.isSignedIn).thenReturn(value);

    final result = presenter.isSignedIn();

    expect(result, value);
  });

  test('deleteComment', () async {
    when(mockCommunityProvider.communityId).thenReturn('communityId');

    await presenter.deleteComment(mockDiscussionThreadComment);

    verify(
      mockFirestoreDiscussionThreadCommentsService
          .deleteDiscussionThreadComment(
        communityId: 'communityId',
        discussionThreadId: 'id',
        discussionThreadComment: mockDiscussionThreadComment,
      ),
    ).called(1);
    verify(
      mockView.showMessage(
        'Comment was deleted',
        toastType: ToastType.success,
      ),
    );
  });

  test('getCommentCount', () {
    final comments = <DiscussionThreadComment>[
      DiscussionThreadComment(
        id: 'id',
        creatorId: 'creatorId1',
        comment: 'comment1',
        isDeleted: true,
      ),
      DiscussionThreadComment(
        id: 'id2',
        creatorId: 'creatorId2',
        comment: 'comment2',
        isDeleted: false,
      ),
      DiscussionThreadComment(
        id: 'id3',
        creatorId: 'creatorId3',
        comment: 'comment3',
        isDeleted: true,
      ),
      DiscussionThreadComment(
        id: 'id4',
        creatorId: 'creatorId4',
        comment: 'comment4',
        isDeleted: false,
      ),
    ];

    final result = presenter.getCommentCount(comments);

    expect(result, 2);
  });

  test('getCurrentlySelectedEmotion', () {
    when(mockUserService.currentUserId).thenReturn('userId');
    final isSignedIn = Random().nextBool();
    final emotion =
        Emotion(creatorId: 'userId', emotionType: EmotionType.hundred);
    when(mockUserService.isSignedIn).thenReturn(isSignedIn);
    when(mockEmotionHelper.getMyEmotion([], isSignedIn, 'userId'))
        .thenReturn(emotion);

    final result = presenter.getCurrentlySelectedEmotion([]);

    expect(result, emotion);
  });
}
