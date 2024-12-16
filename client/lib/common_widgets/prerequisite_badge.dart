import 'package:flutter/material.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

// Widget that shows prerequisite required badge on topic page
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
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.redLightMode),
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
            JuntoText(
              'Prerequisite Required',
              style: AppTextStyle.subhead.copyWith(color: AppColor.lightRed),
            )
          ],
        ),
      ),
    );
  }
}
