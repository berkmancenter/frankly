import 'dart:async';

import 'package:client/features/community/utils/guard_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/features/templates/features/create_template/presentation/create_template_presenter.dart';
import 'package:client/features/templates/features/create_template/presentation/create_template_tag_presenter.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/features/community/presentation/widgets/create_tag_widget.dart';
import 'package:client/core/widgets/editable_image.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

enum TemplateActionType {
  create,
  edit,
  duplicate,
}

class CreateCustomTemplatePage extends StatelessWidget {
  final FutureOr<void> Function(Template template)? afterSubmit;
  final CommunityProvider communityProvider;
  final TemplateActionType templateActionType;
  final Template? template;
  const CreateCustomTemplatePage({
    this.afterSubmit,
    required this.communityProvider,
    required this.templateActionType,
    this.template,
  });
  @override
  Widget build(BuildContext context) {
    final templateId = template?.id ??
        firestoreDatabase.generateNewDocId(
          collectionPath: firestoreDatabase
              .templatesCollection(communityProvider.community.id)
              .path,
        );
    return ChangeNotifierProvider<CreateTemplatePresenter>(
      create: (_) => CreateTemplatePresenter(
        communityProvider: communityProvider,
        templateActionType: templateActionType,
        template: template,
        templateId: templateId,
      )..initialize(),
      child: ChangeNotifierProvider<CreateTemplateTagPresenter>(
        create: (_) => CreateTemplateTagPresenter(
          templateId: templateId,
          communityId: communityProvider.community.id,
          isNewTemplate: templateActionType != TemplateActionType.edit,
        )..initialize(),
        child: _CreateCustomTemplatePage(afterSubmit: afterSubmit),
      ),
    );
  }
}

class _CreateCustomTemplatePage extends StatefulWidget {
  final FutureOr<void> Function(Template template)? afterSubmit;

  const _CreateCustomTemplatePage({
    Key? key,
    this.afterSubmit,
  }) : super(key: key);

  @override
  __CreateCustomTemplatePageState createState() =>
      __CreateCustomTemplatePageState();
}

class __CreateCustomTemplatePageState extends State<_CreateCustomTemplatePage> {
  final borderRadius = BorderRadius.circular(4);
  final int titleMaxCharactersLength = 80;

  Future<void> _getButtonFunction() {
    final templatePresenter = context.read<CreateTemplatePresenter>();
    final tagPresenter = context.read<CreateTemplateTagPresenter>();
    switch (templatePresenter.templateActionType) {
      case TemplateActionType.create:
        return alertOnError(
          context,
          () => guardCommunityMember(
              context, templatePresenter.communityProvider.community, () async {
            final newTemplate = await templatePresenter.createTemplate();
            await tagPresenter.submit();
            final localAfterSubmit = widget.afterSubmit;
            if (localAfterSubmit != null) {
              await localAfterSubmit(newTemplate);
            }
            Navigator.of(context).pop(newTemplate);
          }),
        );
      case TemplateActionType.edit:
        return alertOnError(
          context,
          () => guardCommunityMember(
              context, templatePresenter.communityProvider.community, () async {
            await templatePresenter.updateTemplate();
            await tagPresenter.submit();
            final localAfterSubmit = widget.afterSubmit;
            if (localAfterSubmit != null) {
              await localAfterSubmit(templatePresenter.updatedTemplate);
            }
          }),
        );
      case TemplateActionType.duplicate:
        return alertOnError(
          context,
          () => guardCommunityMember(
              context, templatePresenter.communityProvider.community, () async {
            final newTemplate = await templatePresenter.createTemplate();
            await tagPresenter.submit();
            Navigator.of(context).pop(newTemplate);
          }),
        );
    }
  }

  Widget _buildCurrentPage() {
    final templatePresenter = context.read<CreateTemplatePresenter>();
    final title = templatePresenter.getPageTitle();
    final buttonTitle = templatePresenter.getButtonTitle();

    return CustomListView(
      children: [
        HeightConstrainedText(
          title,
          style: Theme.of(context).textTheme.headlineLarge,
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
    final templateTagPresenter =
        Provider.of<CreateTemplateTagPresenter>(context);
    return Padding(
      padding: EdgeInsets.all(20),
      child: CustomStreamBuilder(
        entryFrom: 'CreateCustomTemplatePage._buildAddTagsSection',
        stream: templateTagPresenter.tagsStream,
        builder: (context, _) => CreateTagWidget(
          tags: Provider.of<CreateTemplateTagPresenter>(context).tags,
          onAddTag: (text) =>
              alertOnError(context, () => templateTagPresenter.addTag(text)),
          checkIsSelected: (tag) => templateTagPresenter.isSelected(tag),
          onTapTag: (tag) =>
              alertOnError(context, () => templateTagPresenter.onTapTag(tag)),
        ),
      ),
    );
  }

  Widget _buildDisplayLayout(BuildContext context) {
    if (responsiveLayoutService.isMobile(context)) {
      return Column(
        children: [
          SizedBox(height: 10),
          _buildImage(),
          SizedBox(height: 10),
          ..._buildTextFields(),
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
        SizedBox(height: 20),
        _buildAddTagsSection(),
      ],
    );
  }

  Widget _buildImage() {
    final templatePresenter = context.watch<CreateTemplatePresenter>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: context.theme.colorScheme.surfaceContainer,
        width: 160,
        height: 160,
        child: EditableImage(
          initialUrl: templatePresenter.updatedTemplate.image ?? '',
          allowEdit: true,
          onImageSelect: (image) =>
              templatePresenter.updateTemplateImage(image),
          child: ProxiedImage(templatePresenter.updatedTemplate.image),
        ),
      ),
    );
  }

  List<Widget> _buildTextFields() {
    final templatePresenter = context.watch<CreateTemplatePresenter>();
    return [
      Align(
        alignment: Alignment.topLeft,
        child: CustomTextField(
          labelText: 'Template name',
          maxLines: 1,
          maxLength: titleMaxCharactersLength,
          initialValue: !isNullOrEmpty(templatePresenter.updatedTemplate.title)
              ? templatePresenter.updatedTemplate.title
              : null,
          onChanged: (value) => templatePresenter.onChangeTitle(value),
        ),
      ),
      SizedBox(height: 10),
      Align(
        alignment: Alignment.topLeft,
        child: CustomTextField(
          labelText: 'Description',
          minLines: 4,
          maxLines: 4,
          initialValue:
              !isNullOrEmpty(templatePresenter.updatedTemplate.description)
                  ? templatePresenter.updatedTemplate.description
                  : null,
          onChanged: (value) => templatePresenter.onChangeDescription(value),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _buildCurrentPage();
  }
}
