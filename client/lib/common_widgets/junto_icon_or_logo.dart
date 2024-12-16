import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';

/// This widget either shows the 'Frankly' icon or a logo of the selected community, if one is selected.
class CurrentJuntoIconOrLogo extends StatelessWidget {
  static const kLightLogo = AppAsset.kLogoHorizontalLightPng;
  static const kDarkLogo = AppAsset.kLogoHorizontalDarkPng;

  /// If true, this widget is a button that navigates either to Frankly's website or the community's landing page
  final bool withNav;
  final bool darkLogo;
  final Junto? junto;

  const CurrentJuntoIconOrLogo({
    this.withNav = true,
    this.junto,
    this.darkLogo = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentJunto = Provider.of<NavBarProvider>(context).currentJunto ?? junto;
    final showOrganizationIcon = routerDelegate.currentBeamLocation is! HomeLocation;
    final isMobile = responsiveLayoutService.isMobile(context);

    if (currentJunto != null && withNav && showOrganizationIcon) {
      return JuntoInkWell(
        boxShape: BoxShape.circle,
        onTap: () => routerDelegate.beamTo(
          JuntoPageRoutes(
            juntoDisplayId: currentJunto.displayId,
          ).juntoHome,
        ),
        child: JuntoCircleIcon(
          currentJunto,
          withBorder: isMobile,
          isTooltipShown: false,
        ),
      );
    } else if (withNav) {
      return JuntoInkWell(
        onTap: () => routerDelegate.beamTo(HomeLocation()),
        child: _buildLogo(isMobile: isMobile),
      );
    } else if (currentJunto != null) {
      return JuntoCircleIcon(
        currentJunto,
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
        // child: JuntoImage(null, asset: darkLogo ? kDarkLogo : kLightLogo),
        child: Row(
          children: [
            Text(
              'Frankly',
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
            )
          ],
        ),
      ),
    );
  }
}

class JuntoCircleIcon extends StatelessWidget {
  final bool withBorder;
  final Junto junto;
  final double imageHeight;
  final bool isTooltipShown;

  const JuntoCircleIcon(
    this.junto, {
    this.withBorder = false,
    this.imageHeight = 40,
    this.isTooltipShown = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isTooltipShown) {
      return Tooltip(
        message: junto.name ?? '',
        child: _buildChild(),
      );
    } else {
      return _buildChild();
    }
  }

  Widget _buildChild() {
    String? profileImageUrl = junto.profileImageUrl;
    if (profileImageUrl == null || profileImageUrl.isEmpty) {
      profileImageUrl = generateRandomImageUrl(seed: junto.id.hashCode, resolution: 160);
    }

    return Container(
      decoration: BoxDecoration(
        border: withBorder ? Border.all(color: AppColor.gray4, width: 1) : null,
        shape: BoxShape.circle,
        color: AppColor.gray3,
      ),
      child: ClipOval(
        child: JuntoImage(
          profileImageUrl,
          height: imageHeight,
          width: imageHeight,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
