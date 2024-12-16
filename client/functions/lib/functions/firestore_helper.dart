/**
 * Helper for functions in the '/on_firestore' directory. This does not get deployed as a standalone firebase function. 
 */

class FirestoreHelper {
  static const _kJunto = 'junto';
  static const kJuntoId = 'juntoId';
  // Under junto
  static const _kDiscussionThreads = 'discussion-threads';
  static const kDiscussionThreadId = 'discussionThreadId';
  // Under discussion-threads
  static const _kDiscussionThreadComments = 'discussion-thread-comments';
  static const kDiscussionThreadCommentId = 'discussionThreadCommentId';
  // ---
  static const kMembership = 'membership';
  // Under membership. Very important - collection name is `junto-membership` not `junto-membershipS`.
  static const kJuntoMemberships = 'junto-membership';

  String getPathToJuntoTrigger() {
    return '$_kJunto/{$kJuntoId}';
  }

  String getPathToJuntoCollection() {
    return _kJunto;
  }

  String getPathToJuntoDocument({required String juntoId}) {
    return '$_kJunto/$juntoId';
  }

  String getPathToDiscussionThreadsTrigger() {
    final prePath = getPathToJuntoTrigger();
    return '$prePath/$_kDiscussionThreads/{$kDiscussionThreadId}';
  }

  String getPathToDiscussionThreadsCollection({required String juntoId}) {
    final prePath = getPathToJuntoDocument(juntoId: juntoId);
    return '$prePath/$_kDiscussionThreads';
  }

  String getPathToDiscussionThreadsDocument({
    required String juntoId,
    required String discussionThreadId,
  }) {
    final prePath = getPathToJuntoDocument(juntoId: juntoId);
    return '$prePath/$_kDiscussionThreads/$discussionThreadId';
  }

  String getPathToDiscussionThreadCommentsTrigger() {
    final prePath = getPathToDiscussionThreadsTrigger();
    return '$prePath/$_kDiscussionThreadComments/{$kDiscussionThreadCommentId}';
  }

  String getPathToDiscussionThreadCommentsCollection({
    required String juntoId,
    required String discussionThreadId,
  }) {
    final prePath = getPathToDiscussionThreadsDocument(
      juntoId: juntoId,
      discussionThreadId: discussionThreadId,
    );
    return '$prePath/$_kDiscussionThreadComments';
  }

  String getPathToDiscussionThreadCommentsDocument({
    required String juntoId,
    required String discussionThreadId,
    required String discussionThreadCommentId,
  }) {
    final prePath = getPathToDiscussionThreadsDocument(
      juntoId: juntoId,
      discussionThreadId: discussionThreadId,
    );
    return '$prePath/$_kDiscussionThreadComments/$discussionThreadCommentId';
  }
}
