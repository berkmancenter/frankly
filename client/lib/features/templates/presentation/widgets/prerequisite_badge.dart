import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

// Widget that shows prerequisite required badge on template page
class PrerequisiteBadge extends StatelessWidget {
  const PrerequisiteBadge({
    Key? key,
    this.textStyle,
  }) : super(key: key);

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: context.theme.colorScheme.errorContainer,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: context.theme.colorScheme.onErrorContainer,
              child: Icon(
                Icons.school_outlined,
                color: context.theme.colorScheme.errorContainer,
                size: 20,
              ),
            ),
            SizedBox(width: 10),
            HeightConstrainedText(
              'Prerequisite Required',
              style: (textStyle ?? AppTextStyle.subhead)
                  .copyWith(color: context.theme.colorScheme.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }
}
