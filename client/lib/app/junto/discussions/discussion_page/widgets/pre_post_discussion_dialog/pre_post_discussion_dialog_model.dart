import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/pre_post_card.dart';

class PrePostDiscussionDialogModel {
  final PrePostCard prePostCard;
  final Discussion discussion;

  PrePostDiscussionDialogModel(this.prePostCard, this.discussion);
}
