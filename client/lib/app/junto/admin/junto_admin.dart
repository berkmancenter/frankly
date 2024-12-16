import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/admin/billing_tab.dart';
import 'package:junto/app/junto/admin/conversations_tab.dart';
import 'package:junto/app/junto/admin/members_tab.dart';
import 'package:junto/app/junto/admin/overview/overview_tab.dart';
import 'package:junto/app/junto/admin/settings_tab.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/sign_in_dialog.dart';
import 'package:junto/common_widgets/tabs/tab_bar.dart';
import 'package:junto/common_widgets/tabs/tab_bar_view.dart';
import 'package:junto/common_widgets/tabs/tab_controller.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:provider/provider.dart';

class JuntoAdmin extends StatefulWidget {
  final String? tab;

  const JuntoAdmin({required this.tab});

  @override
  _JuntoAdminState createState() => _JuntoAdminState();
}

enum JuntoAdminTabs {
  overview,
  members,
  conversations,
  settings,
  billing,
}

class _JuntoAdminState extends State<JuntoAdmin> with SingleTickerProviderStateMixin {
  late final SelectedTabController _selectedTabController;

  List<JuntoAdminTabs> get tabs {
    final juntoProvider = context.read<JuntoProvider>();
    return [
      if (juntoProvider.junto.isOnboardingOverviewEnabled) JuntoAdminTabs.overview,
      JuntoAdminTabs.members,
      JuntoAdminTabs.conversations,
      JuntoAdminTabs.settings,
      if (kShowStripeFeatures) JuntoAdminTabs.billing,
    ];
  }

  int getTabIndex(JuntoAdminTabs tab) {
    return tabs.indexOf(tab);
  }

  @override
  void initState() {
    super.initState();

    if (!userService.isSignedIn) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => SignInDialog.show(isDismissable: false));
    }

    final queryParamTabs = tabs.map((e) => describeEnum(e)).toList();
    final tab = widget.tab;
    final int initialIndex = tab != null ? max(0, queryParamTabs.indexOf(tab)) : 0;
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
              child: JuntoTabBar(
                padding: null,
                isWhiteBackground: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSections() {
    final juntoProvider = context.watch<JuntoProvider>();
    final enableOverview = juntoProvider.junto.isOnboardingOverviewEnabled;

    return JuntoTabController(
      selectedTabController: _selectedTabController,
      tabs: [
        if (enableOverview)
          JuntoTabAndContent(
            tab: 'OVERVIEW',
            content: (_) => OverviewTab(
              onUpgradeTap: () => _selectedTabController.setTabIndex(
                getTabIndex(JuntoAdminTabs.billing),
              ),
            ),
          ),
        JuntoTabAndContent(
          tab: 'MEMBERS',
          content: (context) => MembersTab(),
        ),
        JuntoTabAndContent(
          tab: 'CONVERSATIONS',
          content: (context) => ConversationsTab(),
        ),
        JuntoTabAndContent(
          tab: 'SETTINGS',
          content: (context) => SettingsTab(
            onUpgradeTap: () => _selectedTabController.setTabIndex(
              getTabIndex(JuntoAdminTabs.billing),
            ),
          ),
        ),
        if (kShowStripeFeatures)
          JuntoTabAndContent(
            tab: 'BILLING',
            content: (context) => AdminBillingTab(),
          ),
      ],
      child: JuntoListView(
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          ConstrainedBody(
            child: JuntoTabBarView(),
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
          child: JuntoText('Must be logged in and an admin to access this section'));
    }

    return _buildAdminSections();
  }
}
