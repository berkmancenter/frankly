import 'package:junto/app/junto/discussions/discussion_page/widgets/prerequisite_topic_widget/prerequisite_topic_widget_page.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/topic.dart';

class PrerequisiteTopicWidgetModel {
  final Discussion? discussion;
  final Topic? topic;

  final bool isEditable;

  PrerequisiteTopicWidgetType prerequisiteTopicWidgetType;

  bool isExpanded = true;

  String? selectedTopicId;

  PrerequisiteTopicWidgetModel({
    this.discussion,
    required this.isEditable,
    required this.prerequisiteTopicWidgetType,
    this.topic,
  });
}
