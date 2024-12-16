import 'package:flutter/material.dart';
import 'package:client/app/community/discussion_threads/manipulate_discussion_thread/manipulate_discussion_thread_page.dart';
import 'package:client/app/community/events/create_event/create_event_dialog.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/custom_ink_well.dart';
import 'package:client/common_widgets/navbar/profile_or_login.dart';
import 'package:client/common_widgets/navbar/selectable_navigation_icon.dart';
import 'package:client/routing/locations.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:provider/provider.dart';

/// This is the nav bar attached to the bottom of the screen on the Community Home page. It appears on
/// smaller / mobile screen sizes and contains context-specific navigation icons
class CommunityBottomNavBar extends StatelessWidget {
  final bool showCreateMeetingButton;
  final bool showCreateNewEventButton;

  const CommunityBottomNavBar({
    Key? key,
    this.showCreateMeetingButton = false,
    this.showCreateNewEventButton = false,
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
              _buildEventsIcon(context),
              if (showCreateMeetingButton)
                _BottomNavAddIcon(
                  onTap: () => CreateEventDialog.show(context),
                ),
              if (showCreateNewEventButton)
                _BottomNavAddIcon(
                  onTap: () async {
                    await guardSignedIn(
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManipulateDiscussionThreadPage(
                            communityProvider:
                                context.read<CommunityProvider>(),
                            discussionThread: null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ProfileOrLogin(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsIcon(BuildContext context) {
    return CustomInkWell(
      child: Container(
        height: AppSize.kBottomNavBarHeight,
        width: AppSize.kBottomNavBarHeight,
        alignment: Alignment.center,
        child: SelectableNavigationIcon(
          isSelected: false,
          imagePath: AppAsset.kEventsIcon,
          iconSize: 35,
        ),
      ),
      onTap: () => guardSignedIn(() async {
        routerDelegate.beamTo(
          UserSettingsLocation(
            initialSection: UserSettingsSection.events,
          ),
        );
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
          _buildEventsIcon(context),
          ProfileOrLogin(),
        ],
      ),
    );
  }

  Widget _buildEventsIcon(BuildContext context) {
    return CustomInkWell(
      child: Container(
        height: AppSize.kBottomNavBarHeight,
        width: AppSize.kBottomNavBarHeight,
        alignment: Alignment.center,
        child: SelectableNavigationIcon(
          isSelected: false,
          imagePath: AppAsset.kEventsIcon,
          iconSize: 35,
        ),
      ),
      onTap: () => guardSignedIn(() async {
        routerDelegate.beamTo(
          UserSettingsLocation(
            initialSection: UserSettingsSection.events,
          ),
        );
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
    return CustomInkWell(
      onTap: onTap,
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
          child: HeightConstrainedText(
            '+',
            style:
                AppTextStyle.body.copyWith(color: AppColor.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
