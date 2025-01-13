import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:data_models/community/community.dart';

class CreateCommunityTextFields extends StatefulWidget {
  final bool showChooseCustomDisplayId;
  final void Function(String) onNameChanged;
  final void Function(String) onTaglineChanged;
  final void Function(String) onAboutChanged;
  final void Function(String)? onCustomDisplayIdChanged;
  final FocusNode? nameFocus;
  final FocusNode? aboutFocus;
  final FocusNode? taglineFocus;
  final Community community;
  final bool compact;

  const CreateCommunityTextFields({
    this.showChooseCustomDisplayId = false,
    Key? key,
    required this.onNameChanged,
    required this.onTaglineChanged,
    required this.onAboutChanged,
    this.onCustomDisplayIdChanged,
    this.nameFocus,
    this.aboutFocus,
    this.taglineFocus,
    required this.community,
    this.compact = false,
  }) : super(key: key);

  @override
  State<CreateCommunityTextFields> createState() =>
      _CreateCommunityTextFieldsState();
}

class _CreateCommunityTextFieldsState extends State<CreateCommunityTextFields> {
  bool get _showNameCounter => !isNullOrEmpty(widget.community.name);

  bool get _showTaglineCounter => !isNullOrEmpty(widget.community.tagLine);
  final int titleMaxCharactersLength = 80;
  final int taglineMaxCharactersLength = 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCreateCommunityTextField(
          maxLines: 1,
          maxLength: titleMaxCharactersLength,
          counterText: _showNameCounter
              ? '${widget.community.name!.length}/$titleMaxCharactersLength'
              : '',
          label: 'Name',
          hint: 'Ex: The Justice League',
          initialValue: widget.community.name,
          onChanged: widget.onNameChanged,
          focus: widget.nameFocus,
        ),
        if (widget.showChooseCustomDisplayId) ...[
          _buildCreateCommunityTextField(
            label: 'Unique URL display name (Optional)',
            hint: 'Ex: the-justice-league',
            initialValue: widget.community.displayId,
            onChanged: widget.onCustomDisplayIdChanged,
          ),
        ],
        _buildCreateCommunityTextField(
          label: 'Tagline',
          hint: 'Ex: Protecting the earth from all invaders',
          initialValue: widget.community.tagLine,
          onChanged: widget.onTaglineChanged,
          maxLength: taglineMaxCharactersLength,
          counterText: _showTaglineCounter
              ? '${widget.community.tagLine!.length}/$taglineMaxCharactersLength'
              : '',
          minLines: 3,
          focus: widget.taglineFocus,
          containerHeight: 118,
        ),
        _buildCreateCommunityTextField(
          label: 'About',
          hint: 'Add more detail as to the goals of this community',
          maxLines: 3,
          minLines: 3,
          initialValue: widget.community.description,
          onChanged: widget.onAboutChanged,
          focus: widget.aboutFocus,
          containerHeight: 108,
          isOptional: true,
        ),
      ],
    );
  }

  Widget _buildCreateCommunityTextField({
    required String label,
    required String hint,
    required void Function(String)? onChanged,
    required String? initialValue,
    int? maxLines,
    int? minLines,
    String? counterText,
    int? maxLength,
    double containerHeight = 78,
    FocusNode? focus,
    bool isOptional = false,
  }) =>
      Container(
        alignment: Alignment.topCenter,
        height: containerHeight,
        child: CustomTextField(
          counterAlignment: Alignment.topRight,
          focusNode: focus,
          maxLength: maxLength,
          counterText: counterText,
          padding: EdgeInsets.zero,
          labelText: label,
          hintText: hint,
          maxLines: maxLines,
          minLines: minLines,
          initialValue: initialValue,
          onChanged: onChanged,
          isOptional: isOptional,
          optionalPadding: const EdgeInsets.only(top: 12, right: 12),
        ),
      );
}
