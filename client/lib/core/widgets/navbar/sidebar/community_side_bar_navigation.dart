import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:flutter/material.dart';
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
        ActionButton(
          type: ActionButtonType.text,
          text: 'Events',
          onPressed: () =>
              routerDelegate.beamTo(initialCommunityRoute.eventsPage),
          textStyle: context.theme.textTheme.bodyMedium,
          expand: true,
          padding: EdgeInsets.symmetric(horizontal: 16),
          contentAlign: ActionButtonContentAlignment.start,
        ),
        if (enableDiscussionThreads) ...[
          ActionButton(
            type: ActionButtonType.text,
            text: 'Posts',
            onPressed: () => routerDelegate
                .beamTo(initialCommunityRoute.discussionThreadsPage),
            textStyle: context.theme.textTheme.bodyMedium,
            padding: EdgeInsets.symmetric(horizontal: 16),
            expand: true,
            contentAlign: ActionButtonContentAlignment.start,
          ),
        ],
        if (showResources) ...[
          ActionButton(
            type: ActionButtonType.text,
            text: 'Resources',
            onPressed: () =>
                routerDelegate.beamTo(initialCommunityRoute.resourcesPage),
            textStyle: context.theme.textTheme.bodyMedium,
            expand: true,
            padding: EdgeInsets.symmetric(horizontal: 16),
            contentAlign: ActionButtonContentAlignment.start,
          ),
        ],
        ActionButton(
          type: ActionButtonType.text,
          text: 'Templates',
          onPressed: () =>
              routerDelegate.beamTo(initialCommunityRoute.browseTemplatesPage),
          textStyle: context.theme.textTheme.bodyMedium,
          expand: true,
          padding: EdgeInsets.symmetric(horizontal: 16),
          contentAlign: ActionButtonContentAlignment.start,
        ),
        if (showLeaveCommunity)
          Semantics(
            label: 'Sidebar Unfollow Button',
            identifier: 'sidebar_unfollow_button',
            button: true,
            child: ActionButton(
              type: ActionButtonType.text,
              text: 'Unfollow',
              onPressed: () => alertOnError(
                context,
                () => Provider.of<UserDataService>(context, listen: false)
                    .requestChangeCommunityMembership(
                  community: community,
                  join: false,
                ),
              ),
              textStyle: context.theme.textTheme.bodyMedium,
              expand: true,
              padding: EdgeInsets.symmetric(horizontal: 16),
              contentAlign: ActionButtonContentAlignment.start,
            ),
          ),
        if (showAdmin) ...[
          ActionButton(
            type: ActionButtonType.text,
            text: 'Admin',
            onPressed: () =>
                routerDelegate.beamTo(initialCommunityRoute.communityAdmin()),
            textStyle: context.theme.textTheme.bodyMedium,
            expand: true,
            padding: EdgeInsets.symmetric(horizontal: 16),
            contentAlign: ActionButtonContentAlignment.start,
          ),
        ],
      ],
    );
  }
}
