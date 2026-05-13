import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { OnFirestoreFunction, FirestoreEventType } from '../on_firestore_function';
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils';
import { firestoreHelper, FirestoreHelper } from '../utils/infra/on_firestore_helper';

interface DiscussionThreadComment {
  id?: string;
  isDeleted?: boolean;
  [key: string]: unknown;
}

type DocumentSnapshot = admin.firestore.DocumentSnapshot;

export class OnDiscussionThreadComment extends OnFirestoreFunction<DiscussionThreadComment> {
  constructor() {
    super(
      [
        { functionName: 'DiscussionThreadCommentOnCreate', firestoreEventType: FirestoreEventType.onCreate },
        { functionName: 'DiscussionThreadCommentOnDelete', firestoreEventType: FirestoreEventType.onDelete },
        { functionName: 'DiscussionThreadCommentOnUpdate', firestoreEventType: FirestoreEventType.onUpdate },
      ],
      (snapshot: DocumentSnapshot) => ({
        ...(firestoreUtils.fromFirestoreJson(snapshot.data() ?? {}) as unknown as DiscussionThreadComment),
        id: snapshot.id,
      })
    );
  }

  get documentPath(): string {
    return firestoreHelper.getPathToDiscussionThreadCommentsTrigger();
  }

  async onCreate(
    documentSnapshot: DocumentSnapshot,
    _parsedData: DiscussionThreadComment,
    _updateTime: Date,
    context: functions.EventContext
  ): Promise<void> {
    const communityId = context.params[FirestoreHelper.kCommunityId];
    if (!communityId) throw new Error('communityId is null');
    const discussionThreadId = context.params[FirestoreHelper.kDiscussionThreadId];
    if (!discussionThreadId) throw new Error('discussionThreadId is null');

    const pathToDiscussionThread = firestoreHelper.getPathToDiscussionThreadsDocument({
      communityId,
      discussionThreadId,
    });
    const threadSnap = await firestore.doc(pathToDiscussionThread).get();
    const updateMap = { commentCount: admin.firestore.FieldValue.increment(1) };
    console.log(`ID: ${documentSnapshot.id}, Data:`, updateMap);
    await threadSnap.ref.update(updateMap);
  }

  async onUpdate(
    changes: functions.Change<DocumentSnapshot>,
    before: DiscussionThreadComment,
    after: DiscussionThreadComment,
    _updateTime: Date,
    context: functions.EventContext
  ): Promise<void> {
    const communityId = context.params[FirestoreHelper.kCommunityId];
    if (!communityId) throw new Error('communityId is null');
    const discussionThreadId = context.params[FirestoreHelper.kDiscussionThreadId];
    if (!discussionThreadId) throw new Error('discussionThreadId is null');

    const pathToDiscussionThread = firestoreHelper.getPathToDiscussionThreadsDocument({
      communityId,
      discussionThreadId,
    });

    const beforeIsDeleted = before.isDeleted;
    const afterIsDeleted = after.isDeleted;

    if (beforeIsDeleted !== afterIsDeleted) {
      const threadSnap = await firestore.doc(pathToDiscussionThread).get();
      const incrementValue = afterIsDeleted ? -1 : 1;
      const updateMap = { commentCount: admin.firestore.FieldValue.increment(incrementValue) };
      console.log(`Path: ${pathToDiscussionThread}, Data:`, updateMap);
      await threadSnap.ref.update(updateMap);
    }
  }

  async onDelete(
    documentSnapshot: DocumentSnapshot,
    _parsedData: DiscussionThreadComment,
    _updateTime: Date,
    context: functions.EventContext
  ): Promise<void> {
    const communityId = context.params[FirestoreHelper.kCommunityId];
    if (!communityId) throw new Error('communityId is null');
    const discussionThreadId = context.params[FirestoreHelper.kDiscussionThreadId];
    if (!discussionThreadId) throw new Error('discussionThreadId is null');

    const pathToDiscussionThread = firestoreHelper.getPathToDiscussionThreadsDocument({
      communityId,
      discussionThreadId,
    });
    const threadSnap = await firestore.doc(pathToDiscussionThread).get();

    const updateMap = { commentCount: admin.firestore.FieldValue.increment(-1) };
    console.log(`ID: ${documentSnapshot.id}, Data:`, updateMap);

    if (!threadSnap.exists) {
      console.log(`Discussion Thread (${threadSnap.id}) not found. Probably it is already deleted`);
      return;
    }

    await threadSnap.ref.update(updateMap);
  }
}
