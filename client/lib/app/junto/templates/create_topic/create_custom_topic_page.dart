import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_presenter.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_tag_presenter.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/create_tag_widget.dart';
import 'package:junto/common_widgets/editable_image.dart';
import 'package:junto/common_widgets/featured_toggle_button.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

enum TopicActionType {
  create,
  edit,
  duplicate,
}

class CreateCustomTopicPage extends StatelessWidget {
  final FutureOr<void> Function(Topic topic)? afterSubmit;
  final JuntoProvider juntoProvider;
  final TopicActionType topicActionType;
  final Topic? topic;
  const CreateCustomTopicPage({
    this.afterSubmit,
    required this.juntoProvider,
    required this.topicActionType,
    this.topic,
  });
  @override
  Widget build(BuildContext context) {
    final topicId = topic?.id ??
        firestoreDatabase.generateNewDocId(
          collectionPath: firestoreDatabase.topicsCollection(juntoProvider.junto.id).path,
        );
    return ChangeNotifierProvider<CreateTopicPresenter>(
      create: (_) => CreateTopicPresenter(
        juntoProvider: juntoProvider,
        topicActionType: topicActionType,
        topic: topic,
        topicId: topicId,
      )..initialize(),
      child: ChangeNotifierProvider<CreateTopicTagPresenter>(
        create: (_) => CreateTopicTagPresenter(
            topicId: topicId,
            juntoId: juntoProvider.junto.id,
            isNewTopic: topicActionType != TopicActionType.edit)
          ..initialize(),
        child: _CreateCustomTopicPage(afterSubmit: afterSubmit),
      ),
    );
  }
}

class _CreateCustomTopicPage extends StatefulWidget {
  final FutureOr<void> Function(Topic topic)? afterSubmit;

  const _CreateCustomTopicPage({
    Key? key,
    this.afterSubmit,
  }) : super(key: key);

  @override
  __CreateCustomTopicPageState createState() => __CreateCustomTopicPageState();
}

class __CreateCustomTopicPageState extends State<_CreateCustomTopicPage> {
  final borderRadius = BorderRadius.circular(4);

  Future<void> _getButtonFunction() {
    final topicPresenter = context.read<CreateTopicPresenter>();
    final tagPresenter = context.read<CreateTopicTagPresenter>();
    switch (topicPresenter.topicActionType) {
      case TopicActionType.create:
        return alertOnError(
            context,
            () => guardJuntoMember(context, topicPresenter.juntoProvider.junto, () async {
                  final newTopic = await topicPresenter.createTopic();
                  await tagPresenter.submit();
                  final localAfterSubmit = widget.afterSubmit;
                  if (localAfterSubmit != null) {
                    await localAfterSubmit(newTopic);
                  }
                  Navigator.of(context).pop(newTopic);
                }));
      case TopicActionType.edit:
        return alertOnError(
            context,
            () => guardJuntoMember(context, topicPresenter.juntoProvider.junto, () async {
                  await topicPresenter.updateTopic();
                  await tagPresenter.submit();
                  final localAfterSubmit = widget.afterSubmit;
                  if (localAfterSubmit != null) {
                    await localAfterSubmit(topicPresenter.updatedTopic);
                  }
                }));
      case TopicActionType.duplicate:
        return alertOnError(
            context,
            () => guardJuntoMember(context, topicPresenter.juntoProvider.junto, () async {
                  final newTopic = await topicPresenter.createTopic();
                  await tagPresenter.submit();
                  Navigator.of(context).pop(newTopic);
                }));
    }
  }

