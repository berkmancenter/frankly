import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/services/firestore/firestore_database.dart';
import 'package:junto/services/firestore/firestore_discussion_thread_comments_service.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto_models/firestore/discussion_thread_comment.dart';
import 'package:mockito/mockito.dart';
import '../../mocked_classes.mocks.dart';

void main() {
  final mockFirestoreDatabase = MockFirestoreDatabase();
  final mockFirebaseFirestore = MockFirebaseFirestore();
  final mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
  final mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
  final mockQuery = MockQuery<Map<String, dynamic>>();
  final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
  final mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
  final mockEmotionHelper = MockEmotionHelper();
  final mockEmotion = MockEmotion();
  final mockWriteBatch = MockWriteBatch();
  final firestoreDiscussionThreadCommentsService = FirestoreDiscussionThreadCommentsService();

  setUp(() {
    GetIt.instance.registerSingleton<FirestoreDatabase>(mockFirestoreDatabase);
  });

  tearDown(() async {
    reset(mockFirestoreDatabase);
    reset(mockFirebaseFirestore);
    reset(mockCollectionReference);
    reset(mockDocumentReference);
    reset(mockQuery);
    reset(mockQuerySnapshot);
    reset(mockDocumentSnapshot);
    reset(mockEmotionHelper);
    reset(mockEmotion);
    reset(mockWriteBatch);
    await GetIt.instance.reset();
  });

  test('getPathToCollection', () {
    final result = firestoreDiscussionThreadCommentsService.getPathToCollection(
      juntoId: '1',
      discussionThreadId: '2',
    );

    expect(result, 'junto/1/discussion-threads/2/discussion-thread-comments');
  });

  test('getPathToDocument', () {
    final result = firestoreDiscussionThreadCommentsService.getPathToDocument(
      juntoId: '1',
      discussionThreadId: '2',
      discussionThreadCommentId: '3',
    );

    expect(result, 'junto/1/discussion-threads/2/discussion-thread-comments/3');
  });

  test('getNewDocumentId', () {
    when(
      mockFirestoreDatabase.generateNewDocId(
          collectionPath:
              'junto/juntoId/discussion-threads/discussionThreadId/discussion-thread-comments'),
    ).thenReturn('docId');

    final result = firestoreDiscussionThreadCommentsService.getNewDocumentId(
      juntoId: 'juntoId',
      discussionThreadId: 'discussionThreadId',
    );

    expect(result, 'docId');
    verify(
      mockFirestoreDatabase.generateNewDocId(
          collectionPath:
              'junto/juntoId/discussion-threads/discussionThreadId/discussion-thread-comments'),
    ).called(1);
  });

  test('getDiscussionThreadCommentsStream', () {}, skip: 'not sure how to test');

  test('getMostRecentDiscussionThreadCommentsStream', () {}, skip: 'not sure how to test');

  test('addNewDiscussionThreadComment', () async {
    const collectionPath =
        'junto/juntoId/discussion-threads/discussionThreadId/discussion-thread-comments';
    final discussionThreadComment = DiscussionThreadComment(
      id: 'oldId',
      creatorId: 'creatorId',
      comment: 'comment',
    );
    final newDiscussionThreadComment = DiscussionThreadComment(
      id: 'newId',
      creatorId: 'creatorId',
      comment: 'comment',
    );
    when(mockFirestoreDatabase.firestore).thenReturn(mockFirebaseFirestore);
    when(mockFirebaseFirestore.collection(collectionPath)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc('newId')).thenReturn(mockDocumentReference);
    when(mockFirestoreDatabase.generateNewDocId(collectionPath: collectionPath))
        .thenReturn('newId');

    await firestoreDiscussionThreadCommentsService.addNewDiscussionThreadComment(
      juntoId: 'juntoId',
      discussionThreadId: 'discussionThreadId',
      discussionThreadComment: discussionThreadComment,
    );

    verify(mockDocumentReference.set(toFirestoreJson(newDiscussionThreadComment.toJson()))).called(1);
  });

  test('deleteDiscussionThreadComment', () async {
    const docPath =
        'junto/juntoId/discussion-threads/discussionThreadId/discussion-thread-comments/discussionCommentId';
    when(mockFirestoreDatabase.firestore).thenReturn(mockFirebaseFirestore);
    when(mockFirebaseFirestore.doc(docPath)).thenReturn(mockDocumentReference);

    await firestoreDiscussionThreadCommentsService.deleteDiscussionThreadComment(
      juntoId: 'juntoId',
      discussionThreadId: 'discussionThreadId',
      discussionThreadComment: DiscussionThreadComment(
        id: 'discussionCommentId',
        creatorId: 'creatorId',
        comment: 'comment',
        isDeleted: false,
      ),
    );

    verify(mockDocumentReference.update({DiscussionThreadComment.kFieldIsDeleted: true})).called(1);
  });

  test('updateEmotion', () async {
    final existingEmotion = MockEmotion();
    final emotion = MockEmotion();
    const docPath =
        'junto/juntoId/discussion-threads/discussionThreadId/discussion-thread-comments/docId';
    final discussionThreadComment = DiscussionThreadComment(
      id: 'docId',
      creatorId: 'creatorId',
      comment: '',
    );
    when(mockFirestoreDatabase.firestore).thenReturn(mockFirebaseFirestore);
    when(mockFirebaseFirestore.batch()).thenReturn(mockWriteBatch);
    when(mockFirebaseFirestore.doc(docPath)).thenReturn(mockDocumentReference);
    when(mockDocumentReference.get()).thenAnswer((_) async => await mockDocumentSnapshot);
    when(mockDocumentSnapshot.reference).thenReturn(mockDocumentReference);
    when(mockEmotionHelper.updateBatch(
        mockDocumentReference, existingEmotion, emotion, mockWriteBatch));

    await firestoreDiscussionThreadCommentsService.updateEmotion(
      emotion,
      existingEmotion: existingEmotion,
      juntoId: 'juntoId',
      discussionThreadId: 'discussionThreadId',
      discussionThreadComment: discussionThreadComment,
      emotionHelper: mockEmotionHelper,
    );

    verify(mockWriteBatch.commit()).called(1);
  });
}
