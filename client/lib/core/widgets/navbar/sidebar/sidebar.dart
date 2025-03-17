import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/presentation/widgets/freemium_dialog_flow.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/core/widgets/navbar/sidebar/nav_list_tile.dart';
import 'package:client/core/widgets/navbar/sidebar/side_bar_navigation_button.dart';
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
      color: context.theme.colorScheme.secondary,
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
        _builSidebardHeader(),
        Expanded(
          child: CustomListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: AppColor.white,
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
        _builSidebardHeader(),
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

  Widget _builSidebardHeader() {
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
          NavListItem(
            isCollapsible: false,
            community: community,
          ),
        ],
      );

  Widget _buildBottomSidebarButtons() {
    const showHomeButton = true;
    final version =
        js_util.getProperty(html.window, 'platformVersion').toString();
    return Container(
      color: context.theme.colorScheme.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          if (showHomeButton)
            Row(
              children: [
                SizedBox(width: 5),
                ProxiedImage(
                  null,
                  asset: AppAsset.kLogoIconPng,
                  width: 20,
                  height: 20,
                ),
                SideBarNavigationButton(
                  text: '${Environment.appName} Home',
                  onTap: () => routerDelegate.beamTo(HomeLocation()),
                  style: AppTextStyle.eyebrowSmall,
                  verticalPadding: 6,
                ),
              ],
            ),
          SideBarNavigationButton(
            text: 'Help Center',
            onTap: () => launch(Environment.helpCenterUrl),
            style: AppTextStyle.eyebrowSmall,
            verticalPadding: 6,
          ),
          SideBarNavigationButton(
            text: 'About ${Environment.appName}',
            onTap: () => launch(Environment.aboutUrl),
            style: AppTextStyle.eyebrowSmall,
            verticalPadding: 6,
          ),
          SideBarNavigationButton(
            text: 'Privacy Policy',
            onTap: () => launch(Environment.privacyPolicyUrl),
            style: AppTextStyle.eyebrowSmall,
            verticalPadding: 6,
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
                style: AppTextStyle.eyebrowSmall.copyWith(
                  color: AppColor.gray2,
                  fontSize: 12,
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
                style: AppTextStyle.eyebrowSmall.copyWith(
                  color: AppColor.gray2,
                  fontSize: 12,
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
              if (community != widget.communities.first) themedDivider,
              NavListItem(
                community: community,
                isOpenByDefault: (community == widget.communities.first) &&
                    CheckCurrentLocation.isCommunityRoute,
              ),
            ],
            if (owner || Uri.base.origin.contains('localhost')) ...[
              themedDivider,
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
            CustomInkWell(
              boxShape: BoxShape.circle,
              onTap: _startCommunityTapped,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.darkBlue,
                ),
                height: 40,
                width: 40,
                child: DottedBorder(
                  borderType: BorderType.Circle,
                  dashPattern: const [3, 3],
                  color: AppColor.gray2,
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 11),
            HeightConstrainedText(
              'Start a community',
              style: AppTextStyle.body.copyWith(color: AppColor.gray2),
            ),
          ],
        ),
      );
}
