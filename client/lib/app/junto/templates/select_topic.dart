import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_dialog.dart';
import 'package:junto/app/junto/templates/select_topic_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/empty_page_content.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/tag_filter_widget.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/junto_tag.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

/// Widget that shows all topics within the junto and lets you search through
/// them and select them.
class SelectTopic extends StatefulWidget {
  final Function()? onAddNew;

  const SelectTopic({required this.onAddNew});

  @override
  _SelectTopicState createState() => _SelectTopicState();
}

class _SelectTopicState extends State<SelectTopic> {
  final _chipsFocusNode = FocusNode();

  @override
  void initState() {
    context.read<SelectTopicProvider>().initialize();
    super.initState();
  }

  Widget _buildSearchBarField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search templates',
        border: InputBorder.none,
      ),
      onChanged: context.read<SelectTopicProvider>().onSearchChanged,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.white,
      ),
      padding: const EdgeInsets.only(left: 12, right: 32),
      constraints: BoxConstraints(maxWidth: 450),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search, color: AppColor.gray1),
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
        backgroundColor: Color(0x59C4C4C4),
        selectedColor: Color(0x452F5EFF),
        labelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColor.black,
        ),
        options: Provider.of<SelectTopicProvider>(context)
            .allCategories
            .map((option) => FormBuilderChipOption(value: option))
            .toList(),
        onChanged: Provider.of<SelectTopicProvider>(context, listen: false).updateCategory,
        name: 'category_filter',
      ),
    );
  }

  Widget _buildTopics() {
    final provider = Provider.of<SelectTopicProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JuntoStreamBuilder<List<JuntoTag>>(
          stream: provider.allTagsStream,
          entryFrom: 'SelectTopicState._buildTopics',
          builder: (context, snapshot) {
            if (provider.allTags.isEmpty) return SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: TagFilterWidget(
                tags: provider.allTags,
                isSelectedDefinitionId: (tagDefinitionId) =>
                    provider.selectedTagDefinitionId.contains(tagDefinitionId),
                onTapTag: (tagDefinitionId) =>
                    Provider.of<SelectTopicProvider>(context, listen: false)
                        .selectTag(tagDefinitionId),
              ),
            );
          },
        ),
        Row(
          children: [
            Flexible(child: _buildSearchBar()),
            if (widget.onAddNew != null && provider.displayTopics.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ActionButton(
                  type: ActionButtonType.outline,
                  color: AppColor.white,
                  textColor: AppColor.gray1,
                  onPressed: widget.onAddNew,
                  text: 'Add New',
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: provider.allCategories.isNotEmpty ? _buildCategories() : SizedBox.shrink(),
        ),
        if (provider.displayTopics.isEmpty)
          Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                EmptyPageContent(
                  type: EmptyPageType.templates,
                  showContainer: false,
                  isBackgroundPrimaryColor: true,
                  onButtonPress: context.watch<CommunityPermissionsProvider>().canCreateTopic
                      ? () => CreateTopicDialog.show(
                            juntoProvider: context.read<JuntoProvider>(),
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
              for (final topic in provider.displayTopics)
                SizedBox(
                  width: 160,
                  height: 160,
                  child: TopicCard(
                    juntoDisplayId: JuntoProvider.watch(context).displayId,
                    topic: topic,
                  ),
                )
            ],
          ),
        if (provider.moreTopics)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: ActionButton(
              onPressed: provider.showMoreTopics,
              text: 'View more templates',
            ),
          ),
      ],
    );
  }

  Widget _buildTopicsLoading() {
    final provider = Provider.of<SelectTopicProvider>(context);
    return FutureBuilder<List<Topic>>(
      future: provider.topicsFuture,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          loggingService.log('Error in loading templates',
              logType: LogType.error,
              error: snapshot.error,
              stackTrace: (snapshot.error as Error).stackTrace);

          return Text('There was an error loading event templates.');
        } else if (!snapshot.hasData) {
          return Container(
            height: 400,
            alignment: Alignment.center,
            child: JuntoLoadingIndicator(),
          );
        }

        return _buildTopics();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTopicsLoading();
  }
}

class TopicCard extends StatelessWidget {
  final String juntoDisplayId;
  final Topic topic;

  const TopicCard({
    required this.juntoDisplayId,
    required this.topic,
  });

  void _onTapFunction(BuildContext context) {
    routerDelegate.beamTo(
      JuntoPageRoutes(
        juntoDisplayId: juntoDisplayId,
      ).topicPage(topicId: topic.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.5),
              blurRadius: 4,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: JuntoInkWell(
          onTap: () => _onTapFunction(context),
          hoverColor: Color(0xFF5568FF).withOpacity(0.2),
          child: Stack(
            children: [
              Positioned.fill(
                child: JuntoImage(
                  topic.image,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF303B5F).withOpacity(0.8),
                  backgroundBlendMode: BlendMode.multiply,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                alignment: Alignment.bottomLeft,
                child: JuntoText(
                  topic.title ?? '',
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.3,
                    color: AppColor.white,
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
