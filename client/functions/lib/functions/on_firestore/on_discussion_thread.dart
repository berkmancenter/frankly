import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/firestore_event_function.dart';
import 'package:junto_functions/functions/firestore_helper.dart';
import 'package:junto_functions/functions/on_firestore_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/firestore/discussion_thread.dart';

class OnDiscussionThread extends OnFirestoreFunction<DiscussionThread> {
  OnDiscussionThread()
      : super(
          [AppFirestoreFunctionData('DiscussionThreadOnDelete', FirestoreEventType.onDelete)],
          (snapshot) {
            final dataMap = snapshot.data!.toMap();
            return DiscussionThread.fromJson(firestoreUtils.fromFirestoreJson(dataMap)).copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath => firestoreHelper.getPathToDiscussionThreadsTrigger();

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    DiscussionThread parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    final juntoId = context.params[FirestoreHelper.kJuntoId];
    if (juntoId == null) {
      throw ArgumentError.notNull('juntoId');
    }
    final discussionThreadId = context.params[FirestoreHelper.kDiscussionThreadId];
    if (discussionThreadId == null) {
      throw ArgumentError.notNull('discussionThreadId');
    }

    final pathToCollection = firestoreHelper.getPathToDiscussionThreadsDocument(
      juntoId: juntoId,
      discussionThreadId: discussionThreadId,
    );

    final discussionThreadComments = await firestore.collection(pathToCollection).get();
    final futures = discussionThreadComments.documents.map((e) => e.reference.delete());

    print('Path: $pathToCollection. Deleting ${futures.length} discussion thread comments.');

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
