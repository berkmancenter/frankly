import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/navbar/sidebar/side_bar_navigation_button.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';

class JuntoSideBarNavigation extends StatelessWidget {
  final bool showAdmin;
  final bool enableDiscussionThreads;
  final bool showResources;
  final bool showLeaveJunto;
  final Junto junto;

  const JuntoSideBarNavigation({
    Key? key,
    required this.junto,
    this.showAdmin = false,
    this.enableDiscussionThreads = false,
    this.showResources = false,
    this.showLeaveJunto = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialJuntoRoute = JuntoPageRoutes(juntoDisplayId: junto.displayId);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12),
        SideBarNavigationButton(
          text: 'Events',
          onTap: () => routerDelegate.beamTo(initialJuntoRoute.discussionsPage),
          style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
        ),
        if (enableDiscussionThreads) ...[
          SideBarNavigationButton(
            text: 'Posts',
            onTap: () => routerDelegate.beamTo(initialJuntoRoute.discussionThreadsPage),
            style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
          ),
        ],
        if (showResources) ...[
          SideBarNavigationButton(
            text: 'Resources',
            style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
            onTap: () => routerDelegate.beamTo(initialJuntoRoute.resourcesPage),
          ),
        ],
        SideBarNavigationButton(
          text: 'Templates',
          onTap: () => routerDelegate.beamTo(initialJuntoRoute.browseTopicsPage),
          style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
        ),
        if (showLeaveJunto)
          SideBarNavigationButton(
            text: 'Unfollow',
            onTap: () => alertOnError(
              context,
              () => Provider.of<JuntoUserDataService>(context, listen: false)
                  .requestChangeJuntoMembership(
                junto: junto,
                join: false,
              ),
            ),
          ),
        if (showAdmin) ...[
          SideBarNavigationButton(
            text: 'Admin',
            onTap: () => routerDelegate.beamTo(initialJuntoRoute.juntoAdmin()),
            style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
          ),
        ],
      ],
    );
  }
}