  Widget _buildCurrentPage() {
    final topicPresenter = context.read<CreateTopicPresenter>();
    final title = topicPresenter.getPageTitle();
    final buttonTitle = topicPresenter.getButtonTitle();

    return JuntoListView(
      children: [
        JuntoText(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 30,
                color: AppColor.darkBlue,
              ),
        ),
        SizedBox(height: 25),
        _buildDisplayLayout(context),
        SizedBox(height: 15),
        Align(
          alignment: Alignment.centerRight,
          child: ActionButton(
            onPressed: _getButtonFunction,
            text: buttonTitle,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAddTagsSection() {
    final topicTagPresenter = Provider.of<CreateTopicTagPresenter>(context);
    return Padding(
      padding: EdgeInsets.all(20),
      child: JuntoStreamBuilder(
        entryFrom: 'CreateCustomTopicPage._buildAddTagsSection',
        stream: topicTagPresenter.tagsStream,
        builder: (context, _) => CreateTagWidget(
          tags: Provider.of<CreateTopicTagPresenter>(context).tags,
          onAddTag: (text) => alertOnError(context, () => topicTagPresenter.addTag(text)),
          checkIsSelected: (tag) => topicTagPresenter.isSelected(tag),
          onTapTag: (tag) => alertOnError(context, () => topicTagPresenter.onTapTag(tag)),
        ),
      ),
    );
  }

  Widget _buildDisplayLayout(BuildContext context) {
    final topicPresenter = context.read<CreateTopicPresenter>();
    final canEditCommunity = Provider.of<CommunityPermissionsProvider>(context).canEditCommunity;
    if (responsiveLayoutService.isMobile(context)) {
      return Column(
        children: [
          SizedBox(height: 10),
          _buildImage(),
          SizedBox(height: 10),
          ..._buildTextFields(),
          if (topicPresenter.topicActionType == TopicActionType.edit && canEditCommunity) ...[
            SizedBox(width: 10),
            _buildFeaturedToggle(),
          ],
          SizedBox(height: 10),
          _buildAddTagsSection(),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(height: 10),
            _buildImage(),
            SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: _buildTextFields(),
              ),
            ),
          ],
        ),
        if (topicPresenter.topicActionType == TopicActionType.edit && canEditCommunity) ...[
          SizedBox(height: 20),
          _buildFeaturedToggle(),
        ],
        SizedBox(height: 20),
        _buildAddTagsSection(),
      ],
    );
  }

  Widget _buildImage() {
    final topicPresenter = context.watch<CreateTopicPresenter>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: AppColor.white,
        width: 160,
        height: 160,
        child: EditableImage(
          initialUrl: topicPresenter.updatedTopic.image ?? '',
          allowEdit: true,
          onImageSelect: (image) => topicPresenter.updateTopicImage(image),
          child: JuntoImage(topicPresenter.updatedTopic.image),
        ),
      ),
    );
  }

  List<Widget> _buildTextFields() {
    final topicPresenter = context.watch<CreateTopicPresenter>();
    return [
      Align(
        alignment: Alignment.topLeft,
        child: JuntoTextField(
          labelText: 'Template name',
          maxLines: 1,
          maxLength: titleMaxCharactersLength,
          initialValue: !isNullOrEmpty(topicPresenter.updatedTopic.title)
              ? topicPresenter.updatedTopic.title
              : null,
          onChanged: (value) => topicPresenter.onChangeTitle(value),
        ),
      ),
      SizedBox(height: 10),
      Align(
        alignment: Alignment.topLeft,
        child: JuntoTextField(
          labelText: 'Description',
          minLines: 4,
          maxLines: 4,
          initialValue: !isNullOrEmpty(topicPresenter.updatedTopic.description)
              ? topicPresenter.updatedTopic.description
              : null,
          onChanged: (value) => topicPresenter.onChangeDescription(value),
        ),
      ),
    ];
  }

  Widget _buildFeaturedToggle() {
    final topicPresenter = context.watch<CreateTopicPresenter>();
    return FeaturedToggleButton(
      controlAffinity: ListTileControlAffinity.leading,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      textColor: AppColor.darkBlue,
      juntoId: topicPresenter.juntoProvider.juntoId,
      label: 'Feature on ${topicPresenter.juntoProvider.junto.name} homepage',
      documentId: topicPresenter.updatedTopic.id,
      documentPath:
          '/junto/${topicPresenter.juntoProvider.juntoId}/topics/${topicPresenter.updatedTopic.id}',
      featuredType: FeaturedType.topic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCurrentPage();
  }
}
