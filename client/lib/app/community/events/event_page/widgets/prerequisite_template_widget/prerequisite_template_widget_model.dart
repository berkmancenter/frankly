import 'package:client/app/community/events/event_page/widgets/prerequisite_template_widget/prerequisite_template_widget_page.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';

class PrerequisiteTemplateWidgetModel {
  final Event? event;
  final Template? template;

  final bool isEditable;

  PrerequisiteTemplateWidgetType prerequisiteTemplateWidgetType;

  bool isExpanded = true;

  String? selectedTemplateId;

  PrerequisiteTemplateWidgetModel({
    this.event,
    required this.isEditable,
    required this.prerequisiteTemplateWidgetType,
    this.template,
  });
}
