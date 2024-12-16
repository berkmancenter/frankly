import 'package:flutter/material.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_membership_button.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/junto.dart';

class LeaveRegularDialog extends StatefulWidget {
  final Junto? junto;
  final bool isMember;
  final void Function() onMinimizeCard;

  const LeaveRegularDialog({
    Key? key,
    required this.junto,
    required this.isMember,
    required this.onMinimizeCard,
  }) : super(key: key);

  @override
  State<LeaveRegularDialog> createState() => _LeaveRegularDialogState();
}

class _LeaveRegularDialogState extends State<LeaveRegularDialog> {
  @override
  Widget build(BuildContext context) {
    final bool isMobileScale = responsiveLayoutService.isMobile(context);
    String content;

    if (widget.isMember) {
      content =
          'That’s the end of your agenda. You can hang out and finish up for as long as you’d like.';
    } else {
      content =
          'That’s the end of your agenda. You can hang out and finish up for as long as you’d like. Follow ${widget.junto?.name} for more great events.';
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColor.white,
      ),
      child: isMobileScale ? _buildMobileLayout(content) : _buildDesktopLayout(content),
    );
  }

  Widget _buildDesktopLayout(String content) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          JuntoText(
                            "That's it!",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: responsiveLayoutService.getDynamicSize(
                                context,
                                18,
                                scale: 3 / 4,
                              ),
                              color: AppColor.darkBlue,
                            ),
                          ),
                          SizedBox(height: 18),
                          Flexible(
                            child: JuntoText(
                              content,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: responsiveLayoutService.getDynamicSize(
                                  context,
                                  14,
                                  scale: 3 / 4,
                                ),
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          if (!widget.isMember) _buildFollowButton(),
                        ],
                      ),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 3,
                      child: JuntoImage(
                        null,
                        asset: AppAsset('media/dialog-image.png'),
                        loadingColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: _buildMinimizeButton(),
        )
      ],
    );
  }

  Widget _buildMobileLayout(String content) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  JuntoText(
                    "That's it!",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  SizedBox(height: 14),
                  Flexible(
                    child: JuntoText(
                      content,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.isMember) ...[
              SizedBox(height: 16),
              _buildFollowButton(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    final junto = widget.junto;

    if (junto == null) {
      return SizedBox.shrink();
    }

    return JuntoMembershipButton(
      junto,
      text: 'Follow ${junto.name}',
      textColor: AppColor.darkBlue,
    );
  }

  Widget _buildMinimizeButton() {
    return ActionButton(
      type: ActionButtonType.flat,
      tooltipText: 'Hide Agenda Item',
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
      minWidth: 0,
      height: 0,
      onPressed: widget.onMinimizeCard,
      color: AppColor.white,
      padding: EdgeInsets.zero,
      child: JuntoImage(
        null,
        asset: AppAsset.kMinimizePng,
        loadingColor: Colors.transparent,
        height: 22,
        width: 22,
      ),
    );
  }
}
