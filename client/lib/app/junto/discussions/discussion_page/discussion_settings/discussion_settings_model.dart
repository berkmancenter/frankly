import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_drawer.dart';
import 'package:junto_models/firestore/discussion.dart';

class DiscussionSettingsModel {
  final DiscussionSettingsDrawerType discussionSettingsDrawerType;
  late final String title;
  late final DiscussionSettings initialDiscussionSettings;
  late DiscussionSettings discussionSettings;
  late final DiscussionSettings defaultSettings;

  DiscussionSettingsModel(this.discussionSettingsDrawerType);
}
