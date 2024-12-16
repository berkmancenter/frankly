import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto_models/firestore/discussion_thread.dart';

class ManipulateDiscussionThreadModel {
  final JuntoProvider juntoProvider;
  final DiscussionThread? existingDiscussionThread;

  String content = '';
  String? pickedImageUrl;

  ManipulateDiscussionThreadModel(this.juntoProvider, this.existingDiscussionThread);
}
