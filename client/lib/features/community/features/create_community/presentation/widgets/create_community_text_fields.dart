import 'package:client/config/environment.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:data_models/community/community.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/services.dart';

class CreateCommunityTextFields extends StatefulWidget {
  final bool showChooseCustomDisplayId;
  final void Function(String) onNameChanged;
  final void Function(String) onCustomDisplayIdChanged;
  final void Function(String)? onTaglineChanged;
  final void Function(String)? onAboutChanged;
  final FocusNode? nameFocus;
  final FocusNode? aboutFocus;
  final Community community;
  final bool compact;
  final bool showAllFields;

  final FocusNode? taglineFocus;
  const CreateCommunityTextFields({
    this.showChooseCustomDisplayId = false,
    Key? key,
    required this.onNameChanged,
    required this.onCustomDisplayIdChanged,
    this.onTaglineChanged,
    this.onAboutChanged,
    this.nameFocus,
    this.aboutFocus,
    this.taglineFocus,
    required this.community,
    this.compact = false,
    this.showAllFields = false,
  }) : super(key: key);

  @override
  State<CreateCommunityTextFields> createState() =>
      _CreateCommunityTextFieldsState();
}

class _CreateCommunityTextFieldsState extends State<CreateCommunityTextFields> {
  final int titleMaxCharactersLength = 80;
  final int customIdMaxCharactersLength = 80;
  final int taglineMaxCharactersLength = 100;

  late final TextEditingController _nameController;
  late final TextEditingController _displayIdController;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.community.name ?? '',
    );
    _displayIdController =
        TextEditingController(text: widget.community.displayId);
  }

  String _formatDisplayIdFromName(String displayId) {
    final String formattedDisplayId = displayId
        .replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '-')
        .replaceAll(RegExp(r'--+'), '-')
        .replaceAll(RegExp(r'-+$'), '-')
        .toLowerCase();
    return formattedDisplayId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCreateCommunityTextField(
          controller: _nameController,
          maxLength: titleMaxCharactersLength,
          label: context.l10n.name,
          onChanged: (String val) => {
            widget.onNameChanged.call(val),
            widget.onCustomDisplayIdChanged.call(_formatDisplayIdFromName(val)),
            setState(() {
              // Update the displayId when the name changes
              _displayIdController.text = _formatDisplayIdFromName(val);
            }),
          },
          focus: widget.nameFocus,
          helperText: context.l10n.youCanChangeThisLater,
          // Allow only alphanumeric characters, spaces
          formatterRegex: r'[\s?\w?]',
        ),
        SizedBox(
          height: widget.compact ? 0 : 10,
        ),
        _buildCreateCommunityTextField(
          controller: _displayIdController,
          maxLength: customIdMaxCharactersLength,
          label: context.l10n.uniqueUrlDisplayNameOptional,
          initialValue: _nameController.text,
          onChanged: widget.onCustomDisplayIdChanged,
          helperText: _displayIdController.text.isNotEmpty
              ? '${Environment.appUrl}/${_displayIdController.text}'
              : null,
          // Allow only numbers, lowercase letters, and dashes
          formatterRegex: '[0-9a-z-+]',
        ),
        SizedBox(
          height: widget.compact ? 0 : 10,
        ),
        if (widget.showAllFields)
          Column(
            children: [
              _buildCreateCommunityTextField(
                hint: 'Ex: Protecting the earth from all invaders',
                label: 'Tagline',
                initialValue: widget.community.tagLine,
                onChanged: widget.onTaglineChanged,
                maxLength: taglineMaxCharactersLength,
                counterText:
                    '${widget.community.tagLine?.length}/$taglineMaxCharactersLength',
                focus: widget.taglineFocus,
                minLines: 3,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(
                height: widget.compact ? 0 : 10,
              ),
              _buildCreateCommunityTextField(
                label: 'About',
                hint: 'Add more detail as to the goals of this community',
                initialValue: widget.community.description,
                onChanged: widget.onAboutChanged,
                focus: widget.aboutFocus,
                isOptional: true,
                maxLines: 3,
                minLines: 3,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCreateCommunityTextField({
    required String label,
    required void Function(String)? onChanged,
    String? formatterRegex,
    TextEditingController? controller,
    String? hint,
    String? helperText,
    String? initialValue,
    String? counterText,
    int? maxLength,
    int maxLines = 1,
    int minLines = 1,
    double containerHeight = 78,
    FocusNode? focus,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      Container(
        alignment: Alignment.topCenter,
        height: containerHeight,
        child: CustomTextField(
          controller: controller,
          borderType: BorderType.underline,
          counterAlignment: Alignment.topRight,
          focusNode: focus,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: minLines,
          counterText: counterText,
          padding: EdgeInsets.zero,
          labelText: label,
          hintText: hint,
          helperText: helperText,
          initialValue: initialValue,
          onChanged: onChanged,
          isOptional: isOptional,
          optionalPadding: const EdgeInsets.only(top: 12, right: 12),
          inputFormatters: formatterRegex == null
              ? null
              : FilteringTextInputFormatter.allow(RegExp(formatterRegex)),
          keyboardType: keyboardType,
        ),
      );
}
