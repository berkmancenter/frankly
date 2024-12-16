import 'dart:math';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/app/self/conversations_tab.dart';
import 'package:junto/app/self/notifications_tab.dart';
import 'package:junto/app/self/profile_tab.dart';
import 'package:junto/app/self/subscriptions_tab.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/navbar/junto_scaffold.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/common_widgets/sign_in_dialog.dart';
import 'package:junto/common_widgets/tabs/tab_bar.dart';
import 'package:junto/common_widgets/tabs/tab_bar_view.dart';
import 'package:junto/common_widgets/tabs/tab_controller.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:provider/provider.dart';

class UserSettingsPage extends StatefulWidget {
  final String? juntoId;
  final UserSettingsSection? initialSection;

  const UserSettingsPage({
    this.juntoId,
    this.initialSection,
  });

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<NavBarProvider>().checkIfShouldResetNav();

    if (!userService.isSignedIn) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => SignInDialog.show());
    }
  }

  int _getInitialIndex() {
    final sectionIndexLookup = <UserSettingsSection, int>{
      UserSettingsSection.conversations: 0,
      UserSettingsSection.profile: 1,
      UserSettingsSection.notifications: 2,
      if (kShowStripeFeatures) UserSettingsSection.subscriptions: 3,
    };
    return sectionIndexLookup[widget.initialSection] ?? 0;
  }

  Widget _buildTabs() {
    List<JuntoTabAndContent> _tabsAndContent = [
      JuntoTabAndContent(
        tab: 'MY EVENTS',
        content: (context) => ConversationsTab.create(),
      ),
      JuntoTabAndContent(
        tab: 'PROFILE',
        content: (context) => ConstrainedBody(
          child: ChangeNotifierProvider(
            create: (_) => AppDrawerProvider(),
            builder: (_, __) {
              return ProfileTab(
                currentUserId: userService.currentUserId!,
                isPreviewButtonVisible: true,
              );
            },
          ),
        ),
      ),
      JuntoTabAndContent(
        tab: 'NOTIFICATIONS',
        content: (context) => ConstrainedBody(
          child: NotificationsTab(initialJuntoId: widget.juntoId),
        ),
      ),
      if (kShowStripeFeatures)
        JuntoTabAndContent(
          tab: 'BILLING',
          content: (context) => ConstrainedBody(child: SubscriptionsTab()),
        ),
    ];

    return JuntoTabController(
      selectedTabController: SelectedTabController(initialTab: _getInitialIndex()),
      tabs: _tabsAndContent,
      child: JuntoListView(
        children: [
          _buildHeaderAndTabs(),
          JuntoTabBarView(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeaderAndTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 30),
        Align(
          alignment: Alignment.bottomLeft,
          child: LayoutBuilder(
            builder: (_, constraints) {
              final padding = EdgeInsets.symmetric(
                horizontal: max(
                    ConstrainedBody.outerPadding,
                    (constraints.biggest.width - ConstrainedBody.defaultMaxWidth) / 2 +
                        ConstrainedBody.outerPadding),
              );
              return JuntoTabBar(
                padding: padding,
                isWhiteBackground: true,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext buildContext) {
    return JuntoScaffold(
      bgColor: AppColor.gray6,
      child: Provider.of<UserService>(context).isSignedIn
          ? _buildTabs()
          : Container(
              alignment: Alignment.center,
              child: Text('Must be logged in to access this section'),
            ),
    );
  }
}
