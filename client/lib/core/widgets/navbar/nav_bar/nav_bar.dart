import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/constrained_body.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/presentation/views/create_community_dialog.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/create_event/presentation/views/create_event_dialog.dart';
import 'package:client/features/templates/features/create_template/presentation/views/create_template_dialog.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/buttons/app_clickable_widget.dart';
import 'package:client/features/community/presentation/widgets/community_icon_or_logo.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/features/community/presentation/widgets/community_membership_button.dart';
import 'package:client/core/widgets/navbar/community_announcements.dart';
import 'package:client/core/widgets/navbar/nav_bar/nav_bar_contract.dart';
import 'package:client/core/widgets/navbar/nav_bar/nav_bar_model.dart';
import 'package:client/core/widgets/navbar/nav_bar/nav_bar_presenter.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/core/widgets/navbar/profile_or_login.dart';
import 'package:client/core/widgets/navbar/selectable_navigation_icon.dart';
import 'package:client/core/widgets/step_progress_indicator.dart';
import 'package:client/config/environment.dart';
import 'package:client/app.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';
import 'package:client/core/utils/extensions.dart';

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
    final community = _presenter.getCommunity();
    if (community == null) {
      loggingService.log(
        '_NavBarState._goToSettingsPage: Community is null',
        logType: LogType.error,
      );
      return;
    }

    routerDelegate.beamTo(
      CommunityPageRoutes(communityDisplayId: community.displayId)
          .communityAdmin(),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<UserService>();

    final onboardingStep = _presenter.getCurrentOnboardingStep();
    final isAdminButtonVisible = _presenter.isAdminButtonVisible();
    final isCommunityHomePage = _presenter.isCommunityHomePage();
    final isOnboardingOverviewEnabled =
        _presenter.isOnboardingOverviewEnabled();

    return Column(
      children: [
        if (isOnboardingOverviewEnabled &&
            isCommunityHomePage &&
            isAdminButtonVisible &&
            onboardingStep != null)
          AnimatedSize(
            duration: kTabScrollDuration,
            child: !_model.isOnboardingTooltipShown
                ? SizedBox.shrink()
                : _buildOnboardingOverviewTooltip(onboardingStep),
          ),
        Container(
          color: context.theme.colorScheme.surfaceContainerLowest,
          alignment: Alignment.center,
          child: _buildHeaderContent(),
        ),
        Divider(height: 1, color: context.theme.colorScheme.onPrimaryContainer),
      ],
    );
  }

  @override
  void updateView() {
    setState(() {});
  }

  /// Create a semantically-wrapped button with label for the community membership button
  Widget _buildMembershipButton(Community currentCommunity) {
    return Semantics(
      label: 'Follow Community Button',
      identifier: 'follow_community_button',
      button: true,
      child: CommunityMembershipButton(
        currentCommunity,
      ),
    );
  }

  Widget _buildHeaderContent() {
    final canViewCommunityLinks = _presenter.canViewCommunityLinks();
    final isOnCommunityPage = _presenter.isCommunityLocation();
    final currentCommunity = context.watch<NavBarProvider>().currentCommunity;
    final showBottomNavBar = _presenter.showBottomNavBar(context);
    final isMobile = _presenter.isMobile(context);

    return ConstrainedBody(
      padding: EdgeInsets.only(left: 20, right: 10),
      child: SizedBox(
        height: AppSize.kNavBarHeight,
        child: Row(
          children: [
            ..._buildLeftSideOfNav(currentCommunity, isOnCommunityPage),
            if (!showBottomNavBar &&
                isOnCommunityPage &&
                currentCommunity != null)
              ..._buildCenterOfNav(currentCommunity)
            else if (!isOnCommunityPage)
              Spacer(),
            if (currentCommunity != null &&
                canViewCommunityLinks &&
                isOnCommunityPage &&
                !isMobile)
              AnnouncementsIcon(communityId: currentCommunity.id),
            ..._buildRightSideOfNav(currentCommunity),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLeftSideOfNav(
    Community? currentCommunity,
    bool isOnCommunityPage,
  ) {
    final canViewCommunityLinks = _presenter.canViewCommunityLinks();
    final isMobile = _presenter.isMobile(context);
    final showCommunityMembershipButton = !canViewCommunityLinks && !isMobile;

    return [
      CurrentCommunityIconOrLogo(community: currentCommunity, darkLogo: true),
      if (currentCommunity != null && isOnCommunityPage && !isMobile) ...[
        SizedBox(width: 8),
        Expanded(
          flex: showCommunityMembershipButton ? 0 : 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 180),
            child: CustomInkWell(
              onTap: () => routerDelegate.beamTo(
                CommunityPageRoutes(
                  communityDisplayId: currentCommunity.displayId,
                ).communityHome,
              ),
              child: HeightConstrainedText(
                currentCommunity.name ?? Environment.appName,
                maxLines: 2,
                style: AppTextStyle.subhead
                    .copyWith(color: context.theme.colorScheme.secondary),
              ),
            ),
          ),
        ),
        if (showCommunityMembershipButton) ...[
          SizedBox(width: 20),
          Expanded(
            child: _buildMembershipButton(currentCommunity),
          ),
        ] else
          Spacer(),
      ],
    ];
  }

  List<Widget> _buildRightSideOfNav(Community? currentCommunity) {
    final canViewCommunityLinks = _presenter.canViewCommunityLinks();
    final isCommunityLocation = _presenter.isCommunityLocation();
    final showBottomNav = _presenter.showBottomNavBar(context);
    final isMobile = _presenter.isMobile(context);
    final isAdminButtonVisible = _presenter.isAdminButtonVisible();

    return [
      if (!showBottomNav)
        ProfileOrLogin(
          showMenuAboveIcon: false,
        ),
      if (showBottomNav) ...[
        if (currentCommunity != null && isCommunityLocation) ...[
          ..._buildRightSideNavIcons(currentCommunity, canViewCommunityLinks),
        ],
      ],
      if (isMobile) Spacer(),
      if (isAdminButtonVisible) _buildAdminButton(),
      Semantics(
        button: true,
        label: 'Show Sidebar Button',
        child: CustomInkWell(
          onTap: () => Scaffold.of(context).openEndDrawer(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.menu,
                size: 34,
                color: context.theme.colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildRightSideNavIcons(
    Community community,
    bool canViewCommunityLinks,
  ) {
    final enableDiscussionThreads =
        community.settingsMigration.enableDiscussionThreads;

    if (!canViewCommunityLinks) {
      return [
        SizedBox(width: 20),
        _buildMembershipButton(community),
      ];
    }
    return [
      SizedBox(width: 20),
      SelectableNavigationIcon(
        imagePath: AppAsset.kCalendarGreyPng,
        selectedImagePath: AppAsset.kCalendarBluePng,
        isSelected: CheckCurrentLocation.isCommunitySchedulePage,
        iconSize: 32,
        onTap: () => routerDelegate.beamTo(
          CommunityPageRoutes(communityDisplayId: community.displayId)
              .eventsPage,
        ),
      ),
      if (enableDiscussionThreads) ...[
        SizedBox(width: 20),
        SelectableNavigationIcon(
          imagePath: AppAsset.kChatBubbleGreyPng,
          selectedImagePath: AppAsset.kChatBubbleBluePng,
          isSelected: CheckCurrentLocation.isDiscussionThreadsPage,
          iconSize: 32,
          onTap: () => routerDelegate.beamTo(
            CommunityPageRoutes(
              communityDisplayId: CommunityProvider.read(context).displayId,
            ).discussionThreadsPage,
          ),
        ),
      ],
      SizedBox(width: 10),
      if (Provider.of<NavBarProvider>(context).showResources) ...[
        SizedBox(width: 10),
        SelectableNavigationIcon(
          imagePath: AppAsset.kDocumentsGreyPng,
          selectedImagePath: AppAsset.kDocumentsBluePng,
          isSelected: CheckCurrentLocation.isCommunityResourcesPage,
          iconSize: 32,
          onTap: () => routerDelegate.beamTo(
            CommunityPageRoutes(communityDisplayId: community.displayId)
                .resourcesPage,
          ),
        ),
        SizedBox(width: 4),
      ],
    ];
  }

  List<Widget> _buildCenterOfNav(Community currentCommunity) {
    final communityDisplayId = currentCommunity.displayId;
    final enableDiscussionThreads =
        currentCommunity.settingsMigration.enableDiscussionThreads;
    return [
      _SelectableNavigationButton(
        title: 'Events',
        onTap: () => routerDelegate.beamTo(
          CommunityPageRoutes(communityDisplayId: communityDisplayId)
              .eventsPage,
        ),
        isSelected: CheckCurrentLocation.isCommunitySchedulePage,
      ),
      if (enableDiscussionThreads)
        _SelectableNavigationButton(
          title: 'Posts',
          onTap: () => routerDelegate.beamTo(
            CommunityPageRoutes(communityDisplayId: communityDisplayId)
                .discussionThreadsPage,
          ),
          isSelected: CheckCurrentLocation.isDiscussionThreadsPage,
        ),
      if (Provider.of<NavBarProvider>(context).showResources)
        _SelectableNavigationButton(
          title: 'Resources',
          onTap: () => routerDelegate.beamTo(
            CommunityPageRoutes(communityDisplayId: communityDisplayId)
                .resourcesPage,
          ),
          isSelected: CheckCurrentLocation.isCommunityResourcesPage,
        ),
      _SelectableNavigationButton(
        title: 'Templates',
        onTap: () => routerDelegate.beamTo(
          CommunityPageRoutes(communityDisplayId: communityDisplayId)
              .browseTemplatesPage,
        ),
        isSelected: CheckCurrentLocation.isCommunityTemplatesPage,
      ),
    ];
  }

  Widget _buildAdminButton() {
    return SelectableNavigationIcon(
      key: _model.adminButtonKey,
      iconData: Icons.settings_outlined,
      iconSize: 30,
      onTap: () => _goToAdminPage(),
      isSelected: CheckCurrentLocation.isCommunityAdminPage,
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
            decoration: BoxDecoration(color: context.theme.colorScheme.primary),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: StepProgressIndicator(
                        completedStepCount: completedStepCount,
                        totalSteps: totalSteps,
                        backgroundColor:
                            context.theme.colorScheme.surfaceContainer,
                        progressColor: context.theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '$completedStepCount/$totalSteps',
                      style: AppTextStyle.body
                          .copyWith(color: context.theme.colorScheme.onPrimary),
                    ),
                    SizedBox(width: 20),
                    AppClickableWidget(
                      child: ProxiedImage(
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
                          ProxiedImage(
                            null,
                            asset: onboardingStep.titleIconPath,
                            width: 16,
                            height: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            onboardingStep.title,
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: context.theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            onboardingStep.sectionTitle,
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: context.theme.colorScheme.onPrimary,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: context.theme.colorScheme.onPrimary,
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
                      painter: TrianglePainter(context),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(color: context.theme.colorScheme.primary),
            child: ConstrainedBody(
              maxWidth: 1100,
              child: Row(
                children: [
                  AppClickableWidget(
                    isIcon: false,
                    onTap: () => _getOnTap(onboardingStep),
                    child: Row(
                      children: [
                        ProxiedImage(
                          null,
                          asset: onboardingStep.titleIconPath,
                          width: 16,
                          height: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          onboardingStep.title,
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: context.theme.colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          onboardingStep.sectionTitle,
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: context.theme.colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: context.theme.colorScheme.onPrimary,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 300,
                    child: StepProgressIndicator(
                      completedStepCount: completedStepCount,
                      totalSteps: totalSteps,
                      backgroundColor:
                          context.theme.colorScheme.surfaceContainer,
                      progressColor: context.theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$completedStepCount/$totalSteps',
                    style: AppTextStyle.body
                        .copyWith(color: context.theme.colorScheme.onPrimary),
                  ),
                  SizedBox(width: 20),
                  AppClickableWidget(
                    child: ProxiedImage(
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
              color: context.theme.colorScheme.surfaceContainerLowest,
              height: 10,
              child: Stack(
                children: [
                  Positioned(
                    // Finds the center of the relevant widget.
                    right: totalWidth - settingsXPosition - 25,
                    child: CustomPaint(
                      size: Size(20, 10),
                      painter: TrianglePainter(context),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
  }

  Future<void> _getOnTap(OnboardingStep onboardingStep) async {
    switch (onboardingStep) {
      case OnboardingStep.brandSpace:
        final community = _presenter.getCommunity();

        await CreateCommunityDialog(community: community).show();
        break;
      case OnboardingStep.createGuide:
        await CreateTemplateDialog.show(
          communityProvider: context.read<CommunityProvider>(),
          communityPermissionsProvider:
              context.read<CommunityPermissionsProvider>(),
        );
        break;
      case OnboardingStep.hostEvent:
        await CreateEventDialog.show(context);
        break;
      case OnboardingStep.inviteSomeone:
        _goToAdminPage();
        break;
      case OnboardingStep.createStripeAccount:
        await alertOnError(
          context,
          () => _presenter.proceedToConnectWithStripePage(),
        );
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
    return ActionButton(
      type: ActionButtonType.text,
      onPressed: onTap,
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              )
            : null,
        child: HeightConstrainedText(
          title,
          style: context.theme.textTheme.titleMedium!.copyWith(
            color: isSelected
                ? context.theme.colorScheme.primary
                : context.theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

/// Draws downwards pointing triangle.
class TrianglePainter extends CustomPainter {
  final Paint painter;

  TrianglePainter(BuildContext context)
      : painter = Paint()
          ..color = context.theme.colorScheme.primary
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
