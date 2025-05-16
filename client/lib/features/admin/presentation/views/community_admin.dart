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
    return ConstrainedBody(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 30),
          SizedBox(
            height: 600,
            child: DefaultTabController(
              length: 4,
              child: Scaffold(
                appBar: AppBar(
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'Profile'),
                      Tab(text: 'Members'),
                      Tab(text: 'Settings'),
                      Tab(text: 'Data'),
                    ],
                  ),
                  title: const Text('Community Admin'),
                ),
                body: TabBarView(
                  children: [
                    OverviewTab(),
                    MembersTab(),
                    SettingsTab(),
                    AdminBillingTab(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
