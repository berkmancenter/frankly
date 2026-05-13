import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { OnFirestoreFunction, FirestoreEventType } from '../on_firestore_function';
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils';
import { firestoreHelper } from '../utils/infra/on_firestore_helper';
import { FirestoreHelper } from '../utils/infra/on_firestore_helper';

interface DiscussionThread {
  id?: string;
  commentCount?: number;
  [key: string]: unknown;
}

type DocumentSnapshot = admin.firestore.DocumentSnapshot;

export class OnDiscussionThread extends OnFirestoreFunction<DiscussionThread> {
  constructor() {
    super(
      [{ functionName: 'DiscussionThreadOnDelete', firestoreEventType: FirestoreEventType.onDelete }],
      (snapshot: DocumentSnapshot) => ({
        ...(firestoreUtils.fromFirestoreJson(snapshot.data() ?? {}) as unknown as DiscussionThread),
        id: snapshot.id,
      })
    );
  }

  get documentPath(): string {
    return firestoreHelper.getPathToDiscussionThreadsTrigger();
  }

  async onDelete(
    documentSnapshot: DocumentSnapshot,
    _parsedData: DiscussionThread,
    _updateTime: Date,
    context: functions.EventContext
  ): Promise<void> {
    const communityId = context.params[FirestoreHelper.kCommunityId];
    if (!communityId) throw new Error('communityId is null');

    const discussionThreadId = context.params[FirestoreHelper.kDiscussionThreadId];
    if (!discussionThreadId) throw new Error('discussionThreadId is null');

    const pathToCollection = firestoreHelper.getPathToDiscussionThreadsDocument({
      communityId,
      discussionThreadId,
    });

    const discussionThreadComments = await firestore.collection(pathToCollection).get();
    const futures = discussionThreadComments.docs.map((e) => e.ref.delete());
    console.log(`Path: ${pathToCollection}. Deleting ${futures.length} discussion thread comments.`);
    await Promise.all(futures);
  }
}
