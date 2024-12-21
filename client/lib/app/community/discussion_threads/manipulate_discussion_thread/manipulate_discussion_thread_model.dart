import 'package:client/app/community/community_provider.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';

class ManipulateDiscussionThreadModel {
  final CommunityProvider communityProvider;
  final DiscussionThread? existingDiscussionThread;

  String content = '';
  String? pickedImageUrl;

  ManipulateDiscussionThreadModel(
    this.communityProvider,
    this.existingDiscussionThread,
  );
}
