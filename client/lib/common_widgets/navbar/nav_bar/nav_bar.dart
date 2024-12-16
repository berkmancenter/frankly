import 'package:flutter/material.dart';
import 'package:junto/app/home/creation_dialog/create_junto_dialog.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_dialog.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/app_clickable_widget.dart';
import 'package:junto/common_widgets/junto_icon_or_logo.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_membership_button.dart';
import 'package:junto/common_widgets/navbar/junto_announcements.dart';
import 'package:junto/common_widgets/navbar/nav_bar/nav_bar_contract.dart';
import 'package:junto/common_widgets/navbar/nav_bar/nav_bar_model.dart';
import 'package:junto/common_widgets/navbar/nav_bar/nav_bar_presenter.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/common_widgets/navbar/profile_or_login.dart';
import 'package:junto/common_widgets/navbar/selectable_navigation_icon.dart';
import 'package:junto/common_widgets/overview_progress_indicator.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';
import 'package:junto/utils/extensions.dart';

class NavBar extends StatefulWidget {
  NavBar() : super(key: Key('navBar'));

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> implements NavBarView {
  late final NavBarModel _model;
  late final NavBarPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _model = NavBarModel();
    _presenter = NavBarPresenter(context, this, _model);
    _presenter.init();
  }

  void _goToAdminPage() {
    final junto = _presenter.getJunto();
    if (junto == null) {
      loggingService.log('_NavBarState._goToSettingsPage: Junto is null', logType: LogType.error);
      return;
    }

    routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: junto.displayId).juntoAdmin());
  }

  @override
  Widget build(BuildContext context) {
    context.watch<UserService>();

    final onboardingStep = _presenter.getCurrentOnboardingStep();
    final isAdminButtonVisible = _presenter.isAdminButtonVisible();
    final isJuntoHomePage = _presenter.isJuntoHomePage();
    final isOnboardingOverviewEnabled = _presenter.isOnboardingOverviewEnabled();

    return Column(
      children: [
        if (isOnboardingOverviewEnabled &&
            isJuntoHomePage &&
            isAdminButtonVisible &&
            onboardingStep != null)
          AnimatedSize(
            duration: kTabScrollDuration,
            child: !_model.isOnboardingTooltipShown
                ? SizedBox.shrink()
                : _buildOnboardingOverviewTooltip(onboardingStep),
          ),
        Container(
          color: AppColor.white,
          alignment: Alignment.center,
          child: _buildHeaderContent(),
        ),
        Divider(height: 1, color: AppColor.gray5),
      ],
    );
  }

  @override
  void updateView() {
    setState(() {});
  }

  Widget _buildHeaderContent() {
    final canViewCommunityLinks = _presenter.canViewCommunityLinks();
    final isOnJuntoPage = _presenter.isJuntoLocation();
    final currentJunto = context.watch<NavBarProvider>().currentJunto;
    final showBottomNavBar = _presenter.showBottomNavBar(context);
    final isMobile = _presenter.isMobile(context);

    return ConstrainedBody(
      padding: EdgeInsets.only(left: 20, right: 10),
      child: SizedBox(
        height: AppSize.kNavBarHeight,
        child: Row(
          children: [
            ..._buildLeftSideOfNav(currentJunto, isOnJuntoPage),
            if (!showBottomNavBar && isOnJuntoPage && currentJunto != null)
              ..._buildCenterOfNav(currentJunto)
            else if (!isOnJuntoPage)
              Spacer(),
            if (currentJunto != null && canViewCommunityLinks && isOnJuntoPage && !isMobile)
              AnnouncementsIcon(juntoId: currentJunto.id),
            ..._buildRightSideOfNav(currentJunto),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLeftSideOfNav(Junto? currentJunto, bool isOnJuntoPage) {
    final canViewCommunityLinks = _presenter.canViewCommunityLinks();
    final isMobile = _presenter.isMobile(context);
    final showJuntoMembershipButton = !canViewCommunityLinks && !isMobile;

    return [
      CurrentJuntoIconOrLogo(junto: currentJunto, darkLogo: true),
      if (currentJunto != null && isOnJuntoPage && !isMobile) ...[
        SizedBox(width: 8),
        Expanded(
          flex: showJuntoMembershipButton ? 0 : 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 180),
            child: JuntoInkWell(
              onTap: () => routerDelegate.beamTo(
                JuntoPageRoutes(
                  juntoDisplayId: currentJunto.displayId,
                ).juntoHome,
              ),
              child: JuntoText(
                currentJunto.name ?? 'Frankly',
                maxLines: 2,
                style: AppTextStyle.subhead.copyWith(color: AppColor.gray1),
              ),
            ),
          ),
        ),
        if (showJuntoMembershipButton) ...[
          SizedBox(width: 20),
          Expanded(
            child: JuntoMembershipButton(
              currentJunto,
              bgColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ] else
          Spacer(),
      ]
    ];
  }

  List<Widget> _buildRightSideOfNav(Junto? currentJunto) {
    final canViewCommunityLinks = _presenter.canViewCommunityLinks();
    final isJuntoLocation = _presenter.isJuntoLocation();
    final showBottomNav = _presenter.showBottomNavBar(context);
    final isMobile = _presenter.isMobile(context);
    final isAdminButtonVisible = _presenter.isAdminButtonVisible();

    return [
      if (!showBottomNav)
        Theme(
          data: ThemeData(
            textTheme: Theme.of(context).textTheme.apply(bodyColor: AppColor.gray1),
          ),
          child: ProfileOrLogin(
            showMenuAboveIcon: false,
          ),
        ),
      if (showBottomNav) ...[
        if (currentJunto != null && isJuntoLocation) ...[
          ..._buildRightSideNavIcons(currentJunto, canViewCommunityLinks),
        ],
      ],
      if (isMobile) Spacer(),
      if (isAdminButtonVisible) _buildAdminButton(),
      Semantics(button: true, label: 'Show Sidebar Button', child: JuntoInkWell(
        onTap: () => Scaffold.of(context).openEndDrawer(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.menu, size: 34, color: AppColor.gray1),
          ),
        ),
      ),
      ),
    ];
  }

  List<Widget> _buildRightSideNavIcons(Junto junto, bool canViewCommunityLinks) {
    final enableDiscussionThreads = junto.settingsMigration.enableDiscussionThreads;

    if (!canViewCommunityLinks) {
      return [
        SizedBox(width: 20),
        JuntoMembershipButton(
          junto,
          bgColor: Theme.of(context).colorScheme.primary,
        ),
      ];
    }
    return [
      SizedBox(width: 20),
      SelectableNavigationIcon(
        imagePath: AppAsset.kCalendarGreyPng,
        selectedImagePath: AppAsset.kCalendarBluePng,
        isSelected: CheckCurrentLocation.isJuntoSchedulePage,
        iconSize: 32,
        onTap: () =>
            routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: junto.displayId).discussionsPage),
      ),
      if (enableDiscussionThreads) ...[
        SizedBox(width: 20),
        SelectableNavigationIcon(
          imagePath: AppAsset.kChatBubbleGreyPng,
          selectedImagePath: AppAsset.kChatBubbleBluePng,
          isSelected: CheckCurrentLocation.isDiscussionThreadsPage,
          iconSize: 32,
          iconSpacing: 2,
          onTap: () => routerDelegate.beamTo(
            JuntoPageRoutes(juntoDisplayId: JuntoProvider.read(context).displayId)
                .discussionThreadsPage,
          ),
        ),
      ],
      SizedBox(width: 10),
      if (Provider.of<NavBarProvider>(context).showResources) ...[
        SizedBox(width: 10),
        SelectableNavigationIcon(
          imagePath: AppAsset.kDocumentsGreyPng,
          selectedImagePath: AppAsset.kDocumentsBluePng,
          isSelected: CheckCurrentLocation.isJuntoResourcesPage,
          iconSize: 32,
          onTap: () =>
              routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: junto.displayId).resourcesPage),
        ),
        SizedBox(width: 4),
      ],
    ];
  }

  List<Widget> _buildCenterOfNav(Junto currentJunto) {
    final juntoDisplayId = currentJunto.displayId;
    final enableDiscussionThreads = currentJunto.settingsMigration.enableDiscussionThreads;
    return [
      SizedBox(width: 20),
      _SelectableNavigationButton(
        title: 'Events',
        onTap: () =>
            routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: juntoDisplayId).discussionsPage),
        isSelected: CheckCurrentLocation.isJuntoSchedulePage,
      ),
      if (enableDiscussionThreads) ...[
        SizedBox(width: 20),
        _SelectableNavigationButton(
          title: 'Posts',
          onTap: () => routerDelegate
              .beamTo(JuntoPageRoutes(juntoDisplayId: juntoDisplayId).discussionThreadsPage),
          isSelected: CheckCurrentLocation.isDiscussionThreadsPage,
        ),
      ],
      if (Provider.of<NavBarProvider>(context).showResources) ...[
        SizedBox(width: 20),
        _SelectableNavigationButton(
          title: 'Resources',
          onTap: () =>
              routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: juntoDisplayId).resourcesPage),
          isSelected: CheckCurrentLocation.isJuntoResourcesPage,
        ),
      ],
      SizedBox(width: 20),
      _SelectableNavigationButton(
        title: 'Templates',
        onTap: () =>
            routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: juntoDisplayId).browseTopicsPage),
        isSelected: CheckCurrentLocation.isJuntoTopicsPage,
      ),
    ];
  }

  Widget _buildAdminButton() {
    return SelectableNavigationIcon(
      key: _model.adminButtonKey,
      iconData: Icons.settings_outlined,
      iconSize: 30,
      onTap: () => _goToAdminPage(),
      isSelected: CheckCurrentLocation.isJuntoAdminPage,
    );
  }

  Widget _buildOnboardingOverviewTooltip(OnboardingStep onboardingStep) {
    _presenter.updateAdminButtonXPosition();
    
     final onboardingSteps = List.from(OnboardingStep.values);
    if (!kShowStripeFeatures) {
      onboardingSteps.remove(OnboardingStep.createStripeAccount);
    }
    
    final totalSteps = onboardingSteps.length;
    final completedStepCount = _presenter.getCompletedStepCount();
    final totalWidth = MediaQuery.of(context).size.width;
    final settingsXPosition = _model.adminButtonXPosition;
    final isMobile = _presenter.isMobile(context);

    if (isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(color: AppColor.black),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OnboardingOverviewProgressIndicator(
                        completedStepCount: completedStepCount,
                        totalSteps: totalSteps,
                        backgroundColor: AppColor.gray3,
                        progressColor: AppColor.brightGreen,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '$completedStepCount/$totalSteps',
                      style: AppTextStyle.body.copyWith(color: AppColor.white),
                    ),
                    SizedBox(width: 20),
                    AppClickableWidget(
                      child: JuntoImage(
                        null,
                        asset: AppAsset.kXWhitePng,
                        width: 20,
                        height: 20,
                      ),
                      onTap: () => _presenter.closeOnboardingTooltip(),
                    ),
                  ],
                ),
                AppClickableWidget(
                  isIcon: false,
                  onTap: () => _getOnTap(onboardingStep),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          JuntoImage(
                            null,
                            asset: onboardingStep.titleIconPath,
                            width: 16,
                            height: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            onboardingStep.title,
                            style: AppTextStyle.bodyMedium.copyWith(color: AppColor.white),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            onboardingStep.sectionTitle,
                            style: AppTextStyle.bodyMedium.copyWith(color: AppColor.white),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColor.white,
                            size: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (settingsXPosition != null)
            SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Positioned(
                    // Finds the center of the relevant widget.
                    right: totalWidth - settingsXPosition - 25,
                    child: CustomPaint(
                      size: Size(20, 10),
                      painter: TrianglePainter(),
                    ),
                  ),
                ],
              ),
            )
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(color: AppColor.black),
            child: ConstrainedBody(
              maxWidth: 1100,
              child: Row(
                children: [
                  AppClickableWidget(
                    isIcon: false,
                    onTap: () => _getOnTap(onboardingStep),
                    child: Row(
                      children: [
                        JuntoImage(
                          null,
                          asset: onboardingStep.titleIconPath,
                          width: 16,
                          height: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          onboardingStep.title,
                          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.white),
                        ),
                        SizedBox(width: 10),
                        Text(
                          onboardingStep.sectionTitle,
                          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.white),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColor.white,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 300,
                    child: OnboardingOverviewProgressIndicator(
                      completedStepCount: completedStepCount,
                      totalSteps: totalSteps,
                      backgroundColor: AppColor.gray3,
                      progressColor: AppColor.brightGreen,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$completedStepCount/$totalSteps',
                    style: AppTextStyle.body.copyWith(color: AppColor.white),
                  ),
                  SizedBox(width: 20),
                  AppClickableWidget(
                    child: JuntoImage(
                      null,
                      asset: AppAsset.kXWhitePng,
                      width: 20,
                      height: 20,
                    ),
                    onTap: () => _presenter.closeOnboardingTooltip(),
                  ),
                ],
              ),
            ),
          ),
          if (settingsXPosition != null)
            Container(
              // Making optical illusion that `triangle` is overlapping app bar.
              color: AppColor.white,
              height: 10,
              child: Stack(
                children: [
                  Positioned(
                    // Finds the center of the relevant widget.
                    right: totalWidth - settingsXPosition - 25,
                    child: CustomPaint(
                      size: Size(20, 10),
                      painter: TrianglePainter(),
                    ),
                  ),
                ],
              ),
            )
        ],
      );
    }
  }

  Future<void> _getOnTap(OnboardingStep onboardingStep) async {
    switch (onboardingStep) {
      case OnboardingStep.brandSpace:
        final junto = _presenter.getJunto();

        await CreateJuntoDialog(junto: junto).show();
        break;
      case OnboardingStep.createGuide:
        await CreateTopicDialog.show(
          juntoProvider: context.read<JuntoProvider>(),
          communityPermissionsProvider: context.read<CommunityPermissionsProvider>(),
        );
        break;
      case OnboardingStep.hostConversation:
        await CreateDiscussionDialog.show(context);
        break;
      case OnboardingStep.inviteSomeone:
        _goToAdminPage();
        break;
      case OnboardingStep.createStripeAccount:
        await alertOnError(context, () => _presenter.proceedToConnectWithStripePage());
        break;
    }
  }
}

class _SelectableNavigationButton extends StatelessWidget {
  final void Function() onTap;
  final bool isSelected;
  final String title;

  const _SelectableNavigationButton({
    Key? key,
    required this.title,
    required this.onTap,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JuntoInkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1),
        decoration: isSelected
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColor.darkBlue, width: 1.5),
                ),
              )
            : null,
        child: JuntoText(
          title,
          style: AppTextStyle.bodyMedium.copyWith(
            color: isSelected ? AppColor.darkBlue : AppColor.gray3,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Draws downwards pointing triangle.
class TrianglePainter extends CustomPainter {
  final Paint painter;

  TrianglePainter()
      : painter = Paint()
          ..color = AppColor.black
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
