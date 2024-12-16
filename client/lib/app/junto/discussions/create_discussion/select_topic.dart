import 'package:dotted_border/dotted_border.dart' as dotted_border;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:junto/app/junto/templates/select_topic_provider.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/custom_form_builder_choice_chips.dart';
import 'package:junto/utils/junto_drag_scroll_behaviour.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

/// Widget that shows all topics within the junto and lets you search through
/// them and select them.
class SelectTopic extends StatefulWidget {
  final Function(Topic topic)? onSelected;
  final Topic? selectedTopic;
  final void Function()? onAddNew;

  const SelectTopic._({
    this.onSelected,
    this.selectedTopic,
    this.onAddNew,
  });

  static Widget create({
    required String juntoId,
    Function(Topic)? onSelected,
    Topic? selectedTopic,
    Function()? onAddNew,
  }) {
    return ChangeNotifierProvider(
      create: (_) => SelectTopicProvider(
        juntoId: juntoId,
      ),
      child: SelectTopic._(
        onSelected: onSelected,
        selectedTopic: selectedTopic,
        onAddNew: onAddNew,
      ),
    );
  }

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

  Widget _buildSearchBar() {
    return JuntoTextField(
      padding: EdgeInsets.zero,
      labelText: 'Search templates',
      labelStyle: TextStyle(color: AppColor.darkBlue),
      textStyle: TextStyle(color: AppColor.darkBlue, fontSize: 16),
      borderType: BorderType.outline,
      backgroundColor: AppColor.gray4.withOpacity(0.2),
      borderRadius: 10,
      borderColor: Colors.transparent,
      maxLines: 1,
      onChanged: (value) => context.read<SelectTopicProvider>().onSearchChanged(value),
    );
  }

  Widget _buildCategories() {
    final provider = Provider.of<SelectTopicProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: CustomFormBuilderChoiceChip(
        focusNode: _chipsFocusNode,
        initialValue: const [],
        elevation: 0,
        padding: EdgeInsets.all(0),
        backgroundColor: AppColor.darkBlue,
        selectedColor: AppColor.brightGreen,
        direction: Axis.horizontal,
        labelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColor.white,
        ),
        options: [
          for (final category in provider.allCategories) FormBuilderFieldOption(value: category),
        ],
        onChanged: (value) => provider.updateCategory(value),
        name: 'category_filter',
      ),
    );
  }

  Widget _buildAddNewTopic() {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 156,
      height: 156,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColor.brightGreen,
        ),
        onPressed: widget.onAddNew,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 5, top: 10, right: 5),
              child: Icon(Icons.add, color: AppColor.darkBlue),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5, bottom: 10, right: 5),
              child: JuntoText(
                'Create a new template',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColor.darkBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopics() {
    final provider = Provider.of<SelectTopicProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: _buildSearchBar(),
        ),
        SizedBox(height: 6),
        if (provider.allCategories.isNotEmpty) ...[
          _buildCategories(),
          SizedBox(height: 20),
        ] else
          SizedBox.shrink(),
        if (provider.displayTopics.isEmpty && widget.onAddNew == null)
          JuntoText(
            'No templates found.',
            style: AppTextStyle.body.copyWith(color: AppColor.gray4),
          )
        else
          Container(
            padding: provider.allCategories.isNotEmpty
                ? const EdgeInsets.only(top: 1)
                : const EdgeInsets.only(top: 20),
            height: 160,
            child: ScrollConfiguration(
              behavior: JuntoDragScrollBehavior(),
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  if (widget.onAddNew != null) _buildAddNewTopic(),
                  for (final topic in provider.displayTopics)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      width: 146,
                      height: 156,
                      child: TopicSelectionCard(
                        topic: topic,
                        // selectedTopic can be null if there is no topic selected
                        selectedTopic: widget.selectedTopic,
                        onSelected: widget.onSelected!,
                      ),
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
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopicsLoading() {
    final provider = Provider.of<SelectTopicProvider>(context);
    return JuntoStreamBuilder<List<Topic>>(
        entryFrom: '_SelectTopicState._buildTopicsLoading',
        stream: Stream.fromFuture(provider.topicsFuture),
        errorMessage: 'There was an error loading events.',
        builder: (_, __) => _buildTopics());
  }

  @override
  Widget build(BuildContext context) {
    return _buildTopicsLoading();
  }
}

class TopicSelectionCard extends StatelessWidget {
  final Topic? topic;
  final Function(Topic topic) onSelected;
  final Topic? selectedTopic;

  const TopicSelectionCard({
    this.topic,
    this.selectedTopic,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedTopic != null && selectedTopic?.id == topic?.id;

    return AspectRatio(
      aspectRatio: 1.0,
      child: dotted_border.DottedBorder(
        strokeCap: StrokeCap.round,
        borderType: dotted_border.BorderType.RRect,
        radius: Radius.circular(10),
        color: isSelected ? AppColor.brightGreen : AppColor.white,
        dashPattern: isSelected ? const [1, 0] : const [5, 5],
        strokeWidth: isSelected ? 4 : 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColor.white,
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.5),
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Provider.of<SelectTopicProvider>(context, listen: false).updateSelectedTopic(topic);
              onSelected(topic!);
            },
            hoverColor: Color(0xFF5568FF).withOpacity(0.2),
            child: Stack(
              children: [
                Positioned.fill(
                  child: JuntoImage(
                    topic?.image,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
                    topic?.title ?? '',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: AppColor.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 10),
                  child: Container(
                    width: 23,
                    height: 23,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColor.white, width: 1),
                        color: Colors.transparent,
                        shape: BoxShape.circle),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 11, top: 13),
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: selectedTopic != null && selectedTopic?.id == topic?.id
                          ? AppColor.brightGreen
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
