import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class ConfirmTextInputDialog extends StatefulWidget {
  final String title;
  final String mainText;
  final String subText;
  final String confirmText;
  final Function(BuildContext context, String input)? onConfirm;
  final String cancelText;
  final Function(BuildContext context)? onCancel;
  final String textLabel;
  final String textHint;

  const ConfirmTextInputDialog({
    this.title = '',
    this.mainText = '',
    this.subText = '',
    this.confirmText = 'Confirm',
    this.onConfirm,
    this.cancelText = 'Cancel',
    this.onCancel,
    required this.textLabel,
    this.textHint = '',
  });

  Future<String?> show({BuildContext? context}) async {
    return (await showCustomDialog(builder: (_) => this));
  }

  @override
  State<ConfirmTextInputDialog> createState() => _ConfirmTextInputDialogState();
}

class _ConfirmTextInputDialogState extends State<ConfirmTextInputDialog> {
  String _textInput = '';

  void _cancel() {
    final onCancel = widget.onCancel;
    if (onCancel != null) {
      onCancel(context);
    } else {
      Navigator.of(context).pop(null);
    }
  }

  void _confirm() {
    final onConfirm = widget.onConfirm;
    if (onConfirm != null) {
      onConfirm(context, _textInput);
    } else {
      Navigator.of(context).pop(_textInput);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(40),
      content: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isNullOrEmpty(widget.title)) ...[
              HeightConstrainedText(
                widget.title,
                style: context.theme.textTheme.headlineMedium,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20),
            ],
            if (!isNullOrEmpty(widget.mainText)) ...[
              HeightConstrainedText(
                widget.mainText,
                style: context.theme.textTheme.bodyMedium,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 10),
            ],
            if (!isNullOrEmpty(widget.subText)) ...[
              HeightConstrainedText(
                widget.subText,
                style: context.theme.textTheme.bodyMedium,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 10),
            ],
            CustomTextField(
              labelText: widget.textLabel,
              hintText: widget.textHint,
              initialValue: '',
              onChanged: (value) => setState(() => _textInput = value),
              minLines: 2,
              maxLines: 2,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isNullOrEmpty(widget.cancelText))
                  ActionButton(
                    type: ActionButtonType.outline,
                    height: 55,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    minWidth: 100,
                    text: widget.cancelText,
                    textStyle: context.theme.textTheme.bodyMedium,
                    onPressed: _cancel,
                  )
                else
                  SizedBox.shrink(),
                ActionButton(
                  height: 55,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  text: widget.confirmText,
                  textStyle: context.theme.textTheme.bodyMedium,
                  onPressed: (_textInput != '') ? _confirm : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
