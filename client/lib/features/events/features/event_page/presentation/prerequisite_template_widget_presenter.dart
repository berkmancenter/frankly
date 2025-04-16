import 'package:client/features/events/features/event_page/presentation/views/pre_post_card_widget_contract.dart';
import 'package:client/features/events/features/event_page/data/models/prerequisite_template_widget_model.dart';
import 'package:client/features/events/features/event_page/presentation/views/prerequisite_template_widget_page.dart';

class PrerequisiteTemplateWidgetPresenter {
  final PrePostCardWidgetView _view;
  final PrerequisiteTemplateWidgetModel _model;

  PrerequisiteTemplateWidgetPresenter(
    this._view,
    this._model,
  );

  String? get selectedTemplate => _model.selectedTemplateId;

  bool isEditIconShown() {
    return _model.isEditable &&
        _model.prerequisiteTemplateWidgetType ==
            PrerequisiteTemplateWidgetType.overview;
  }

  void setTemplateId(templateId) {
    _model.selectedTemplateId = templateId;
  }

  void onChangedTemplate(templateId) {
    if (_model.prerequisiteTemplateWidgetType ==
        PrerequisiteTemplateWidgetType.overview) {
      updateCardType();
    }
    _model.selectedTemplateId = templateId;
    _view.updateView();
  }

  void toggleExpansion() {
    _model.isExpanded = !_model.isExpanded;
    _view.updateView();
  }

  void updateCardType() {
    switch (_model.prerequisiteTemplateWidgetType) {
      case PrerequisiteTemplateWidgetType.overview:
        _model.prerequisiteTemplateWidgetType =
            PrerequisiteTemplateWidgetType.edit;
        break;
      case PrerequisiteTemplateWidgetType.edit:
        _model.prerequisiteTemplateWidgetType =
            PrerequisiteTemplateWidgetType.overview;
        break;
    }
    _view.updateView();
  }
}
