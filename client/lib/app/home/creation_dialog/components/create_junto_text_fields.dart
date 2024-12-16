import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto_models/firestore/junto.dart';

class CreateJuntoTextFields extends StatefulWidget {
  final bool showChooseCustomDisplayId;
  final void Function(String) onNameChanged;
  final void Function(String) onTaglineChanged;
  final void Function(String) onAboutChanged;
  final void Function(String)? onCustomDisplayIdChanged;
  final FocusNode? nameFocus;
  final FocusNode? aboutFocus;
  final FocusNode? taglineFocus;
  final Junto junto;
  final bool compact;

  const CreateJuntoTextFields({
    this.showChooseCustomDisplayId = false,
    Key? key,
    required this.onNameChanged,
    required this.onTaglineChanged,
    required this.onAboutChanged,
    this.onCustomDisplayIdChanged,
    this.nameFocus,
    this.aboutFocus,
    this.taglineFocus,
    required this.junto,
    this.compact = false,
  }) : super(key: key);

  @override
  State<CreateJuntoTextFields> createState() => _CreateJuntoTextFieldsState();
}

class _CreateJuntoTextFieldsState extends State<CreateJuntoTextFields> {
  bool get _showNameCounter => !isNullOrEmpty(widget.junto.name);

  bool get _showTaglineCounter => !isNullOrEmpty(widget.junto.tagLine);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCreateJuntoTextField(
          maxLines: 1,
          maxLength: titleMaxCharactersLength,
          counterText:
              _showNameCounter ? '${widget.junto.name!.length}/$titleMaxCharactersLength' : '',
          label: 'Name',
          hint: 'Ex: The Justice League',
          initialValue: widget.junto.name,
          onChanged: widget.onNameChanged,
          focus: widget.nameFocus,
        ),
        if (widget.showChooseCustomDisplayId) ...[
          _buildCreateJuntoTextField(
            label: 'Unique URL display name (Optional)',
            hint: 'Ex: the-justice-league',
            initialValue: widget.junto.displayId,
            onChanged: widget.onCustomDisplayIdChanged,
          ),
        ],
        _buildCreateJuntoTextField(
          label: 'Tagline',
          hint: 'Ex: Protecting the earth from all invaders',
          initialValue: widget.junto.tagLine,
          onChanged: widget.onTaglineChanged,
          maxLength: taglineMaxCharactersLength,
          counterText: _showTaglineCounter
              ? '${widget.junto.tagLine!.length}/$taglineMaxCharactersLength'
              : '',
          minLines: 3,
          focus: widget.taglineFocus,
          containerHeight: 118,
        ),
        _buildCreateJuntoTextField(
          label: 'About',
          hint: 'Add more detail as to the goals of this community',
          maxLines: 3,
          minLines: 3,
          initialValue: widget.junto.description,
          onChanged: widget.onAboutChanged,
          focus: widget.aboutFocus,
          containerHeight: 108,
          isOptional: true,
        ),
      ],
    );
  }

  Widget _buildCreateJuntoTextField({
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
        child: JuntoTextField(
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
