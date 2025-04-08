import 'package:client/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/navbar/sidebar/side_bar_navigation_button.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';

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
          text: 'Events',
          onTap: () => routerDelegate.beamTo(initialCommunityRoute.eventsPage),
          style: AppTextStyle.body,
        ),
        if (enableDiscussionThreads) ...[
          SideBarNavigationButton(
            text: 'Posts',
            onTap: () => routerDelegate
                .beamTo(initialCommunityRoute.discussionThreadsPage),
            style: AppTextStyle.body,
          ),
        ],
        if (showResources) ...[
          SideBarNavigationButton(
            text: 'Resources',
            style: AppTextStyle.body,
            onTap: () =>
                routerDelegate.beamTo(initialCommunityRoute.resourcesPage),
          ),
        ],
        SideBarNavigationButton(
          text: 'Templates',
          onTap: () =>
              routerDelegate.beamTo(initialCommunityRoute.browseTemplatesPage),
          style: AppTextStyle.body,
        ),
        if (showLeaveCommunity)
          SideBarNavigationButton(
            text: 'Unfollow',
            onTap: () => alertOnError(
              context,
              () => Provider.of<UserDataService>(context, listen: false)
                  .requestChangeCommunityMembership(
                community: community,
                join: false,
              ),
            ),
          ),
        if (showAdmin) ...[
          SideBarNavigationButton(
            text: 'Admin',
            onTap: () =>
                routerDelegate.beamTo(initialCommunityRoute.communityAdmin()),
            style: AppTextStyle.body,
          ),
        ],
      ],
    );
  }
}
