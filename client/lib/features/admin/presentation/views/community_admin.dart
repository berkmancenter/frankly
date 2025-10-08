import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/constrained_body.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/community/community.dart';
import 'package:flutter/material.dart';
import 'package:client/features/admin/presentation/views/data_tab.dart';
import 'package:client/features/admin/presentation/views/members_tab.dart';
import 'package:client/features/admin/presentation/views/overview_tab.dart';
import 'package:client/features/admin/presentation/views/settings_tab.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';

class CommunityAdmin extends StatefulWidget {
  final String? tab;

  const CommunityAdmin({required this.tab});

  @override
  CommunityAdminState createState() => CommunityAdminState();
}

class CommunityAdminState extends State<CommunityAdmin>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
    );

    if (!userService.isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => SignInDialog.show(isDismissable: false),
      );
    }
  }

  _buildTab(BuildContext context, String text, IconData icon, bool mobile) {
    return Flex(
      direction: mobile ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon),
        SizedBox(width: mobile ? 0 : 8),
        HeightConstrainedText(
          text,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontSize: mobile ? 11 : 16,
              ),
          maxLines: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<CommunityPermissionsProvider>(context).canEditCommunity) {
      return Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: HeightConstrainedText(
          'Must be logged in and an admin to access this section',
        ),
      );
    }
    final Community community =
        Provider.of<CommunityProvider>(context).community;
    final mobile = responsiveLayoutService.isMobile(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActionButton(
              text: community.name,
              type: ActionButtonType.text,
              icon: Icon(Icons.arrow_back_outlined),
              onPressed: () {
                Navigator.of(context).pop();
                routerDelegate.beamTo(
                  CommunityPageRoutes(
                    communityDisplayId: community.displayId,
                  ).communityHome,
                );
              },
            ),
            HeightConstrainedText(
              context.l10n.manageCommunity,
              style: context.theme.textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(
              child: _buildTab(
                context,
                context.l10n.profile,
                Icons.edit_square,
                mobile,
              ),
            ),
            Tab(
              child: _buildTab(
                context,
                context.l10n.members,
                Icons.group_outlined,
                mobile,
              ),
            ),
            Tab(
              child: _buildTab(
                context,
                context.l10n.data,
                Icons.downloading_outlined,
                mobile,
              ),
            ),
            Tab(
              child: _buildTab(
                context,
                context.l10n.settings,
                Icons.settings,
                mobile,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(),
                MembersTab(),
                DataTab(),
                SettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
