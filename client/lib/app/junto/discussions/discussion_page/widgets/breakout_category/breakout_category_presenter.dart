import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/utils/extensions.dart';

class BreakoutCategoryPresenter extends ChangeNotifier {
  final DiscussionProvider discussionProvider;

  BreakoutCategoryPresenter({required this.discussionProvider});

  List<BreakoutCategory> get breakoutCategories =>
      discussionProvider.discussion.breakoutRoomDefinition?.categories ?? [];
}
