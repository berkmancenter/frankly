import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services.dart';
import 'package:client/features/discussion_threads/data/services/models_helper.dart';
import 'package:data_models/discussion_threads/discussion_thread_comment.dart';
import 'package:data_models/chat/emotion.dart';
import 'package:data_models/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/utils/firestore_utils.dart';

class FirestoreDiscussionThreadCommentsService {
  @visibleForTesting
  String getPathToCollection({
    required String communityId,
    required String discussionThreadId,
  }) {
    return 'community/$communityId/discussion-threads/$discussionThreadId/discussion-thread-comments';
  }

  @visibleForTesting
  String getPathToDocument({
    required String communityId,
    required String discussionThreadId,
    required String discussionThreadCommentId,
  }) {
    return 'community/$communityId/discussion-threads/$discussionThreadId/discussion-thread-comments/$discussionThreadCommentId';
  }

  String getNewDocumentId({
    required String communityId,
    required String discussionThreadId,
  }) {
    final collectionPath = getPathToCollection(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );
    return firestoreDatabase.generateNewDocId(collectionPath: collectionPath);
  }

  Stream<List<DiscussionThreadComment>> getDiscussionThreadCommentsStream({
    required String communityId,
    required String discussionThreadId,
  }) {
    final path = getPathToCollection(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );

    return firestoreDatabase.firestore
        .collection(path)
        .orderBy(DiscussionThreadComment.kFieldCreatedAt, descending: true)
        .snapshots()
        .sampleTime(Duration(milliseconds: 200))
        .map((s) => s.docs)
        .asyncMap(_convertDiscussionThreadCommentsListAsync);
  }

  Stream<DiscussionThreadComment?> getMostRecentDiscussionThreadCommentsStream({
    required String communityId,
    required String discussionThreadId,
  }) {
    final path = getPathToCollection(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );
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
    required String communityId,
    required String discussionThreadId,
    required DiscussionThreadComment discussionThreadComment,
  }) async {
    final collectionPath = getPathToCollection(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );
    final id =
        firestoreDatabase.generateNewDocId(collectionPath: collectionPath);
    final finalisedDiscussionThreadComment =
        discussionThreadComment.copyWith(id: id);
    final dataMap = toFirestoreJson(finalisedDiscussionThreadComment.toJson());

    loggingService.log(
      'FirestoreDiscussionThreadCommentsService.addNewDiscussionThreadComment: Path: $collectionPath, DocID: $id, Data: $dataMap',
    );

    await firestoreDatabase.firestore
        .collection(collectionPath)
        .doc(id)
        .set(toFirestoreJson(dataMap));
  }

  Future<void> deleteDiscussionThreadComment({
    required String communityId,
    required String discussionThreadId,
    required DiscussionThreadComment discussionThreadComment,
  }) async {
    final updatedComment = discussionThreadComment.copyWith(isDeleted: true);

    final pathToDoc = getPathToDocument(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
      discussionThreadCommentId: discussionThreadComment.id,
    );

    final dataMap = jsonSubset(
      [DiscussionThreadComment.kFieldIsDeleted],
      updatedComment.toJson(),
    );

    loggingService.log(
      'FirestoreDiscussionThreadCommentsService.deleteDiscussionThreadComment: Path: $pathToDoc, Data: $dataMap',
    );

    await firestoreDatabase.firestore.doc(pathToDoc).update(dataMap);
  }

  static Future<List<DiscussionThreadComment>>
      _convertDiscussionThreadCommentsListAsync(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    return Future.wait(
      docs.map(
        (doc) => compute(_convertDiscussionThreadCommentItem, doc.data()),
      ),
    );
  }

  static DiscussionThreadComment _convertDiscussionThreadCommentItem(
    Map<String, dynamic> data,
  ) {
    return DiscussionThreadComment.fromJson(fromFirestoreJson(data));
  }

  Future<void> updateEmotion(
    Emotion emotion, {
    required Emotion? existingEmotion,
    required String communityId,
    required String discussionThreadId,
    required DiscussionThreadComment discussionThreadComment,
    required EmotionHelper emotionHelper,
  }) async {
    final pathToDoc = getPathToDocument(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
      discussionThreadCommentId: discussionThreadComment.id,
    );

    loggingService.log(
      'FirestoreDiscussionThreadCommentsService.updateEmotion: DiscussionEmotion: $emotion, Path: $pathToDoc',
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
}
