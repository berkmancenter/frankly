import 'package:flutter/material.dart';
import 'package:client/core/widgets/action_button.dart';

class ThickOutlineButton extends StatelessWidget {
  final Function()? onPressed;
  final String? text;
  final Color? textColor;
  final Color? backgroundColor;
  final Widget? icon;
  final double? minWidth;
  final double borderWidth;
  final bool expand;
  final String? eventName;

  const ThickOutlineButton({
    Key? key,
    this.onPressed,
    this.text,
    this.textColor,
    this.backgroundColor,
    this.icon,
    this.expand = false,
    this.minWidth = 0,
    this.borderWidth = 1,
    this.eventName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lineColor = textColor ??
        DefaultTextStyle.of(context).style.color ??
        Theme.of(context).primaryColor;
    return ActionButton(
      onPressed: onPressed,
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
      type: ActionButtonType.outline,
      borderSide: BorderSide(
        color: lineColor,
        width: borderWidth,
      ),
      minWidth: minWidth,
      textColor: lineColor,
      expand: expand,
      eventName: eventName,
      icon: icon,
      text: text,
      color: backgroundColor,
    );
  }
}
