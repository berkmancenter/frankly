import 'package:flutter/material.dart';
import 'package:client/app/home/my_communities_section.dart';
import 'package:client/app/home/upcoming_events_section.dart';
import 'package:client/app/home/sign_in_section.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/navbar/bottom_nav_bar.dart';
import 'package:client/common_widgets/navbar/custom_scaffold.dart';
import 'package:client/common_widgets/navbar/nav_bar_provider.dart';
import 'package:client/services/services.dart';
import 'package:client/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    context.read<NavBarProvider>().checkIfShouldResetNav();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isUserSignedIn = Provider.of<UserService>(context).isSignedIn;
    return CustomScaffold(
      bgColor: AppColor.gray6,
      fillViewport: !isUserSignedIn,
      bottomNavigationBar: responsiveLayoutService.showBottomNavBar(context)
          ? HomeBottomNavBar()
          : null,
      child: isUserSignedIn ? _buildHomePageContent() : HomePageSignInSection(),
    );
  }

  Widget _buildHomePageContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 30),
        if (responsiveLayoutService.isMobile(context))
          ..._buildMobileLayout()
        else
          ..._buildDesktopLayout(),
      ],
    );
  }

  List<Widget> _buildMobileLayout() {
    return [
      RepaintBoundary(
        child: MyCommunitiesSection(),
      ),
      SizedBox(height: 30),
      ConstrainedBody(
        maxWidth: AppSize.kHomeContentMaxWidthMobile,
        child: UpcomingEventsSection.create(),
      ),
      SizedBox(height: 20),
    ];
  }

  List<Widget> _buildDesktopLayout() {
    return [
      ConstrainedBody(
        child: RepaintBoundary(
          child: MyCommunitiesSection(),
        ),
      ),
      SizedBox(height: 30),
      ConstrainedBody(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: UpcomingEventsSection.create(),
            ),
            Expanded(
              flex: 1,
              child: SizedBox.shrink(),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
    ];
  }
}
