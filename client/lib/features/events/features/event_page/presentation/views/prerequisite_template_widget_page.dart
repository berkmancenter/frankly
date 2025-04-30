import 'package:client/core/utils/toast_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_card_widget_contract.dart';
import 'package:client/features/events/features/event_page/data/models/prerequisite_template_widget_model.dart';
import 'package:client/features/events/features/event_page/presentation/prerequisite_template_widget_presenter.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';

enum PrerequisiteTemplateWidgetType {
  overview,
  edit,
}

class PrerequisiteTemplateWidgetPage extends StatefulWidget {
  final void Function(String) onUpdate;
  final void Function() onDelete;
  final Event? event;
  final Template? template;
  final Future<List<Template>>? templatesFuture;
  final PrerequisiteTemplateWidgetType prerequisiteTemplateWidgetType;
  final bool isEditable;
  final bool isWhiteBackground;

  const PrerequisiteTemplateWidgetPage({
    Key? key,
    required this.onUpdate,
    required this.onDelete,
    this.event,
    this.template,
    this.templatesFuture,
    this.isWhiteBackground = false,
    this.prerequisiteTemplateWidgetType =
        PrerequisiteTemplateWidgetType.overview,
    this.isEditable = false,
  }) : super(key: key);

  @override
  State<PrerequisiteTemplateWidgetPage> createState() =>
      _PrerequisiteTemplateWidgetPageState();
}

