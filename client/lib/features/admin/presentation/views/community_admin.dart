import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/constrained_body.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/community/community.dart';
import 'package:flutter/material.dart';
import 'package:client/features/admin/presentation/views/billing_tab.dart';
import 'package:client/features/admin/presentation/views/events_tab.dart';
import 'package:client/features/admin/presentation/views/members_tab.dart';
import 'package:client/features/admin/presentation/views/overview_tab.dart';
import 'package:client/features/admin/presentation/views/settings_tab.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/js.dart';

class CommunityAdmin extends StatefulWidget {
  final String? tab;

  const CommunityAdmin({required this.tab});

  @override
  _CommunityAdminState createState() => _CommunityAdminState();
}

class _CommunityAdminState extends State<CommunityAdmin>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

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
    return ConstrainedBody(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(height: 10),
          HeightConstrainedText(
            context.l10n.manageCommunity,
            style: context.theme.textTheme.headlineMedium,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 30),
          SizedBox(
            height: 600,
            child: DefaultTabController(
              length: 4,
              child: Scaffold(
                appBar: AppBar(
                  bottom: TabBar(
                    tabs: [
                      Tab(
                        child:
                            _buildTab(context, 'Overview', Icons.edit, mobile),
                      ),
                      Tab(
                        child: _buildTab(context, 'Members',
                            Icons.groups_3_outlined, mobile,),
                      ),
                      Tab(
                        child: _buildTab(context, 'Data',
                            Icons.downloading_outlined, mobile,),
                      ),
                      Tab(
                        child: _buildTab(
                            context, 'Settings', Icons.settings, mobile,),
                      ),
                    ],
                  ),
                  
                ),body: TabBarView(
                  children: [
                    OverviewTab(),
                    MembersTab(),
                    SettingsTab(),
                    AdminBillingTab(),
                  ],
              ),
            ),
          ),
      ),],
      ),
    );
  }
}
