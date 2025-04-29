import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:data_models/community/community.dart';
import 'package:client/styles/styles.dart';

class CreateCommunityTextFields extends StatefulWidget {
  final bool showChooseCustomDisplayId;
  final void Function(String) onNameChanged;
  final void Function(String)? onCustomDisplayIdChanged;
  final FocusNode? nameFocus;
  final FocusNode? aboutFocus;
  final Community community;
  final bool compact;

  final FocusNode? taglineFocus;
  const CreateCommunityTextFields({
    this.showChooseCustomDisplayId = false,
    Key? key,
    required this.onNameChanged,
    required this.onCustomDisplayIdChanged,
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
  final int titleMaxCharactersLength = 80;
  final int customIdMaxCharactersLength = 80;
  final _nameController = TextEditingController();
  final _displayIdController = TextEditingController();

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
          label: 'Name',
          onChanged: (String val) => {
            widget.onNameChanged.call(val),
            setState(() {
              // Update the displayId when the name changes
              _displayIdController.text = _formatDisplayIdFromName(val);
            }),
          },
          focus: widget.nameFocus,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('You can change this later',
            style: context.theme.textTheme.bodySmall,
          ),
        ),
        _buildCreateCommunityTextField(
          controller: _displayIdController,
          maxLength: customIdMaxCharactersLength,
          label: 'Unique URL display name (Optional)',
          initialValue: _nameController.text,
          onChanged: widget.onCustomDisplayIdChanged,
          helperText: widget.community.displayId.isNotEmpty
              ? 'https://www.example.com/${widget.community.displayId}'
              : 'https://www.example.com/your_custom_url',
        ),
      ],
    );
  }

  Widget _buildCreateCommunityTextField({
    required String label,
    required void Function(String)? onChanged,
    TextEditingController? controller,
    String? hint,
    String? helperText,
    String? initialValue,
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
          controller: controller,
          borderType: BorderType.underline,
          counterAlignment: Alignment.topRight,
          focusNode: focus,
          maxLength: maxLength,
          counterText: counterText,
          padding: EdgeInsets.zero,
          labelText: label,
          hintText: hint,
          helperText: helperText,
          initialValue: initialValue,
          onChanged: onChanged,
          isOptional: isOptional,
          optionalPadding: const EdgeInsets.only(top: 12, right: 12),
        ),
      );
}
