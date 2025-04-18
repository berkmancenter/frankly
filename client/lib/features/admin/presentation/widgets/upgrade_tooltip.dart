import 'dart:math';

import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/upgrade_icon.dart';
import 'package:client/config/environment.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';

/// This is wrapped around the widget which is anchored to the freemium 'Explore Plans' tooltip
class UpgradeTooltip extends StatelessWidget {
  final bool isTooltipVisible;
  final void Function() onCloseIconTap;
  final Widget child;
  final bool isBelowIcon;

  const UpgradeTooltip({
    Key? key,
    required this.isTooltipVisible,
    required this.onCloseIconTap,
    required this.child,
    this.isBelowIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TooltipAnchor(
      isTooltipVisible: isTooltipVisible,
      tooltip: _UpgradeTooltipContents(),
      onCloseIconTap: onCloseIconTap,
      child: child,
    );
  }
}

class _UpgradeTooltipContents extends StatefulWidget {
  const _UpgradeTooltipContents({Key? key}) : super(key: key);

  @override
  State<_UpgradeTooltipContents> createState() =>
      _UpgradeTooltipContentsState();
}

class _UpgradeTooltipContentsState extends State<_UpgradeTooltipContents> {
  bool _launching = false;

  void _launchBilling() {
    setState(() => _launching = true);
    launch(Environment.pricingUrl, targetIsSelf: true);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 292,
      child: Column(
        children: [
          Row(
            children: [
              UpgradeIcon(),
              SizedBox(width: 8),
              HeightConstrainedText(
                'Upgrade for access',
                style: AppTextStyle.headline4
                    .copyWith(color: context.theme.colorScheme.primary),
              ),
            ],
          ),
          SizedBox(height: 30),
          _launching
              ? CircularProgressIndicator()
              : Align(
                  alignment: Alignment.centerLeft,
                  child: ActionButton(
                    type: ActionButtonType.outline,
                    text: 'Explore Plans',
                    borderSide:
                        BorderSide(color: context.theme.colorScheme.primary),
                    textColor: context.theme.colorScheme.primary,
                    onPressed: _launchBilling,
                  ),
                ),
        ],
      ),
    );
  }
}

/// This widget uses the Portal package to superimpose and focus a tooltip over the viewport. When
/// visible, the background is faded and the tooltip must be dismissed to interact with the page again
class TooltipAnchor extends StatefulWidget {
  final Widget child;
  final Widget tooltip;
  final bool isTooltipVisible;
  final void Function() onCloseIconTap;
  final bool isBelowIcon;

  const TooltipAnchor({
    required this.child,
    required this.tooltip,
    required this.isTooltipVisible,
    required this.onCloseIconTap,
    this.isBelowIcon = false,
    Key? key,
  }) : super(key: key);

  @override
  _TooltipAnchorState createState() => _TooltipAnchorState();
}

class _TooltipAnchorState extends State<TooltipAnchor> {
  final GlobalKey _positionKey = GlobalKey();
  double _offset = 0;

  @override
  void initState() {
    _calculateOffset();
    super.initState();
  }

  void _calculateOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final renderBox =
          _positionKey.currentContext?.findRenderObject() as RenderBox;
      final toolTipCenter =
          renderBox.localToGlobal(renderBox.paintBounds.center);
      setState(
        () => _offset = ((screenWidth - toolTipCenter.dx) - 156).clamp(-126, 0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: widget.isTooltipVisible,
      portalFollower: Container(
        color: Colors.black.withOpacity(.3),
        child: GestureDetector(
          onTap: widget.onCloseIconTap,
        ),
      ),
      child: PortalTarget(
        key: _positionKey,
        visible: widget.isTooltipVisible,
        portalFollower: _TooltipContainer(
          dialogOffset: _offset,
          isBelowIcon: widget.isBelowIcon,
          onClose: widget.onCloseIconTap,
          child: widget.tooltip,
        ),
        anchor: widget.isBelowIcon
            ? Aligned(
                target: Alignment.bottomCenter,
                follower: Alignment.topCenter,
              )
            : Aligned(
                target: Alignment.topCenter,
                follower: Alignment.bottomCenter,
              ),
        child: widget.child,
      ),
    );
  }
}

class _TooltipContainer extends StatefulWidget {
  final void Function() onClose;
  final bool isBelowIcon;
  final double dialogOffset;
  final Widget child;

  const _TooltipContainer({
    required this.onClose,
    required this.child,
    this.isBelowIcon = true,
    this.dialogOffset = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<_TooltipContainer> createState() => _TooltipContainerState();
}

class _TooltipContainerState extends State<_TooltipContainer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          verticalDirection: widget.isBelowIcon
              ? VerticalDirection.up
              : VerticalDirection.down,
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicWidth(
              child: Container(
                transform: Matrix4.translationValues(widget.dialogOffset, 0, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  boxShadow: const [AppDecoration.lightBoxShadow],
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: widget.child,
              ),
            ),
            Container(
              width: 18,
              height: 18,
              color: AppColor.white,
              transform: Matrix4.identity()
                ..translate(0, 10 * (widget.isBelowIcon ? 1 : -1))
                ..rotateZ(pi / 4),
              transformAlignment: Alignment.center,
            ),
          ],
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: Icon(Icons.close),
            onPressed: widget.onClose,
            color: context.theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
