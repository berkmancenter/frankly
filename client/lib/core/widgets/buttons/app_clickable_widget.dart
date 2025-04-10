import 'package:flutter/material.dart';

/// Widget that is clickable.
///
/// It conveniently exposes hover and splash via [InkWell] while making the [child] look
/// neat while clicking is being executed.
class AppClickableWidget extends StatelessWidget {
  final Widget child;
  final void Function() onTap;
  final String? tooltipMessage;

  /// Describes if [child] is an icon. If it is - circular shape will be applied. Otherwise -
  /// rectangular shape will be applied.
  final bool isIcon;

  const AppClickableWidget({
    Key? key,
    required this.child,
    required this.onTap,
    this.tooltipMessage,
    this.isIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localTooltipMessage = tooltipMessage;

    if (localTooltipMessage != null) {
      return Tooltip(
        message: localTooltipMessage,
        child: _buildChild(),
      );
    } else {
      return _buildChild();
    }
  }

  Widget _buildChild() {
    final shapeBorder = isIcon
        ? CircleBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

    return Material(
      shape: shapeBorder,
      color: Colors.transparent,
      child: InkWell(
        customBorder: shapeBorder,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }
}
