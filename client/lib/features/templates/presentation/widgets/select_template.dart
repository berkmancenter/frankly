import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/templates/features/create_template/presentation/views/create_template_dialog.dart';
import 'package:client/features/templates/data/providers/select_template_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/tag_filter_widget.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/community_tag.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

/// Widget that shows all templates within the community and lets you search through
/// them and select them.
class SelectTemplate extends StatefulWidget {
  final Function()? onAddNew;

  const SelectTemplate({required this.onAddNew});

  @override
  _SelectTemplateState createState() => _SelectTemplateState();
}

class _SelectTemplateState extends State<SelectTemplate> {
  final _chipsFocusNode = FocusNode();

  @override
  void initState() {
    context.read<SelectTemplateProvider>().initialize();
    super.initState();
  }

  Widget _buildSearchBarField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search templates',
        border: InputBorder.none,
      ),
      onChanged: context.read<SelectTemplateProvider>().onSearchChanged,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.theme.colorScheme.surfaceContainer,
      ),
      padding: const EdgeInsets.only(left: 12, right: 32),
      constraints: BoxConstraints(maxWidth: 450),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search),
          ),
          Expanded(
            child: _buildSearchBarField(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FormBuilderChoiceChip(
        focusNode: _chipsFocusNode,
        initialValue: const [],
        spacing: 4,
        runSpacing: 3,
        backgroundColor: context.theme.colorScheme.surfaceContainer,
        selectedColor: context.theme.colorScheme.primary,
        labelStyle: AppTextStyle.bodySmall,
        options: Provider.of<SelectTemplateProvider>(context)
            .allCategories
            .map((option) => FormBuilderChipOption(value: option))
            .toList(),
        onChanged: Provider.of<SelectTemplateProvider>(context, listen: false)
            .updateCategory,
        name: 'category_filter',
      ),
    );
  }

  Widget _buildTemplates() {
    final provider = Provider.of<SelectTemplateProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomStreamBuilder<List<CommunityTag>>(
          stream: provider.allTagsStream,
          entryFrom: 'SelectTemplateState._buildTemplates',
          builder: (context, snapshot) {
            if (provider.allTags.isEmpty) return SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: TagFilterWidget(
                tags: provider.allTags,
                isSelectedDefinitionId: (tagDefinitionId) =>
                    provider.selectedTagDefinitionId.contains(tagDefinitionId),
                onTapTag: (tagDefinitionId) =>
                    Provider.of<SelectTemplateProvider>(context, listen: false)
                        .selectTag(tagDefinitionId),
              ),
            );
          },
        ),
        Row(
          children: [
            Flexible(child: _buildSearchBar()),
            if (widget.onAddNew != null && provider.displayTemplates.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ActionButton(
                  color: context.theme.colorScheme.primary,
                  onPressed: widget.onAddNew,
                  text: 'Add New',
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: provider.allCategories.isNotEmpty
              ? _buildCategories()
              : SizedBox.shrink(),
        ),
        if (provider.displayTemplates.isEmpty)
          Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                EmptyPageContent(
                  type: EmptyPageType.templates,
                  showContainer: false,
                  isBackgroundPrimaryColor: true,
                  onButtonPress: context
                          .watch<CommunityPermissionsProvider>()
                          .canCreateTemplate
                      ? () => CreateTemplateDialog.show(
                            communityProvider:
                                context.read<CommunityProvider>(),
                            communityPermissionsProvider:
                                context.read<CommunityPermissionsProvider>(),
                          )
                      : null,
                ),
              ],
            ),
          )
        else
          Wrap(
            runSpacing: 14,
            spacing: 8,
            children: [
              for (final template in provider.displayTemplates)
                SizedBox(
                  width: 160,
                  height: 160,
                  child: TemplateCard(
                    communityDisplayId:
                        CommunityProvider.watch(context).displayId,
                    template: template,
                  ),
                ),
            ],
          ),
        if (provider.moreTemplates)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: ActionButton(
              onPressed: provider.showMoreTemplates,
              text: 'View more templates',
            ),
          ),
      ],
    );
  }

  Widget _buildTemplatesLoading() {
    final provider = Provider.of<SelectTemplateProvider>(context);
    return FutureBuilder<List<Template>>(
      future: provider.templatesFuture,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          loggingService.log(
            'Error in loading templates',
            logType: LogType.error,
            error: snapshot.error,
            stackTrace: (snapshot.error as Error).stackTrace,
          );

          return Text('There was an error loading event templates.');
        } else if (!snapshot.hasData) {
          return Container(
            height: 400,
            alignment: Alignment.center,
            child: CustomLoadingIndicator(),
          );
        }

        return _buildTemplates();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTemplatesLoading();
  }
}

class TemplateCard extends StatelessWidget {
  final String communityDisplayId;
  final Template template;

  const TemplateCard({
    required this.communityDisplayId,
    required this.template,
  });

  void _onTapFunction(BuildContext context) {
    routerDelegate.beamTo(
      CommunityPageRoutes(
        communityDisplayId: communityDisplayId,
      ).templatePage(templateId: template.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainer,
          boxShadow: [
            BoxShadow(
              color: context.theme.colorScheme.shadow,
              blurRadius: 4,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: CustomInkWell(
          onTap: () => _onTapFunction(context),
          hoverColor: context.theme.colorScheme.primary.withOpacity(0.38),
          child: Stack(
            children: [
              Positioned.fill(
                child: ProxiedImage(
                  template.image,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary,
                  backgroundBlendMode: BlendMode.multiply,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                alignment: Alignment.bottomLeft,
                child: HeightConstrainedText(
                  template.title ?? '',
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.3,
                    color: context.theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
