import 'dart:math';

import 'package:client/core/widgets/constrained_body.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:client/features/admin/presentation/views/billing_tab.dart';
import 'package:client/features/admin/presentation/views/events_tab.dart';
import 'package:client/features/admin/presentation/views/members_tab.dart';
import 'package:client/features/admin/presentation/views/overview_tab.dart';
import 'package:client/features/admin/presentation/views/settings_tab.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/core/widgets/tabs/tab_bar.dart';
import 'package:client/core/widgets/tabs/tab_bar_view.dart';
import 'package:client/core/widgets/tabs/tab_controller.dart';
import 'package:client/app.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:provider/provider.dart';

class CommunityAdmin extends StatefulWidget {
  final String? tab;

  const CommunityAdmin({required this.tab});

  @override
  _CommunityAdminState createState() => _CommunityAdminState();
}

enum CommunityAdminTabs {
  overview,
  members,
  events,
  settings,
  billing,
}

class _CommunityAdminState extends State<CommunityAdmin>
    with SingleTickerProviderStateMixin {
  late final SelectedTabController _selectedTabController;

  List<CommunityAdminTabs> get tabs {
    final communityProvider = context.read<CommunityProvider>();
    return [
      if (communityProvider.community.isOnboardingOverviewEnabled)
        CommunityAdminTabs.overview,
      CommunityAdminTabs.members,
      CommunityAdminTabs.events,
      CommunityAdminTabs.settings,
      if (kShowStripeFeatures) CommunityAdminTabs.billing,
    ];
  }

  int getTabIndex(CommunityAdminTabs tab) {
    return tabs.indexOf(tab);
  }

  @override
  void initState() {
    super.initState();

    if (!userService.isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => SignInDialog.show(isDismissable: false),
      );
    }

    final queryParamTabs = tabs.map((e) => describeEnum(e)).toList();
    final tab = widget.tab;
    final int initialIndex =
        tab != null ? max(0, queryParamTabs.indexOf(tab)) : 0;
    _selectedTabController = SelectedTabController(initialTab: initialIndex);
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) => ConstrainedBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            SizedBox(height: 30),
            Align(
              alignment: Alignment.bottomLeft,
              child: CustomTabBar(
                padding: null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSections() {
    final communityProvider = context.watch<CommunityProvider>();
    final enableOverview =
        communityProvider.community.isOnboardingOverviewEnabled;

    return CustomTabController(
      selectedTabController: _selectedTabController,
      tabs: [
        if (enableOverview)
          CustomTabAndContent(
            tab: 'OVERVIEW',
            content: (_) => OverviewTab(
              onUpgradeTap: () => _selectedTabController.setTabIndex(
                getTabIndex(CommunityAdminTabs.billing),
              ),
            ),
          ),
        CustomTabAndContent(
          tab: 'MEMBERS',
          content: (context) => MembersTab(),
        ),
        CustomTabAndContent(
          tab: 'EVENTS',
          content: (context) => EventsTab(),
        ),
        CustomTabAndContent(
          tab: 'SETTINGS',
          content: (context) => SettingsTab(
            onUpgradeTap: () => _selectedTabController.setTabIndex(
              getTabIndex(CommunityAdminTabs.billing),
            ),
          ),
        ),
        if (kShowStripeFeatures)
          CustomTabAndContent(
            tab: 'BILLING',
            content: (context) => AdminBillingTab(),
          ),
      ],
      child: CustomListView(
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          ConstrainedBody(
            child: CustomTabBarView(),
          ),
          SizedBox(height: 100),
        ],
      ),
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

    return _buildAdminSections();
  }
}
