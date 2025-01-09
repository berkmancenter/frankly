import 'dart:async';
import 'dart:math' as math;

import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:dotted_border/dotted_border.dart' as dotted_border;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/features/community/presentation/widgets/community_tag_builder.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/community_tag.dart';
import 'package:data_models/community/community_tag_definition.dart';

/// This is a widget that shows the create tag section
/// displays existing tags and add tag field
class CreateTagWidget extends StatefulWidget {
  /// Tags to choose from.
  final List<CommunityTag> tags;

  /// The user has tapped the check icon after entering a valid tag in the textfield
  final Future<void> Function(String) onAddTag;

  /// function callback that checks if tag is selected
  final bool Function(CommunityTag) checkIsSelected;

  /// function callback that returns tapped tag
  final void Function(CommunityTag) onTapTag;

  final bool isFeaturedTag;
  final bool showIcon;
  final String? titleText;
  final TextStyle? titleTextStyle;
  final Color tagBackgroundColor;
  final Color tagTextColor;

  const CreateTagWidget({
    Key? key,
    required this.tags,
    required this.onAddTag,
    required this.checkIsSelected,
    required this.onTapTag,
    this.isFeaturedTag = false,
    this.showIcon = true,
    this.titleText,
    this.titleTextStyle,
    this.tagBackgroundColor = AppColor.darkBlue,
    this.tagTextColor = AppColor.white,
  }) : super(key: key);

  @override
  State<CreateTagWidget> createState() => _CreateTagWidgetState();
}

class _CreateTagWidgetState extends State<CreateTagWidget> {
  final _formKey = GlobalKey<FormState>();

  bool _isTagFieldShown = false;

  bool _hasValidInput = false;

  final TextEditingController _controller = TextEditingController();

  Future<List<CommunityTagDefinition>> _lookupDefinitions(String input) async {
    return firestoreTagService.getSuggestions(input: input);
  }

  void _onTapAddButton() {
    setState(() {
      _isTagFieldShown = !_isTagFieldShown;
    });
  }

  String? validator(String? value) {
    if (value == null) return value;
    if (value.contains(' ')) return 'Space not allowed';
    if (value.length > 20) return 'Exceeds 20 characters limit';
    final regex = RegExp(r'[^A-Za-z0-9]');
    if (regex.hasMatch(value)) {
      return 'Invalid characters(s)';
    }
    return null;
  }

  Widget _buildTags() {
    return Row(
      children: [
        if (widget.showIcon) ...[
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: Icon(CupertinoIcons.tags),
          ),
          SizedBox(width: 5),
        ],
        HeightConstrainedText(
          widget.titleText ?? (widget.isFeaturedTag ? 'Featured Tags' : 'Tags'),
          style: widget.titleTextStyle ??
              AppTextStyle.body.copyWith(color: AppColor.darkBlue),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Wrap(
            spacing: 5,
            children: [
              for (var tag in widget.tags)
                CommunityTagBuilder(
                  tagDefinitionId: tag.definitionId,
                  builder: (_, isLoading, snapshot) {
                    if (isLoading) return CustomLoadingIndicator();
                    if (snapshot == null) return const SizedBox.shrink();
                    return TagChip(
                      label: snapshot.title,
                      isSelected: widget.checkIsSelected(tag),
                      onPressed: () => widget.onTapTag(tag),
                      tagBackgroundColor: widget.tagBackgroundColor,
                      tagTextColor: widget.tagTextColor,
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _validateTagInput() {
    setState(() {
      _hasValidInput = _formKey.currentState?.validate() ?? false;
    });
  }

  Widget _buildAddTagField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeightConstrainedText(
          'Add a new tag',
          style: TextStyle(color: AppColor.gray3),
        ),
        Row(
          children: [
            Expanded(
              child: Semantics(
                textField: true,
                label: 'Tag',
                child: TypeAheadFormField<CommunityTagDefinition>(
                  textFieldConfiguration: TextFieldConfiguration(
                    autofocus: true,
                    controller: _controller,
                    style: AppTextStyle.body,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColor.accentBlue,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onEditingComplete: () async {
                      _validateTagInput();
                      if (_hasValidInput) {
                        final title = _controller.text;
                        _controller.clear();
                        await widget.onAddTag(title);
                      }
                    },
                    onChanged: (value) {
                      _validateTagInput();
                    },
                  ),
                  hideOnError: true,
                  hideOnEmpty: true,
                  hideOnLoading: true,
                  autovalidateMode: AutovalidateMode.always,
                  validator: validator,
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty == true) return [];

                    return _lookupDefinitions(pattern);
                  },
                  itemBuilder: (context, tag) {
                    return ListTile(
                      title: HeightConstrainedText(
                        tag.title,
                        style: AppTextStyle.body,
                      ),
                    );
                  },
                  onSuggestionSelected: (tag) {
                    setState(() => _controller.text = tag.title);
                  },
                ),
              ),
            ),
            if (_controller.text.isNotEmpty) ...[
              SizedBox(width: 10),
              Semantics(
                button: true,
                label: 'Submit Tag Button',
                child: CustomInkWell(
                  boxShape: BoxShape.circle,
                  onTap: _hasValidInput
                      ? () {
                          widget.onAddTag(_controller.text);
                          _controller.clear();
                        }
                      : null,
                  child: CircleAvatar(
                    backgroundColor: _hasValidInput
                        ? AppColor.darkBlue
                        : AppColor.darkBlue.withOpacity(0.5),
                    child: Icon(
                      Icons.check,
                      color: AppColor.brightGreen,
                    ),
                  ),
                ),
              ),
            ],
            Spacer(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTags(),
          if (_isTagFieldShown) ...[
            SizedBox(height: 20),
            _buildAddTagField(),
          ],
          SizedBox(height: 20),
          ActionButton(
            borderSide: BorderSide(color: AppColor.black, width: 1),
            borderRadius: BorderRadius.circular(30),
            icon: Icon(
              Icons.add,
              color: AppColor.darkBlue,
            ),
            type: ActionButtonType.outline,
            color: AppColor.white,
            onPressed: () => _onTapAddButton(),
            child: HeightConstrainedText(
              'Add tag',
              style: TextStyle(color: AppColor.darkBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  final String? label;
  final void Function() onPressed;
  final bool isSelected;
  final Color tagBackgroundColor;
  final Color tagTextColor;

  const TagChip({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.isSelected,
    required this.tagBackgroundColor,
    required this.tagTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      color: isSelected ? tagBackgroundColor : AppColor.white,
      borderRadius: BorderRadius.circular(30),
      child: dotted_border.DottedBorder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dashPattern: const [5, 5],
        strokeCap: StrokeCap.round,
        borderType: dotted_border.BorderType.RRect,
        radius: Radius.circular(30),
        color: isSelected ? tagBackgroundColor : AppColor.gray3,
        child: HeightConstrainedText(
          '#${label ?? ''}',
          style: AppTextStyle.body
              .copyWith(color: isSelected ? tagTextColor : AppColor.gray1),
        ),
      ),
    );
  }
}
