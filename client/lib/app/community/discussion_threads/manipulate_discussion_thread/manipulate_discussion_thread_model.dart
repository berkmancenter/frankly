import 'package:client/app/community/community_provider.dart';
import 'package:data_models/firestore/discussion_thread.dart';

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
