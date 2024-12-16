import 'package:flutter/material.dart';
import 'package:client/common_widgets/action_button.dart';
import 'package:client/styles/app_styles.dart';

class ThickOutlineButton extends StatelessWidget {
  final Function()? onPressed;
  final String? text;
  final Color? textColor;
  final Widget? icon;
  final double? minWidth;
  final double thickness;
  final bool whiteBackground;
  final bool expand;
  final String? eventName;

  const ThickOutlineButton({
    Key? key,
    this.onPressed,
    this.text,
    this.textColor,
    this.icon,
    this.expand = false,
    this.minWidth = 0,
    this.thickness = 1,
    this.whiteBackground = true,
    this.eventName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = textColor ??
        DefaultTextStyle.of(context).style.color ??
        (whiteBackground ? Theme.of(context).primaryColor : AppColor.white);
    return ActionButton(
      onPressed: onPressed,
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
      type: ActionButtonType.outline,
      borderSide: BorderSide(
        color: color,
        width: thickness,
      ),
      minWidth: minWidth,
      textColor: color,
      expand: expand,
      eventName: eventName,
      icon: icon,
      text: text,
    );
  }
}
