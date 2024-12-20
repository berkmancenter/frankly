import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../firestore_event_function.dart';
import '../utils/firestore_helper.dart';
import '../on_firestore_function.dart';
import '../utils/firestore_utils.dart';
import 'package:data_models/firestore/discussion_thread.dart';
import 'package:data_models/firestore/discussion_thread_comment.dart';

class OnDiscussionThreadComment
    extends OnFirestoreFunction<DiscussionThreadComment> {
  OnDiscussionThreadComment()
      : super(
          [
            AppFirestoreFunctionData(
              'DiscussionThreadCommentOnCreate',
              FirestoreEventType.onCreate,
            ),
            AppFirestoreFunctionData(
              'DiscussionThreadCommentOnDelete',
              FirestoreEventType.onDelete,
            ),
            AppFirestoreFunctionData(
              'DiscussionThreadCommentOnUpdate',
              FirestoreEventType.onUpdate,
            ),
          ],
          (snapshot) {
            final dataMap = snapshot.data.toMap();
            return DiscussionThreadComment.fromJson(
              firestoreUtils.fromFirestoreJson(dataMap),
            ).copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath =>
      firestoreHelper.getPathToDiscussionThreadCommentsTrigger();

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    DiscussionThreadComment parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    final communityId = context.params[FirestoreHelper.kCommunityId];
    if (communityId == null) {
      throw ArgumentError.notNull('communityId');
    }
    final discussionThreadId =
        context.params[FirestoreHelper.kDiscussionThreadId];
    if (discussionThreadId == null) {
      throw ArgumentError.notNull('discussionThreadId');
    }

    final pathToDiscussionThread =
        firestoreHelper.getPathToDiscussionThreadsDocument(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );
    final discussionThreadSnap =
        await firestore.document(pathToDiscussionThread).get();
    final updateMap = {
      DiscussionThread.kFieldCommentCount: Firestore.fieldValues.increment(1),
    };
    print('ID: ${documentSnapshot.documentID}, Data: $updateMap');

    return discussionThreadSnap.reference
        .updateData(UpdateData.fromMap(updateMap));
  }

  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    DiscussionThreadComment before,
    DiscussionThreadComment after,
    DateTime updateTime,
    EventContext context,
  ) async {
    final communityId = context.params[FirestoreHelper.kCommunityId];
    if (communityId == null) {
      throw ArgumentError.notNull('communityId');
    }
    final discussionThreadId =
        context.params[FirestoreHelper.kDiscussionThreadId];
    if (discussionThreadId == null) {
      throw ArgumentError.notNull('discussionThreadId');
    }

    final pathToDiscussionThread =
        firestoreHelper.getPathToDiscussionThreadsDocument(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );
    final beforeIsDeleted = before.isDeleted;
    final afterIsDeleted = after.isDeleted;

    if (beforeIsDeleted != afterIsDeleted) {
      final discussionThreadSnap =
          await firestore.document(pathToDiscussionThread).get();
      final incrementValue = afterIsDeleted ? -1 : 1;
      final Map<String, FieldValue> updateMap = {
        DiscussionThread.kFieldCommentCount:
            Firestore.fieldValues.increment(incrementValue),
      };

      print('Path: $pathToDiscussionThread, Data: $updateMap');
      await discussionThreadSnap.reference
          .updateData(UpdateData.fromMap(updateMap));
    }
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    DiscussionThreadComment parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    final communityId = context.params[FirestoreHelper.kCommunityId];
    if (communityId == null) {
      throw ArgumentError.notNull('communityId');
    }
    final discussionThreadId =
        context.params[FirestoreHelper.kDiscussionThreadId];
    if (discussionThreadId == null) {
      throw ArgumentError.notNull('discussionThreadId');
    }

    final pathToDiscussionThread =
        firestoreHelper.getPathToDiscussionThreadsDocument(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );
    final discussionThreadSnap =
        await firestore.document(pathToDiscussionThread).get();

    final updateMap = {
      DiscussionThread.kFieldCommentCount: Firestore.fieldValues.increment(-1),
    };
    print('ID: ${documentSnapshot.documentID}, Data: $updateMap');

    // It can crash if `discussionThreadComments` are being deleted when `discussionThread` is deleted.
    // `DiscussionThread` deletion will trigger deletion of all comments within that thread.
    // Therefore during this scenario, `discussionThread` won't exist anymore.
    if (!discussionThreadSnap.exists) {
      print(
        'Discussion Thread (${discussionThreadSnap.documentID}) not found. Probably it is already deleted',
      );
      return;
    }

    return discussionThreadSnap.reference
        .updateData(UpdateData.fromMap(updateMap));
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    DiscussionThreadComment before,
    DiscussionThreadComment after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
