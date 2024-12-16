import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/junto_text.dart';

class JumpToRoomDialog extends StatefulWidget {
  const JumpToRoomDialog();

  Future<String?> show() async {
    return showJuntoDialog<String>(builder: (_) => this);
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
        JuntoText(
          'Room Number:',
          textAlign: TextAlign.center,
          style: body.copyWith(fontSize: 14),
        ),
        SizedBox(
          width: 60,
          child: JuntoTextField(
            hintText: 'Ex: 2',
            controller: _textController,
          ),
        ),
        ActionButton(
          onPressed: () => Navigator.of(context).pop(_textController.text),
          text: 'View',
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
