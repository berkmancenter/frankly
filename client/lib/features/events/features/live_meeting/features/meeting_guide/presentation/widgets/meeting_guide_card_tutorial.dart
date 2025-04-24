import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/widgets/raising_hand.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

class MeetingGuideTutorial extends StatefulWidget {
  @override
  State<MeetingGuideTutorial> createState() => _MeetingGuideTutorialState();
}

class _MeetingGuideTutorialState extends State<MeetingGuideTutorial> {
  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);
    final kDialogWidth = isMobile ? 300.0 : 950.0;
    final kDialogHeight = isMobile ? 540.0 : 540.0;
    // Arrow and text takes extra additional space in the page. These measurements are the threshold
    // where text and arrow doesn't overflow/clip. After threshold is reached - this section is hidden.
    final bool canShowTutorialTextArrowSectionOutside =
        !isMobile && MediaQuery.of(context).size.height >= 560;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: kDialogWidth,
        maxHeight: kDialogHeight,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: isMobile
                ? EdgeInsets.zero
                : EdgeInsets.symmetric(vertical: 100, horizontal: 125),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: isMobile
                  ? Column(
                      children: [
                        Expanded(flex: 5, child: _buildMainCard()),
                        Expanded(flex: 3, child: _buildSupportCard()),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(flex: 5, child: _buildMainCard()),
                        Expanded(flex: 2, child: _buildSupportCard()),
                      ],
                    ),
            ),
          ),
          if (canShowTutorialTextArrowSectionOutside)
            _buildTutorialHelperOutside(),
        ],
      ),
    );
  }

  Widget _buildTutorialHelperOutside() {
    return Positioned(
      bottom: 6,
      right: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProxiedImage(
            null,
            asset: AppAsset('media/tutorial-arrow-bottom-up-left.png'),
            height: 70,
          ),
          Text(
            'Click here when\nyou’re ready to\nget started',
            style: GoogleFonts.fingerPaint(
              fontSize: _getDynamicSize(18),
              fontWeight: FontWeight.normal,
              color: AppColor.brightGreen,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _getDynamicSize(double originalValue, {double scale = 2 / 3}) {
    final value = responsiveLayoutService.isMobile(context)
        ? originalValue * scale
        : originalValue;

    return value.roundToDouble();
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      color: AppColor.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeightConstrainedText(
                'Agenda Item 1 of 10',
                style: TextStyle(
                  fontSize: _getDynamicSize(24),
                  fontWeight: FontWeight.w700,
                  color: AppColor.darkBlue,
                ),
              ),
              IgnorePointer(
                ignoring: true,
                child: RaisingHandToggle(
                  isHandRaised: false,
                  isCardMinimized: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          DottedBorder(
            padding: EdgeInsets.symmetric(
              vertical: _getDynamicSize(40),
              horizontal: _getDynamicSize(32),
            ),
            color: AppColor.darkBlue,
            strokeWidth: 1,
            dashPattern: const [8, 4],
            child: Column(
              children: [
                HeightConstrainedText(
                  'This is your agenda.',
                  style: TextStyle(
                    fontSize: _getDynamicSize(24),
                    fontWeight: FontWeight.w700,
                    color: AppColor.darkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                HeightConstrainedText(
                  '''Prompts will appear here. Once most people have clicked “Next”, we’ll move on to the next agenda item.''',
                  style: TextStyle(
                    fontSize: _getDynamicSize(16),
                    fontWeight: FontWeight.normal,
                    color: AppColor.darkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(double emptyProfileSize) {
    return ProxiedImage(
      null,
      asset: AppAsset('media/profile-empty.png'),
      width: emptyProfileSize,
      height: emptyProfileSize,
    );
  }

  Widget _buildSupportCard() {
    const kEmptyProfileSize = 32.0;

    return Container(
      color: AppColor.gray6,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: kEmptyProfileSize * 1.25),
                  child: _buildProfileImage(kEmptyProfileSize),
                ),
              ),
              Align(child: _buildProfileImage(kEmptyProfileSize)),
              Align(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: kEmptyProfileSize * 1.25),
                  child: _buildProfileImage(kEmptyProfileSize),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          HeightConstrainedText(
            'Ready to move on?',
            style: TextStyle(
              fontSize: _getDynamicSize(18),
              fontWeight: FontWeight.w700,
              color: AppColor.darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          HeightConstrainedText(
            '2 of 3 are ready',
            style: TextStyle(
              fontSize: _getDynamicSize(16),
              fontWeight: FontWeight.w400,
              color: AppColor.darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          Spacer(),
          Row(
            mainAxisAlignment: responsiveLayoutService.isMobile(context)
                ? MainAxisAlignment.center
                : MainAxisAlignment.end,
            children: [
              ActionButton(
                color: AppColor.darkBlue,
                textColor: AppColor.brightGreen,
                sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                text: 'Next',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
