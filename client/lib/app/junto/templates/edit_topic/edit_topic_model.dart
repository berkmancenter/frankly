import 'package:junto_models/firestore/topic.dart';

class EditTopicModel {
  late Topic topic;
  late final Topic initialTopic;
  bool? isFeatured;
  bool? initialFeatured;

  EditTopicModel();
}
