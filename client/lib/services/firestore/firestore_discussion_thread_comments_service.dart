import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/models_helper.dart';
import 'package:junto_models/firestore/discussion_thread_comment.dart';
import 'package:junto_models/firestore/emotion.dart';
import 'package:junto_models/utils.dart';
import 'package:rxdart/rxdart.dart';

import 'firestore_utils.dart';

class FirestoreDiscussionThreadCommentsService {
  @visibleForTesting
  String getPathToCollection({
    required String juntoId,
    required String discussionThreadId,
  }) {
    return 'junto/$juntoId/discussion-threads/$discussionThreadId/discussion-thread-comments';
  }

  @visibleForTesting
  String getPathToDocument({
    required String juntoId,
    required String discussionThreadId,
    required String discussionThreadCommentId,
  }) {
    return 'junto/$juntoId/discussion-threads/$discussionThreadId/discussion-thread-comments/$discussionThreadCommentId';
  }

  String getNewDocumentId({required String juntoId, required String discussionThreadId}) {
    final collectionPath = getPathToCollection(
      juntoId: juntoId,
      discussionThreadId: discussionThreadId,
    );
    return firestoreDatabase.generateNewDocId(collectionPath: collectionPath);
  }

  Stream<List<DiscussionThreadComment>> getDiscussionThreadCommentsStream({
    required String juntoId,
    required String discussionThreadId,
  }) {
    final path = getPathToCollection(juntoId: juntoId, discussionThreadId: discussionThreadId);

    return firestoreDatabase.firestore
        .collection(path)
        .orderBy(DiscussionThreadComment.kFieldCreatedAt, descending: true)
        .snapshots()
        .sampleTime(Duration(milliseconds: 200))
        .map((s) => s.docs)
        .asyncMap(_convertDiscussionThreadCommentsListAsync);
  }

  Stream<DiscussionThreadComment?> getMostRecentDiscussionThreadCommentsStream({
    required String juntoId,
    required String discussionThreadId,
  }) {
    final path = getPathToCollection(juntoId: juntoId, discussionThreadId: discussionThreadId);
    return firestoreDatabase.firestore
        .collection(path)
        .where(DiscussionThreadComment.kFieldIsDeleted, isEqualTo: false)
        .orderBy(DiscussionThreadComment.kFieldCreatedAt, descending: true)
        .limit(1)
        .snapshots()
        .sampleTime(Duration(milliseconds: 200))
        .map((s) {
      if (s.docs.isEmpty) {
        return null;
      } else {
        return _convertDiscussionThreadCommentItem(s.docs.first.data());
      }
    });
  }

  Future<void> addNewDiscussionThreadComment({
    required String juntoId,
    required String discussionThreadId,
    required DiscussionThreadComment discussionThreadComment,
  }) async {
    final collectionPath =
        getPathToCollection(juntoId: juntoId, discussionThreadId: discussionThreadId);
    final id = firestoreDatabase.generateNewDocId(collectionPath: collectionPath);
    final finalisedDiscussionThreadComment = discussionThreadComment.copyWith(id: id);
    final dataMap = toFirestoreJson(finalisedDiscussionThreadComment.toJson());

    loggingService.log(
        'FirestoreDiscussionThreadCommentsService.addNewDiscussionThreadComment: Path: $collectionPath, DocID: $id, Data: $dataMap');

    await firestoreDatabase.firestore.collection(collectionPath).doc(id).set(toFirestoreJson(dataMap));
  }

  Future<void> deleteDiscussionThreadComment({
    required String juntoId,
    required String discussionThreadId,
    required DiscussionThreadComment discussionThreadComment,
  }) async {
    final updatedComment = discussionThreadComment.copyWith(isDeleted: true);

    final pathToDoc = getPathToDocument(
      juntoId: juntoId,
      discussionThreadId: discussionThreadId,
      discussionThreadCommentId: discussionThreadComment.id,
    );

    final dataMap = jsonSubset(
      [DiscussionThreadComment.kFieldIsDeleted],
      updatedComment.toJson(),
    );

    loggingService.log(
        'FirestoreDiscussionThreadCommentsService.deleteDiscussionThreadComment: Path: $pathToDoc, Data: $dataMap');

    await firestoreDatabase.firestore.doc(pathToDoc).update(dataMap);
  }

  static Future<List<DiscussionThreadComment>> _convertDiscussionThreadCommentsListAsync(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    return Future.wait(
      docs.map(
        (doc) => compute(_convertDiscussionThreadCommentItem, doc.data()),
      ),
    );
  }

  static DiscussionThreadComment _convertDiscussionThreadCommentItem(Map<String, dynamic> data) {
    return DiscussionThreadComment.fromJson(fromFirestoreJson(data));
  }

  Future<void> updateEmotion(
    Emotion emotion, {
    required Emotion? existingEmotion,
    required String juntoId,
    required String discussionThreadId,
    required DiscussionThreadComment discussionThreadComment,
    required EmotionHelper emotionHelper,
  }) async {
    final pathToDoc = getPathToDocument(
      juntoId: juntoId,
      discussionThreadId: discussionThreadId,
      discussionThreadCommentId: discussionThreadComment.id,
    );

    loggingService.log(
        'FirestoreDiscussionThreadCommentsService.updateEmotion: DiscussionEmotion: $emotion, Path: $pathToDoc');

    final docSnap = await firestoreDatabase.firestore.doc(pathToDoc).get();
    final batch = firestoreDatabase.firestore.batch();

    emotionHelper.updateBatch(docSnap.reference, existingEmotion, emotion, batch);

    return await batch.commit();
  }
}
