import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/home/creation_dialog/freemium_dialog_flow.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/common_widgets/navbar/sidebar/nav_list_tile.dart';
import 'package:junto/common_widgets/navbar/sidebar/side_bar_navigation_button.dart';
import 'package:junto/common_widgets/sign_in_options_content.dart';
import 'package:junto/common_widgets/user_info_builder.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/public_user_info.dart';
import 'package:provider/provider.dart';

/// This is the side navigation drawer that appears when the hamburger icon is clicked. It contains
/// links to sign in if the user is not signed in, otherwise it contains links to the user's communities
class SideBar extends StatefulWidget {
  SideBar() : super(key: Key('sideBar'));

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  // This prevents an error from being thrown if navigating to a Frankly page from the home page by
  // cancelling the lookup of the JuntoProvider before it is initialized, as the sidebar is closing.
  final bool isInitializedOnHome = routerDelegate.currentBeamLocation is HomeLocation;
  Junto? get junto => Provider.of<NavBarProvider>(context)?.currentJunto;

  @override
  Widget build(BuildContext context) {
    return JuntoUiMigration(
      whiteBackground: true,
      child: Container(
        width: AppSize.kSidebarWidth,
        color: AppColor.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxHeight < 750) {
              return _buildMobileLayout();
            } else {
              return _buildDesktopLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _builSidebardHeader(),
        Expanded(
          child: Container(
            color: AppColor.gray6,
            child: JuntoListView(
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
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _builSidebardHeader(),
        Expanded(
          child: JuntoListView(
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
          child: JuntoInkWell(
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
      );
    }
  }

  Widget _buildSignedInSidebarContent() {
    return JuntoStreamBuilder<List<Junto>>(
      entryFrom: 'Sidebar._buildSidebarJuntoNavigation',
      stream: juntoUserDataService.userCommunities,
      builder: (context, juntosUserBelongsTo) {
        final currentJunto = context.watch<JuntoProvider?>()?.junto;
        var juntos = [
          if (routerDelegate.currentBeamLocation is JuntoLocation &&
              !isInitializedOnHome &&
              currentJunto != null)
            currentJunto,
          if (juntosUserBelongsTo != null) ...juntosUserBelongsTo
        ];

        switch (juntos.length) {
          case 0:
            return SizedBox.shrink();
          case 1:
            return _buildSingleJuntoNav(juntos.first);
          default:
            return _buildMultipleJuntoNav(juntos);
        }
      },
    );
  }

  Widget _buildMultipleJuntoNav(List<Junto> juntos) {
    if (routerDelegate.currentBeamLocation is JuntoLocation && !isInitializedOnHome) {
      final currentJunto =
          juntos.firstWhere((element) => context.watch<JuntoProvider>().juntoId == element.id);

      juntos = [
        currentJunto,
        ...juntos.where((junto) => junto.id != currentJunto.id),
      ];
    }

    return AnimatedSidebarContent(
      juntos: juntos,
    );
  }

  Widget _buildSingleJuntoNav(Junto junto) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavListItem(
            isCollapsible: false,
            junto: junto,
          ),
        ],
      );

  Widget _buildBottomSidebarButtons() {
    const showHomeButton = true;
    return Container(
      color: AppColor.gray6,
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
                JuntoImage(
                  null,
                  asset: AppAsset.kLogoIconPng,
                  width: 20,
                  height: 20,
                ),
                SideBarNavigationButton(
                  text: 'Explore Frankly',
                  onTap: () => routerDelegate.beamTo(HomeLocation()),
                  style: AppTextStyle.eyebrowSmall,
                  verticalPadding: 6,
                ),
              ],
            ),
          SideBarNavigationButton(
            text: 'About Frankly',
            onTap: () => launch('https://frankly.org'),
            style: AppTextStyle.eyebrowSmall,
            verticalPadding: 6,
          ),
          SideBarNavigationButton(
            text: 'Privacy Policy',
            onTap: () => launch('https://frankly.org/privacy'),
            style: AppTextStyle.eyebrowSmall,
            verticalPadding: 6,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Frankly is operated by the ',
                  ),
                  TextSpan(
                    text: 'Applied Social Media Lab',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://asml.cyber.harvard.edu/');
                      },
                  ),
                  TextSpan(
                    text: ' at the ',
                  ),
                  TextSpan(
                    text: 'Berkman Klein Center for Internet & Society',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://cyber.harvard.edu/');
                      },
                  ),
                  TextSpan(
                    text: '.\n© 2024 President and Fellows of Harvard College.',
                  ),
                ],
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
  final List<Junto> juntos;

  const AnimatedSidebarContent({required this.juntos, Key? key}) : super(key: key);

  @override
  State<AnimatedSidebarContent> createState() => _AnimatedSidebarContentState();
}

class _AnimatedSidebarContentState extends State<AnimatedSidebarContent> {
  void _startCommunityTapped() => guardSignedIn(() => FreemiumDialogFlow().show());

  @override
  Widget build(BuildContext context) {
    return UserInfoBuilder(
      userId: userService.currentUserId,
      builder: (BuildContext context, bool isLoading, AsyncSnapshot<PublicUserInfo?> snapshot) {
        final userInfo = snapshot.data;

        if (isLoading) {
          return Column(children: const [
            CircularProgressIndicator(),
          ]);
        }
        final owner = userInfo?.isOwner ?? false;
        return Column(
          children: [
            for (final junto in widget.juntos) ...[
              if (junto != widget.juntos.first) _buildDivider(),
              NavListItem(
                junto: junto,
                isOpenByDefault:
                    (junto == widget.juntos.first) && CheckCurrentLocation.isJuntoRoute,
              ),
            ],
            if (owner) ...[
              _buildDivider(),
              _buildStartCommunity(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDivider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          color: AppColor.gray5,
          height: 1,
        ),
      );

  Widget _buildStartCommunity() => GestureDetector(
        onTap: _startCommunityTapped,
        child: Row(
          children: [
            JuntoInkWell(
              boxShape: BoxShape.circle,
              onTap: _startCommunityTapped,
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.darkBlue),
                height: 40,
                width: 40,
                child: DottedBorder(
                  borderType: BorderType.Circle,
                  dashPattern: [3, 3],
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
            JuntoText(
              'Start a community',
              style: AppTextStyle.body.copyWith(color: AppColor.gray2),
            )
          ],
        ),
      );
}
