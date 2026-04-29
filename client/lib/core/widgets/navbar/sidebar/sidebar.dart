import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/buttons/circle_icon_button.dart';
import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/dialog_flow.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/core/widgets/navbar/sidebar/sidebar_navigation_list_item.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/config/environment.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js_util.dart' as js_util;
import 'package:client/core/localization/language_selector.dart';

/// This is the side navigation drawer that appears when the hamburger icon is clicked. It contains
/// links to sign in if the user is not signed in, otherwise it contains links to the user's communities
class SideBar extends StatefulWidget {
  SideBar() : super(key: Key('sideBar'));

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  // This prevents an error from being thrown if navigating to an app page from the home page by
  // cancelling the lookup of the CommunityProvider before it is initialized, as the sidebar is closing.
  final bool isInitializedOnHome =
      routerDelegate.currentBeamLocation is HomeLocation;
  Community? get community =>
      Provider.of<NavBarProvider>(context).currentCommunity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.kSidebarWidth,
      color: context.theme.colorScheme.surfaceContainerLowest,
      child: LayoutBuilder(
        builder: (context, constraints) {
            return _buildLayout();

        },
      ),
    );
  }

  Widget _buildLayout() {
    final isSignedIn = Provider.of<UserService>(context).isSignedIn;

    return Column(
      children: [
        _buildSidebarCloseButton(),
        if (isSignedIn)
          Expanded(
            child: CustomListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildNavigation(),
              ],
            ),
          ),
        _buildBottomSidebarButtons(isSignedIn),
      ],
    );
  }

  Widget _buildSidebarCloseButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 26, right: 26),
        child:
           Semantics(
          button: true,
          label: context.l10n.close,
          child: IconButton(
            onPressed: () =>  Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              size: 34,
              color: context.theme.colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    final isSignedIn = Provider.of<UserService>(context).isSignedIn;

    if (isSignedIn) {
      return _buildSignedInSidebarContent();
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildSignedInSidebarContent() {
    return CustomStreamBuilder<List<Community>>(
      entryFrom: 'Sidebar._buildSidebarCommunityNavigation',
      stream: userDataService.userCommunities,
      builder: (context, communitiesUserBelongsTo) {
        final currentCommunity = context.watch<CommunityProvider?>()?.community;
        var communities = [
          if (routerDelegate.currentBeamLocation is CommunityLocation &&
              !isInitializedOnHome &&
              currentCommunity != null)
            currentCommunity,
          if (communitiesUserBelongsTo != null) ...communitiesUserBelongsTo,
        ];

        switch (communities.length) {
          case 0:
            return SizedBox.shrink();
          case 1:
            return _buildSingleCommunityNav(communities.first);
          default:
            return _buildMultipleCommunityNav(communities);
        }
      },
    );
  }

  Widget _buildMultipleCommunityNav(List<Community> communities) {
    if (routerDelegate.currentBeamLocation is CommunityLocation &&
        !isInitializedOnHome) {
      final currentCommunity = communities.firstWhere(
        (element) =>
            context.watch<CommunityProvider?>()?.communityId == element.id,
      );

      communities = [
        currentCommunity,
        ...communities
            .where((community) => community.id != currentCommunity.id),
      ];
    }

    return AnimatedSidebarContent(
      communities: communities,
    );
  }

  Widget _buildSingleCommunityNav(Community community) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SidebarNavigationListItem(
            isCollapsible: false,
            community: community,
          ),
        ],
      );

  Widget _buildBottomSidebarButtons(bool isSignedIn) {
    final version =
        js_util.getProperty(html.window, 'platformVersion').toString();
    return Container(
      color: isSignedIn ? context.theme.colorScheme.surface : null,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.0),
          ActionButton(
            type: ActionButtonType.text,
            icon: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 12.0),
              child: ProxiedImage(
                null,
                asset: AppAsset.kLogoIconPng,
                width: 20,
                height: 20,
              ),
            ),
            text: '${Environment.appName} Home',
            onPressed: () => routerDelegate.beamTo(HomeLocation()),
          ),
          ActionButton(
            text: context.l10n.language,
            type: ActionButtonType.text,
            icon: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                '🌐',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(context.l10n.selectLanguage),
                  content: LanguageSelector(),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.l10n.close),
                    ),
                  ],
                ),
              );
            },
          ),
          ActionButton(
            text: context.l10n.helpCenter,
            type: ActionButtonType.text,
            onPressed: () => launch(Environment.helpCenterUrl),
          ),
          ActionButton(
            text: '${context.l10n.about} ${Environment.appName}',
            type: ActionButtonType.text,
            onPressed: () => launch(Environment.aboutUrl),
          ),
          ActionButton(
            text: context.l10n.privacyPolicy,
            type: ActionButtonType.text,
            onPressed: () => launch(Environment.privacyPolicyUrl),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
            child: RichText(
              text: TextSpan(
                children: const [
                  TextSpan(text: Environment.sidebarFooter),
                  TextSpan(
                    text: '.\n© ${Environment.copyrightStatement}',
                  ),
                ],
                style: context.theme.textTheme.labelMedium!.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
            child: RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                text: 'v$version',
                style: context.theme.textTheme.labelMedium!.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedSidebarContent extends StatefulWidget {
  final List<Community> communities;

  const AnimatedSidebarContent({required this.communities, Key? key})
      : super(key: key);

  @override
  State<AnimatedSidebarContent> createState() => _AnimatedSidebarContentState();
}

class _AnimatedSidebarContentState extends State<AnimatedSidebarContent> {
  void _startCommunityTapped() => guardSignedIn(() => DialogFlow().show());

  @override
  Widget build(BuildContext context) {
    return UserInfoBuilder(
      userId: userService.currentUserId,
      builder: (
        BuildContext context,
        bool isLoading,
        AsyncSnapshot<PublicUserInfo?> snapshot,
      ) {
        final userInfo = snapshot.data;

        if (isLoading) {
          return Column(
            children: const [
              CircularProgressIndicator(),
            ],
          );
        }
        final owner = userInfo?.isOwner ?? false;
        return Column(
          children: [
            for (final community in widget.communities) ...[
              if (community != widget.communities.first) Divider(height: 16),
              SidebarNavigationListItem(
                community: community,
                isOpenByDefault: (community == widget.communities.first) &&
                    CheckCurrentLocation.isCommunityRoute,
              ),
            ],
            if (owner || Uri.base.origin.contains('localhost')) ...[
              Divider(height: 16),
              _buildStartCommunity(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStartCommunity() => GestureDetector(
        onTap: _startCommunityTapped,
        child: Row(
          children: [
            CircleIconButton(
              onPressed: _startCommunityTapped,
              icon: Icons.add,
              toolTipText: 'Start a community',
            ),
            SizedBox(width: 11),
            HeightConstrainedText(
              context.l10n.startCommunity,
              style: AppTextStyle.body.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
}
