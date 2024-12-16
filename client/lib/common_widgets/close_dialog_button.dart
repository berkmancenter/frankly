import 'package:flutter/material.dart';
import 'package:client/common_widgets/custom_ink_well.dart';

class CloseDialogButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 4, top: 4),
        child: CustomInkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.close,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
