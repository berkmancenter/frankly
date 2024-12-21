import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:client/services/firestore/firestore_database.dart';
import 'package:client/services/firestore/firestore_discussion_threads_service.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:mockito/mockito.dart';
import '../../mocked_classes.mocks.dart';

void main() {
  final mockFirestoreDatabase = MockFirestoreDatabase();
  final mockFirebaseFirestore = MockFirebaseFirestore();
  final mockCollectionReference =
      MockCollectionReference<Map<String, dynamic>>();
  final mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
  final mockQuery = MockQuery<Map<String, dynamic>>();
  final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
  final mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
  final mockEmotionHelper = MockEmotionHelper();
  final mockEmotion = MockEmotion();
  final mockWriteBatch = MockWriteBatch();
  final FirestoreDiscussionThreadsService firestoreDiscussionThreadsService =
      FirestoreDiscussionThreadsService();

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
    final result =
        firestoreDiscussionThreadsService.getPathToCollection(communityId: '1');

    expect(result, 'community/1/discussion-threads');
  });

  test('getPathToDocument', () {
    final result = firestoreDiscussionThreadsService.getPathToDocument(
      communityId: '1',
      discussionThreadId: '2',
    );

    expect(result, 'community/1/discussion-threads/2');
  });

  test('getNewDocumentId', () {
    when(
      mockFirestoreDatabase.generateNewDocId(
        collectionPath: 'community/communityId/discussion-threads',
      ),
    ).thenReturn('docId');

    final result =
        firestoreDiscussionThreadsService.getNewDocumentId('communityId');

    expect(result, 'docId');
    verify(
      mockFirestoreDatabase.generateNewDocId(
        collectionPath: 'community/communityId/discussion-threads',
      ),
    ).called(1);
  });

  test(
    'getDiscussionThreadsStream',
    () {
      // Leaving for git reference
      // when(mockFirestoreDatabase.firestore).thenReturn(mockFirebaseFirestore);
      // when(mockFirebaseFirestore.collection('community/communityId/discussion-threads'))
      //     .thenReturn(mockCollectionReference);
      // when(mockCollectionReference.where(DiscussionThread.kFieldIsDeleted, isEqualTo: false))
      //     .thenReturn(mockQuery);
      // when(mockCollectionReference.orderBy(DiscussionThread.kFieldCreatedAt, descending: true))
      //     .thenReturn(mockQuery);
      // when(mockQuery.snapshots()).thenReturn(mockQuerySnapshot);
    },
    skip: 'Not sure how to write it properly',
  );

  test(
    'getDiscussionThreadStream',
    () {},
    skip: 'Not sure how to write it properly',
  );

  test('addNewDiscussionThread', () async {
    const collectionPath = 'community/communityId/discussion-threads';
    final discussionThread =
        DiscussionThread(id: 'oldId', creatorId: 'creatorId', content: '');
    final newDiscussionThread =
        DiscussionThread(id: 'newId', creatorId: 'creatorId', content: '');
    when(mockFirestoreDatabase.firestore).thenReturn(mockFirebaseFirestore);
    when(mockFirebaseFirestore.collection(collectionPath))
        .thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc('newId'))
        .thenReturn(mockDocumentReference);
    when(mockFirestoreDatabase.generateNewDocId(collectionPath: collectionPath))
        .thenReturn('newId');

    await firestoreDiscussionThreadsService.addNewDiscussionThread(
      'communityId',
      discussionThread,
    );

    verify(
      mockDocumentReference.set(toFirestoreJson(newDiscussionThread.toJson())),
    ).called(1);
  });

  test('updateDiscussionThread', () async {
    const docPath = 'community/communityId/discussion-threads/docId';
    final discussionThread =
        DiscussionThread(id: 'docId', creatorId: 'creatorId', content: '');
    when(mockFirestoreDatabase.firestore).thenReturn(mockFirebaseFirestore);
    when(mockFirebaseFirestore.doc(docPath)).thenReturn(mockDocumentReference);

    await firestoreDiscussionThreadsService.updateDiscussionThread(
      'communityId',
      discussionThread,
    );

    verify(
      mockDocumentReference.update(toFirestoreJson(discussionThread.toJson())),
    ).called(1);
  });

  test('deleteDiscussionThread', () async {
    const docPath = 'community/communityId/discussion-threads/docId';
    when(mockFirestoreDatabase.firestore).thenReturn(mockFirebaseFirestore);
    when(mockFirebaseFirestore.doc(docPath)).thenReturn(mockDocumentReference);

    await firestoreDiscussionThreadsService.deleteDiscussionThread(
      communityId: 'communityId',
      discussionThreadId: 'docId',
    );

    verify(
      mockDocumentReference.update({DiscussionThread.kFieldIsDeleted: true}),
    ).called(1);
  });

  group('toggleLike', () {
    void executeTest(LikeType likeType) {
      test('$likeType', () async {
        const docPath = 'community/communityId/discussion-threads/docId';
        when(mockFirestoreDatabase.firestore).thenReturn(mockFirebaseFirestore);
        when(mockFirebaseFirestore.doc(docPath))
            .thenReturn(mockDocumentReference);

        await firestoreDiscussionThreadsService.toggleLike(
          likeType,
          'userId',
          communityId: 'communityId',
          discussionThread: DiscussionThread(
            id: 'docId',
            creatorId: 'creatorId',
            content: '',
          ),
        );

        switch (likeType) {
          case LikeType.like:
            verify(
              mockDocumentReference.update({
                DiscussionThread.kFieldLikedByIds:
                    FieldValue.arrayUnion(['userId']),
                DiscussionThread.kFieldDislikedByIds:
                    FieldValue.arrayRemove(['userId']),
              }),
            ).called(1);
            break;
          case LikeType.neutral:
            verify(
              mockDocumentReference.update({
                DiscussionThread.kFieldLikedByIds:
                    FieldValue.arrayRemove(['userId']),
                DiscussionThread.kFieldDislikedByIds:
                    FieldValue.arrayRemove(['userId']),
              }),
            ).called(1);
            break;
          case LikeType.dislike:
            verify(
              mockDocumentReference.update({
                DiscussionThread.kFieldLikedByIds:
                    FieldValue.arrayRemove(['userId']),
                DiscussionThread.kFieldDislikedByIds:
                    FieldValue.arrayUnion(['userId']),
              }),
            ).called(1);
            break;
        }
      });
    }

    for (var likeType in LikeType.values) {
      executeTest(likeType);
    }
  });

  test('updateEmotion', () async {
    final existingEmotion = MockEmotion();
    final emotion = MockEmotion();
    const docPath = 'community/communityId/discussion-threads/docId';
    final discussionThread =
        DiscussionThread(id: 'docId', creatorId: 'creatorId', content: '');
    when(mockFirestoreDatabase.firestore).thenReturn(mockFirebaseFirestore);
    when(mockFirebaseFirestore.batch()).thenReturn(mockWriteBatch);
    when(mockFirebaseFirestore.doc(docPath)).thenReturn(mockDocumentReference);
    when(mockDocumentReference.get())
        .thenAnswer((_) async => mockDocumentSnapshot);
    when(mockDocumentSnapshot.reference).thenReturn(mockDocumentReference);
    when(
      mockEmotionHelper.updateBatch(
        mockDocumentReference,
        existingEmotion,
        emotion,
        mockWriteBatch,
      ),
    );

    await firestoreDiscussionThreadsService.updateEmotion(
      emotion,
      existingEmotion: existingEmotion,
      communityId: 'communityId',
      discussionThread: discussionThread,
      emotionHelper: mockEmotionHelper,
    );

    verify(mockWriteBatch.commit()).called(1);
  });
}
