class DiscussionThreadModel {
  final String discussionThreadId;
  final bool scrollToComments;

  bool wasScrolledToComments = false;

  DiscussionThreadModel(this.discussionThreadId, this.scrollToComments);
}
