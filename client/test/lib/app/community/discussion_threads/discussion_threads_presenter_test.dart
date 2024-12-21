import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:client/app/community/discussion_threads/discussion_threads_model.dart';
import 'package:client/app/community/discussion_threads/discussion_threads_presenter.dart';
import 'package:client/utils/extensions.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/discussion_threads/discussion_thread_comment.dart';
import 'package:mockito/mockito.dart';
import '../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBuildContext = MockBuildContext();
  final mockView = MockDiscussionThreadsView();
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
  final mockStream = MockStream();

  late DiscussionThreadsModel model;
  late DiscussionThreadsPresenter presenter;

  setUp(() {
    model = DiscussionThreadsModel();
    presenter = DiscussionThreadsPresenter(
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
  });

  tearDown(() {
    reset(mockBuildContext);
    reset(mockView);
    reset(mockResponsiveLayoutService);
    reset(mockFirestoreDiscussionThreadCommentsService);
    reset(mockFirestoreDiscussionThreadsService);
    reset(mockUserService);
    reset(mockCommunityProvider);
    reset(mockEmotionHelper);
    reset(mockDiscussionThread);
    reset(mockEmotion);
    reset(mockStream);
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

  test('isMobile', () {
    final value = Random().nextBool();
    when(mockResponsiveLayoutService.isMobile(mockBuildContext))
        .thenReturn(value);

    expect(value, presenter.isMobile(mockBuildContext));
  });

  group('updateDiscussionEmotion', () {
    void executeTest(EmotionType emotionType) async {
      test(emotionType, () async {
        final emotion = Emotion(
          creatorId: 'creatorId',
          emotionType: EmotionType.exclamation,
        );
        final emotions = <Emotion>[mockEmotion, mockEmotion];
        final isSignedIn = Random().nextBool();
        when(mockDiscussionThread.emotions).thenReturn(emotions);
        when(mockUserService.isSignedIn).thenReturn(isSignedIn);
        when(mockCommunityProvider.communityId).thenReturn('communityId');
        when(mockUserService.currentUserId).thenReturn('userId');
        when(mockEmotionHelper.getMyEmotion(emotions, isSignedIn, 'userId'))
            .thenReturn(emotion);

        await presenter.updateDiscussionEmotion(
          emotionType,
          mockDiscussionThread,
        );

        verify(mockEmotionHelper.getMyEmotion(emotions, isSignedIn, 'userId'))
            .called(1);
        verify(
          mockFirestoreDiscussionThreadsService.updateEmotion(
            Emotion(creatorId: 'userId', emotionType: emotionType),
            existingEmotion: emotion,
            communityId: 'communityId',
            discussionThread: mockDiscussionThread,
            emotionHelper: mockEmotionHelper,
          ),
        ).called(1);
      });
    }

    for (var emotionType in EmotionType.values) {
      executeTest(emotionType);
    }
  });

  test('getCommunityDisplayId', () {
    when(mockCommunityProvider.displayId).thenReturn('displayId');

    final result = presenter.getCommunityDisplayId();

    expect(result, 'displayId');
  });

  test('getCommunityId', () {
    when(mockCommunityProvider.communityId).thenReturn('communityId');

    final result = presenter.getCommunityId();

    expect(result, 'communityId');
  });

  test('getDiscussionThreadsStream', () {
    final stream = MockStream<List<DiscussionThread>>();
    when(
      mockFirestoreDiscussionThreadsService.getDiscussionThreadsStream(
        communityId: 'communityId',
      ),
    ).thenAnswer((_) => stream);

    final result = presenter.getDiscussionThreadsStream('communityId');

    expect(result, stream);
  });

  test('addNewComment', () async {
    when(mockCommunityProvider.communityId).thenReturn('communityId');
    when(mockUserService.currentUserId).thenReturn('userId');
    when(mockFirestoreDiscussionThreadsService.getNewDocumentId('communityId'))
        .thenReturn('docId');

    await presenter.addNewComment('comment', 'discussionThreadId');

    verify(
      mockFirestoreDiscussionThreadsService.getNewDocumentId('communityId'),
    ).called(1);
    verify(
      mockFirestoreDiscussionThreadCommentsService
          .addNewDiscussionThreadComment(
        communityId: 'communityId',
        discussionThreadId: 'discussionThreadId',
        discussionThreadComment: DiscussionThreadComment(
          id: 'docId',
          creatorId: 'userId',
          comment: 'comment',
        ),
      ),
    ).called(1);
  });

  test('getMostRecentDiscussionThreadCommentStream', () {
    final stream = MockStream<DiscussionThreadComment?>();
    when(mockCommunityProvider.communityId).thenReturn('communityId');
    when(
      mockFirestoreDiscussionThreadCommentsService
          .getMostRecentDiscussionThreadCommentsStream(
        discussionThreadId: 'discussionThreadId',
        communityId: 'communityId',
      ),
    ).thenAnswer((_) => stream);

    final result = presenter
        .getMostRecentDiscussionThreadCommentStream('discussionThreadId');

    expect(result, stream);
  });

  test('getCurrentlySelectedDiscussionThreadEmotion', () {
    final isSignedIn = Random().nextBool();
    final emotions = <Emotion>[mockEmotion, mockEmotion];
    when(mockUserService.currentUserId).thenReturn('userId');
    when(mockUserService.isSignedIn).thenReturn(isSignedIn);
    when(mockDiscussionThread.emotions).thenReturn(emotions);
    when(mockEmotionHelper.getMyEmotion(emotions, isSignedIn, 'userId'))
        .thenReturn(mockEmotion);

    final result = presenter
        .getCurrentlySelectedDiscussionThreadEmotion(mockDiscussionThread);

    expect(result, mockEmotion);
    verify(mockEmotionHelper.getMyEmotion(emotions, isSignedIn, 'userId'))
        .called(1);
  });
}
