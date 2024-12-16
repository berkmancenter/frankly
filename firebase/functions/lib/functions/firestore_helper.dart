/**
 * Helper for functions in the '/on_firestore' directory. This does not get deployed as a standalone firebase function. 
 */

class FirestoreHelper {
  static const _kCommunity = 'community';
  static const kCommunityId = 'communityId';
  // Under community
  static const _kDiscussionThreads = 'discussion-threads';
  static const kDiscussionThreadId = 'discussionThreadId';
  // Under discussion-threads
  static const _kDiscussionThreadComments = 'discussion-thread-comments';
  static const kDiscussionThreadCommentId = 'discussionThreadCommentId';
  // ---
  static const kMembership = 'membership';
  // Under membership. Very important - collection name is `community-membership` not `community-membershipS`.
  static const kCommunityMemberships = 'community-membership';

  String getPathToCommunityTrigger() {
    return '$_kCommunity/{$kCommunityId}';
  }

  String getPathToCommunityCollection() {
    return _kCommunity;
  }

  String getPathToCommunityDocument({required String communityId}) {
    return '$_kCommunity/$communityId';
  }

  String getPathToDiscussionThreadsTrigger() {
    final prePath = getPathToCommunityTrigger();
    return '$prePath/$_kDiscussionThreads/{$kDiscussionThreadId}';
  }

  String getPathToDiscussionThreadsCollection({required String communityId}) {
    final prePath = getPathToCommunityDocument(communityId: communityId);
    return '$prePath/$_kDiscussionThreads';
  }

  String getPathToDiscussionThreadsDocument({
    required String communityId,
    required String discussionThreadId,
  }) {
    final prePath = getPathToCommunityDocument(communityId: communityId);
    return '$prePath/$_kDiscussionThreads/$discussionThreadId';
  }

  String getPathToDiscussionThreadCommentsTrigger() {
    final prePath = getPathToDiscussionThreadsTrigger();
    return '$prePath/$_kDiscussionThreadComments/{$kDiscussionThreadCommentId}';
  }

  String getPathToDiscussionThreadCommentsCollection({
    required String communityId,
    required String discussionThreadId,
  }) {
    final prePath = getPathToDiscussionThreadsDocument(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );
    return '$prePath/$_kDiscussionThreadComments';
  }

  String getPathToDiscussionThreadCommentsDocument({
    required String communityId,
    required String discussionThreadId,
    required String discussionThreadCommentId,
  }) {
    final prePath = getPathToDiscussionThreadsDocument(
      communityId: communityId,
      discussionThreadId: discussionThreadId,
    );
    return '$prePath/$_kDiscussionThreadComments/$discussionThreadCommentId';
  }
}
