import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

/// This is the FAB shown on the Frankly Home Page to create new events.
///
/// This should only be shown if the space does not have a feature flag of
/// 'dontAllowMembersToCreateMeetings'.
class JuntoPageFloatingActionButton extends StatelessWidget {
  final void Function() onTap;
  final String text;

  const JuntoPageFloatingActionButton({
    required this.onTap,
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 10.0,
        bottom: responsiveLayoutService.isMobile(context) ? AppSize.kBottomNavBarHeight : 10.0,
      ),
      child: JuntoInkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(45),
        child: Container(
          height: 87,
          constraints: BoxConstraints(minWidth: 87),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
            color: Theme.of(context).colorScheme.primary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 41,
                color: AppColor.white,
              ),
              if (!responsiveLayoutService.isMobile(context)) ...[
                SizedBox(width: 20),
                JuntoText(
                  text,
                  style: AppTextStyle.subhead.copyWith(
                    color: AppColor.white,
                  ),
                ),
                SizedBox(width: 20),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
