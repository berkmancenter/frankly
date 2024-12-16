import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussion_threads/manipulate_discussion_thread/manipulate_discussion_thread_page.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/navbar/profile_or_login.dart';
import 'package:junto/common_widgets/navbar/selectable_navigation_icon.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:provider/provider.dart';

/// This is the nav bar attached to the bottom of the screen on the Junto Home page. It appears on
/// smaller / mobile screen sizes and contains context-specific navigation icons
class JuntoBottomNavBar extends StatelessWidget {
  final bool showCreateMeetingButton;
  final bool showCreateNewDiscussionButton;

  const JuntoBottomNavBar({
    Key? key,
    this.showCreateMeetingButton = false,
    this.showCreateNewDiscussionButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.white,
      // Adjusting AppSize.bottomNavBarHeight directly - does not seem to work
      // therefore we add amendment here.
      height: AppSize.kBottomNavBarHeight + 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildConversationsIcon(context),
              if (showCreateMeetingButton)
                _BottomNavAddIcon(onTap: () => CreateDiscussionDialog.show(context)),
              if (showCreateNewDiscussionButton)
                _BottomNavAddIcon(onTap: () async {
                  await guardSignedIn(
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManipulateDiscussionThreadPage(
                          juntoProvider: context.read<JuntoProvider>(),
                          discussionThread: null,
                        ),
                      ),
                    ),
                  );
                }),
              ProfileOrLogin(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsIcon(BuildContext context) {
    return JuntoInkWell(
      child: Container(
        height: AppSize.kBottomNavBarHeight,
        width: AppSize.kBottomNavBarHeight,
        alignment: Alignment.center,
        child: SelectableNavigationIcon(
          isSelected: false,
          imagePath: AppAsset.kConversationsIcon,
          iconSize: 35,
        ),
      ),
      onTap: () => guardSignedIn(() async {
        routerDelegate
            .beamTo(UserSettingsLocation(initialSection: UserSettingsSection.conversations));
      }),
    );
  }
}

/// This is the bottom nav bar for the home page. It appears at smaller screen sizes.
class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.white,
      height: AppSize.kBottomNavBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildConversationsIcon(context),
          ProfileOrLogin(),
        ],
      ),
    );
  }

  Widget _buildConversationsIcon(BuildContext context) {
    return JuntoInkWell(
      child: Container(
        height: AppSize.kBottomNavBarHeight,
        width: AppSize.kBottomNavBarHeight,
        alignment: Alignment.center,
        child: SelectableNavigationIcon(
          isSelected: false,
          imagePath: AppAsset.kConversationsIcon,
          iconSize: 35,
        ),
      ),
      onTap: () => guardSignedIn(() async {
        routerDelegate
            .beamTo(UserSettingsLocation(initialSection: UserSettingsSection.conversations));
      }),
    );
  }
}

class _BottomNavAddIcon extends StatelessWidget {
  final void Function()? onTap;

  const _BottomNavAddIcon({
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JuntoInkWell(
      child: Container(
        height: AppSize.kBottomNavBarHeight,
        width: AppSize.kBottomNavBarHeight,
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.primary,
          ),
          height: 32,
          width: 32,
          child: JuntoText(
            '+',
            style: AppTextStyle.body.copyWith(color: AppColor.white, fontSize: 20),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
