import 'dart:math';

import 'package:client/core/widgets/constrained_body.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/user/presentation/views/events_tab.dart';
import 'package:client/features/user/presentation/views/notifications_tab.dart';
import 'package:client/features/user/presentation/views/profile_tab.dart';
import 'package:client/features/user/presentation/views/subscriptions_tab.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/navbar/custom_scaffold.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/core/widgets/tabs/tab_bar.dart';
import 'package:client/core/widgets/tabs/tab_bar_view.dart';
import 'package:client/core/widgets/tabs/tab_controller.dart';
import 'package:client/app.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

class UserSettingsPage extends StatefulWidget {
  final String? communityId;
  final UserSettingsSection? initialSection;

  const UserSettingsPage({
    this.communityId,
    this.initialSection,
  });

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<NavBarProvider>().checkIfShouldResetNav();

    if (!userService.isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => SignInDialog.show());
    }
  }

  int _getInitialIndex() {
    final sectionIndexLookup = <UserSettingsSection, int>{
      UserSettingsSection.events: 0,
      UserSettingsSection.profile: 1,
      UserSettingsSection.notifications: 2,
      if (kShowStripeFeatures) UserSettingsSection.subscriptions: 3,
    };
    return sectionIndexLookup[widget.initialSection] ?? 0;
  }

  Widget _buildTabs() {
    List<CustomTabAndContent> tabsAndContent = [
      CustomTabAndContent(
        tab: context.l10n.myEvents,
        content: (context) => EventsTab.create(),
      ),
      CustomTabAndContent(
        tab: context.l10n.profile,
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
      CustomTabAndContent(
        tab: context.l10n.notifications,
        content: (context) => ConstrainedBody(
          child: NotificationsTab(initialCommunityId: widget.communityId),
        ),
      ),
      if (kShowStripeFeatures)
        CustomTabAndContent(
          tab: context.l10n.billing,
          content: (context) => ConstrainedBody(child: SubscriptionsTab()),
        ),
    ];

    return CustomTabController(
      selectedTabController:
          SelectedTabController(initialTab: _getInitialIndex()),
      tabs: tabsAndContent,
      child: CustomListView(
        children: [
          _buildHeaderAndTabs(),
          CustomTabBarView(),
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
                  (constraints.biggest.width -
                              ConstrainedBody.defaultMaxWidth) /
                          2 +
                      ConstrainedBody.outerPadding,
                ),
              );
              return CustomTabBar(
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
    return CustomScaffold(
      child: Provider.of<UserService>(context).isSignedIn
          ? _buildTabs()
          : Container(
              alignment: Alignment.center,
              child: Text(context.l10n.mustBeLoggedInToAccessThisSection),
            ),
    );
  }
}
