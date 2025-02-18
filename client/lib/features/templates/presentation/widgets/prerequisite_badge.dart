import 'package:flutter/material.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

// Widget that shows prerequisite required badge on template page
class PrerequisiteBadge extends StatelessWidget {
  const PrerequisiteBadge({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColor.redLightMode,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColor.lightRed,
              child: Icon(
                Icons.school_outlined,
                color: AppColor.darkRed,
                size: 20,
              ),
            ),
            SizedBox(width: 10),
            HeightConstrainedText(
              'Prerequisite Required',
              style: AppTextStyle.subhead.copyWith(color: AppColor.lightRed),
            ),
          ],
        ),
      ),
    );
  }
}
