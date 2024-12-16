import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_card_widget/pre_post_card_widget_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/prerequisite_topic_widget/prerequisite_topic_widget_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/prerequisite_topic_widget/prerequisite_topic_widget_page.dart';

class PrerequisiteTopicWidgetPresenter {
  final PrePostCardWidgetView _view;
  final PrerequisiteTopicWidgetModel _model;

  PrerequisiteTopicWidgetPresenter(
    this._view,
    this._model,
  );

  String? get selectedTopic => _model.selectedTopicId;

  bool isEditIconShown() {
    return _model.isEditable &&
        _model.prerequisiteTopicWidgetType == PrerequisiteTopicWidgetType.overview;
  }

  void setTopicId(topicId) {
    _model.selectedTopicId = topicId;
  }

  void onChangedTopic(topicId) {
    if (_model.prerequisiteTopicWidgetType == PrerequisiteTopicWidgetType.overview) {
      updateCardType();
    }
    _model.selectedTopicId = topicId;
    _view.updateView();
  }

  void toggleExpansion() {
    _model.isExpanded = !_model.isExpanded;
    _view.updateView();
  }

  void updateCardType() {
    switch (_model.prerequisiteTopicWidgetType) {
      case PrerequisiteTopicWidgetType.overview:
        _model.prerequisiteTopicWidgetType = PrerequisiteTopicWidgetType.edit;
        break;
      case PrerequisiteTopicWidgetType.edit:
        _model.prerequisiteTopicWidgetType = PrerequisiteTopicWidgetType.overview;
        break;
    }
    _view.updateView();
  }
}
