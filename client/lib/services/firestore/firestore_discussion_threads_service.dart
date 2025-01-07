import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services/services.dart';
import 'package:client/utils/extensions.dart';
import 'package:client/utils/models_helper.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:rxdart/rxdart.dart';

import 'firestore_utils.dart';

class FirestoreDiscussionThreadsService {
  @visibleForTesting
  String getPathToCollection({required String communityId}) {
    return 'community/$communityId/discussion-threads';
  }

  @visibleForTesting
  String getPathToDocument({
    required String communityId,
    required String discussionThreadId,
  }) {
    return 'community/$communityId/discussion-threads/$discussionThreadId';
  }

  String getNewDocumentId(String communityId) {
    final collectionPath = getPathToCollection(communityId: communityId);
    return firestoreDatabase.generateNewDocId(collectionPath: collectionPath);
  }

  Stream<List<DiscussionThread>> getDiscussionThreadsStream({
    required String communityId,
  }) {
    final path = getPathToCollection(communityId: communityId);

    return firestoreDatabase.firestore
        .collection(path)
        .where(DiscussionThread.kFieldIsDeleted, isEqualTo: false)
        .orderBy(DiscussionThread.kFieldCreatedAt, descending: true)
        .snapshots()
        .sampleTime(Duration(milliseconds: 200))
        .map((s) => s.docs)
        .asyncMap(_convertDiscussionThreadListAsync);
  }

  Stream<DiscussionThread> getDiscussionThreadStream({
    required String communityId,
    required String discussionThreadId,
  }) {
    final pathToDoc = getPathToDocument(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );

    return firestoreDatabase.firestore
        .doc(pathToDoc)
        .snapshots()
        .sampleTime(Duration(milliseconds: 200))
        .map(
          (s) => _convertDiscussionThreadItem(s.data() as Map<String, dynamic>),
        );
  }

  Future<void> addNewDiscussionThread(
    String communityId,
    DiscussionThread discussionThread,
  ) async {
    final collectionPath = getPathToCollection(communityId: communityId);
    final id =
        firestoreDatabase.generateNewDocId(collectionPath: collectionPath);
    final finalisedDiscussionThread = discussionThread.copyWith(id: id);
    final dataMap = toFirestoreJson(finalisedDiscussionThread.toJson());

    loggingService.log(
      'FirestoreDiscussionThreadsService.addNewDiscussionThread: Path: $collectionPath, DocID: $id, Data: $dataMap',
    );

    await firestoreDatabase.firestore
        .collection(collectionPath)
        .doc(id)
        .set(toFirestoreJson(dataMap));
  }

  Future<void> updateDiscussionThread(
    String communityId,
    DiscussionThread discussionThread,
  ) async {
    final pathToDoc = getPathToDocument(
      communityId: communityId,
      discussionThreadId: discussionThread.id,
    );
    final dataMap = toFirestoreJson(discussionThread.toJson());

    loggingService.log(
      'FirestoreDiscussionThreadsService.updateDiscussionThread: Path: $pathToDoc, Data: $dataMap',
    );

    await firestoreDatabase.firestore.doc(pathToDoc).update(dataMap);
  }

  Future<void> deleteDiscussionThread({
    required String communityId,
    required String discussionThreadId,
  }) async {
    final pathToDoc = getPathToDocument(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );
    final dataMap = {DiscussionThread.kFieldIsDeleted: true};
    loggingService.log(
      'FirestoreDiscussionThreadsService.updateDiscussionThread: Path: $pathToDoc, Data: $dataMap',
    );

    await firestoreDatabase.firestore.doc(pathToDoc).update(dataMap);
  }

  Future<void> toggleLike(
    LikeType likeType,
    String userId, {
    required String communityId,
    required DiscussionThread discussionThread,
  }) async {
    final pathToDoc = getPathToDocument(
      communityId: communityId,
      discussionThreadId: discussionThread.id,
    );

    loggingService.log(
      'FirestoreDiscussionThreadsService.toggleLike: LikeType: $likeType, UserId: $userId, Path: $pathToDoc',
    );

    switch (likeType) {
      case LikeType.like:
        await firestoreDatabase.firestore.doc(pathToDoc).update({
          DiscussionThread.kFieldLikedByIds: FieldValue.arrayUnion([userId]),
          DiscussionThread.kFieldDislikedByIds:
              FieldValue.arrayRemove([userId]),
        });
        break;
      case LikeType.neutral:
        await firestoreDatabase.firestore.doc(pathToDoc).update({
          DiscussionThread.kFieldLikedByIds: FieldValue.arrayRemove([userId]),
          DiscussionThread.kFieldDislikedByIds:
              FieldValue.arrayRemove([userId]),
        });
        break;
      case LikeType.dislike:
        await firestoreDatabase.firestore.doc(pathToDoc).update({
          DiscussionThread.kFieldLikedByIds: FieldValue.arrayRemove([userId]),
          DiscussionThread.kFieldDislikedByIds: FieldValue.arrayUnion([userId]),
        });
        break;
    }
  }

  Future<void> updateEmotion(
    Emotion emotion, {
    required Emotion? existingEmotion,
    required String communityId,
    required DiscussionThread discussionThread,
    required EmotionHelper emotionHelper,
  }) async {
    final pathToDoc = getPathToDocument(
      communityId: communityId,
      discussionThreadId: discussionThread.id,
    );

    loggingService.log(
      'FirestoreDiscussionThreadsService.updateEmotion: DiscussionEmotion: $emotion, Path: $pathToDoc',
    );

    final docSnap = await firestoreDatabase.firestore.doc(pathToDoc).get();
    final batch = firestoreDatabase.firestore.batch();

    emotionHelper.updateBatch(
      docSnap.reference,
      existingEmotion,
      emotion,
      batch,
    );

    return await batch.commit();
  }

  static Future<List<DiscussionThread>> _convertDiscussionThreadListAsync(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    return Future.wait(
      docs.map(
        (doc) => compute(_convertDiscussionThreadItem, doc.data()),
      ),
    );
  }

  static DiscussionThread _convertDiscussionThreadItem(
    Map<String, dynamic> data,
  ) {
    return DiscussionThread.fromJson(fromFirestoreJson(data));
  }
}
