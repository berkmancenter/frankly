import 'dart:math';

import 'package:flutter/material.dart';
import 'package:client/common_widgets/community_icon_or_logo.dart';
import 'package:client/common_widgets/custom_ink_well.dart';
import 'package:client/common_widgets/community_membership_button.dart';
import 'package:client/common_widgets/navbar/sidebar/community_side_bar_navigation.dart';
import 'package:client/routing/locations.dart';
import 'package:client/services/user_data_service.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:client/utils/stream_utils.dart';
import 'package:data_models/firestore/community.dart';
import 'package:provider/provider.dart';

class NavListItem extends StatefulWidget {
  final Community community;
  final bool isCollapsible;
  final bool buttonActive;
  final bool isOpenByDefault;

  const NavListItem({
    this.isOpenByDefault = true,
    this.isCollapsible = true,
    this.buttonActive = true,
    required this.community,
    Key? key,
  }) : super(key: key);

  @override
  State<NavListItem> createState() => _NavListItemState();
}

class _NavListItemState extends State<NavListItem> {
  late bool isOpen = widget.isOpenByDefault ? true : false;

  void _activateTitle() => setState(() => isOpen = !isOpen);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTitleRow(),
        if (isOpen) _buildNavLinks(),
      ],
    );
  }

  Widget _buildTitleRow() {
    final initialCommunityRoute =
        CommunityPageRoutes(communityDisplayId: widget.community.displayId);

    return Row(
      children: [
        CustomInkWell(
          hoverColor: Colors.transparent,
          onTap: () =>
              routerDelegate.beamTo(initialCommunityRoute.communityHome),
          child: CommunityCircleIcon(
            widget.community,
            withBorder: true,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: CustomInkWell(
            onTap: () =>
                routerDelegate.beamTo(initialCommunityRoute.communityHome),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: HeightConstrainedText(
                widget.community.name ?? 'Unnamed Community',
                style: AppTextStyle.body.copyWith(color: AppColor.gray1),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        if (widget.isCollapsible)
          CustomInkWell(
            hoverColor: Colors.transparent,
            onTap: _activateTitle,
            child: Transform.rotate(
              angle: pi / 2 + (isOpen ? pi : 0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavLinks() =>
      CommunitySidebarNavLinks(community: widget.community);
}

class CommunitySidebarNavLinks extends StatelessWidget {
  final Community community;

  const CommunitySidebarNavLinks({required this.community, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userIsMember =
        context.watch<UserDataService>().isMember(communityId: community.id);
    final userIsAdmin =
        CommunityPermissionsProvider.canEditCommunityFromId(community.id);

    if (userIsMember) {
      return CustomStreamGetterBuilder<bool>(
        streamGetter: () => firestoreCommunityResourceService
            .communityHasResources(communityId: community.id),
        keys: const [],
        entryFrom: 'CommunitySidebarNavLinks.build',
        showLoading: false,
        builder: (context, showLinks) {
          return CommunitySideBarNavigation(
            community: community,
            showResources: (showLinks != null && (showLinks)) || userIsAdmin,
            showAdmin: userIsAdmin,
            enableDiscussionThreads:
                community.settingsMigration.enableDiscussionThreads,
            showLeaveCommunity: !userIsAdmin,
          );
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: CommunityMembershipButton(
          community,
          bgColor: AppColor.darkBlue,
          minWidth: 315,
        ),
      );
    }
  }
}
