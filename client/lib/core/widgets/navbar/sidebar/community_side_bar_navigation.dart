import 'package:client/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/navbar/sidebar/side_bar_navigation_button.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';
class CommunitySideBarNavigation extends StatelessWidget {
  final bool showAdmin;
  final bool enableDiscussionThreads;
  final bool showResources;
  final bool showLeaveCommunity;
  final Community community;

  const CommunitySideBarNavigation({
    Key? key,
    required this.community,
    this.showAdmin = false,
    this.enableDiscussionThreads = false,
    this.showResources = false,
    this.showLeaveCommunity = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialCommunityRoute =
        CommunityPageRoutes(communityDisplayId: community.displayId);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12),
        SideBarNavigationButton(
          text: context.l10n.sidebarEventsButton,
          onTap: () => routerDelegate.beamTo(initialCommunityRoute.eventsPage),
          style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
        ),
        if (enableDiscussionThreads) ...[
          SideBarNavigationButton(
            text: context.l10n.sidebarPostsButton,
            onTap: () => routerDelegate
                .beamTo(initialCommunityRoute.discussionThreadsPage),
            style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
          ),
        ],
        if (showResources) ...[
          SideBarNavigationButton(
            text: context.l10n.sidebarResourcesButton,
            style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
            onTap: () =>
                routerDelegate.beamTo(initialCommunityRoute.resourcesPage),
          ),
        ],
        SideBarNavigationButton(
          text: context.l10n.sidebarTemplatesButton,
          onTap: () =>
              routerDelegate.beamTo(initialCommunityRoute.browseTemplatesPage),
          style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
        ),
        if (showLeaveCommunity)
         Semantics(
          label: context.l10n.sidebarUnfollowButton,
          identifier: 'sidebar_unfollow_button',
          button: true,
          child: SideBarNavigationButton(
              text: context.l10n.unfollow,
              onTap: () => alertOnError(
                context,
                () => Provider.of<UserDataService>(context, listen: false)
                    .requestChangeCommunityMembership(
                  community: community,
                  join: false,
                ),
              ),
            ),
          ),
        if (showAdmin) ...[
          SideBarNavigationButton(
            text: context.l10n.sidebarAdminButton,
            onTap: () =>
                routerDelegate.beamTo(initialCommunityRoute.communityAdmin()),
            style: AppTextStyle.body.copyWith(color: AppColor.darkBlue),
          ),
        ],
      ],
    );
  }
}
