import 'package:client/features/events/features/event_page/presentation/views/prerequisite_template_widget_page.dart';
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
