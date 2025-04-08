import 'package:client/core/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';

/// This widget either shows the app icon or a logo of the selected community, if one is selected.
class CurrentCommunityIconOrLogo extends StatelessWidget {
  static const kLightLogo = AppAsset.kLogoHorizontalLightPng;
  static const kDarkLogo = AppAsset.kLogoHorizontalDarkPng;

  /// If true, this widget is a button that navigates either to the app's website or the community's landing page
  final bool withNav;
  final bool darkLogo;
  final Community? community;

  const CurrentCommunityIconOrLogo({
    this.withNav = true,
    this.community,
    this.darkLogo = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentCommunity =
        Provider.of<NavBarProvider>(context).currentCommunity ?? community;
    final showOrganizationIcon =
        routerDelegate.currentBeamLocation is! HomeLocation;
    final isMobile = responsiveLayoutService.isMobile(context);

    if (currentCommunity != null && withNav && showOrganizationIcon) {
      return CustomInkWell(
        boxShape: BoxShape.circle,
        onTap: () => routerDelegate.beamTo(
          CommunityPageRoutes(
            communityDisplayId: currentCommunity.displayId,
          ).communityHome,
        ),
        child: CommunityCircleIcon(
          currentCommunity,
          withBorder: isMobile,
          isTooltipShown: false,
        ),
      );
    } else if (withNav) {
      return CustomInkWell(
        onTap: () => routerDelegate.beamTo(HomeLocation()),
        child: _buildLogo(isMobile: isMobile),
      );
    } else if (currentCommunity != null) {
      return CommunityCircleIcon(
        currentCommunity,
        withBorder: isMobile,
        isTooltipShown: false,
      );
    } else {
      return _buildLogo(isMobile: isMobile);
    }
  }

  Widget _buildLogo({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.only(left: isMobile ? 1 : 8),
      child: SizedBox(
        height: 35,
        // TODO Rebranding: Replace text with logo images
        // child: CustomImage(null, asset: darkLogo ? kDarkLogo : kLightLogo),
        child: Row(
          children: [
            Text(
              Environment.appName,
              style: AppTextStyle.headline2.copyWith(
                color: darkLogo ? AppColor.black : AppColor.white,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFE5E0D6),
                borderRadius: BorderRadius.circular(64),
              ),
              child: Text(
                'BETA',
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColor.black,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityCircleIcon extends StatelessWidget {
  final bool withBorder;
  final Community community;
  final double imageHeight;
  final bool isTooltipShown;

  const CommunityCircleIcon(
    this.community, {
    this.withBorder = false,
    this.imageHeight = 40,
    this.isTooltipShown = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isTooltipShown) {
      return Tooltip(
        message: community.name ?? '',
        child: _buildChild(),
      );
    } else {
      return _buildChild();
    }
  }

  Widget _buildChild() {
    String? profileImageUrl = community.profileImageUrl;
    if (profileImageUrl == null || profileImageUrl.isEmpty) {
      profileImageUrl =
          generateRandomImageUrl(seed: community.id.hashCode, resolution: 160);
    }

    return Container(
      decoration: BoxDecoration(
        border: withBorder ? Border.all(color: AppColor.gray4, width: 1) : null,
        shape: BoxShape.circle,
        color: AppColor.gray3,
      ),
      child: ClipOval(
        child: ProxiedImage(
          profileImageUrl,
          height: imageHeight,
          width: imageHeight,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
