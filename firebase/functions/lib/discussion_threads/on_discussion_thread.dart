import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../utils/infra/firestore_event_function.dart';
import '../utils/infra/on_firestore_helper.dart';
import '../on_firestore_function.dart';
import '../utils/infra/firestore_utils.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';

class OnDiscussionThread extends OnFirestoreFunction<DiscussionThread> {
  OnDiscussionThread()
      : super(
          [
            AppFirestoreFunctionData(
              'DiscussionThreadOnDelete',
              FirestoreEventType.onDelete,
            ),
          ],
          (snapshot) {
            final dataMap = snapshot.data.toMap();
            return DiscussionThread.fromJson(
              firestoreUtils.fromFirestoreJson(dataMap),
            ).copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath =>
      firestoreHelper.getPathToDiscussionThreadsTrigger();

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    DiscussionThread parsedData,
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

    final pathToCollection = firestoreHelper.getPathToDiscussionThreadsDocument(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );

    final discussionThreadComments =
        await firestore.collection(pathToCollection).get();
    final futures =
        discussionThreadComments.documents.map((e) => e.reference.delete());

    print(
      'Path: $pathToCollection. Deleting ${futures.length} discussion thread comments.',
    );

    await Future.wait(futures);
  }

  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    DiscussionThread before,
    DiscussionThread after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    DiscussionThread parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    DiscussionThread before,
    DiscussionThread after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
