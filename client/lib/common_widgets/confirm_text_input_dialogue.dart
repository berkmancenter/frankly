import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/junto_text.dart';

class ConfirmTextInputDialogue extends StatefulWidget {
  final String title;
  final String mainText;
  final String subText;
  final String confirmText;
  final Function(BuildContext context, String input)? onConfirm;
  final String cancelText;
  final Function(BuildContext context)? onCancel;
  final String textLabel;
  final String textHint;

  const ConfirmTextInputDialogue({
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
    return (await showJuntoDialog(builder: (_) => this));
  }

  @override
  State<ConfirmTextInputDialogue> createState() => _ConfirmTextInputDialogueState();
}

class _ConfirmTextInputDialogueState extends State<ConfirmTextInputDialogue> {
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

  Widget _buildDialog(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.darkBlue,
          ),
          padding: const EdgeInsets.all(40),
          child: JuntoListView(
            shrinkWrap: true,
            children: [
              if (!isNullOrEmpty(widget.title)) ...[
                JuntoText(
                  widget.title,
                  style: AppTextStyle.headline1.copyWith(color: AppColor.white),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 20),
              ],
              if (!isNullOrEmpty(widget.mainText)) ...[
                JuntoText(
                  widget.mainText,
                  style: AppTextStyle.body.copyWith(color: AppColor.white),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 10),
              ],
              if (!isNullOrEmpty(widget.subText)) ...[
                JuntoText(
                  widget.subText,
                  style: AppTextStyle.body.copyWith(color: AppColor.white),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 10),
              ],
              JuntoTextField(
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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      minWidth: 100,
                      color: Colors.transparent,
                      text: widget.cancelText,
                      textStyle: AppTextStyle.body.copyWith(color: AppColor.white),
                      onPressed: _cancel,
                    )
                  else
                    SizedBox.shrink(),
                  ActionButton(
                    height: 55,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    color: AppColor.brightGreen,
                    text: widget.confirmText,
                    textStyle: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
                    onPressed: (_textInput != '') ? _confirm : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JuntoUiMigration(
      child: Align(
        alignment: Alignment.center,
        child: Builder(
          builder: (context) => _buildDialog(context),
        ),
      ),
    );
  }
}
