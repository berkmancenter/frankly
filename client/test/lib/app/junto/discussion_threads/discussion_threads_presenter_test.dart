import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussion_threads/discussion_threads_model.dart';
import 'package:junto/app/junto/discussion_threads/discussion_threads_presenter.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto_models/firestore/discussion_thread.dart';
import 'package:junto_models/firestore/discussion_thread_comment.dart';
import 'package:mockito/mockito.dart';
import '../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBuildContext = MockBuildContext();
  final mockView = MockDiscussionThreadsView();
  final mockResponsiveLayoutService = MockResponsiveLayoutService();
  final mockFirestoreDiscussionThreadCommentsService =
      MockFirestoreDiscussionThreadCommentsService();
  final mockFirestoreDiscussionThreadsService = MockFirestoreDiscussionThreadsService();
  final mockUserService = MockUserService();
  final mockJuntoProvider = MockJuntoProvider();
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
      firestoreDiscussionThreadCommentsService: mockFirestoreDiscussionThreadCommentsService,
      firestoreDiscussionThreadsService: mockFirestoreDiscussionThreadsService,
      userService: mockUserService,
      juntoProvider: mockJuntoProvider,
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
    reset(mockJuntoProvider);
    reset(mockEmotionHelper);
    reset(mockDiscussionThread);
    reset(mockEmotion);
    reset(mockStream);
  });

  group('toggleLikeDislike', () {
    void executeTest(LikeType likeType) {
      test('$likeType', () async {
        when(mockJuntoProvider.juntoId).thenReturn('juntoId');
        when(mockUserService.currentUserId).thenReturn('userId');

        await presenter.toggleLikeDislike(likeType, mockDiscussionThread);

        verify(
          mockFirestoreDiscussionThreadsService.toggleLike(likeType, 'userId',
              juntoId: 'juntoId', discussionThread: mockDiscussionThread),
        ).called(1);
      });
    }

    LikeType.values.forEach((likeType) {
      executeTest(likeType);
    });
  });

  test('isMobile', () {
    final value = Random().nextBool();
    when(mockResponsiveLayoutService.isMobile(mockBuildContext)).thenReturn(value);

    expect(value, presenter.isMobile(mockBuildContext));
  });

  group('updateDiscussionEmotion', () {
    void executeTest(EmotionType emotionType) async {
      test(emotionType, () async {
        final emotion = Emotion(creatorId: 'creatorId', emotionType: EmotionType.exclamation);
        final emotions = <Emotion>[mockEmotion, mockEmotion];
        final isSignedIn = Random().nextBool();
        when(mockDiscussionThread.emotions).thenReturn(emotions);
        when(mockUserService.isSignedIn).thenReturn(isSignedIn);
        when(mockJuntoProvider.juntoId).thenReturn('juntoId');
        when(mockUserService.currentUserId).thenReturn('userId');
        when(mockEmotionHelper.getMyEmotion(emotions, isSignedIn, 'userId')).thenReturn(emotion);

        await presenter.updateDiscussionEmotion(emotionType, mockDiscussionThread);

        verify(mockEmotionHelper.getMyEmotion(emotions, isSignedIn, 'userId')).called(1);
        verify(
          mockFirestoreDiscussionThreadsService.updateEmotion(
            Emotion(creatorId: 'userId', emotionType: emotionType),
            existingEmotion: emotion,
            juntoId: 'juntoId',
            discussionThread: mockDiscussionThread,
            emotionHelper: mockEmotionHelper,
          ),
        ).called(1);
      });
    }

    EmotionType.values.forEach((emotionType) {
      executeTest(emotionType);
    });
  });

  test('getJuntoDisplayId', () {
    when(mockJuntoProvider.displayId).thenReturn('displayId');

    final result = presenter.getJuntoDisplayId();

    expect(result, 'displayId');
  });

  test('getJuntoId', () {
    when(mockJuntoProvider.juntoId).thenReturn('juntoId');

    final result = presenter.getJuntoId();

    expect(result, 'juntoId');
  });

  test('getDiscussionThreadsStream', () {
    final stream = MockStream<List<DiscussionThread>>();
    when(mockFirestoreDiscussionThreadsService.getDiscussionThreadsStream(juntoId: 'juntoId'))
        .thenAnswer((_) => stream);

    final result = presenter.getDiscussionThreadsStream('juntoId');

    expect(result, stream);
  });

  test('addNewComment', () async {
    when(mockJuntoProvider.juntoId).thenReturn('juntoId');
    when(mockUserService.currentUserId).thenReturn('userId');
    when(mockFirestoreDiscussionThreadsService.getNewDocumentId('juntoId')).thenReturn('docId');

    await presenter.addNewComment('comment', 'discussionThreadId');

    verify(mockFirestoreDiscussionThreadsService.getNewDocumentId('juntoId')).called(1);
    verify(
      mockFirestoreDiscussionThreadCommentsService.addNewDiscussionThreadComment(
        juntoId: 'juntoId',
        discussionThreadId: 'discussionThreadId',
        discussionThreadComment:
            DiscussionThreadComment(id: 'docId', creatorId: 'userId', comment: 'comment'),
      ),
    ).called(1);
  });

  test('getMostRecentDiscussionThreadCommentStream', () {
    final stream = MockStream<DiscussionThreadComment?>();
    when(mockJuntoProvider.juntoId).thenReturn('juntoId');
    when(
      mockFirestoreDiscussionThreadCommentsService.getMostRecentDiscussionThreadCommentsStream(
          discussionThreadId: 'discussionThreadId', juntoId: 'juntoId'),
    ).thenAnswer((_) => stream);

    final result = presenter.getMostRecentDiscussionThreadCommentStream('discussionThreadId');

    expect(result, stream);
  });

  test('getCurrentlySelectedDiscussionThreadEmotion', () {
    final isSignedIn = Random().nextBool();
    final emotions = <Emotion>[mockEmotion, mockEmotion];
    when(mockUserService.currentUserId).thenReturn('userId');
    when(mockUserService.isSignedIn).thenReturn(isSignedIn);
    when(mockDiscussionThread.emotions).thenReturn(emotions);
    when(mockEmotionHelper.getMyEmotion(emotions, isSignedIn, 'userId')).thenReturn(mockEmotion);

    final result = presenter.getCurrentlySelectedDiscussionThreadEmotion(mockDiscussionThread);

    expect(result, mockEmotion);
    verify(mockEmotionHelper.getMyEmotion(emotions, isSignedIn, 'userId')).called(1);
  });
}
