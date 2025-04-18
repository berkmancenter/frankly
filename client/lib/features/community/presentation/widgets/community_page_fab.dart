import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

/// This is the FAB shown on the Home Page to create new events.
///
/// This should only be shown if the space does not have a feature flag of
/// 'dontAllowMembersToCreateMeetings'.
class CommunityPageFloatingActionButton extends StatelessWidget {
  final void Function() onTap;
  final String text;

  const CommunityPageFloatingActionButton({
    required this.onTap,
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 10.0,
        bottom: responsiveLayoutService.isMobile(context)
            ? AppSize.kBottomNavBarHeight
            : 10.0,
      ),
      child: CustomInkWell(
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
                color: context.theme.colorScheme.onPrimary,
              ),
              if (!responsiveLayoutService.isMobile(context)) ...[
                SizedBox(width: 20),
                HeightConstrainedText(
                  text,
                  style: AppTextStyle.subhead.copyWith(
                    color: context.theme.colorScheme.onPrimary,
                  ),
                ),
                SizedBox(width: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
