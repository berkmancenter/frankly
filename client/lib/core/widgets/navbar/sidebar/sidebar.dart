import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/buttons/circle_icon_button.dart';
import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/freemium_dialog_flow.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/core/widgets/navbar/sidebar/sidebar_navigation_list_item.dart';
import 'package:client/features/auth/presentation/widgets/sign_in_options_content.dart';
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
          if (constraints.maxHeight < 750) {
            return _buildMobileLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSidebarCloseButton(),
        Expanded(
          child: CustomListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: context.theme.colorScheme.surfaceContainerLowest,
                child: _buildNavigationOrSignIn(),
              ),
              _buildBottomSidebarButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _buildSidebarCloseButton(),
        Expanded(
          child: CustomListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildNavigationOrSignIn(),
            ],
          ),
        ),
        _buildBottomSidebarButtons(),
      ],
    );
  }

  Widget _buildSidebarCloseButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 26, right: 26),
        child: Semantics(
          button: true,
          label: 'Close',
          child: CustomInkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.close, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationOrSignIn() {
    final isSignedIn = Provider.of<UserService>(context).isSignedIn;

    if (isSignedIn) {
      return _buildSignedInSidebarContent();
    } else {
      return SignInOptionsContent(
        onComplete: () => Navigator.of(context).pop(),
        openDialogOnEmailProviderSelected: true,
      );
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
            context.watch<CommunityProvider>().communityId == element.id,
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

  Widget _buildBottomSidebarButtons() {
    final version =
        js_util.getProperty(html.window, 'platformVersion').toString();
    return Container(
      color: context.theme.colorScheme.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.0),
          Row(
            children: [
              SizedBox(width: 8.0),
              ProxiedImage(
                null,
                asset: AppAsset.kLogoIconPng,
                width: 20,
                height: 20,
              ),
              ActionButton(
                type: ActionButtonType.text,
                text: '${Environment.appName} Home',
                onPressed: () => routerDelegate.beamTo(HomeLocation()),
              ),
            ],
          ),
          ActionButton(
            type: ActionButtonType.text,
            text: 'Help Center',
            onPressed: () => launch(Environment.helpCenterUrl),
          ),
          ActionButton(
            type: ActionButtonType.text,
            text: 'About ${Environment.appName}',
            onPressed: () => launch(Environment.aboutUrl),
          ),
          ActionButton(
            type: ActionButtonType.text,
            text: 'Privacy Policy',
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
  void _startCommunityTapped() =>
      guardSignedIn(() => FreemiumDialogFlow().show());

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
              'Start a community',
              style: AppTextStyle.body.copyWith(
                  color: context.theme.colorScheme.onPrimaryContainer),
            ),
          ],
        ),
      );
}
