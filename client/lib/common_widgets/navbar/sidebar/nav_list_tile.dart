import 'dart:math';

import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_icon_or_logo.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_membership_button.dart';
import 'package:junto/common_widgets/navbar/sidebar/junto_side_bar_navigation.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';

class NavListItem extends StatefulWidget {
  final Junto junto;
  final bool isCollapsible;
  final bool buttonActive;
  final bool isOpenByDefault;

  const NavListItem({
    this.isOpenByDefault = true,
    this.isCollapsible = true,
    this.buttonActive = true,
    required this.junto,
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
    final initialJuntoRoute = JuntoPageRoutes(juntoDisplayId: widget.junto.displayId);

    return Row(
      children: [
        JuntoInkWell(
          hoverColor: Colors.transparent,
          onTap: () => routerDelegate.beamTo(initialJuntoRoute.juntoHome),
          child: JuntoCircleIcon(
            widget.junto,
            withBorder: true,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: JuntoInkWell(
            onTap: () => routerDelegate.beamTo(initialJuntoRoute.juntoHome),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: JuntoText(
                widget.junto.name ?? 'Unnamed Community',
                style: AppTextStyle.body.copyWith(color: AppColor.gray1),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        if (widget.isCollapsible)
          JuntoInkWell(
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
          )
      ],
    );
  }

  Widget _buildNavLinks() => JuntoSidebarNavLinks(junto: widget.junto);
}

class JuntoSidebarNavLinks extends StatelessWidget {
  final Junto junto;

  const JuntoSidebarNavLinks({required this.junto, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userIsMember = context.watch<JuntoUserDataService>().isMember(juntoId: junto.id);
    final userIsAdmin = CommunityPermissionsProvider.canEditCommunityFromId(junto.id);

    if (userIsMember) {
      return JuntoStreamGetterBuilder<bool>(
        streamGetter: () => firestoreJuntoResourceService.juntoHasResources(juntoId: junto.id),
        keys: const [],
        entryFrom: 'JuntoSidebarNavLinks.build',
        showLoading: false,
        builder: (context, showLinks) {
          return JuntoSideBarNavigation(
            junto: junto,
            showResources: (showLinks != null && (showLinks)) || userIsAdmin,
            showAdmin: userIsAdmin,
            enableDiscussionThreads: junto.settingsMigration.enableDiscussionThreads,
            showLeaveJunto: !userIsAdmin,
          );
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: JuntoMembershipButton(
          junto,
          bgColor: AppColor.darkBlue,
          minWidth: 315,
        ),
      );
    }
  }
}
