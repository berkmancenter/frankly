import 'package:client/styles/styles.dart';
import 'package:dotted_border/dotted_border.dart' as dotted_border;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:client/features/templates/data/providers/select_template_provider.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/features/events/features/create_event/presentation/widgets/custom_form_builder_choice_chips.dart';
import 'package:client/features/events/presentation/widgets/custom_drag_scroll_behaviour.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

/// Widget that shows all templates within the community and lets you search through
/// them and select them.
class SelectTemplate extends StatefulWidget {
  final Function(Template template)? onSelected;
  final Template? selectedTemplate;
  final void Function()? onAddNew;

  const SelectTemplate._({
    this.onSelected,
    this.selectedTemplate,
    this.onAddNew,
  });

  static Widget create({
    required String communityId,
    Function(Template)? onSelected,
    Template? selectedTemplate,
    Function()? onAddNew,
  }) {
    return ChangeNotifierProvider(
      create: (_) => SelectTemplateProvider(
        communityId: communityId,
      ),
      child: SelectTemplate._(
        onSelected: onSelected,
        selectedTemplate: selectedTemplate,
        onAddNew: onAddNew,
      ),
    );
  }

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

  Widget _buildSearchBar() {
    return CustomTextField(
      padding: EdgeInsets.zero,
      labelText: 'Search templates',
      labelStyle: TextStyle(color: context.theme.colorScheme.primary),
      textStyle:
          TextStyle(color: context.theme.colorScheme.primary, fontSize: 16),
      borderType: BorderType.outline,
      backgroundColor: AppColor.gray4.withOpacity(0.2),
      borderRadius: 10,
      borderColor: Colors.transparent,
      maxLines: 1,
      onChanged: (value) =>
          context.read<SelectTemplateProvider>().onSearchChanged(value),
    );
  }

  Widget _buildCategories() {
    final provider = Provider.of<SelectTemplateProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: CustomFormBuilderChoiceChip(
        focusNode: _chipsFocusNode,
        initialValue: const [],
        elevation: 0,
        padding: EdgeInsets.all(0),
        backgroundColor: context.theme.colorScheme.primary,
        selectedColor: AppColor.brightGreen,
        direction: Axis.horizontal,
        labelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: context.theme.colorScheme.onPrimary,
        ),
        options: [
          for (final category in provider.allCategories)
            FormBuilderFieldOption(value: category),
        ],
        onChanged: (value) => provider.updateCategory(value),
        name: 'category_filter',
      ),
    );
  }

  Widget _buildTemplates() {
    final provider = Provider.of<SelectTemplateProvider>(context);

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
        if (provider.displayTemplates.isEmpty && widget.onAddNew == null)
          HeightConstrainedText(
            'No templates found.',
            style: AppTextStyle.body
                .copyWith(color: context.theme.colorScheme.onPrimaryContainer),
          )
        else
          Container(
            padding: provider.allCategories.isNotEmpty
                ? const EdgeInsets.only(top: 1)
                : const EdgeInsets.only(top: 20),
            height: 160,
            child: ScrollConfiguration(
              behavior: CustomDragScrollBehavior(),
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  if (widget.onAddNew != null)
                    _AddNewTemplateButton(
                      onAddNew: widget.onAddNew,
                    ),
                  for (final template in provider.displayTemplates)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      width: 146,
                      height: 156,
                      child: TemplateSelectionCard(
                        template: template,
                        // selectedTemplate can be null if there is no template selected
                        selectedTemplate: widget.selectedTemplate,
                        onSelected: widget.onSelected!,
                      ),
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
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTemplatesLoading() {
    final provider = Provider.of<SelectTemplateProvider>(context);
    return CustomStreamBuilder<List<Template>>(
      entryFrom: '_SelectTemplateState._buildTemplatesLoading',
      stream: Stream.fromFuture(provider.templatesFuture),
      errorMessage: 'There was an error loading events.',
      builder: (_, __) => _buildTemplates(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTemplatesLoading();
  }
}

class _AddNewTemplateButton extends StatelessWidget {
  const _AddNewTemplateButton({
    required this.onAddNew,
  });

  final void Function()? onAddNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 156,
      height: 156,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColor.brightGreen,
        ),
        onPressed: onAddNew,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 5, top: 10, right: 5),
              child: Icon(Icons.add, color: context.theme.colorScheme.primary),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5, bottom: 10, right: 5),
              child: HeightConstrainedText(
                'Create a new template',
                style: TextStyle(
                  fontSize: 13,
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TemplateSelectionCard extends StatelessWidget {
  final Template? template;
  final Function(Template template) onSelected;
  final Template? selectedTemplate;

  const TemplateSelectionCard({
    this.template,
    this.selectedTemplate,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        selectedTemplate != null && selectedTemplate?.id == template?.id;

    return AspectRatio(
      aspectRatio: 1.0,
      child: dotted_border.DottedBorder(
        strokeCap: StrokeCap.round,
        borderType: dotted_border.BorderType.RRect,
        radius: Radius.circular(10),
        color: isSelected
            ? AppColor.brightGreen
            : context.theme.colorScheme.onPrimary,
        dashPattern: isSelected ? const [1, 0] : const [5, 5],
        strokeWidth: isSelected ? 4 : 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.theme.colorScheme.surfaceContainerLowest,
            boxShadow: [
              BoxShadow(
                color: context.theme.colorScheme.scrim.withScrimOpacity,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Provider.of<SelectTemplateProvider>(context, listen: false)
                  .updateSelectedTemplate(template);
              onSelected(template!);
            },
            hoverColor: Color(0xFF5568FF).withOpacity(0.2),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ProxiedImage(
                    template?.image,
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
                  child: HeightConstrainedText(
                    template?.title ?? '',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: context.theme.colorScheme.onPrimary,
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
                      border: Border.all(
                        color: context.theme.colorScheme.onPrimary,
                        width: 1,
                      ),
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 11, top: 13),
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: selectedTemplate != null &&
                              selectedTemplate?.id == template?.id
                          ? AppColor.brightGreen
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
