import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_card_widget/pre_post_card_widget_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/prerequisite_topic_widget/prerequisite_topic_widget_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/prerequisite_topic_widget/prerequisite_topic_widget_presenter.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/topic.dart';

enum PrerequisiteTopicWidgetType {
  overview,
  edit,
}

class PrerequisiteTopicWidgetPage extends StatefulWidget {
  final void Function(String) onUpdate;
  final void Function() onDelete;
  final Discussion? discussion;
  final Topic? topic;
  final Future<List<Topic>>? topicsFuture;
  final PrerequisiteTopicWidgetType prerequisiteTopicWidgetType;
  final bool isEditable;
  final bool isWhiteBackground;

  const PrerequisiteTopicWidgetPage({
    Key? key,
    required this.onUpdate,
    required this.onDelete,
    this.discussion,
    this.topic,
    this.topicsFuture,
    this.isWhiteBackground = false,
    this.prerequisiteTopicWidgetType = PrerequisiteTopicWidgetType.overview,
    this.isEditable = false,
  }) : super(key: key);

  @override
  State<PrerequisiteTopicWidgetPage> createState() => _PrerequisiteTopicWidgetPageState();
}

class _PrerequisiteTopicWidgetPageState extends State<PrerequisiteTopicWidgetPage>
    implements PrePostCardWidgetView {
  final _scrollController = ScrollController();
  late final PrerequisiteTopicWidgetModel _model;
  late final PrerequisiteTopicWidgetPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _model = PrerequisiteTopicWidgetModel(
      discussion: widget.discussion,
      isEditable: widget.isEditable,
      topic: widget.topic,
      prerequisiteTopicWidgetType: widget.prerequisiteTopicWidgetType,
    );
    _presenter = PrerequisiteTopicWidgetPresenter(this, _model);
    final discussion = widget.discussion;
    if (discussion != null) {
      _presenter.setTopicId(widget.discussion?.prerequisiteTopicId);
    } else {
      _presenter.setTopicId(widget.topic?.prerequisiteTopicId);
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
    switch (_model.prerequisiteTopicWidgetType) {
      case PrerequisiteTopicWidgetType.overview:
        return _buildOverviewPrePostCard();
      case PrerequisiteTopicWidgetType.edit:
        return _buildEditablePrePostCard();
    }
  }

  Widget _buildEditablePrePostCard() {
    return Column(
      key: Key('prePostCardWidget-editablePrePostCard'),
      children: [
        _buildPrerequisiteTopicSection(),
        SizedBox(height: 14),
        Container(
          alignment: Alignment.centerRight,
          child: FloatingActionButton(
            onPressed: () {
              final selectedTopic = _presenter.selectedTopic;
              if (selectedTopic != null) {
                _presenter.updateCardType();
                widget.onUpdate(selectedTopic);
              }
            },
            backgroundColor: widget.isWhiteBackground ? AppColor.darkBlue : AppColor.brightGreen,
            child: Icon(
              Icons.check,
              size: 16,
              color: widget.isWhiteBackground ? AppColor.white : AppColor.darkBlue,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPrerequisiteTopicSection() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.isWhiteBackground ? AppColor.gray6 : AppColor.darkerBlue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JuntoText(
            'Template',
            style: AppTextStyle.subhead.copyWith(
              color: widget.isWhiteBackground ? AppColor.darkBlue : AppColor.white,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.gray3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: JuntoStreamBuilder<List<Topic>>(
                    stream: widget.topicsFuture?.asStream(),
                    entryFrom: '_PrerequisiteTopicWidgetPageState._buildPrerequisiteTopicSection',
                    height: 40,
                    builder: (_, topics) {
                      topics ??= [];
                      final topicIds = topics.map((e) => e.id).toSet();
                      final currentTopicId = widget.discussion?.topicId ?? widget.topic?.id;
                      topics.removeWhere((value) => value.id == currentTopicId);

                      return DropdownButton<String>(
                        value: topicIds.contains(_presenter.selectedTopic)
                            ? _presenter.selectedTopic
                            : null,
                        isExpanded: true,
                        icon: Icon(
                          CupertinoIcons.chevron_down,
                          color: widget.isWhiteBackground ? AppColor.darkBlue : AppColor.white,
                        ),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: AppColor.white),
                        borderRadius: BorderRadius.circular(10),
                        underline: SizedBox.shrink(),
                        iconEnabledColor: AppColor.darkBlue,
                        onChanged: (topicId) => _presenter.onChangedTopic(topicId),
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
                                  topics.isEmpty ? 'No Templates Available' : 'Choose Template',
                                  style: AppTextStyle.body.copyWith(
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          for (final topic in topics)
                            DropdownMenuItem(
                              value: topic.id,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    topic.title ?? '',
                                    style: AppTextStyle.body.copyWith(
                                      color: AppColor.darkBlue,
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
                                  (topics ?? []).isEmpty
                                      ? 'No Templates Available'
                                      : 'Choose Template',
                                  style: AppTextStyle.body.copyWith(
                                    color: widget.isWhiteBackground
                                        ? AppColor.darkBlue
                                        : AppColor.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          for (final Topic topic in topics ?? [])
                            DropdownMenuItem(
                              value: topic.id,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    topic.title ?? '',
                                    style: AppTextStyle.body.copyWith(
                                        color: widget.isWhiteBackground
                                            ? AppColor.darkBlue
                                            : AppColor.white),
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
              Spacer()
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOverviewPrePostCard() {
    return Container(
      key: Key('prePostCardWidget-overviewPrePostCard'),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: widget.isWhiteBackground ? AppColor.gray6 : AppColor.darkBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildPrerequisiteTopicSection()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditIconShown = _presenter.isEditIconShown();

    return Material(
      child: JuntoUiMigration(
        whiteBackground: widget.isWhiteBackground,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: widget.isWhiteBackground ? AppColor.white : AppColor.darkBlue,
                  border: Border.all(
                    width: 1,
                    color: widget.isWhiteBackground ? AppColor.gray5 : AppColor.darkBlue,
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
                                color:
                                    widget.isWhiteBackground ? AppColor.darkBlue : AppColor.white,
                              ),
                            ),
                          ),
                          if (_model.isEditable)
                            IconButton(
                              key: Key('prerequisiteTopicWidgetPage-deleteCard'),
                              icon: Icon(
                                Icons.delete,
                                color:
                                    widget.isWhiteBackground ? AppColor.darkBlue : AppColor.white,
                              ),
                              onPressed: () => _showDeleteDialog(),
                            ),
                          if (isEditIconShown)
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color:
                                    widget.isWhiteBackground ? AppColor.darkBlue : AppColor.white,
                              ),
                              onPressed: () => _presenter.updateCardType(),
                            ),
                          IconButton(
                            icon: Icon(
                              _model.isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: widget.isWhiteBackground ? AppColor.darkBlue : AppColor.white,
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
      ),
    );
  }
}
