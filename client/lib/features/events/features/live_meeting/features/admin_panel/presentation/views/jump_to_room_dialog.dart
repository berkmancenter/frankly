import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/localization/localization_helper.dart';

class JumpToRoomDialog extends StatefulWidget {
  const JumpToRoomDialog();

  Future<String?> show() async {
    return showCustomDialog<String>(builder: (_) => this);
  }

  @override
  _JumpToRoomDialogState createState() => _JumpToRoomDialogState();
}

class _JumpToRoomDialogState extends State<JumpToRoomDialog> {
  final _textController = TextEditingController();

  Widget _buildBreakoutRoomChooser() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        HeightConstrainedText(
          context.l10n.roomNumber,
          textAlign: TextAlign.center,
          style: body.copyWith(fontSize: 14),
        ),
        SizedBox(
          width: 60,
          child: CustomTextField(
            hintText: context.l10n.enterRoomNumber,
            controller: _textController,
          ),
        ),
        ActionButton(
          onPressed: () => Navigator.of(context).pop(_textController.text),
          text: context.l10n.view,
          textColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(4),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Jump To Room',
              style: TextStyle(color: AppColor.white, fontSize: 16),
            ),
          ),
        ),
        SizedBox(height: 24),
        _buildBreakoutRoomChooser(),
        SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color(0xFF5568FF),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: Stack(
          children: [
            _buildMainContent(),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