class _PrerequisiteTemplateWidgetPageState
    extends State<PrerequisiteTemplateWidgetPage>
    implements PrePostCardWidgetView {
  final _scrollController = ScrollController();
  late final PrerequisiteTemplateWidgetModel _model;
  late final PrerequisiteTemplateWidgetPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _model = PrerequisiteTemplateWidgetModel(
      event: widget.event,
      isEditable: widget.isEditable,
      template: widget.template,
      prerequisiteTemplateWidgetType: widget.prerequisiteTemplateWidgetType,
    );
    _presenter = PrerequisiteTemplateWidgetPresenter(this, _model);
    final event = widget.event;
    if (event != null) {
      _presenter.setTemplateId(widget.event?.prerequisiteTemplateId);
    } else {
      _presenter.setTemplateId(widget.template?.prerequisiteTemplateId);
    }
  }

  @override
  void updateView() {
    setState(() {});
  }

  @override
  void showToast(String text) {
    showRegularToast(context, text, toastType: ToastType.success);
  }

  Future<void> _showDeleteDialog() async {
    await ConfirmDialog(
      title: 'Delete prerequisite template',
      mainText: 'Are you sure want to delete?',
      onConfirm: (context) {
        Navigator.pop(context);
        widget.onDelete();
      },
    ).show();
  }

  Widget _buildCardContent() {
    switch (_model.prerequisiteTemplateWidgetType) {
      case PrerequisiteTemplateWidgetType.overview:
        return _buildOverviewPrePostCard();
      case PrerequisiteTemplateWidgetType.edit:
        return _buildEditablePrePostCard();
    }
  }

  Widget _buildEditablePrePostCard() {
    return Column(
      key: Key('prePostCardWidget-editablePrePostCard'),
      children: [
        _buildPrerequisiteTemplateSection(),
        SizedBox(height: 14),
        Container(
          alignment: Alignment.centerRight,
          child: FloatingActionButton(
            onPressed: () {
              final selectedTemplate = _presenter.selectedTemplate;
              if (selectedTemplate != null) {
                _presenter.updateCardType();
                widget.onUpdate(selectedTemplate);
              }
            },
            backgroundColor: widget.isWhiteBackground
                ? context.theme.colorScheme.primary
                : context.theme.colorScheme.onPrimary,
            child: Icon(
              Icons.check,
              size: 16,
              color: widget.isWhiteBackground
                  ? context.theme.colorScheme.onPrimary
                  : context.theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrerequisiteTemplateSection() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.isWhiteBackground
            ? context.theme.colorScheme.surface
            : context.theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeightConstrainedText(
            'Template',
            style: AppTextStyle.subhead.copyWith(
              color: widget.isWhiteBackground
                  ? context.theme.colorScheme.primary
                  : context.theme.colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.theme.colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomStreamBuilder<List<Template>>(
                    stream: widget.templatesFuture?.asStream(),
                    entryFrom:
                        '_PrerequisiteTemplateWidgetPageState._buildPrerequisiteTemplateSection',
                    height: 40,
                    builder: (_, templates) {
                      templates ??= [];
                      final templateIds = templates.map((e) => e.id).toSet();
                      final currentTemplateId =
                          widget.event?.templateId ?? widget.template?.id;
                      templates.removeWhere(
                        (value) => value.id == currentTemplateId,
                      );

                      return DropdownButton<String>(
                        value: templateIds.contains(_presenter.selectedTemplate)
                            ? _presenter.selectedTemplate
                            : null,
                        isExpanded: true,
                        icon: Icon(
                          CupertinoIcons.chevron_down,
                          color: widget.isWhiteBackground
                              ? context.theme.colorScheme.primary
                              : context.theme.colorScheme.onPrimary,
                        ),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                          color: context.theme.colorScheme.onPrimary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        underline: SizedBox.shrink(),
                        iconEnabledColor: context.theme.colorScheme.primary,
                        onChanged: (templateId) =>
                            _presenter.onChangedTemplate(templateId),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            enabled: true,
                            child: Container(
                              // Add alignment, because by default it show on top
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  templates.isEmpty
                                      ? 'No Templates Available'
                                      : 'Choose Template',
                                  style: AppTextStyle.body.copyWith(
                                    color: context.theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          for (final template in templates)
                            DropdownMenuItem(
                              value: template.id,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    template.title ?? '',
                                    style: AppTextStyle.body.copyWith(
                                      color: context.theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                        selectedItemBuilder: (_) => [
                          DropdownMenuItem(
                            value: null,
                            enabled: false,
                            child: Container(
                              // Add alignment, because by default it show on top
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  (templates ?? []).isEmpty
                                      ? 'No Templates Available'
                                      : 'Choose Template',
                                  style: AppTextStyle.body.copyWith(
                                    color: widget.isWhiteBackground
                                        ? context.theme.colorScheme.primary
                                        : context.theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          for (final Template template in templates ?? [])
                            DropdownMenuItem(
                              value: template.id,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    template.title ?? '',
                                    style: AppTextStyle.body.copyWith(
                                      color: widget.isWhiteBackground
                                          ? context.theme.colorScheme.primary
                                          : context.theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewPrePostCard() {
    return Container(
      key: Key('prePostCardWidget-overviewPrePostCard'),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: widget.isWhiteBackground
            ? context.theme.colorScheme.surface
            : context.theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildPrerequisiteTemplateSection()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditIconShown = _presenter.isEditIconShown();

    return Material(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: widget.isWhiteBackground
                    ? context.theme.colorScheme.surfaceContainerLowest
                    : context.theme.colorScheme.primary,
                border: Border.all(
                  width: 1,
                  color: widget.isWhiteBackground
                      ? context.theme.colorScheme.outline
                      : context.theme.colorScheme.primary,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _presenter.toggleExpansion(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Prerequisite Template',
                            style: AppTextStyle.subhead.copyWith(
                              color: widget.isWhiteBackground
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        if (_model.isEditable)
                          IconButton(
                            key: Key(
                              'prerequisiteTemplateWidgetPage-deleteCard',
                            ),
                            icon: Icon(
                              Icons.delete,
                              color: widget.isWhiteBackground
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.onPrimary,
                            ),
                            onPressed: () => _showDeleteDialog(),
                          ),
                        if (isEditIconShown)
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: widget.isWhiteBackground
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.onPrimary,
                            ),
                            onPressed: () => _presenter.updateCardType(),
                          ),
                        IconButton(
                          icon: Icon(
                            _model.isExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: widget.isWhiteBackground
                                ? context.theme.colorScheme.primary
                                : context.theme.colorScheme.onPrimary,
                          ),
                          onPressed: () => _presenter.toggleExpansion(),
                        ),
                      ],
                    ),
                  ),
                  if (_model.isExpanded) SizedBox(height: 20),
                  // Apply additional animation for more fancy experience
                  AnimatedSize(
                    duration: kTabScrollDuration,
                    curve: Curves.easeIn,
                    child: Container(
                      child: _model.isExpanded ? _buildCardContent() : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
