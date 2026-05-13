/**
 * FirestoreHelper — path-building utilities for Firestore document paths.
 * Corresponds to Dart's FirestoreHelper class.
 */
export class FirestoreHelper {
  static readonly kCommunity = 'community';
  static readonly kCommunityId = 'communityId';
  static readonly kDiscussionThreads = 'discussion-threads';
  static readonly kDiscussionThreadId = 'discussionThreadId';
  static readonly kDiscussionThreadComments = 'discussion-thread-comments';
  static readonly kDiscussionThreadCommentId = 'discussionThreadCommentId';
  static readonly kMembership = 'membership';
  static readonly kCommunityMemberships = 'community-membership';

  getPathToCommunityTrigger(): string {
    return `${FirestoreHelper.kCommunity}/{${FirestoreHelper.kCommunityId}}`;
  }

  getPathToCommunityCollection(): string {
    return FirestoreHelper.kCommunity;
  }

  getPathToCommunityDocument({ communityId }: { communityId: string }): string {
    return `${FirestoreHelper.kCommunity}/${communityId}`;
  }

  getPathToDiscussionThreadsTrigger(): string {
    return `${this.getPathToCommunityTrigger()}/${FirestoreHelper.kDiscussionThreads}/{${FirestoreHelper.kDiscussionThreadId}}`;
  }

  getPathToDiscussionThreadsCollection({ communityId }: { communityId: string }): string {
    return `${this.getPathToCommunityDocument({ communityId })}/${FirestoreHelper.kDiscussionThreads}`;
  }

  getPathToDiscussionThreadsDocument({
    communityId,
    discussionThreadId,
  }: {
    communityId: string;
    discussionThreadId: string;
  }): string {
    return `${this.getPathToCommunityDocument({ communityId })}/${FirestoreHelper.kDiscussionThreads}/${discussionThreadId}`;
  }

  getPathToDiscussionThreadCommentsTrigger(): string {
    return `${this.getPathToDiscussionThreadsTrigger()}/${FirestoreHelper.kDiscussionThreadComments}/{${FirestoreHelper.kDiscussionThreadCommentId}}`;
  }

  getPathToDiscussionThreadCommentsCollection({
    communityId,
    discussionThreadId,
  }: {
    communityId: string;
    discussionThreadId: string;
  }): string {
    return `${this.getPathToDiscussionThreadsDocument({ communityId, discussionThreadId })}/${FirestoreHelper.kDiscussionThreadComments}`;
  }

  getPathToDiscussionThreadCommentsDocument({
    communityId,
    discussionThreadId,
    discussionThreadCommentId,
  }: {
    communityId: string;
    discussionThreadId: string;
    discussionThreadCommentId: string;
  }): string {
    return `${this.getPathToDiscussionThreadsDocument({ communityId, discussionThreadId })}/${FirestoreHelper.kDiscussionThreadComments}/${discussionThreadCommentId}`;
  }
}

export const firestoreHelper = new FirestoreHelper();
